import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // Expand tilde to home directory
    function expandPath(path) {
        if (path.startsWith("~/")) {
            return Quickshell.env("HOME") + path.substring(1);
        }
        return path;
    }

    property string wallpaperPath: {
        var path = pluginData.wallpaperPath || "~/Pictures";
        return expandPath(path);
    }

    property string shuffleInfoPath: wallpaperPath + "/.dms-wallpaper-shuffler"
    property string currentWallpaper: ""
    property string nextWallpaper: ""
    property int currentIndex: 0
    property int totalWallpapers: 0
    property int shuffleInterval: (pluginData.shuffleInterval || 1800) * 1000
    property string scriptPath: Qt.resolvedUrl("shuffle-wallpapers").toString().replace("file://", "")
    property string getWallpaperScriptPath: Qt.resolvedUrl("get-current-wallpaper").toString().replace("file://", "")

    popoutWidth: 420
    popoutHeight: 690

    // Invisible preloader images - keep thumbnails cached for instant display
    Item {
        visible: false
        Image {
            id: currentPreloader
            source: root.currentWallpaper ? "file://" + root.currentWallpaper : ""
            sourceSize.width: 800
            sourceSize.height: 450
            asynchronous: true
            cache: true
        }
        Image {
            id: nextPreloader
            source: root.nextWallpaper ? "file://" + root.nextWallpaper : ""
            sourceSize.width: 800
            sourceSize.height: 450
            asynchronous: true
            cache: true
        }
    }

    popoutContent: Component {
        Column {
            width: parent.width
            spacing: Theme.spacingM

            // Header with close button
            Item {
                width: parent.width
                height: 40

                StyledText {
                    text: I18n.tr("Wallpaper Shuffler")
                    font.pixelSize: Theme.fontSizeLarge + 4
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: closeArea.containsMouse ? Theme.errorHover : "transparent"

                    DankIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: Theme.iconSize - 4
                        color: closeArea.containsMouse ? Theme.error : Theme.surfaceText
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: {
                            if (closePopout) {
                                closePopout();
                            }
                        }
                    }
                }
            }

            // Folder path section
            Rectangle {
                width: parent.width
                height: pathColumn.height + Theme.spacingM * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, Theme.getContentBackgroundAlpha() * 0.6)
                border.width: 0

                Column {
                    id: pathColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingXS

                    Row {
                        spacing: Theme.spacingXS
                        width: parent.width

                        DankIcon {
                            name: "folder"
                            size: Theme.iconSize - 4
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: I18n.tr("Shuffle Folder")
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        text: root.wallpaperPath || "~/Pictures"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        width: parent.width
                        elide: Text.ElideMiddle
                    }
                }
            }

            // Current wallpaper section
            Rectangle {
                width: parent.width
                height: currentColumn.height + Theme.spacingM * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, Theme.getContentBackgroundAlpha() * 0.6)
                border.width: 0

                Column {
                    id: currentColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingS

                    Row {
                        spacing: Theme.spacingXS
                        width: parent.width

                        DankIcon {
                            name: "image"
                            size: Theme.iconSize - 4
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: I18n.tr("Current Wallpaper")
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Current wallpaper preview
                    Rectangle {
                        width: parent.width
                        height: 180
                        radius: Theme.cornerRadius
                        color: Theme.surfaceLight
                        border.color: Theme.outlineLight
                        border.width: 1
                        clip: true

                        CachingImage {
                            id: currentImage
                            anchors.fill: parent
                            source: root.currentWallpaper ? "file://" + root.currentWallpaper : ""
                            sourceSize.width: 800
                            sourceSize.height: 450
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true
                            visible: root.currentWallpaper !== ""

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Theme.outlineLight
                                border.width: 1
                                radius: Theme.cornerRadius
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacingS
                            visible: !root.currentWallpaper

                            DankIcon {
                                name: "broken_image"
                                size: 48
                                color: Theme.surfaceVariantText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledText {
                                text: I18n.tr("No wallpaper set")
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceVariantText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    StyledText {
                        text: root.currentWallpaper ? root.currentWallpaper.split('/').pop() : I18n.tr("None")
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        width: parent.width
                        elide: Text.ElideMiddle
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Next wallpaper section
            Rectangle {
                width: parent.width
                height: nextColumn.height + Theme.spacingM * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, Theme.getContentBackgroundAlpha() * 0.6)
                border.width: 0

                Column {
                    id: nextColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingS

                    Row {
                        spacing: Theme.spacingXS
                        width: parent.width

                        DankIcon {
                            name: "skip_next"
                            size: Theme.iconSize - 4
                            color: Theme.secondary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: I18n.tr("Next Wallpaper")
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Next wallpaper preview
                    Rectangle {
                        width: parent.width
                        height: 180
                        radius: Theme.cornerRadius
                        color: Theme.surfaceLight
                        border.color: Theme.outlineLight
                        border.width: 1
                        clip: true

                        CachingImage {
                            id: nextImage
                            anchors.fill: parent
                            source: root.nextWallpaper ? "file://" + root.nextWallpaper : ""
                            sourceSize.width: 800
                            sourceSize.height: 450
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true
                            visible: root.nextWallpaper !== ""

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Theme.outlineLight
                                border.width: 1
                                radius: Theme.cornerRadius
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacingS
                            visible: !root.nextWallpaper

                            DankIcon {
                                name: "image_not_supported"
                                size: 40
                                color: Theme.surfaceVariantText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledText {
                                text: I18n.tr("No next wallpaper")
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceVariantText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    StyledText {
                        text: root.nextWallpaper ? root.nextWallpaper.split('/').pop() : I18n.tr("None")
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        width: parent.width
                        elide: Text.ElideMiddle
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("=== Wallpaper Shuffler Widget Started ===");
        console.log("Plugin Data:", JSON.stringify(pluginData));
        console.log("Wallpaper Path (configured):", pluginData.wallpaperPath);
        console.log("Wallpaper Path (expanded):", root.wallpaperPath);
        console.log("Shuffle Interval:", root.shuffleInterval, "ms");
        console.log("Shuffle Script Path:", root.scriptPath);
        console.log("Get Wallpaper Script Path:", root.getWallpaperScriptPath);
        
        // Immediately restore the current wallpaper from shuffle state to prevent
        // system wallpaper daemon from taking over on boot
        restoreCurrentWallpaperProcess.running = true;
    }

    // Read wallpaper info
    Process {
        id: wallpaperInfoProcess
        command: ["bash", root.getWallpaperScriptPath, root.wallpaperPath]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim();
                const lines = output.split('\n');
                if (lines.length >= 4) {
                    currentWallpaper = lines[0] || "";
                    nextWallpaper = lines[1] || "";
                    currentIndex = parseInt(lines[2]) || 0;
                    totalWallpapers = parseInt(lines[3]) || 0;
                    console.log("Wallpaper info updated:", currentIndex, "/", totalWallpapers);
                    console.log("Current:", currentWallpaper);
                    console.log("Next:", nextWallpaper);
                } else {
                    console.log("get-current-wallpaper returned invalid data:", output);
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                console.log("get-current-wallpaper script failed, exit code:", exitCode);
            }
        }
    }

    // Shuffle wallpaper process
    Process {
        id: shuffleProcess
        command: []
        running: false

        onRunningChanged: {
            console.log("Shuffle process running:", running);
            if (!running) {
                console.log("Wallpaper shuffled successfully");
                // Update wallpaper info after shuffling
                wallpaperInfoProcess.running = true;
            }
        }

        onExited: (exitCode, exitStatus) => {
            console.log("Shuffle process exited with code:", exitCode);
        }
    }

    // Timer to shuffle wallpapers
    Timer {
        interval: root.shuffleInterval
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            console.log("Timer triggered - starting shuffle process");
            console.log("Using wallpaper path:", root.wallpaperPath);
            shuffleProcess.command = ["bash", root.scriptPath, root.wallpaperPath];
            shuffleProcess.running = true;
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
            // Now update the widget info
            wallpaperInfoProcess.running = true;
        }
    }

    // Update wallpaper info periodically
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wallpaperInfoProcess.running = true
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS
            rightPadding: Theme.spacingXS

            StyledText {
                text: "󰸉 "
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: root.showCounter
                text: root.totalWallpapers > 0 ? `${root.currentIndex}/${root.totalWallpapers}` : "--"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            StyledText {
                text: "󰸉 "
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: root.showCounter
                text: root.totalWallpapers > 0 ? `${root.currentIndex}/${root.totalWallpapers}` : "--"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
