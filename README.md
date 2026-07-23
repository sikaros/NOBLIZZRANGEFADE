# NoBlizzRangeFade

NoBlizzRangeFade keeps Blizzard party and raid frames at full opacity when group members move out of range.

Out-of-range frames also receive a grey range overlay.

## Requirements

- World of Warcraft: Midnight 12.0.7 or later
- Default Blizzard party or raid frames

Custom frame addons such as ElvUI and VuhDo are not supported.

## Install

1. Download the latest release.
2. Extract the `NoBlizzRangeFade` folder into `_retail_/Interface/AddOns/`.
3. Restart World of Warcraft or reload the interface.

## Commands

- `/norangefade status` shows the addon version and debug state.
- `/norangefade debug` turns debug messages on or off.

## How it works

The addon checks the default group frames ten times per second. Each check disables Blizzard's range fade and restores full frame opacity.

The overlay passes range values to Blizzard's secret-safe display API. The addon does not inspect those values in Lua.

The addon does not hook Blizzard's protected range functions.

## Limits

- A brief flicker can occur before the addon restores frame opacity.
- Frames created during combat receive an overlay after combat ends.
- Only default Blizzard group frames are supported.

## Credits

The addon was inspired by an issue [highlighted by anniefuchsia](https://www.twitch.tv/anniefuchsia/clip/WanderingGoldenDolphinRlyTho-DXq_fRXwz6PllHzB).

## License

See [LICENSE](LICENSE).
