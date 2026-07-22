# CLAUDE.md

## Project Overview
**NoBlizzRangeFade** is a World of Warcraft addon targeting the *Midnight* client that prevents raid and party frames from fading when units are out of range.

The addon works by identifying the *actual* frame names used by Midnight (not Blizzard defaults) and aggressively restoring frame alpha via hooks and a periodic fixer.

This project prioritizes correctness in a sandboxed WoW Lua environment over elegance.

---

## Target Environment (CRITICAL)
- Platform: World of Warcraft (Midnight)
- Language: WoW Lua (sandboxed)
- UI System: Blizzard Compact / Raid Frames (Midnight variant)
- Persistence: SavedVariables only

### WoW Lua Sandbox Limitations
- No `io`, `os`, `date`, or filesystem access
- No direct file writing
- Some globals are protected or proxied
- Iterating `_G` can crash if done unsafely

Assume the environment is hostile by default.

---

## Frame Name Reality (CURRENT LIVE OVERRIDE)

The live 12.0.7+ UI source supersedes the older diagnostic notes later in this file.

### Midnight currently uses:
- `CompactRaidFrame1-40` for compact raid unit frames
- `CompactPartyFrameMember1-5` for compact party unit frames

### Do not target:
- `RaidGroupButton1-40`, which are raid-management controls and can interfere with Edit Mode
- `UseCompactRaidFrame()`
- `GetRaidMaxSize()`

Any work involving raid frames must target `CompactRaidFrameX` and verify names against the current live Blizzard UI source.

---

## Architecture Overview

### Core.lua
- ADDON_LOADED initialization
- Event handling
- Slash command registration
- SavedVariables setup

### Fixes.lua
- All frame-fixing logic
- Hooks
- Continuous OnUpdate fixer

### Namespace (`ns`)
- Shared state
- Logging utilities
- Debug flags

Files communicate strictly through the addon namespace.

---

## Frame Fix Strategy

The addon uses a **behavior override** approach, intercepting Blizzard's fading logic at the source rather than fighting it every frame.

### Method 1: SetAlpha Hooks (PRIMARY)
- Hook each frame's `SetAlpha` method
- Block any call with `alpha < 1`
- Intercepts fading **at the moment it happens**
- Minimal performance overhead (only runs when Blizzard tries to fade)
- Survives frame recreation (we re-hook periodically)

### Method 2: CompactUnitFrame_UpdateInRange Hook (SECONDARY)
- `hooksecurefunc` on Blizzard's range update function
- Catches some frames that bypass SetAlpha
- Acts as a safety net for edge cases

### Method 3: Periodic Re-Hooker (MAINTENANCE)
- Runs `FixAllFrames()` every 5 seconds
- Re-hooks frames that may have been recreated
- Ensures current alpha state is correct
- Much lighter than old 0.5s polling approach

**Why this works:**
- We don't fight Blizzard every frame (expensive)
- We intercept their fading logic once per frame (cheap)
- We re-hook periodically to catch new frames (minimal overhead)

**Critical requirement:**
- Check for `frame.unit` existence, NOT `frame:IsVisible()`
- Visibility state is unreliable in Midnight's parent-child container model

---

## Debug & Investigation Tools

Active slash commands:

- `/norangefade debug`
  Toggle live chat logging

- `/norangefade snapshot`
  Dump frame state to memory buffer

- `/norangefade scan`
  Scan `_G` to discover real frame names

- `/norangefade dumplog`
  Print last ~50 log lines to chat

- `/norangefade status`
  Show addon state and log buffer size

### Logging Rules
- Logs are stored in memory
- Persist only via SavedVariables
- No file I/O of any kind
- Use `GetTime()` instead of `date()`

---

## Midnight-Specific Gotchas (v12.0)

### 1. IsVisible() is Unreliable
**Problem:** Frames can have valid `.unit` properties but report `IsVisible() = false`

**Cause:** Midnight changed visibility inheritance. Parent containers control visibility, not child buttons.

