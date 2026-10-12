// SPDX-License-Identifier: GPL-3.0-or-later
#include "LunaPikafish.h"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstring>
#include <exception>
#include <filesystem>
#include <fstream>
#include <memory>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <thread>
#include <vector>

#include "../Vendor/src/attacks.h"
#include "../Vendor/src/engine.h"
#include "../Vendor/src/movegen.h"
#include "../Vendor/src/position.h"
#include "../Vendor/src/search.h"
#include "../Vendor/src/types.h"

namespace {

void write_error(char *error, size_t capacity, const char *message) noexcept {
    if (!error || !capacity)
        return;
    const size_t length = std::min(std::strlen(message), capacity - 1);
    std::memcpy(error, message, length);
    error[length] = '\0';
}

void initialize() {
    static std::once_flag once;
    std::call_once(once, [] {
        Stockfish::Attacks::init();
        Stockfish::Position::init();
    });
}

std::string position_fen(const char *board_fen, int black) {
    if (!board_fen || (black != 0 && black != 1))
        throw std::invalid_argument("A board FEN and a side of 0 or 1 are required.");

    // A valid 9x10 piece placement cannot exceed 99 characters. Bound the read
    // before constructing a string, and reject full FENs or extra fields.
    size_t length = 0;
    while (length <= 100 && board_fen[length])
        ++length;
    if (!length || length > 100)
        throw std::invalid_argument("Invalid board FEN length.");

    std::string board(board_fen, length);
    if (board.back() == '/')
        board.pop_back(); // LunaFENCoder appends a slash after its tenth rank.

    int ranks = 1;
    int files = 0;
    for (char piece : board)
    {
        if (piece == '/')
        {
            if (files != 9 || ++ranks > 10)
                throw std::invalid_argument("Board FEN must have ten ranks of nine files.");
            files = 0;
        }
        else if (piece >= '1' && piece <= '9')
            files += piece - '0';
        else if (std::string_view("RNBAKCPrnbakcp").find(piece) != std::string_view::npos)
            ++files;
        else
            throw std::invalid_argument("Unsupported character in board FEN.");

        if (files > 9)
            throw std::invalid_argument("Board FEN rank exceeds nine files.");
    }
    if (ranks != 10 || files != 9)
        throw std::invalid_argument("Board FEN must have ten ranks of nine files.");

    // History counters start at zero deliberately; Luna remains the game referee.
    return board + (black ? " b - - 0 1" : " w - - 0 1");
}

uint8_t mailbox(Stockfish::Square square) noexcept {
    return uint8_t(((12 - int(Stockfish::rank_of(square))) << 4)
                   | (int(Stockfish::file_of(square)) + 3));
}

uint16_t luna_move(Stockfish::Move move) noexcept {
    return uint16_t((uint16_t(mailbox(move.from_sq())) << 8) | mailbox(move.to_sq()));
}

bool valid_mailbox(uint8_t location) noexcept {
    const int row = location >> 4;
    const int column = location & 15;
    return row >= 3 && row <= 12 && column >= 3 && column <= 11;
}

bool valid_luna_move(uint16_t move) noexcept {
    const uint8_t from = uint8_t(move >> 8);
    const uint8_t to = uint8_t(move);
    return from != to && valid_mailbox(from) && valid_mailbox(to);
}

std::string uci_move(Stockfish::Move move) {
    return {char('a' + Stockfish::file_of(move.from_sq())),
            char('0' + Stockfish::rank_of(move.from_sq())),
            char('a' + Stockfish::file_of(move.to_sq())),
            char('0' + Stockfish::rank_of(move.to_sq()))};
}

uint16_t luna_move_from_uci(std::string_view move) noexcept {
    if (move.size() != 4 || move[0] < 'a' || move[0] > 'i' || move[2] < 'a'
        || move[2] > 'i' || move[1] < '0' || move[1] > '9' || move[3] < '0'
        || move[3] > '9')
        return 0;

    const uint8_t from = uint8_t(((12 - (move[1] - '0')) << 4) | (move[0] - 'a' + 3));
    const uint8_t to = uint8_t(((12 - (move[3] - '0')) << 4) | (move[2] - 'a' + 3));
    const uint16_t result = uint16_t((uint16_t(from) << 8) | to);
    return valid_luna_move(result) ? result : 0;
}

void set_option(Stockfish::Engine& engine, const char *name, const std::string& value) {
    std::istringstream command("name " + std::string(name) + " value " + value);
    engine.get_options().setoption(command);
}

void update_depth(std::atomic<int>& target, int value) noexcept {
    int previous = target.load(std::memory_order_relaxed);
    while (previous < value
           && !target.compare_exchange_weak(previous, value, std::memory_order_relaxed))
    {}
}

} // namespace

struct LPFEngine {
    // Declare the engine last so worker threads are joined before their callback
    // state and mutex are destroyed, including during failed model validation.
    std::mutex search_mutex;
    std::atomic<bool> stop_requested{false};
    std::atomic<bool> completed{false};
    std::atomic<uint16_t> best_move{0};
    std::atomic<int> completed_depth{0};
    std::unique_ptr<Stockfish::Engine> engine;
};

