import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent{
    id: root
    
    // Expand tilde to home directory
    function expandPath(path) {
        if (path.startsWith("~/")) {
            return Quickshell.env("HOME") + path.substring(1);
        }
        return path;
    }
    
    // Reactive binding that updates whenever pluginData.wallpaperPath changes
    property string wallpaperPath: {
        var path = pluginData.wallpaperPath || "~/Pictures";
        return expandPath(path);
    }
    property int shuffleInterval: (pluginData.shuffleInterval || 1800) * 1000
    property string scriptPath: Qt.resolvedUrl("shuffle-wallpapers").toString().replace("file://", "")

    Component.onCompleted: {
        console.log("=== Wallpaper Shuffler Plugin Started ===");
        console.log("Wallpaper Path:", root.wallpaperPath);
        console.log("Shuffle Interval:", root.shuffleInterval, "ms");
        console.log("Script Path:", root.scriptPath);
        
        // Immediately restore the current wallpaper from shuffle state to prevent
        // system wallpaper daemon from taking over on boot
        restoreCurrentWallpaperProcess.running = true;
    }

    Process {
        id: shuffleProcess
        command: []
        running: false

        onRunningChanged: {
            console.log("Process running:", running);
            if (!running) {
                console.log("Wallpaper shuffled successfully");
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            console.log("Process exited with code:", exitCode);
        }
    }

    // Process to restore current wallpaper on startup (before timer fires)
    Process {
        id: restoreCurrentWallpaperProcess
        command: ["bash", "-c", 
            `WALLPAPER_DIR="${root.wallpaperPath}"
            SHUFFLE_FILE="$WALLPAPER_DIR/.dms-wallpaper-shuffler/wallpaper_shuffle_list"
            CURRENT_INDEX_FILE="$WALLPAPER_DIR/.dms-wallpaper-shuffler/wallpaper_current_index"
            
            # Check if shuffle state exists
            if [ -f "$SHUFFLE_FILE" ] && [ -f "$CURRENT_INDEX_FILE" ]; then
                current_index=$(cat "$CURRENT_INDEX_FILE")
                current_wallpaper=$(sed -n "${current_index}p" "$SHUFFLE_FILE")
                if [ -n "$current_wallpaper" ] && [ -f "$current_wallpaper" ]; then
                    echo "Restoring wallpaper: $current_wallpaper" >&2
                    dms ipc call wallpaper set "$current_wallpaper"
                else
                    echo "No valid wallpaper to restore" >&2
                fi
            else
                echo "No shuffle state found, will create on first timer trigger" >&2
            fi`
        ]
        running: false
        
        onExited: exitCode => {
            console.log("Wallpaper restoration completed with code:", exitCode);
        }
    }

    Timer {
        interval: root.shuffleInterval
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            console.log("Timer triggered - starting shuffle process");
            console.log("Using wallpaper path:", root.wallpaperPath);
            // Set command right before running to ensure it uses the current wallpaperPath value
            shuffleProcess.command = ["bash", root.scriptPath, root.wallpaperPath];
            shuffleProcess.running = true;
        }
    }
}
