import { describe, expect, it } from "vitest";
import { modeById, multiplayerModes } from "../lib/multiplayer-modes";

describe("multiplayer mode catalog", () => {
  it("defines free-for-all, team deathmatch, and capture the flag", () => {
    expect(multiplayerModes.map((mode) => mode.id)).toEqual(["free_for_all", "team_deathmatch", "capture_the_flag"]);
  });

  it("gives team modes explicit team counts and objectives", () => {
    expect(modeById("team_deathmatch").teams).toBe(2);
    expect(modeById("capture_the_flag").scoreLimit).toBe(3);
  });
});
