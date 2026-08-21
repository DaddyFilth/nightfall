import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

type PackageScripts = { scripts?: Record<string, string> };

const packageJson = JSON.parse(readFileSync(resolve(process.cwd(), "package.json"), "utf8")) as PackageScripts;

describe("device connection scripts", () => {
  it("keeps a LAN route for same-network Expo Go testing", () => {
    expect(packageJson.scripts?.["dev:lan"]).toContain("expo start --lan");
    expect(packageJson.scripts?.["dev:lan"]).toContain("--port");
  });

  it("keeps a tunnel route for networks that cannot reach Metro directly", () => {
    expect(packageJson.scripts?.["dev:tunnel"]).toContain("expo start --tunnel");
    expect(packageJson.scripts?.["dev:tunnel"]).toContain("--port");
  });
});
