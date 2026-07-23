# NoBlizzRangeFade

Blizzard dims default party and raid frames when group members move out of range. NoBlizzRangeFade keeps those frames at full opacity and uses a grey overlay to show range instead.

## Requirements

- World of Warcraft: Midnight 12.0.7 or later
- Default Blizzard party or raid frames

The addon does not support ElvUI, VuhDo, or other custom frame replacements.

## Commands

- `/norangefade status` shows the addon version and debug state.
- `/norangefade alpha <0.3-1.0>` sets the grey overlay alpha.
- `/norangefade debug` turns debug messages on or off.

The real Blizzard frame alpha stays at 1.0.
The default grey overlay alpha is 0.40.

## Limits

- You may see a brief flicker before the addon restores a frame.
- A frame created during combat gets its range overlay after combat ends.

Report problems on the project page.
