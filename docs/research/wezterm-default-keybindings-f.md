# WezTerm default keybindings: fullscreen verdict and "F"-key catalog

Research date: 2026-08-02. Scope: verify whether WezTerm ships a default `ToggleFullScreen`
keybinding out of the box, and catalog every default keybinding involving the "F" key
(letter and function keys F1–F12).

## 1. Fullscreen keybinding verdict

**Yes — WezTerm ships a default `ToggleFullScreen` binding: `ALT` + `Enter`, and it applies
on all platforms, including macOS.**

- Primary doc source: the "Default Key Assignments" table lists a row
  `ALT` / `Enter` / `ToggleFullScreen` with an empty Platform column (no restriction noted).
  https://wezterm.org/config/default-keys.html
- Raw doc source (identical content): `docs/config/default-keys.md` at
  `main` — table row `| \`ALT\`       | \`Enter\`  | \`ToggleFullScreen\` |` with no
  platform qualifier.
  https://raw.githubusercontent.com/wezterm/wezterm/main/docs/config/default-keys.md
  (verified byte-identical content also at the historical tag `20240203-110809-5046fc22`,
  see §3).
- **Authoritative confirmation in source code** (this is the code that actually builds the
  default keymap, not just docs): `wezterm-gui/src/commands.rs`, in the match arm for
  `ToggleFullScreen`:
  ```rust
  ToggleFullScreen => CommandDef {
      brief: "Toggle full screen mode".into(),
      doc: "Switch between normal and full screen mode".into(),
      keys: vec![(Modifiers::ALT, "Return".into())],
      args: &[ArgType::ActiveWindow],
      menubar: &["View"],
      icon: Some("md_fullscreen"),
  },
  ```
  https://github.com/wezterm/wezterm/blob/main/wezterm-gui/src/commands.rs#L676-L683
  (this `CommandDef` list is consumed by `CommandDef::default_key_assignments()`, lines
  147–157 of the same file, which is what actually populates WezTerm's `InputMap` of
  default keybindings — see
  https://github.com/wezterm/wezterm/blob/main/wezterm-gui/src/commands.rs#L145-L157).
- The `KeyAssignment` enum confirms `ToggleFullScreen` is a real, first-class action:
  `config/src/keyassignment.rs`, `pub enum KeyAssignment { ... ToggleFullScreen, ... }`.
  https://github.com/wezterm/wezterm/blob/main/config/src/keyassignment.rs

### Platform nuance (matters because the user is on macOS)

- `ALT` is WezTerm's cross-platform modifier name for "Option on macOS / Alt or Meta
  elsewhere." Quoted verbatim from the key-binding docs:
  > "ALT, OPT, META — these are all equivalent: on macOS the `Option` key, on other systems
  > the `Alt` or `Meta` key. Left and right are equivalent."
  https://wezterm.org/config/keys.html
  So on macOS specifically, the default fullscreen toggle is **Option (⌥) + Return**, not
  Cmd+Return.
- `wezterm-gui/src/commands.rs` has an explicit modifier-permutation routine,
  `CommandDef::permute_keys()` (lines 109–143), that auto-synthesizes extra bindings **only**
  for commands whose default modifier is `Modifiers::SUPER` (Cmd on macOS) — it adds a
  `CTRL+SHIFT` equivalent "for environments where SUPER/CMD is reserved for the window
  manager." `ToggleFullScreen`'s default modifier is `ALT`, not `SUPER`, so it does **not**
  go through this synthesis and has exactly one default binding (`ALT+Return`) on every
  platform — no separate Cmd-based fullscreen default is auto-added for macOS.
  https://github.com/wezterm/wezterm/blob/main/wezterm-gui/src/commands.rs#L109-L143
- Contrast with a row that genuinely is platform-restricted, to show the doc table does mark
  such restrictions when they exist: `SUPER` / `h` / `HideApplication` is annotated
  "(macOS only)" in the same table
  (https://wezterm.org/config/default-keys.html and
  https://raw.githubusercontent.com/wezterm/wezterm/main/docs/config/default-keys.md, row
  `| \`SUPER\`  | \`h\`  | \`HideApplication\` (macOS only) |`). `ToggleFullScreen`'s row
  carries no such annotation, which is affirmative evidence it is *not* platform-restricted.

### macOS native fullscreen is a separate mechanism

WezTerm's `ToggleFullScreen` action and macOS's native traffic-light/green-button fullscreen
are two different code paths, both present in the same binary:

- `window/src/os/macos/window.rs` has `toggle_native_fullscreen()` (calls
  `NSWindow::toggleFullScreen_`, i.e. the OS-level fullscreen API) and a separate
  `toggle_simple_fullscreen()` (WezTerm's own borderless-window fullscreen implementation).
  A top-level `toggle_fullscreen()` (line 1308) picks between them based on the
  `native_macos_fullscreen_mode` config option:
  ```rust
  fn toggle_fullscreen(&mut self) {
      let native_fullscreen = self.config.native_macos_fullscreen_mode;
      ...
      if native_fullscreen {
          if !self.exit_simple_fullscreen() {
              self.toggle_native_fullscreen();
          }
      } else {
          if !self.exit_native_fullscreen() {
              self.toggle_simple_fullscreen();
          }
      }
  }
  ```
  https://github.com/wezterm/wezterm/blob/main/window/src/os/macos/window.rs#L1308-L1322
- So triggering the `ToggleFullScreen` `KeyAssignment` (whether via the default `ALT+Enter`
  or the user's custom `CMD+Enter`) drives this same `toggle_fullscreen()` method, which then
  either invokes native macOS fullscreen (`native_macos_fullscreen_mode = true`, the config's
  behavior; not verified as default true/false in this pass) or WezTerm's own "simple"
  fullscreen. Clicking the green traffic-light button on the title bar, or the macOS menu-bar
  "Enter Full Screen" item, invokes native fullscreen directly via the OS, independent of any
  WezTerm keybinding — it is a distinct trigger path from the `KeyAssignment` system entirely.
  Config option doc: `native_macos_fullscreen_mode` —
  https://wezterm.org/config/lua/config/native_macos_fullscreen_mode.html (referenced from
  https://wezterm.org/config/lua/keyassignment/ToggleFullScreen.html).

## 2. Full list of default "F"-key bindings

Checked every row of the default-keys table (both the rendered HTML doc and the raw Markdown
source) plus the full `wezterm-gui/src/commands.rs` `CommandDef` list (the code that actually
builds the default keymap) for: literal letter **F**/**f** combos, and function keys
**F1–F12**.

**Function keys F1–F12: zero default bindings.** No row in
https://wezterm.org/config/default-keys.html, no row in
https://raw.githubusercontent.com/wezterm/wezterm/main/docs/config/default-keys.md, and no
`"F1"`…`"F12"` / `Function(...)` key string anywhere in
https://github.com/wezterm/wezterm/blob/main/wezterm-gui/src/commands.rs (grepped the full
2147-line file for `F1`–`F12` patterns and `Function(` — no matches). In particular, **F11
does not trigger fullscreen** in WezTerm by default, unlike the common browser/Linux-DE
convention.

**Letter "F": two rows, both mapping to `Search`.**

| Key | Mods | Platform | Action (KeyAssignment) | Source citation |
|---|---|---|---|---|
| `f` | `SUPER` (Cmd on macOS) | All | `Search={CaseSensitiveString=""}` (doc naming) / `Search(Pattern::CurrentSelectionOrEmptyString)` (source enum variant) | Doc table row `\| \`SUPER\` \| \`f\` \| \`Search={CaseSensitiveString=""}\` \|` — https://wezterm.org/config/default-keys.html and https://raw.githubusercontent.com/wezterm/wezterm/main/docs/config/default-keys.md. Source: `keys: vec![(Modifiers::SUPER, "f".into())]` under `Search(Pattern::CurrentSelectionOrEmptyString) => CommandDef { ... }`, https://github.com/wezterm/wezterm/blob/main/wezterm-gui/src/commands.rs#L777-L784 |
| `F` | `CTRL+SHIFT` | All | `Search={CaseSensitiveString=""}` | Doc table row `\| \`CTRL+SHIFT\` \| \`F\` \| \`Search={CaseSensitiveString=""}\` \|` — same URLs as above. This row is not a second explicit source entry; it is auto-synthesized from the `SUPER+f` entry by `CommandDef::permute_keys()`, which for any `Modifiers::SUPER` default also adds a `CTRL+SHIFT` variant "for environments where SUPER/CMD is reserved for the window manager" — https://github.com/wezterm/wezterm/blob/main/wezterm-gui/src/commands.rs#L109-L143 |

No other row in the default-keys table contains the letter F in its Key column (checked all
~68 rows of the table transcribed from both the rendered page and the raw Markdown source).

## 3. Version/commit notes

- **The wezterm.org docs site is not version-pinned per page.** No version number, git tag,
  commit hash, or version-selector dropdown appears in the header, footer, or sidebar of
  either https://wezterm.org/config/default-keys.html or
  https://wezterm.org/config/lua/keyassignment/ToggleFullScreen.html (checked directly).
  Instead, the docs use **per-row/per-feature "since" annotations** for features added after
  a given release — visible in the raw Markdown source as
  `{{since('<tag>', inline=True)}}` template macros, e.g. on the `CTRL` `Insert` row:
  `` `CopyTo="PrimarySelection"` {{since('20210203-095643-70a364eb', inline=True)}} ``
  (rendered on the live site as "Since v20210203"). Source:
  https://raw.githubusercontent.com/wezterm/wezterm/main/docs/config/default-keys.md.
  This means the page as a whole always reflects the current `main` branch, with inline
  markers only for individual additions — it is not frozen to one release.
- **Cross-check for stability**: I fetched `docs/config/default-keys.md` both at `main`
  HEAD and at the historical tag `20240203-110809-5046fc22` (2024-02-03) — content was
  byte-identical for every row discussed here (including the `ALT`/`Enter`/`ToggleFullScreen`
  row and both `f`/`F` rows), so these findings are stable across at least that span.
  https://raw.githubusercontent.com/wezterm/wezterm/20240203-110809-5046fc22/docs/config/default-keys.md
- **Repo location / org**: the canonical GitHub org has moved. `https://github.com/wez/wezterm`
  now returns HTTP 301 and redirects to `https://github.com/wezterm/wezterm` (verified via
  `curl -I` and `gh api repos/wez/wezterm` → `full_name: "wezterm/wezterm"`). All source
  citations above use the current canonical `wezterm/wezterm` org.
- **Release cadence**: per the GitHub Releases API
  (`gh api repos/wezterm/wezterm/releases/latest`), the most recent tagged release is
  `20240203-110809-5046fc22` (published 2024-02-03). However, `main` has continued active
  development well past that tag — the latest commit on `main` at research time was
  `d69264df66fdcc928c7a30c673df108984fda821` (authored 2026-07-31, per
  `gh api repos/wezterm/wezterm/commits/main`). All source-code citations in this document
  (`commands.rs`, `keyassignment.rs`) are against `main` at that commit; the docs-derived
  findings were additionally cross-checked against the last tagged release as noted above and
  found identical. In short: **WezTerm effectively ships via nightly/main-branch builds**,
  and the docs site tracks `main`, not a specific numbered release.

## 4. Recommendation for this repo

The user's binding in `home/.config/wezterm/wezterm.lua`:

```lua
{ key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen },
```

is **complementary, not redundant, and not filling a total gap** — it's a second, additional
keystroke for an action WezTerm already binds by default, on a different key combination:

- WezTerm's shipped default for `ToggleFullScreen` on macOS is **Option (⌥) + Return**
  (`ALT`+`Enter`), confirmed in both docs and source (§1). It is a real default, not absent.
- The user's belief that "WezTerm has no default fullscreen keybinding out of the box" is
  **incorrect** — but the mistake is understandable: on macOS, `ALT` in WezTerm's config
  language means the Option key, not Cmd, so if the user was pressing Cmd+Enter and it did
  nothing, that's expected (Cmd+Enter was never bound), while Option+Enter would already have
  worked before this change.
- Because the default lives on `ALT+Enter` and the new binding lives on `CMD+Enter`, there is
  no conflict or override — after this change, WezTerm will respond to fullscreen-toggle on
  **both** Option+Enter (built-in default) and Cmd+Enter (user's addition). This is the
  "same action bound to two different keys" case, not redundant duplication of the same
  keystroke and not a platform gap the user needed to plug.
- Net effect: the new binding is a legitimate, harmless UX preference (Cmd+Enter may better
  match the user's muscle memory from other macOS apps that use Cmd+Ctrl+F or Cmd+Enter for
  fullscreen) layered on top of an existing, functioning default — not a fix for a missing
  capability.
