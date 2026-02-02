# 🌙 NoBlizzRangeFade (Midnight)

**Author:** *Sikaros*  
**Powered by:** Claude (vibe coding ✨)

NoBlizzRangeFade is a lightweight World of Warcraft addon built **specifically for the Midnight client**.

Its mission is simple:

👉 **Stop Party & Raid frames from fading when players are out of range.**

Designed for healers, raid leaders, and anyone who wants clean, readable unit frames at all times.

---

## ✨ What This Addon Does

- Keeps **Party & Raid frames fully visible**
- Prevents Blizzard’s **range-based transparency**
- Safe to use **in combat**
- Built exclusively for **Midnight and beyond**

No taint. No errors. No blocked abilities.

---

## 💡 Why This Exists

During the **Midnight pre-patch (v12.0)**, Blizzard introduced a transparency effect on Party and Raid frames when units move out of range.

This change:
- Is handled in protected **C-side code**
- Breaks traditional addon methods
- Can cause **Secret Value errors**, taint, and combat issues

This issue was publicly highlighted by **streamer anniefuchsia**, who couldn’t find a safe way to fully disable the new transparency behavior.

That frustration inspired this addon.

---

## 🛡️ How It Works — “The Defender” Logic

Instead of fighting Blizzard’s protected systems, NoBlizzRangeFade takes a defensive approach.

### 🔁 Reactive Restoration

- Every **0.05–0.1 seconds**, the addon:
  - Scans visible Party & Raid frames
  - Forces them back to full opacity using `SetAlpha(1)`

### 🧠 Stability First

- No hooks into protected Blizzard functions
- No overrides of `UpdateInRange`
- Zero Lua errors
- Fully combat-safe

### 🎯 Midnight-Aware

Specifically targets:
- `RaidGroupButton`
- `CompactPartyFrameMember`

These structures are unique to the modern Midnight client.

---

## ⚠️ Known Limitation: The Tiny Flicker™

You may notice a **very brief flicker** when a unit moves in or out of range.

### Why it happens

- Blizzard fades the frame instantly
- Lua restores visibility milliseconds later
- A tiny visual gap occurs between the two

### Why it’s not “fixed”

Intercepting Blizzard’s fade logic:
- Turns frame data into **Secret Values**
- Causes severe UI errors
- Can block abilities in combat

### The Tradeoff

- 🟢 Stable, safe UI  
- 🔵 over perfectly static frames

Stability always wins.

---

## 🧪 A Small Personal Note

Hi! I’m **Sikaros**, a **new addon author**.

- This is a learning project
- I’m still figuring things out
- Please be patient — and kind ❤️

Feedback, bug reports, and suggestions are welcome, just keep in mind that this addon prioritizes stability above all else.


## 🙏 Credits & Inspiration

- **anniefuchsia** — for highlighting the issue and inspiring a solution CLIP: https://www.twitch.tv/anniefuchsia/clip/WanderingGoldenDolphinRlyTho-DXq_fRXwz6PllHzB
- **Claude** — powered-by-vibes coding assistance
- Blizzard — for making this necessary 😄
