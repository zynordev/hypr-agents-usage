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

    property real widgetWidth: 420
    property real cardSpacing: 12
    property real cardHeight: 120
    property real cardWidth: (widgetWidth - cardSpacing * 2) / 3
    property bool isVertical: root.configEntry.vertical ?? false

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    component StatCard: Rectangle {
        id: statCard
        property string icon: ""
        property string value: ""
        property string label: ""
        property string sublabel: ""
        property int shape: MaterialShape.Shape.Cookie12Sided
        property color bgColor: Appearance.colors.colPrimaryContainer
        property color shapeColor: Appearance.colors.colPrimary

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
                margins: 14
            }
            spacing: -4

            MaterialShapeWrappedMaterialSymbol {
                Layout.alignment: Qt.AlignRight
                shape: statCard.shape
                color: statCard.shapeColor
                colSymbol: Appearance.colors.colOnPrimary
                text: statCard.icon
                iconSize: 18
                fill: 1
                padding: 6
                implicitWidth: 34
                implicitHeight: 34
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

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onDoubleClicked: {
                AgentsUsage.refresh();
            }
        }
    }

    Grid {
        id: row
        columns: root.isVertical ? 1 : 3
        rows: root.isVertical ? 3 : 1
        spacing: root.cardSpacing

        Behavior on columns {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        StatCard {
            icon: "psychology"
            value: AgentsUsage.ready ? (AgentsUsage.claudeUsed + "%") : "..."
            label: "Claude"
            sublabel: AgentsUsage.ready ? (AgentsUsage.claudeInfo.sessionPercent + "% 5s") : ""
            shape: MaterialShape.Shape.Gem
            bgColor: Appearance.colors.colPrimaryContainer
            shapeColor: Appearance.colors.colPrimary
        }
        StatCard {
            icon: "terminal"
            value: AgentsUsage.ready ? (AgentsUsage.codexUsed + "%") : "..."
            label: "Codex"
            sublabel: AgentsUsage.ready && AgentsUsage.codexInfo.sessionPercent !== null ? (AgentsUsage.codexInfo.sessionPercent + "% 5s") : ""
            shape: MaterialShape.Shape.Cookie4Sided
            bgColor: Appearance.colors.colSecondaryContainer
            shapeColor: Appearance.colors.colSecondary
        }
        StatCard {
            icon: "spark"
            value: AgentsUsage.ready ? (AgentsUsage.antigravityUsed + "%") : "..."
            label: "Antigravity"
            sublabel: AgentsUsage.ready ? (AgentsUsage.antigravityInfo.geminiSession + "% 5s") : ""
            shape: MaterialShape.Shape.Cookie12Sided
            bgColor: Appearance.colors.colTertiaryContainer
            shapeColor: Appearance.colors.colTertiary
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