**Solution:** Check `frame.unit` existence, NOT `frame:IsVisible()`

**Evidence:** Scan logs show `RaidGroupButton30 | unit=raid30 | visible=false`

### 2. Child Frames are "Secret Values"
**Problem:** Accessing child frames like `CompactPartyFrameMember1Buff4Icon` throws "attempt to index a secret value"

**Cause:** Blizzard made child frames of protected parents inaccessible in Midnight

**Solution:**
- Pre-filter scanner to skip patterns like `CompactPartyFrameMember%d+Buff`
- Never attempt to iterate child frames of protected parents
- Target only parent frames directly

**Evidence:** 1,846 errors in initial scan, all on child frames

### 3. Frame Names Changed
**Problem:** Documentation says `CompactRaidFrame1-40`, reality is `RaidGroupButton1-40`

**Cause:** Blizzard renamed frames in Midnight without updating docs

**Solution:** Always scan `_G` to discover actual frame names, never trust documentation

**Evidence:** Scan found `RaidGroupButton1-40` with valid units, `CompactRaidFrame1-40` do not exist

### 4. Protected Frame Access Patterns
**Problem:** Some frames error on ANY property access, even inside `pcall()`

**Cause:** "Secret values" error during table index operation, before function executes

**Solution:**
- Check `type(obj) == "table"` before attempting property access
- Use pattern filtering to skip known protected frames
- Accept that some frames are permanently inaccessible

### 5. Dynamic Frame Creation Timing
**Problem:** `RaidGroupButton1-40` frames don't exist until you join a raid

**Cause:** Blizzard creates these frames dynamically on `GROUP_ROSTER_UPDATE`

**Solution:**
- Hook `GROUP_ROSTER_UPDATE` event to catch frame creation immediately
- Run `FixAllFrames()` when event fires
- Don't rely solely on periodic re-hooking (can miss up to 5s window)

**Evidence:** Scan outside raid shows no `RaidGroupButton` frames, only their children

### 6. Dynamic Raid Expansion Failure
**Problem:** When raid grows (10â†’15â†’20 members), new frame buttons don't appear until /reload

**Cause:** Midnight's `CompactRaidFrameManager` doesn't rebuild layout when raid size increases dynamically

**Solution:**
- Compare `GetNumGroupMembers()` vs actual frames found
- When mismatch detected, call `CompactRaidFrameManager_UpdateShown()` and `CompactRaidFrameContainer_TryUpdate()`
- Wait 0.2s then re-run `FixAllFrames()` to hook newly created frames

**Evidence:** QA testing showed frames 11-15 missing when raid expanded from 10â†’15 members, /reload made them appear

### 7. Frame Recreation During Roster Updates
**Problem:** Wrapping frame.SetAlpha on GROUP_ROSTER_UPDATE causes lua errors

**Cause:** Frames get destroyed and recreated during roster changes. If we wrap SetAlpha and save a reference to originalSetAlpha, that reference becomes invalid when the frame is destroyed.

**Solution:**
- Track which frames already have wrapped SetAlpha (monitoredFrames table)
- Validate frame.SetAlpha exists and is a function before wrapping
- Validate originalSetAlpha stays valid when wrapper executes
- Wrap all installation code in pcall to catch recreation errors
- Skip frames that are already monitored

**Evidence:** Lua error spam on line 127 of Fixes.lua during party testing with GROUP_ROSTER_UPDATE firing

### 8. Secret Values in Hooked Functions
**Problem:** Hooking CompactUnitFrame_UpdateInRange causes "attempt to compare secret value" errors

**Cause:** When we hook Blizzard's functions, our hook runs first, then Blizzard's original code runs. Blizzard's code calls UnitIsConnected() and other functions that return secret values. We can't prevent their code from running.

**Solution:**
- DON'T hook CompactUnitFrame_UpdateInRange or similar protected functions
- Instead, disable range display via optionTable.displayRangeDisplay = false
- Use continuous polling (OnUpdate) to force alpha and re-disable range display
- No hooks = no interaction with protected code = no secret value errors

