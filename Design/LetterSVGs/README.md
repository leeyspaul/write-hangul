# Letter SVGs

This directory stores per-character SVG source assets for the supported Hangul letters.

Each SVG contains:
- `glyph-outline`: the full visible glyph outline, derived from an explicit Hangul-capable system font
- `stroke-paths`: ordered stroke paths with `data-order` and `data-direction` attributes

Generation:

```sh
CLANG_MODULE_CACHE_PATH=/tmp/codex-clang-module-cache \
SWIFT_MODULECACHE_PATH=/tmp/codex-swift-module-cache \
swiftc write-hangul/Data/LetterGuideTemplate.swift \
write-hangul/Data/CanonicalLetterTemplates.swift \
Scripts/GenerateLetterSVGs.swift \
-o /tmp/write-hangul-generate-svgs && \
/tmp/write-hangul-generate-svgs
```