namespace {

// A caller callback may throw (e.g. Objective-C++ code). Always stop and join
// before unwinding, so a cancelled task cannot leave workers using old state.
class SearchJoin {
public:
    explicit SearchJoin(Stockfish::Engine& engine) : engine_(engine) {}
    ~SearchJoin() {
        engine_.stop();
        engine_.wait_for_search_finished();
    }
private:
    Stockfish::Engine& engine_;
};

} // namespace

extern "C" LPFEngine *lpf_engine_create(const char *model_path,
                                         char *error,
                                         size_t error_capacity) {
    write_error(error, error_capacity, "");
    try
    {
        if (!model_path || !*model_path)
            throw std::invalid_argument("Pikafish NNUE model path is missing.");
        const auto model = std::filesystem::absolute(std::filesystem::u8path(model_path));
        if (!std::filesystem::is_regular_file(model))
            throw std::invalid_argument("Pikafish NNUE model file does not exist.");

        std::ifstream file(model, std::ios::binary);
        char header[4] = {};
        file.read(header, sizeof(header));
        // This pinned Pikafish revision loads Zstandard-compressed networks.
        if (file.gcount() != 4 || uint8_t(header[0]) != 0x28 || uint8_t(header[1]) != 0xB5
            || uint8_t(header[2]) != 0x2F || uint8_t(header[3]) != 0xFD)
            throw std::invalid_argument("Pikafish NNUE model is not a supported compressed network.");

        initialize();
        auto result = std::make_unique<LPFEngine>();
        // Pass a synthetic binary pathname in the model directory; never change
        // the process-wide working directory to load an application resource.
        result->engine = std::make_unique<Stockfish::Engine>(model.parent_path() / "pikafish");
        auto& engine = *result->engine;
        engine.get_options().add_info_listener([](const auto&) {});
        engine.set_on_verify_network([](std::string_view message) {
            // Upstream reports an incompatible network before calling exit().
            // Throw on the calling thread here to preserve the host process.
            if (message.substr(0, 6) == "ERROR:")
                throw std::runtime_error("Pikafish NNUE model is corrupt or incompatible with the engine.");
        });

        LPFEngine *state = result.get();
        engine.set_on_update_no_moves([state](const auto& info) {
            update_depth(state->completed_depth, info.depth);
        });
        engine.set_on_update_full([state](const auto& info) {
            update_depth(state->completed_depth, info.depth);
        });
        engine.set_on_iter([](const auto&) {});
        engine.set_on_start([] {});
        engine.set_on_bestmove([state](std::string_view move, std::string_view) {
            state->best_move.store(luna_move_from_uci(move), std::memory_order_relaxed);
            state->completed.store(true, std::memory_order_release);
        });

        set_option(engine, "NumaPolicy", "none");
        set_option(engine, "Threads", "1");
        set_option(engine, "Hash", "16");
        // The constructor already loads pikafish.nnue from its binary directory
        // if there is no same-named model in the process working directory. Use
        // that verified resource directly instead of loading a 64 MiB network
        // again just because its relative name differs from an absolute path.
        const std::filesystem::path default_model("pikafish.nnue");
        const bool default_is_requested = model.filename() == default_model
            && (!std::filesystem::exists(default_model)
                || std::filesystem::equivalent(default_model, model));
        if (!default_is_requested)
            set_option(engine, "EvalFile", model.string());
        engine.verify_network(); // Verify compatibility before returning an instance.
        return result.release();
    }
    catch (const std::exception& exception)
    {
        write_error(error, error_capacity, exception.what());
    }
    catch (...)
    {
        write_error(error, error_capacity, "Unexpected Pikafish initialization failure.");
    }
    return nullptr;
}

extern "C" void lpf_engine_stop(LPFEngine *engine) {
    if (engine)
        engine->stop_requested.store(true, std::memory_order_release);
}

extern "C" void lpf_engine_destroy(LPFEngine *engine) {
    if (!engine)
        return;
    lpf_engine_stop(engine);
    // Existing users must not begin a new operation during destruction.
    {
        std::lock_guard<std::mutex> lock(engine->search_mutex);
        engine->engine->stop();
        engine->engine->wait_for_search_finished();
    }
    delete engine;
}

extern "C" size_t lpf_legal_moves(const char *board_fen,
                                  int black,
                                  uint16_t *out,
                                  size_t capacity,
                                  char *error,
                                  size_t error_capacity) {
    write_error(error, error_capacity, "");
    try
    {
        if (!out && capacity)
            throw std::invalid_argument("Legal-move output buffer is missing.");
        const std::string fen = position_fen(board_fen, black);
        initialize();
        Stockfish::Position position;
        Stockfish::StateInfo state;
        if (auto failure = position.set(fen, &state))
            throw *failure;
        const Stockfish::MoveList<Stockfish::LEGAL> moves(position);
        const size_t copied = std::min(capacity, size_t(moves.size()));
        for (size_t i = 0; i < copied; ++i)
            out[i] = luna_move(moves.begin()[i]);
        return moves.size();
    }
    catch (const std::exception& exception)
    {
        write_error(error, error_capacity, exception.what());
    }
    catch (...)
    {
        write_error(error, error_capacity, "Unexpected Pikafish legal-move failure.");
    }
    return 0;
}

