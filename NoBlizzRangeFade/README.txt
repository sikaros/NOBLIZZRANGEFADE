# NoBlizzRangeFade

NoBlizzRangeFade keeps Blizzard party and raid frames at full opacity when group members move out of range.

The addon also shows a grey range overlay. It passes range values to Blizzard's secret-safe display API without inspecting them in Lua.

## Requirements

- World of Warcraft: Midnight 12.0.7 or later
- Default Blizzard party or raid frames

ElvUI, VuhDo, and other custom frame replacements are not supported.

## Commands

- `/norangefade status` shows the addon version and debug state.
- `/norangefade debug` turns debug messages on or off.

## Limits

- A brief flicker can occur before the addon restores frame opacity.
- Frames created during combat receive an overlay after combat ends.
- Only default Blizzard group frames are supported.

Report problems on the project page.
