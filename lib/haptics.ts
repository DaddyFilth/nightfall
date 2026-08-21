import { Platform } from "react-native";
import * as Haptics from "expo-haptics";
const canVibrate = Platform.OS !== "web";
export const haptic = {
  light: () => canVibrate && Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light),
  medium: () => canVibrate && Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium),
  heavy: () => canVibrate && Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy),
  success: () => canVibrate && Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success),
  selection: () => canVibrate && Haptics.selectionAsync(),
};

