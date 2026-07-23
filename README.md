# NoBlizzRangeFade

Blizzard dims default party and raid frames when group members move out of range. NoBlizzRangeFade keeps those frames at full opacity and uses a grey overlay to show range instead.

## Requirements

- World of Warcraft: Midnight 12.0.7 or later
- Default Blizzard party or raid frames

The addon does not support ElvUI, VuhDo, or other custom frame replacements.

## Install

1. Download the latest release.
2. Copy the `NoBlizzRangeFade` folder to `_retail_/Interface/AddOns/`.
3. Restart World of Warcraft or reload the interface.

## Commands

- `/norangefade status` shows the addon version and debug state.
- `/norangefade debug` turns debug messages on or off.

## How it works

Every 0.1 seconds, the addon checks the default group frames, disables Blizzard's range fade, and resets their opacity.

For the grey overlay, it passes `UnitInRange` results straight to Blizzard's `SetAlphaFromBoolean` API. Blizzard handles restricted values, so the addon never compares them in Lua.

The addon does not hook protected range functions.

## Limits

- You may see a brief flicker before the addon restores a frame.
- A frame created during combat gets its range overlay after combat ends.

## Credits

[A clip from anniefuchsia](https://www.twitch.tv/anniefuchsia/clip/WanderingGoldenDolphinRlyTho-DXq_fRXwz6PllHzB) about Midnight's range fade prompted this addon.

## License

See [LICENSE](LICENSE).
