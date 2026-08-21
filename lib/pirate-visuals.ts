import type { ImageSourcePropType } from "react-native";

export const pirateVisuals: Record<"captain" | "dockyards" | "conductor" | "heraldry", ImageSourcePropType> = {
  captain: require("../assets/images/campaign/bloodwake-captain-portrait-bundled.png"),
  dockyards: require("../assets/images/campaign/brasswake-dockyards-bundled.png"),
  conductor: require("../assets/images/campaign/conductor-drowned-admiral-bundled.png"),
  heraldry: require("../assets/images/campaign/bloodwake-heraldry-bundled.png"),
};
