# Pinned upstream

- Engine: https://github.com/official-pikafish/Pikafish
- Release: `Pikafish-2026-09-06`
- Source commit: `4c17cee11f888ae1d48a9494f2e2239f019f0a1f`
- Sources: tracked `src` files from that commit, with AUTHORS, Copying.txt,
  upstream README.md and CITATION.cff. Upstream algorithm sources are unchanged.
- Model source: `pikafish.nnue` from the official 2026-09-06 distribution.
- Model size: 50,706,378 bytes.
- Model SHA256:
  `7d13d73569a9b571ba0eb20cf1596247bc2a42738967e61afef6482b231e900e`.
- Official distribution archive SHA256:
  `41952bbfe2520faceb5902c69e6ab4845cc999841d2b49a95cc1be7867a25e5b`.

The current master-net is not necessarily compatible with this pinned engine.
Update source and model together and retain the model's license.

The engine's third-party Zstandard decompressor is included in `Vendor/src/external`.
Its source headers offer BSD or GPLv2 terms; the BSD LICENSE text is retained
there, obtained from the official facebook/zstd v1.5.7 LICENSE. The bundled
decompressor itself remains the Pikafish-pinned code (its development version
header reports 1.6.0); adding the unchanged BSD license is not a code update.

Local build/integration choices:

- Exclude the standalone main program, universal launchers and assembly.
- Compile the bundled portable Zstandard C++ decompressor.
- Disable NNUE embedding and load the packaged resource by pathname.
- Use ARM64 NEON or x86-64 SSE2 without requiring AVX instructions.
- Wrap legal generation and search in the C ABI, keeping engine callbacks out
  of Objective-C/Swift worker threads and avoiding duplicate model loading.
