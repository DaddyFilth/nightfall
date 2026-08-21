export type HunterId = "duskstalker" | "crimson-vanguard" | "graveweaver" | "lumenfallen";
export type Difficulty = "Initiate" | "Nightmare" | "Eclipse";
export type MatchIntent = "blood_hunt" | "campaign";

export type Hunter = { id: HunterId; name: string; role: string; initials: string; accent: string; passive: string; tactical: string; movement: string; ultimate: string; counterplay: string };
export type Weapon = { name: string; class: string; cadence: string; note: string };

export const hunters: Hunter[] = [
  { id: "duskstalker", name: "Bloodwake Captain", role: "Vampire cutlass duelist", initials: "BC", accent: "#B68A39", passive: "Close-range eliminations briefly restore vitality.", tactical: "Mistwake — vanish through sea fog with a readable ripple.", movement: "Rigging Leap — a sharp targeted deck-to-deck dash.", ultimate: "Black Tide — darkens a dockside zone and reveals footsteps.", counterplay: "Sun-lantern damage disrupts the veil." },
  { id: "crimson-vanguard", name: "Red Marauder", role: "Blood-armored boarder", initials: "RM", accent: "#8D2634", passive: "Sustained damage produces temporary resilience.", tactical: "Blood Bulwark — a directional crimson deck shield.", movement: "Boarding Charge — a knockback rush.", ultimate: "Keelbreaker — melee frenzy with recovery on elimination.", counterplay: "Vulnerable to flanks and ability baiting." },
  { id: "graveweaver", name: "Tide Hexer", role: "Cursed-water controller", initials: "TH", accent: "#4A877A", passive: "Fresh blood trails stay visible to the hunter.", tactical: "Bone Net — a breakable slow and mark trap.", movement: "Salt Mist — quick movement while weapons are sheathed.", ultimate: "Drowned Chapel — spectral walls and temporary shades.", counterplay: "Traps and walls can be destroyed." },
  { id: "lumenfallen", name: "Brass Corsair", role: "Clockwork sharpshooter", initials: "BC", accent: "#C7973A", passive: "Precision hits build Eclipse Charge.", tactical: "Helios Brand — marks a target for self-only focus damage.", movement: "Sailburst — a directional aerial launch.", ultimate: "Eclipse Harpoon — a visible charged beam.", counterplay: "Requires line of sight and a readable charge-up." },
];

export const weapons: Weapon[] = [
  { name: "Brasswake Wheel-Lock", class: "Burst sidearm", cadence: "3-round burst", note: "Accurate, reliable, and balanced." },
  { name: "Galleon Repeater", class: "Close automatic", cadence: "Rapid", note: "Stable along tight deck corridors." },
  { name: "Catacomb Blunderbuss", class: "Scatter weapon", cadence: "Measured", note: "High impact at boarding range." },
  { name: "Astral Harpoon", class: "Precision launcher", cadence: "Semi-auto", note: "Rewards deliberate shots." },
  { name: "Bloodwake Cutlass", class: "Melee", cadence: "Lunge", note: "Fast close-pressure tool." },
];
export const arenas = ["Brasswake Dockyards", "Drowned Cathedral", "Eclipse Galleonworks"] as const;
export const difficultyConfig: Record<Difficulty, { target: number; enemyHit: number; label: string }> = { Initiate: { target: 5, enemyHit: 5, label: "Measured pressure" }, Nightmare: { target: 7, enemyHit: 8, label: "Aggressive pursuit" }, Eclipse: { target: 9, enemyHit: 11, label: "Relentless eclipse" } };
export function hunterFor(id: HunterId) { return hunters.find((hunter) => hunter.id === id) ?? hunters[0]; }
