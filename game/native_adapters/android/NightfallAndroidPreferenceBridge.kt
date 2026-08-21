// Contract source for a future Godot Android Plugin v2 module. Not compiled by this repository.
// Canonical build-ready source lives in plugin/src/main/kotlin/space/manus/nightfall/bridge.
// This compact copy remains as the platform contract reference beside the original adapter docs.
package space.manus.nightfall.bridge

import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot
import java.io.File

class NightfallAndroidPreferenceBridge(godot: Godot) : GodotPlugin(godot) {
    override fun getPluginName() = "NightfallAndroidPreferenceBridge"

    @UsedByGodot
    fun read_approved_payload(): String {
        // The signed host integration must copy a validated Expo payload to this app-owned directory.
        val file = File(godot.activity.filesDir, "nightfall-bridge/expo-preferences.v1.json")
        return if (file.isFile && file.length() <= 16_384L) file.readText(Charsets.UTF_8) else ""
    }
}
