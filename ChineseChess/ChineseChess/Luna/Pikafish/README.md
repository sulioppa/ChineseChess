# Pikafish integration

The app uses the pinned Pikafish C++ engine in-process for AI moves and the
public `Luna.legalMovesWithLocation:` interface. It does not spawn a UCI process.
The existing Luna history referee, root bans, editing validation, record format,
and internal game-adjudication helpers remain in place.

## iOS

Open `ChineseChess/ChineseChess.xcworkspace` from the repository root. The Luna
framework builds the engine and Objective-C++ bridge and bundles
`Resources/pikafish.nnue`. The minimum deployment target is iOS 13 because the
engine uses C++17 `std::filesystem`. Use Xcode with C++17 support.

The existing Swift-facing `Luna` API is retained. `Luna+NextStep.mm` initializes
one engine lazily on the background search queue. `UserPreference.Level`
retains its existing raw values as stable IDs for saved preferences; its
separate `searchDepth` property maps difficulty labels to the new search
depths. The bridge clamps depth to 4–20 with no thinking-time limit. Each depth
unit is one side's move (a ply). Search time depends on the position and device,
and higher depths may take longer on a phone. The app can still cancel or
supersede a request. The bridge forwards progress with move zero and publishes
only the final move. At the C interface,
`movetime_ms = 0` disables the optional time limit; positive values set one.

The existing difficulty labels in `UserPreference.Level` use these initial
depth settings:

| Depth | App label |
| --- | --- |
| 4 | 小白 |
| 6 | 菜鸟 |
| 8 | 新手 |
| 10 | 入门 |
| 12 | 初级 |
| 14 | 中级 |
| 16 | 高级 |
| 18 | 大师 |
| 20 | 特级大师 |

These are retained UI labels, not calibrated Pikafish ratings. A hint requested
for a human player uses the configured `game.prompt` level and its corresponding
search depth.

The legal-move interface uses a separate lightweight Position and needs no
neural network or AI search. Moves are converted to the existing 256-square
mailbox representation and 16-bit `(from << 8) | to` format. Luna's board-only
FEN, including its trailing slash, is accepted. Only the current side's
interactive moves are exposed; legacy referee helpers continue using Luna.

Game outcome rules have not been migrated to Pikafish. In particular, the
app's historical long-check/chase and 50-round adjudication continue to run as
before. Existing root bans are passed into the engine's allowed search moves.
Pikafish retains its own internal search rules, with no previous game history
supplied to that search. The old opening-book shortcut is no longer used for AI
selection, so every AI answer comes from Pikafish; record/book utilities remain.

This change is compiled and checked on Linux at the portable C++ boundary.
The Objective-C++/Swift framework and app require a subsequent Mac/Xcode build.
On Mac, check model-resource lookup, highlighted destinations, AI completion,
stop/restart, undo/new-game callbacks, and normal multiplayer/record operation.

## Portable build

With CMake >= 3.20, GCC >= 9.3 or Clang >= 11, and a C++17 library:

```sh
cmake -S ChineseChess/ChineseChess/Luna/Pikafish -B /tmp/luna-pikafish-build \
  -DCMAKE_BUILD_TYPE=Release
cmake --build /tmp/luna-pikafish-build -j2
ctest --test-dir /tmp/luna-pikafish-build --output-on-failure
```

The static library is `libluna_pikafish.a`; its public C interface is
`Bridge/LunaPikafish.h`. The small integration check exercises move enumeration,
both sides' coordinate conversion, AI results, existing root bans, cancellation,
and reuse. It is not an engine-strength benchmark. Build outputs stay outside
the checkout. The bundled model is used without network downloads.

## Source and model

See [UPSTREAM.md](UPSTREAM.md) for the pinned source and model checksums.
Engine code is GPLv3-or-later. The bundled NNUE model has a separate license in
`Resources/NNUE-LICENSE.md`, which requires permission for commercial use.
The selected use is personal or open-source research. Preserve the engine,
third-party and model license notices when distributing the integration.
