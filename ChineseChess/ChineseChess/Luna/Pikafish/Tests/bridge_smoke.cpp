// SPDX-License-Identifier: GPL-3.0-or-later
#include "LunaPikafish.h"

#include <algorithm>
#include <array>
#include <chrono>
#include <cstdint>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

namespace {
constexpr const char* InitialBoard =
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR/";

void require(bool condition, const char* message) {
    if (!condition)
        throw std::runtime_error(message);
}

std::vector<uint16_t> legal_moves(int black) {
    char error[256];
    const auto count = lpf_legal_moves(InitialBoard, black, nullptr, 0, error, sizeof(error));
    require(error[0] == '\0' && count == 44, "Initial legal move query should return 44 moves.");
    std::vector<uint16_t> result(count);
    require(lpf_legal_moves(InitialBoard, black, result.data(), result.size(), error, sizeof(error)) == count,
            "Legal-move copy returned a different count.");
    require(error[0] == '\0', "Legal-move copy failed.");
    return result;
}

struct Cancellation {
    std::chrono::steady_clock::time_point deadline;
    int progress_calls = 0;
};

int stop_after_deadline(void* opaque) {
    return std::chrono::steady_clock::now() >= static_cast<Cancellation*>(opaque)->deadline;
}

void on_progress(float progress, uint16_t move, void* opaque) {
    require(progress >= 0 && progress < 1 && move == 0,
            "Progress must not dispatch an intermediate move to the app.");
    ++static_cast<Cancellation*>(opaque)->progress_calls;
}
}

int main(int argc, char** argv) {
    try {
        require(argc == 2, "Pass the matching NNUE model pathname.");
        const auto red = legal_moves(0);
        const auto black = legal_moves(1);
        // Red rook a0-a1 and black rook a9-a8 in Luna's mailbox encoding.
        require(std::find(red.begin(), red.end(), uint16_t(0xC3B3)) != red.end(),
                "Red move coordinates were not bridged correctly.");
        require(std::find(black.begin(), black.end(), uint16_t(0x3343)) != black.end(),
                "Black move coordinates were not bridged correctly.");

        char error[256];
        std::array<uint16_t, 1> short_buffer{};
        require(lpf_legal_moves(InitialBoard, 0, short_buffer.data(), 1, error, sizeof(error)) == 44,
                "A small buffer must report the required capacity.");
        require(lpf_legal_moves("invalid", 0, nullptr, 0, error, sizeof(error)) == 0 && error[0],
                "Malformed FEN must return a recoverable error.");
        require(lpf_engine_create("/missing/luna/pikafish.nnue", error, sizeof(error)) == nullptr && error[0],
                "A missing model must not terminate the host process.");

        std::unique_ptr<LPFEngine, decltype(&lpf_engine_destroy)> engine(
            lpf_engine_create(argv[1], error, sizeof(error)), lpf_engine_destroy);
        require(engine != nullptr, error);
        const auto move = lpf_search(engine.get(), InitialBoard, 0, 4, 0,
                                     nullptr, 0, nullptr, nullptr, nullptr, error, sizeof(error));
        require(error[0] == '\0' && std::find(red.begin(), red.end(), move) != red.end(),
                "Depth-only AI must return a legal move in Luna coordinates.");
        require(lpf_search(engine.get(), InitialBoard, 0, 4, -1,
                           nullptr, 0, nullptr, nullptr, nullptr, error, sizeof(error)) == 0 && error[0],
                "Negative thinking budgets must return a recoverable error.");

        // Keep the app's root-ban semantics: only this one move remains allowed.
        auto banned = red;
        banned.erase(std::find(banned.begin(), banned.end(), move));
        require(lpf_search(engine.get(), InitialBoard, 0, 4, 100, banned.data(), banned.size(),
                           nullptr, nullptr, nullptr, error, sizeof(error)) == move && !error[0],
                "Root bans were not honored.");
        require(lpf_search(engine.get(), InitialBoard, 0, 4, 100, red.data(), red.size(),
                           nullptr, nullptr, nullptr, error, sizeof(error)) == 0 && !error[0],
                "All banned moves must yield no move.");

        Cancellation cancellation{std::chrono::steady_clock::now() + std::chrono::milliseconds(30)};
        require(lpf_search(engine.get(), InitialBoard, 1, 100, 0, nullptr, 0,
                           stop_after_deadline, on_progress, &cancellation, error, sizeof(error)) == 0,
                "Cancelled depth-only search must not return an actionable move.");
        require(error[0] == '\0' && cancellation.progress_calls > 0,
                "Cancellation/progress callbacks failed.");
        const auto retry = lpf_search(engine.get(), InitialBoard, 1, 4, 0,
                                     nullptr, 0, nullptr, nullptr, nullptr, error, sizeof(error));
        require(!error[0] && std::find(black.begin(), black.end(), retry) != black.end(),
                "Engine must remain usable after cancellation.");
        std::cout << "PASS: legal moves, Luna coordinates, AI, root bans, cancellation and reuse.\n";
        return 0;
    } catch (const std::exception& exception) {
        std::cerr << "FAIL: " << exception.what() << '\n';
        return 1;
    }
}
