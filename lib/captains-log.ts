export type CaptainLogEntry = {
  checkpoint: number;
  deck: string;
  title: string;
  transcript: string;
};

export const captainsLogEntries: CaptainLogEntry[] = [
  { checkpoint: 0, deck: "FIRST BELL", title: "BRASSWAKE ARRIVAL", transcript: "Brasswake Harbor lies beneath a dead eclipse. The drowned fleet has opened its lanterns, and every brass compass on the deck points toward the same black tide. We make harbor before the bell answers again." },
  { checkpoint: 2, deck: "LOW TIDE", title: "DOCKYARD DESCENT", transcript: "The dockyards breathe through their iron ribs. Sea fog crosses the deck without wind, and the privateers below are not asleep. Keep the wheel-lock dry, keep the blade close, and follow the bells into the under-harbor." },
  { checkpoint: 3, deck: "LAST LANTERN", title: "THE DROWNED ADMIRAL", transcript: "The Drowned Admiral waits inside the astrolabe chamber. His sails are made of night, but his course can still be broken. When the brass rings turn, strike through the eclipse, then carry the crew home by the light we kept." },
];

export const captainLogForCheckpoint = (checkpoint: number) => captainsLogEntries.find((entry) => entry.checkpoint === checkpoint);
