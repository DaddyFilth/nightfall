import { useEffect, useRef } from "react";
import { Animated, StyleSheet, View } from "react-native";

const sprayDrops = [{ left: 40 }, { left: 92 }, { left: 252 }, { left: 302 }];

export function BrasswakeAtmosphere({ compact = false }: { compact?: boolean }) {
  const fogDrift = useRef(new Animated.Value(0)).current;
  const fogRise = useRef(new Animated.Value(0)).current;
  const sailSway = useRef(new Animated.Value(0)).current;
  const sprayLift = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    const loop = (value: Animated.Value, duration: number) => Animated.loop(Animated.sequence([Animated.timing(value, { toValue: 1, duration, useNativeDriver: true }), Animated.timing(value, { toValue: 0, duration, useNativeDriver: true })]));
    const animations = [loop(fogDrift, 4200), loop(fogRise, 3600), loop(sailSway, 3000), loop(sprayLift, 1700)];
    animations.forEach((animation) => animation.start());
    return () => animations.forEach((animation) => animation.stop());
  }, [fogDrift, fogRise, sailSway, sprayLift]);
  const sailRotate = sailSway.interpolate({ inputRange: [0, 1], outputRange: ["-3deg", "3deg"] });
  const fogX = fogDrift.interpolate({ inputRange: [0, 1], outputRange: [-16, 20] });
  const fogY = fogRise.interpolate({ inputRange: [0, 1], outputRange: [4, -9] });
  const sprayY = sprayLift.interpolate({ inputRange: [0, 1], outputRange: [10, -18] });
  return <View pointerEvents="none" style={styles.layer}><Animated.View style={[styles.sail, compact && styles.sailCompact, { transform: [{ rotate: sailRotate }] }]} /><Animated.View style={[styles.fog, styles.fogLeft, { transform: [{ translateX: fogX }, { translateY: fogY }] }]} /><Animated.View style={[styles.fog, styles.fogRight, { transform: [{ translateX: Animated.multiply(fogX, -0.7) }, { translateY: Animated.multiply(fogY, 0.55) }] }]} />{sprayDrops.map((drop) => <Animated.View key={drop.left} style={[styles.spray, { left: drop.left, opacity: sprayLift.interpolate({ inputRange: [0, 0.55, 1], outputRange: [0, 0.75, 0] }), transform: [{ translateY: sprayY }] }]} />)}</View>;
}

const styles = StyleSheet.create({ layer: { ...StyleSheet.absoluteFillObject, overflow: "hidden" }, sail: { position: "absolute", right: -38, top: -30, width: 116, height: 166, borderLeftWidth: 18, borderLeftColor: "#110C09B8", borderBottomWidth: 112, borderBottomColor: "#110C09B8", transformOrigin: "bottom" }, sailCompact: { right: -56, top: -56, transform: [{ scale: 0.7 }] }, fog: { position: "absolute", width: 190, height: 60, borderRadius: 70, backgroundColor: "#75B7A41F" }, fogLeft: { bottom: -16, left: -34 }, fogRight: { top: 34, right: -62, opacity: 0.66 }, spray: { position: "absolute", bottom: 21, width: 4, height: 12, borderRadius: 6, backgroundColor: "#CDE9DBB8" } });
