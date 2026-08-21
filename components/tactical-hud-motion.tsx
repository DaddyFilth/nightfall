import { Animated, StyleSheet, View } from "react-native";
import { useEffect, useRef } from "react";

export function TacticalHudMotion({ reducedMotion = false }: { reducedMotion?: boolean }) {
  const scan = useRef(new Animated.Value(0)).current;
  const pulse = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    if (reducedMotion) { scan.setValue(0.45); pulse.setValue(0.55); return; }
    const scanLoop = Animated.loop(Animated.sequence([Animated.timing(scan, { toValue: 1, duration: 4400, useNativeDriver: true }), Animated.timing(scan, { toValue: 0, duration: 4400, useNativeDriver: true })]));
    const pulseLoop = Animated.loop(Animated.sequence([Animated.timing(pulse, { toValue: 1, duration: 1800, useNativeDriver: true }), Animated.timing(pulse, { toValue: 0, duration: 1800, useNativeDriver: true })]));
    scanLoop.start(); pulseLoop.start();
    return () => { scanLoop.stop(); pulseLoop.stop(); };
  }, [pulse, reducedMotion, scan]);
  const scanX = scan.interpolate({ inputRange: [0, 1], outputRange: [-110, 520] });
  const dotOpacity = pulse.interpolate({ inputRange: [0, 0.5, 1], outputRange: [0.24, 0.84, 0.24] });
  return <View pointerEvents="none" style={styles.layer}><Animated.View style={[styles.scan, { transform: [{ translateX: scanX }] }]} /><View style={styles.bracketLeft} /><View style={styles.bracketRight} /><Animated.View style={[styles.signalDot, { opacity: dotOpacity }]} /><Animated.View style={[styles.signalLine, { opacity: dotOpacity }]} /></View>;
}

const styles = StyleSheet.create({ layer: { ...StyleSheet.absoluteFillObject, overflow: "hidden" }, scan: { position: "absolute", top: 0, bottom: 0, width: 2, backgroundColor: "#E7CB6370", shadowColor: "#E7CB63", shadowOpacity: 0.8, shadowRadius: 10 }, bracketLeft: { position: "absolute", top: 16, left: 16, width: 33, height: 24, borderTopWidth: 1, borderLeftWidth: 1, borderColor: "#C7973A99" }, bracketRight: { position: "absolute", right: 16, bottom: 16, width: 33, height: 24, borderRightWidth: 1, borderBottomWidth: 1, borderColor: "#4A877AAA" }, signalDot: { position: "absolute", top: 23, right: 31, width: 6, height: 6, borderRadius: 3, backgroundColor: "#4A877A" }, signalLine: { position: "absolute", top: 25, right: 42, width: 44, height: 1, backgroundColor: "#4A877A" } });
