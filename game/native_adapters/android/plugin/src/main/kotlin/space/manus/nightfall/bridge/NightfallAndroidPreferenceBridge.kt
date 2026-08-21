package space.manus.nightfall.bridge

import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot
import java.io.File

/** Read-only bridge from a signed host's app-owned handoff location to Godot. */
class NightfallAndroidPreferenceBridge(godot: Godot) : GodotPlugin(godot) {
    override fun getPluginName(): String = SINGLETON_NAME

    @UsedByGodot
    fun read_approved_payload(): String {
        val filesDir = getActivity()?.filesDir ?: return ""
        val approvedDirectory = File(filesDir, APPROVED_DIRECTORY).canonicalFile
        val candidate = File(approvedDirectory, APPROVED_FILENAME).canonicalFile
        if (candidate.parentFile?.path != approvedDirectory.path || !candidate.isFile) return ""
        if (candidate.length() !in 1..MAX_PAYLOAD_BYTES) return ""
        return try {
            candidate.readText(Charsets.UTF_8)
        } catch (_: SecurityException) {
            ""
        } catch (_: java.io.IOException) {
            ""
        }
    }

    private companion object {
        const val SINGLETON_NAME = "NightfallAndroidPreferenceBridge"
        const val APPROVED_DIRECTORY = "nightfall-bridge"
        const val APPROVED_FILENAME = "expo-preferences.v1.json"
        const val MAX_PAYLOAD_BYTES = 16_384L
    }
}
