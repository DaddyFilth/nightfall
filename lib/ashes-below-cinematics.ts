export type CinematicScene = {
  checkpoint: number;
  timestamp: string;
  chapter: string;
  headline: string;
  context: string;
  transmission: string;
  color: string;
};

export const ashesBelowCinematics: CinematicScene[] = [
  {
    checkpoint: 0,
    timestamp: "ECLIPSE − 72 MINUTES",
    chapter: "TIMELINE // EVENT 01",
    headline: "THE CITY LOOKED UP TOO LATE.",
    context: "At 22:14, a violet corona fixed itself above Nocturne. The municipal rail grid began answering to a frequency no engineer could trace. The bloodlines sealed the surface gates; the station was left beneath the false moon.",
    transmission: "DUSKSTALKER: Find the first relay. If it is listening, it can be made to speak.",
    color: "#8E5CFF",
  },
  {
    checkpoint: 2,
    timestamp: "ECLIPSE + 13 MINUTES",
    chapter: "TIMELINE // EVENT 02",
    headline: "THE MAINTENANCE SPINE BECAME A NERVE.",
    context: "The signal does not travel through cable; it travels through the city’s shared memory. Every failed relay has awakened another Hollowed cluster below the platforms. The foundry access lift is still powered, but something has claimed its controls.",
    transmission: "ARCHIVIST ORA: The Wraith is not guarding the lift. It is carrying an instruction set.",
    color: "#3DE6E6",
  },
  {
    checkpoint: 3,
    timestamp: "ECLIPSE + 24 MINUTES",
    chapter: "TIMELINE // EVENT 03",
    headline: "THE ENGINE LEARNED OUR NAMES.",
    context: "The Blood Wraith dissolved into the furnace vents and left a route into the engine core. The Conductor has copied every emergency protocol the city ever used. It now predicts evacuation, containment, and fear with the same precision.",
    transmission: "ARCHIVIST ORA: Break its rail controls. Do not let it finish the final timetable.",
    color: "#D93056",
  },
];

export function cinematicForCheckpoint(checkpoint: number): CinematicScene | undefined {
  return ashesBelowCinematics.find((scene) => scene.checkpoint === checkpoint);
}

