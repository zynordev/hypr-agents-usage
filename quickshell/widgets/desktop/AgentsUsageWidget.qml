import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "agentsUsage"
    hoverEnabled: true

    property real widgetWidth: 440
    property real cardSpacing: 12
    property real cardHeight: 120
    property real cardWidth: (widgetWidth - cardSpacing * 2) / 3
    property bool isVertical: root.configEntry.vertical ?? false

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    component StatCard: Rectangle {
        id: statCard
        property string icon: ""
        property string customIcon: ""
        property string value: ""
        property string label: ""
        property string sublabel: ""
        property int shape: MaterialShape.Shape.Cookie12Sided
        property color bgColor: Appearance.colors.colPrimaryContainer
        property color shapeColor: Appearance.colors.colPrimary
        property color iconColor: Appearance.colors.colOnPrimary

        implicitWidth: root.cardWidth
        implicitHeight: root.cardHeight
        radius: Appearance.rounding?.verylarge ?? 30
        color: statCard.bgColor

        StyledRectangularShadow {
            target: statCard
            z: -2
            visible: Config.options.background.widgets.shadow
        }

        FastBlurred {
            anchors.fill: parent
            blurSource: root.wallpaperItem
            cardRadius: statCard.radius
            tint: Appearance.colors.colLayer1
            tintOpacity: 0.55
            trackX: statCard.x + root.x
            trackY: statCard.y + root.y
            visible: Config.options.background.widgets.blurWidgets 
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 12
            }
            spacing: -4

            MaterialShape {
                Layout.alignment: Qt.AlignRight
                shape: statCard.shape
                color: statCard.shapeColor
                implicitSize: 32

                CustomIcon {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: statCard.customIcon
                    colorize: true
                    color: statCard.iconColor
                    visible: statCard.customIcon !== ""
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    color: statCard.iconColor
                    text: statCard.icon
                    iconSize: 18
                    fill: 1
                    visible: statCard.customIcon === ""
                }
            }

            Item { Layout.fillHeight: true }

            StyledText {
                text: statCard.value
                font.pixelSize: Appearance.font.pixelSize.hugeass
                font.weight: Font.Bold
                color: Appearance.colors.colOnPrimaryContainer
            }

            RowLayout {
                spacing: 4
                StyledText {
                    text: statCard.label
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnPrimaryContainer
                    opacity: 0.8
                }
                StyledText {
                    text: statCard.sublabel
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnPrimaryContainer
                    opacity: 0.5
                    visible: statCard.sublabel !== ""
                }
            }
        }
    }

    onClicked: (mouse) => {
        if (mouse.button === Qt.RightButton) {
            Config.options.background.widgetsLocked = !Config.options.background.widgetsLocked
        } else if (mouse.modifiers & Qt.ControlModifier) {
            root.selected = !root.selected
        } else {
            var canvas = findCanvas(root.parent)
            if (canvas) canvas.clearSelection()
            root.selected = true
            AgentsUsage.refresh()
        }
    }

    Grid {
        id: row
        columns: root.isVertical ? 1 : 3
        rows: root.isVertical ? 3 : 1
        spacing: root.cardSpacing
        opacity: AgentsUsage.loading ? 0.75 : 1.0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        Behavior on columns {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        // 1. Claude Card
        StatCard {
            customIcon: "claude-symbolic.svg"
            value: AgentsUsage.ready ? (AgentsUsage.claudeUsed + "%") : "..."
            label: "Claude"
            sublabel: AgentsUsage.ready ? (AgentsUsage.claudeInfo.sessionPercent + "% 5s") : ""
            shape: MaterialShape.Shape.Gem
            bgColor: Appearance.colors.colPrimaryContainer
            shapeColor: Appearance.colors.colPrimary
            iconColor: Appearance.colors.colOnPrimary
        }

        // 2. Codex Card
        StatCard {
            customIcon: "openai-symbolic.svg"
            value: AgentsUsage.ready ? (AgentsUsage.codexUsed + "%") : "..."
            label: "Codex"
            sublabel: AgentsUsage.ready && AgentsUsage.codexInfo.sessionPercent !== null ? (AgentsUsage.codexInfo.sessionPercent + "% 5s") : ""
            shape: MaterialShape.Shape.Cookie4Sided
            bgColor: Appearance.colors.colSecondaryContainer
            shapeColor: Appearance.colors.colSecondary
            iconColor: Appearance.colors.colOnSecondary
        }

        // 3. Antigravity Card (Kendisi 3 yatay çizgiye ve hemen sağında %'ye dönüşen kutu)
        Rectangle {
            id: agCard
            implicitWidth: root.cardWidth
            implicitHeight: root.cardHeight
            radius: Appearance.rounding?.verylarge ?? 30
            color: Appearance.colors.colTertiaryContainer
            clip: true

            StyledRectangularShadow {
                target: agCard
                z: -2
                visible: Config.options.background.widgets.shadow
            }

            FastBlurred {
                anchors.fill: parent
                blurSource: root.wallpaperItem
                cardRadius: agCard.radius
                tint: Appearance.colors.colLayer1
                tintOpacity: 0.55
                trackX: agCard.x + root.x
                trackY: agCard.y + root.y
                visible: Config.options.background.widgets.blurWidgets 
            }

            ColumnLayout {
                anchors {
                    fill: parent
                    topMargin: 8
                    bottomMargin: 8
                    leftMargin: 11
                    rightMargin: 11
                }
                spacing: 2

                // Header Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    StyledText {
                        text: "Antigravity"
                        font.pixelSize: Appearance.font.pixelSize.smaller ?? 11
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnTertiaryContainer
                    }

                    Item { Layout.fillWidth: true }

                    MaterialShape {
                        shape: MaterialShape.Shape.Cookie12Sided
                        color: Appearance.colors.colTertiary
                        implicitSize: 20

                        CustomIcon {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            source: "antigravity-symbolic.svg"
                            colorize: true
                            color: Appearance.colors.colOnTertiary
                        }
                    }
                }

                // Line 1: Gemini Models
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: "Gemini Models"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnTertiaryContainer
                        opacity: 0.75
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        // Yatay Çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 4
                            radius: 2
                            color: ColorUtils.transparentize(Appearance.colors.colTertiary, 0.75)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.max(parent.width * (Math.min(100, Math.max(0, AgentsUsage.antigravityInfo.geminiWeekly ?? 0)) / 100), (AgentsUsage.antigravityInfo.geminiWeekly ?? 0) > 0 ? 3 : 0)
                                radius: 2
                                color: Appearance.colors.colTertiary
                            }
                        }

                        // Çizginin hemen sağında %
                        StyledText {
                            text: `${AgentsUsage.antigravityInfo.geminiWeekly ?? 0}%`
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnTertiaryContainer
                        }
                    }
                }

                // Line 2: Claude / ChatGPT
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: "Claude/ChatGPT"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnTertiaryContainer
                        opacity: 0.75
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        // Yatay Çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 4
                            radius: 2
                            color: ColorUtils.transparentize(Appearance.colors.colTertiary, 0.75)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.max(parent.width * (Math.min(100, Math.max(0, AgentsUsage.antigravityInfo.claudeWeekly ?? 0)) / 100), (AgentsUsage.antigravityInfo.claudeWeekly ?? 0) > 0 ? 3 : 0)
                                radius: 2
                                color: Appearance.colors.colTertiary
                            }
                        }

                        // Çizginin hemen sağında %
                        StyledText {
                            text: `${AgentsUsage.antigravityInfo.claudeWeekly ?? 0}%`
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnTertiaryContainer
                        }
                    }
                }

                // Line 3: Argon
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: "Argon"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnTertiaryContainer
                        opacity: 0.75
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        // Yatay Çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 4
                            radius: 2
                            color: ColorUtils.transparentize(Appearance.colors.colTertiary, 0.75)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.max(parent.width * (Math.min(100, Math.max(0, AgentsUsage.antigravityInfo.argonWeekly ?? 0)) / 100), (AgentsUsage.antigravityInfo.argonWeekly ?? 0) > 0 ? 3 : 0)
                                radius: 2
                                color: Appearance.colors.colTertiary
                            }
                        }

                        // Çizginin hemen sağında %
                        StyledText {
                            text: `${AgentsUsage.antigravityInfo.argonWeekly ?? 0}%`
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnTertiaryContainer
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: toggleHandle
        width: 16
        height: 16
        radius: 6
        color: Appearance.colors.colOnPrimaryContainer
        anchors {
            left: parent.right
            bottom: parent.bottom
            margins: -6
        }
        opacity: root.containsMouse || toggleArea.containsMouse ? 0.7 : 0
        visible: opacity > 0 && !Config.options.background.widgetsLocked

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        MaterialSymbol {
            anchors.centerIn: parent
            text: "rotate_right"
            iconSize: 11
            color: Appearance.colors.colPrimaryContainer

            RotationAnimation on rotation {
                running: toggleArea.containsMouse
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }

        MouseArea {
            id: toggleArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.isVertical = !root.isVertical
                root.configEntry.vertical = root.isVertical
            }
        }
    }
}
