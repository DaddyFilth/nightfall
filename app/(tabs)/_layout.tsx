import MaterialIcons from "@expo/vector-icons/MaterialIcons";
import { Tabs } from "expo-router";
import { Platform } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

const icon = (name: React.ComponentProps<typeof MaterialIcons>["name"]) => ({ color, size }: { color: string; size: number }) => <MaterialIcons name={name} color={color} size={size} />;

export default function TabLayout() {
  const insets = useSafeAreaInsets();
  const bottomPadding = Platform.OS === "web" ? 8 : Math.max(insets.bottom, 5);
  return <Tabs screenOptions={{
    headerShown: false,
    tabBarActiveTintColor: "#BFE6D7",
    tabBarInactiveTintColor: "#978B79",
    tabBarActiveBackgroundColor: "#1C2B28",
    tabBarStyle: { height: 62 + bottomPadding, paddingBottom: bottomPadding, paddingTop: 5, backgroundColor: "#0F0C0A", borderTopColor: "#70532B", borderTopWidth: 1, shadowColor: "#000000", shadowOpacity: 0.55, shadowOffset: { width: 0, height: -4 }, shadowRadius: 10 },
    tabBarItemStyle: { maxWidth: 174, borderRadius: 9, marginHorizontal: 3 },
    tabBarLabelStyle: { fontWeight: "900", fontSize: 10, letterSpacing: 0.5 },
  }}>
    <Tabs.Screen name="index" options={{ title: "COMMAND", tabBarIcon: icon("home") }} />
    <Tabs.Screen name="hunt" options={{ title: "DEPLOY", tabBarIcon: icon("gps-fixed") }} />
    <Tabs.Screen name="modes" options={{ title: "MODES", tabBarIcon: icon("sports-esports") }} />
    <Tabs.Screen name="campaign" options={{ title: "STORY", tabBarIcon: icon("auto-stories") }} />
    <Tabs.Screen name="arsenal" options={{ title: "LOADOUT", tabBarIcon: icon("bolt") }} />
    <Tabs.Screen name="profile" options={{ title: "CAPTAIN", tabBarIcon: icon("person") }} />
  </Tabs>;
}