**Evidence:** BugSack errors showing "attempt to compare local 'unitOutOfRange' (a secret value)" at CompactUnitFrame.lua:1027

---

## Defensive Coding Rules (MANDATORY)

When modifying or adding code:

- Wrap all risky calls in `pcall`
- Never assume globals are safe
- Never use `pairs(_G)`
  - Use `next()` with manual iteration
- Capture only the first return value from `gsub()`
- Assume any frame access may be protected
- Prefer â€œugly but safeâ€ over â€œclean but fragileâ€

Crashes inside WoW are catastrophic.
Prevention > elegance.

---

## Development Philosophy
- This is a bug-fixing addon, not a UI framework
- Avoid refactors unless explicitly requested
- Match existing patterns and naming
- Keep changes minimal and scoped
- Prefer explicit logic over abstraction

---

## Current State
- Latest version: 0.3.7 FINAL
- **Status:** STABLE - No lua errors, frames stay visible
- **Method:** Disable range display option + continuous alpha forcing
- **Performance:** 10 checks per second (0.1s interval)
- **Next:** Monitor for any edge cases, then package for release

### v0.3.7 FINAL (Current - WORKING):
- **Solution:** Completely避开 Blizzard's protected code
- **NO function hooks** - Avoids all secret value errors
- **NO SetAlpha wrapper** - Prevents protected property conflicts
- **Method:** Set displayRangeDisplay=false on all frames every 0.1s
- **Fallback:** Force SetAlpha(1) every 0.1s as backup
- **Result:** No lua errors, minimal flicker, stable operation
- **QA STATUS:** User confirmed stable operation

### Lessons Learned from Regression Sprint:
- **REGRESSION RECOVERY:** Restored exact working code from v0.3.7 FIXED v2
- **What broke:** v0.3.8 through v0.4.1 tried different approaches, all regressed
- **Root cause:** Removed the working dual-mechanism (function hooks + SetAlpha wrapper)
- **Restored mechanisms:**
  1. Function hooks: 21 functions hooked, force SetAlpha(1) when they fire
  2. SetAlpha wrapper: BLOCKS any SetAlpha call with alpha < 1.0
- **Changes from diagnostic:** Removed debugstack() to reduce log spam
- **All core blocking logic:** Kept intact from working version
- **QA STATUS:** Awaiting testing to confirm restoration successful

### REGRESSION TIMELINE:
- **v0.3.7 FIXED v2:** User confirmed "last known time i could consistently get good results"
- **v0.3.8 POLLING:** Removed hooks, added polling - USER: "regressed and now it fades"
- **v0.4.0 RANGE OVERRIDE:** Tried inRange flags - USER: "still faded party frames"
- **v0.4.1 BRUTE FORCE:** Tried OnUpdate forcing - USER: "still nothing coming thru on debug"
- **v0.3.7 PRODUCTION RESTORE:** Exact restore of last working version

### v0.3.7 Enhanced Diagnostic FIXED (Last Confirmed Working):
- **Expanded function list:** 17 candidates including Midnight-specific functions
- **Direct SetAlpha monitoring:** Wraps SetAlpha on individual frames (RaidGroupButton*, CompactPartyFrameMember*)
- **Stack trace capture:** Uses debugstack() to show EXACTLY what called SetAlpha
- **Auto-monitoring:** GROUP_ROSTER_UPDATE listener re-installs monitors when roster changes
- **Test plan:** Comprehensive 30-minute QA test plan with data collection template
- **Goal:** Definitively answer "What function does Midnight call when it fades frames?"
- **BUG FIX:** Wrapped SetAlpha installation in monitoredFrames tracking and full pcall protection
- **BUG FIX:** Added WrapFrameSetAlpha helper with validation checks for frame.SetAlpha existence
- **BUG FIX:** Prevents duplicate wrapping on same frame (was causing lua errors on GROUP_ROSTER_UPDATE)
- **QA RESULT:** Party frames stay visible, no lua errors during extended testing

