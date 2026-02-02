🌙 NoBlizzRangeFade (Midnight)

Author: Sikaros
Powered by: Claude (vibe coding ✨)

NoBlizzRangeFade is a lightweight World of Warcraft addon built specifically for the Midnight client.
Its mission is simple:

👉 Stop Party & Raid frames from fading when players are out of range.

Made with healers, raid leaders, and UI enjoyers in mind — because readable frames matter.

✨ What This Addon Does

✅ Keeps Party & Raid frames fully visible

✅ Prevents Blizzard’s new range-based transparency

✅ Safe to use in combat

✅ Built only for Midnight 12.0 and beyond

No taint. No errors. No broken abilities.

💡 Why This Exists

During the Midnight pre-patch (v12.0), Blizzard introduced a new transparency effect on Party and Raid frames when units move out of range.

This change:

Is handled in protected C-side code

Breaks traditional methods used by older addons

Causes “Secret Value” errors, taint, and combat issues if handled incorrectly

This problem was highlighted publicly by streamer anniefuchsia, who couldn’t find a safe way to fully disable the new transparency behavior.

So… this addon was born.

🛡️ How It Works — “The Defender” Logic

Instead of fighting Blizzard’s protected systems, NoBlizzRangeFade takes a defensive approach.

🔁 Reactive Restoration

Every 0.05–0.1 seconds, the addon:

Scans visible Party & Raid frames

Forces them back to full opacity (SetAlpha(1))

🧠 Stability First

🚫 No direct hooks into protected Blizzard functions

🚫 No overrides of UpdateInRange

✅ Zero Lua errors

✅ Fully combat-safe

🎯 Midnight-Aware

Specifically targets:

RaidGroupButton

CompactPartyFrameMember

These are unique to the modern Midnight client

⚠️ Known Limitation: The Tiny Flicker™

You may notice a very brief flicker when a unit moves in or out of range.

Why it happens

Blizzard fades the frame instantly

Lua restores visibility milliseconds later

There’s a tiny visual gap between the two

Why it’s not “fixed”

Trying to intercept Blizzard’s fade logic:

Turns frame data into “Secret Values”

Causes severe UI errors

Can block abilities in combat

The Tradeoff

🟢 Stable, safe UI
🔵 over
🔴 Perfectly static frames

Stability wins every time.

🧪 A Small Personal Note

👋 Hi! I’m Sikaros, and I’m a new addon author.

This is a learning project

I’m still figuring things out as I go

Please be patient — and kind ❤️

Feedback, bug reports, and suggestions are always welcome, just keep in mind that this addon is built carefully and conservatively to avoid breaking the UI.

📦 Installation

Download the latest release

Extract the NoBlizzRangeFade folder into:

World of Warcraft/_retail_/Interface/AddOns/


Restart World of Warcraft

Done — no setup required 🎉

🙏 Credits & Inspiration

💜 anniefuchsia — for highlighting the issue and inspiring a solution

🤖 Claude — powered-by-vibes coding assistance

🧠 Blizzard — for… making this necessary 😄
