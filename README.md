🌙 NoBlizzRangeFade (Midnight)

NoBlizzRangeFade is a lightweight World of Warcraft addon made specifically for the Midnight client.
Its job is simple:

👉 Stop Party & Raid frames from fading when players are out of range.

Perfect for healers, raid leaders, and anyone who wants clean, consistent unit frames at all times.

✨ What This Addon Does

✅ Keeps Raid and Party frames fully visible

✅ Prevents Blizzard’s automatic range-based transparency

✅ Works safely in combat

✅ Designed only for Midnight (v12.0) — no legacy hacks

No weird taint. No blocked abilities. No surprise UI breakage.

❓ Why This Exists

In the Midnight expansion (v12.0), Blizzard moved large parts of unit frame logic into protected C-side code.

That means:

Old addons that disabled range fading now cause:

❌ “Secret Value” errors

❌ UI taint

❌ Abilities becoming unusable in combat

NoBlizzRangeFade avoids all of that.

🛡️ How It Works — “The Defender” Logic

Instead of fighting Blizzard’s protected systems, this addon plays smart defense.

🔁 Reactive Restoration

Every 0.05–0.1 seconds, the addon:

Scans active Party & Raid frames

Forces them back to full visibility (SetAlpha(1))

🧠 Stability First

🚫 No direct hooks into protected Blizzard functions

🚫 No overrides of UpdateInRange

✅ Zero Lua errors

✅ Fully combat-safe

🎯 Midnight-Aware

Targets:

RaidGroupButton

CompactPartyFrameMember

Built specifically for modern Midnight frame structures

⚠️ Known Limitation: The Tiny Flicker™

You might notice a very brief flicker when a unit moves in or out of range.

Why it happens

Blizzard fades the frame instantly

Lua reacts milliseconds later

There’s a tiny visual gap between the two

Why it’s NOT “fixed”

Trying to intercept or override Blizzard’s fade logic:

Triggers Secret Value corruption

Causes catastrophic UI errors

Breaks combat actions

The Tradeoff

🟢 Stable, error-free UI
🔴 vs.
🔵 Perfectly static frames

This addon chooses stability every time.

📦 Installation

Download the latest release

Extract the NoBlizzRangeFade folder into:

World of Warcraft/_retail_/Interface/AddOns/


Restart World of Warcraft

Done — no setup required 🎉

🧘 Final Notes

This addon is intentionally minimal

No config, no slash commands, no fluff

It just does one thing — and does it safely

If you value reliability over risky hacks, this addon is for you.
