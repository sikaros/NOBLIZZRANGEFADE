NoBlizzRangeFade (Midnight)
NoBlizzRangeFade is a lightweight World of Warcraft addon specifically engineered for the Midnight client. It prevents Raid and Party frames from fading (becoming transparent) when units are out of range, ensuring 100% visual consistency for healers and raid leaders.

The Problem
In the Midnight expansion (v12.0), Blizzard moved significant parts of the unit frame logic into protected "C-Side" code. Traditional methods to disable range-fading now trigger "Secret Value" errors or Taint, which can block players from using abilities in combat.

The Solution: "The Defender" Logic
This addon uses an OnUpdate Restoration approach. It allows the game engine to perform its check but immediately "defends" the frame's visibility:

Reactive Restoration: Every 0.05 to 0.1 seconds, the addon scans active frames and forces SetAlpha(1).

Stability First: By avoiding direct function hooks on protected Blizzard methods (like UpdateInRange), this addon ensures zero Lua errors and total combat safety.

Midnight Frame Discovery: Specifically targets RaidGroupButton and CompactPartyFrameMember structures unique to the modern client.

Technical Limitations & "The Flicker"
Because this addon operates in a sandboxed environment, users may notice a minor flicker when a player moves in or out of range.

Why it happens: Blizzard's engine fades the frame faster than Lua can respond. There is a micro-second gap between Blizzard fading the frame and this addon making it visible again.

Why we don't "Fix" it: Attempting to intercept the fade at the engine level (via SetAlpha overrides) causes the frame's range data to become a "Secret Value," leading to catastrophic UI errors.

The Tradeoff: This addon prioritizes a functional, error-free UI over a perfectly static one.

Installation
Download the latest release.

Extract the NoBlizzRangeFade folder into your World of Warcraft/_retail_/Interface/AddOns directory.

Restart World of Warcraft.