### v0.3.6 Diagnostic (Previous):
- First diagnostic attempt
- Hooked 10 possible fading functions
- Discovered need for expanded list and direct SetAlpha monitoring

### v0.3.3 NBR-033 Party Frame Fix (Baseline):
- **REMEDIATION A (Lifecycle Race):** Hook-First Logic â€” hooks installed immediately on frame discovery in _G, no .unit requirement
- **REMEDIATION B (Container Fading):** Parent container targeting â€” hooks PartyFrame, CompactRaidFrameContainer, CompactPartyFrame, CompactRaidFrameManager
- **REMEDIATION C (Secret Values):** Secret value shielding â€” ALL property access wrapped in pcall() to prevent mid-scan crashes
- **REMEDIATION D (Update Taint):** Removed forced Blizzard updates â€” deleted manual CompactRaidFrameManager calls, let protected code finish naturally
- **NEW:** hookedFrames tracking table prevents duplicate hooks
- **NEW:** GROUP_ROSTER_UPDATE event listener re-hooks 0.5s after roster changes (waits for Blizzard to finish)
- **Result:** Party frames hook before units are assigned, container-level alpha inheritance blocked, no more crashes on protected sub-elements, no more UI taint
- **NOTE:** QA testing revealed frames still fading despite all remediations â€” prompted diagnostic mode

### v0.3.2 QA Fix (Dynamic Raid Expansion):
- **Root cause:** CompactRaidFrameManager doesn't create new frames when raid grows in Midnight
- **Detection:** Compare `GetNumGroupMembers()` vs actual frame count found
- **Solution:** Force `CompactRaidFrameManager_UpdateShown()` and `CompactRaidFrameContainer_TryUpdate()` when mismatch detected
- **Automatic re-hook:** Run `FixAllFrames()` again 0.2s after forcing refresh to hook newly created frames
- **Result:** Raid expansion from 10â†’15â†’20+ members now works without manual /reload
- **NOTE:** This forced update approach was REMOVED in v0.3.3 due to taint risk (REMEDIATION D)

### v0.3.1 Critical Changes:
- **Removed `IsVisible()` checks** â€” frames can have valid `.unit` but report `visible=false` in Midnight
- **Replaced 0.5s OnUpdate polling with SetAlpha method hooks** â€” intercept fading at source instead of fighting Blizzard every frame
- **Added pattern filters to scanner** â€” skip protected child frames that are "secret values" (CompactPartyFrameMember*Buff*, etc.)
- **Performance optimization** â€” reduced overhead from 90 checks/sec to 8 checks/sec
- **Behavioral change:** We now override `SetAlpha` on each frame to block values < 1, preventing fading before it happens
- **Added GROUP_ROSTER_UPDATE event** â€” hooks frames immediately when raid composition changes, not waiting up to 5s for periodic re-hooker

### Key Learnings from v0.3.0 â†’ v0.3.1:
1. **Midnight visibility model changed** â€” frames can have units but report `IsVisible()=false` when parent containers manipulate visibility
2. **Child frames are "secret values"** â€” attempting to access properties on child frames like `CompactPartyFrameMember1Buff4Icon` errors with "attempt to index a secret value"
3. **Hooking SetAlpha is superior to polling** â€” intercepts Blizzard's fade logic at the exact moment it happens, with minimal overhead
4. **Status quo was broken** â€” the 0.5s fixer was running but skipping all frames due to `IsVisible()` returning false

---

## Planned (DO NOT IMPLEMENT UNLESS ASKED)
- On/off toggle without reload
- Settings panel (Settings > Addons)
- Per-frame-type toggles (raid / party)
- SavedVariables for user preferences
- CurseForge packaging and README

---

## Notes for Claude
- Do not reintroduce Blizzard default assumptions
- Do not remove redundant fix paths
- Do not add external libraries or dependencies
- When debugging frame behavior, extend existing debug tools instead of inventing new systems

When in doubt, assume Midnight behaves differently than expected.