extern "C" uint16_t lpf_search(LPFEngine *state,
                               const char *board_fen,
                               int black,
                               int depth,
                               int movetime_ms,
                               const uint16_t *banned,
                               size_t banned_count,
                               LPFShouldStop should_stop,
                               LPFProgress progress,
                               void *context,
                               char *error,
                               size_t error_capacity) {
    write_error(error, error_capacity, "");
    try
    {
        if (!state)
            throw std::invalid_argument("Pikafish engine is missing.");
        std::unique_lock<std::mutex> lock(state->search_mutex, std::try_to_lock);
        if (!lock.owns_lock())
            throw std::invalid_argument("This Pikafish instance is already searching.");
        state->stop_requested.store(false, std::memory_order_release);
        state->completed.store(false, std::memory_order_release);
        state->best_move.store(0, std::memory_order_relaxed);
        state->completed_depth.store(0, std::memory_order_relaxed);
        if (depth < 1 || depth >= Stockfish::MAX_PLY || movetime_ms < 1)
            throw std::invalid_argument("Search needs depth 1...245 and a positive time budget.");
        if ((!banned && banned_count) || banned_count > 65536)
            throw std::invalid_argument("Invalid banned-move buffer.");
        for (size_t i = 0; i < banned_count; ++i)
            if (!valid_luna_move(banned[i]))
                throw std::invalid_argument("Banned move has invalid Luna mailbox coordinates.");

        const std::string fen = position_fen(board_fen, black);
        Stockfish::Position position;
        Stockfish::StateInfo position_state;
        if (auto failure = position.set(fen, &position_state))
            throw *failure;
        const Stockfish::MoveList<Stockfish::LEGAL> moves(position);
        std::vector<uint16_t> permitted;
        Stockfish::Search::LimitsType limits;
        limits.depth = depth;
        limits.movetime = movetime_ms;
        for (Stockfish::Move move : moves)
        {
            const uint16_t encoded = luna_move(move);
            bool is_banned = false;
            for (size_t i = 0; i < banned_count; ++i)
                if (banned[i] == encoded)
                {
                    is_banned = true;
                    break;
                }
            if (!is_banned)
            {
                permitted.push_back(encoded);
                limits.searchmoves.push_back(uci_move(move));
            }
        }
        if (permitted.empty())
            return 0; // An empty searchmoves list would otherwise search every move.

        if (state->stop_requested.load(std::memory_order_acquire)
            || (should_stop && should_stop(context)))
            return 0;

        auto& engine = *state->engine;
        if (auto failure = engine.set_position(fen, {}))
            throw *failure;

        using Clock = std::chrono::steady_clock;
        const auto started = Clock::now();
        const auto deadline = started + std::chrono::milliseconds(movetime_ms);
        auto next_progress = started;
        float previous_progress = 0;
        bool cancelled = false;
        limits.startTime = Stockfish::now();
        engine.go(limits);
        SearchJoin join(engine);
        while (!state->completed.load(std::memory_order_acquire))
        {
            if (state->stop_requested.load(std::memory_order_acquire)
                || (should_stop && should_stop(context)))
            {
                cancelled = true;
                engine.stop();
            }
            const auto current = Clock::now();
            if (current >= deadline)
                engine.stop(); // Budget expiry preserves the best completed iteration.
            if (progress && !cancelled && current >= next_progress)
            {
                const float elapsed = std::chrono::duration<float, std::milli>(current - started).count();
                const float by_time = elapsed / float(movetime_ms);
                const float by_depth = float(state->completed_depth.load(std::memory_order_relaxed))
                                       / float(depth);
                previous_progress = std::min(0.99f, std::max(previous_progress, std::max(by_time, by_depth)));
                progress(previous_progress, 0, context);
                next_progress = current + std::chrono::milliseconds(25);
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(5));
        }
        engine.wait_for_search_finished();
        if (cancelled || state->stop_requested.load(std::memory_order_acquire)
            || (should_stop && should_stop(context)))
            return 0;

        const uint16_t best = state->best_move.load(std::memory_order_relaxed);
        if (std::find(permitted.begin(), permitted.end(), best) == permitted.end())
            throw std::runtime_error("Pikafish returned a move outside the permitted legal moves.");
        return best;
    }
    catch (const std::exception& exception)
    {
        write_error(error, error_capacity, exception.what());
    }
    catch (...)
    {
        write_error(error, error_capacity, "Unexpected Pikafish search failure.");
    }
    return 0;
}
