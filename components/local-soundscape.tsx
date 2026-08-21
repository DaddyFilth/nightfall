import { useCallback, useEffect, useRef } from "react";
import { createAudioPlayer, setAudioModeAsync, useAudioPlayer } from "expo-audio";

import { useGame } from "@/lib/game-session";

type SoundscapeScene = "command" | "campaign";
type InterfaceCue = "select" | "deploy" | "locked";

const soundscapes = {
  command: require("../assets/audio/brasswake-command-ambience.mp3"),
  campaign: require("../assets/audio/drowned-chart-campaign-ambience.mp3"),
} as const;

const interfaceSources = {
  select: require("../assets/audio/ui-command-select.wav"),
  deploy: require("../assets/audio/ui-deploy-confirm.wav"),
  locked: require("../assets/audio/ui-route-locked.wav"),
} as const;

export function AmbientSoundscape({ scene }: { scene: SoundscapeScene }) {
  const { settings } = useGame();
  const player = useAudioPlayer(soundscapes[scene]);

  useEffect(() => {
    setAudioModeAsync({ playsInSilentMode: true }).catch(() => undefined);
  }, []);

  useEffect(() => {
    player.loop = true;
    player.volume = settings.ambientMusic ? settings.musicVolume / 100 : 0;
    if (settings.ambientMusic) player.play();
    else player.pause();
  }, [player, settings.ambientMusic, settings.musicVolume]);

  useEffect(() => () => player.pause(), [player]);
  return null;
}

export function useInterfaceSfx() {
  const { settings } = useGame();
  const players = useRef<Partial<Record<InterfaceCue, ReturnType<typeof createAudioPlayer>>>>({});

  useEffect(() => {
    setAudioModeAsync({ playsInSilentMode: true }).catch(() => undefined);
    const created = Object.fromEntries(
      (Object.keys(interfaceSources) as InterfaceCue[]).map((cue) => {
        const player = createAudioPlayer(interfaceSources[cue]);
        player.volume = 0.48;
        return [cue, player];
      }),
    ) as Record<InterfaceCue, ReturnType<typeof createAudioPlayer>>;
    players.current = created;
    return () => {
      Object.values(created).forEach((player) => player.remove());
      players.current = {};
    };
  }, []);

  const play = useCallback((cue: InterfaceCue) => {
    if (!settings.interfaceSounds) return;
    const player = players.current[cue];
    if (!player) return;
    player.seekTo(0);
    player.play();
  }, [settings.interfaceSounds]);

  return { play };
}
