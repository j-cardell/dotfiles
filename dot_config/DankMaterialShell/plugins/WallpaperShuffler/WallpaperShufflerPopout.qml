import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

DankPopout {
    id: root

    property var triggerScreen: null
    property string wallpaperPath: ""
    property string currentWallpaper: ""
    property string nextWallpaper: ""

    function setTriggerPosition(x, y, width, section, screen, folderPath, current, next) {
        triggerX = x;
        triggerY = y;
        triggerWidth = width;
        triggerSection = section;
        triggerScreen = screen;
        wallpaperPath = folderPath;
        currentWallpaper = current;
        nextWallpaper = next;
    }

    popupWidth: 420
    popupHeight: Math.min(Screen.height - 100, 580)
    triggerX: Screen.width - 440 - Theme.spacingL
    triggerY: Theme.barHeight - 4 + SettingsData.dankBarSpacing
    triggerWidth: 30
    positioning: ""
    screen: triggerScreen
    shouldBeVisible: false
    visible: shouldBeVisible

    content: Component {
        Rectangle {
            id: content

            implicitHeight: contentColumn.height + Theme.spacingL * 2
            color: Theme.popupBackground()
            radius: Theme.cornerRadius
            border.color: Theme.outlineMedium
            border.width: 0
            antialiasing: true
            smooth: true
            focus: true
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.close();
                    event.accepted = true;
                }
            }

            // Outer subtle shadow rings
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                color: "transparent"
                radius: parent.radius + 3
                border.color: Qt.rgba(0, 0, 0, 0.05)
                border.width: 0
                z: -3
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                color: "transparent"
                radius: parent.radius + 2
                border.color: Theme.shadowMedium
                border.width: 0
                z: -2
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Theme.outlineStrong
                border.width: 0
                radius: parent.radius
                z: -1
            }

            Column {
                id: contentColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                // Header
                Item {
                    width: parent.width
                    height: 32

                    StyledText {
                        text: I18n.tr("Wallpaper Shuffler")
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Close button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: closeArea.containsMouse ? Theme.errorHover : "transparent"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

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
                            onPressed: root.close()
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
                            height: 200
                            radius: Theme.cornerRadius
                            color: Theme.surfaceLight
                            border.color: Theme.outlineLight
                            border.width: 1
                            clip: true

                            CachingImage {
                                id: currentImage
                                anchors.fill: parent
                                source: root.currentWallpaper ? "file://" + root.currentWallpaper : ""
                                fillMode: Image.PreserveAspectCrop
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
                            height: 150
                            radius: Theme.cornerRadius
                            color: Theme.surfaceLight
                            border.color: Theme.outlineLight
                            border.width: 1
                            clip: true

                            CachingImage {
                                id: nextImage
                                anchors.fill: parent
                                source: root.nextWallpaper ? "file://" + root.nextWallpaper : ""
                                fillMode: Image.PreserveAspectCrop
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
    }
}
