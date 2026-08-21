import { useEffect } from "react";
import { Platform } from "react-native";
import { Stack } from "expo-router";
import { StatusBar } from "expo-status-bar";
import * as ScreenOrientation from "expo-screen-orientation";

import { ThemeProvider } from "@/lib/theme-provider";
import { GameProvider } from "@/lib/game-session";
import { ResourcePackProvider } from "@/lib/resource-packs";

function LandscapeSessionLock() {
  useEffect(() => {
    if (Platform.OS === "web") return;
    const keepLandscape = () => { void ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.LANDSCAPE).catch(() => undefined); };
    keepLandscape();
    const subscription = ScreenOrientation.addOrientationChangeListener(keepLandscape);
    return () => subscription.remove();
  }, []);
  return null;
}

export default function RootLayout() {
  return <ThemeProvider><GameProvider><ResourcePackProvider><LandscapeSessionLock /><StatusBar style="light" hidden /><Stack screenOptions={{ headerShown: false }}><Stack.Screen name="(tabs)" /><Stack.Screen name="mission-two" /><Stack.Screen name="observatory" /><Stack.Screen name="controls" /><Stack.Screen name="demo" /><Stack.Screen name="play-game" /><Stack.Screen name="content-packs" /><Stack.Screen name="harbor-gallery" /></Stack></ResourcePackProvider></GameProvider></ThemeProvider>;
}
