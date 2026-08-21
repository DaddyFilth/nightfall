export const TACTICAL_TUTORIAL_KEY = "nightfall.tactical_tutorial.v1";
export const TACTICAL_TUTORIAL_STEP_COUNT = 3;

export function shouldShowTacticalTutorial(storedValue: string | null): boolean {
  return storedValue !== "completed";
}

export function nextTacticalTutorialStep(currentStep: number): number | null {
  const safeStep = Math.max(0, Math.floor(currentStep));
  return safeStep + 1 >= TACTICAL_TUTORIAL_STEP_COUNT ? null : safeStep + 1;
}
