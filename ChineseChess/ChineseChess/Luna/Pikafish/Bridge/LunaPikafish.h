// SPDX-License-Identifier: GPL-3.0-or-later
#ifndef LUNA_PIKAFISH_H
#define LUNA_PIKAFISH_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct LPFEngine LPFEngine;

/* Called on the thread running lpf_search, never on an engine worker thread. */
typedef int (*LPFShouldStop)(void *context);
typedef void (*LPFProgress)(float progress, uint16_t move, void *context);

/*
 * model_path is the bundled, compatible Pikafish NNUE file, not a directory.
 * Returns NULL on an error and writes a terminated message to error, if supplied.
 * One search may run on an instance at a time. Different instances are independent.
 */
LPFEngine *lpf_engine_create(const char *model_path, char *error, size_t error_capacity);

/* Stop and join the search before releasing an instance. Do not call from a callback. */
void lpf_engine_destroy(LPFEngine *engine);

/* Thread-safe cancellation of the active search. A cancelled search returns zero. */
void lpf_engine_stop(LPFEngine *engine);

/*
 * board_fen contains only the 10 ranks of piece placement. Luna's trailing slash
 * is accepted. black must be 0 (red) or 1 (black). No game history is supplied;
 * this enumerates board legality only, leaving history adjudication to the app.
 *
 * Each result uses Luna's 16-bit move format: (mailbox_from << 8) | mailbox_to.
 * Mailbox files are 3...11 and ranks are 3...12, with red at rank 12.
 * Returns the total count, copying at most capacity entries. out=NULL with
 * capacity=0 queries the count. On invalid input returns zero with an error.
 * Legal enumeration needs no engine instance or NNUE model.
 */
size_t lpf_legal_moves(const char *board_fen,
                      int black,
                      uint16_t *out,
                      size_t capacity,
                      char *error,
                      size_t error_capacity);

/*
 * Synchronous search; run on an application background queue. depth is 1...245;
 * movetime_ms=0 searches by depth without a time limit; a positive value adds
 * an optional thinking budget. Cancellation is available in either mode.
 * banned contains the app's existing root bans; it does not change history rules.
 * Progress callbacks contain a fraction less than 1 and move=0. The caller emits
 * its completion callback after this function returns a nonzero move.
 * Returns zero for cancellation, no permitted move, or an error (see error text).
 * Callbacks and their context must remain valid until the function returns.
 */
uint16_t lpf_search(LPFEngine *engine,
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
                    size_t error_capacity);

#ifdef __cplusplus
}
#endif

#endif
