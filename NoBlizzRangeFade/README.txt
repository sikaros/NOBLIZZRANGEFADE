# NoBlizzRangeFade

**Version:** 1.1.2

Prevents raid and party frames from fading when units are out of range in World of Warcraft: Midnight, while adding a subtle grey range overlay.

---

## 📋 Features

- ✅ **No Fading** - Party and raid frames stay fully visible regardless of range
- ✅ **Range Indicator** - Out-of-range frames get a visible dark overlay instead of transparency
- ✅ **No Errors** - Clean, stable implementation with no lua errors
- ✅ **Lightweight** - Minimal performance impact
- ✅ **Auto-Update** - Automatically handles roster changes

---

## 💬 Commands

Type these commands in-game:

- `/norangefade status` - Show addon version and status
- `/norangefade debug` - Toggle debug logging (for troubleshooting)

---

## ⚙️ Compatibility

- **Game Version:** World of Warcraft Midnight (12.0.7+)
- **Frame Types:** Works with default Blizzard raid/party frames only
- **Not Compatible:** ElvUI, VuhDo, or other custom frame replacements

---

## 📝 Known Issues

- Minor visual flicker may occur when units move in/out of range (unavoidable without causing lua errors)
- The range overlay uses Midnight's secret-safe display API so it can update without inspecting restricted range values
- A unit frame first created during combat receives its range overlay after combat ends
- Only affects default Blizzard frames

---

## 🙏 Thank You!

Thank you for downloading NoBlizzRangeFade! If you encounter any issues or have suggestions, please report them on the project page.

Happy raiding! 🎮
