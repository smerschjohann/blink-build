# blink-build

Builds unsigned IPA releases of [Blink Shell](https://github.com/blinksh/blink) via GitHub Actions.

The upstream project is checked out as a pinned submodule (`blink/`), optionally modified
by a patch series in `patches/`, then archived and packaged into an unsigned `.ipa` —
the same pattern [code-server](https://github.com/coder/code-server) uses for VS Code.

## Layout

| Path | Purpose |
| ---- | ------- |
| `blink/` | Submodule of `blinksh/blink`, pinned to a `raw` branch commit |
| `patches/series` | Ordered list of `.diff` files applied to `blink/` (may be empty) |
| `developer_setup.xcconfig` | Our build settings (bundle id, team, options); copied over the checkout, so most customizations need no patch |
| `scripts/apply-patches.sh` | Applies `patches/series` inside `blink/` |
| `scripts/build.sh` | `xcodebuild archive` with signing disabled → `build/Blink-unsigned.ipa` |
| `scripts/update-upstream.sh` | Moves the pin to upstream `raw` HEAD and dry-run checks all patches |
| `.github/workflows/ipa.yml` | macOS runner build, uploads the IPA as artifact |
| `.github/workflows/upstream-sync.yml` | Weekly auto-bump PR when upstream moved and patches still apply |

## CI

Run the **Build unsigned IPA** workflow (runs automatically on pushes to `main`).
The IPA is uploaded as a workflow artifact.

Unsigned builds cannot be installed directly — re-sign them with a free Apple ID
via AltStore / Sideloadly / Xcode, or with a paid certificate. Entitlements like
iCloud / Push are not embedded in unsigned builds; re-signing tools strip them
automatically if your profile does not support them.

## Local build (macOS)

```bash
git clone https://github.com/smerschjohann/blink-build.git
cd blink-build
git submodule update --init
./scripts/apply-patches.sh
(cd blink && ./get_frameworks.sh && ./get_resources.sh)
cp developer_setup.xcconfig blink/
./scripts/build.sh
```

Requires Xcode ≥ 26 (the raw branch uses iOS 26 SDK APIs like `UIGlassEffect`). The first run downloads all dependencies (XCFrameworks via
SPM, vim runtime resources).

## Updating upstream

```bash
./scripts/update-upstream.sh    # bumps submodule + verifies patches (dry run)
git add blink && git commit -m "chore: bump blink"
```

A weekly workflow does the same automatically and opens a PR. If a patch no longer
applies, the job fails loudly instead of producing a broken build.

## Adding patches

Keep the series minimal: bundle ids, team ids and build options are already
parameterized via `developer_setup.xcconfig`, so patches are only needed for things
like Xcode compatibility fixes or entitlement changes.

```bash
# after editing files inside blink/:
git -C blink diff > patches/001-my-change.diff
echo 001-my-change.diff >> patches/series
```
