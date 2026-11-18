import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root
    property bool vertical: Config.options.bar.vertical
    property bool isMaterial: Config.options.bar.cornerStyle === 3
    property bool mirrored: false

    implicitWidth: 32
    implicitHeight: 30

    Rectangle {
        id: buttonBg
        anchors.centerIn: parent
        width: 28
        height: 28
        radius: Appearance.rounding.full
        color: popup.isOpen
            ? Appearance.colors.colPrimary
            : (mouseArea.containsMouse ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer1Base)
        border.width: 1
        border.color: popup.isOpen ? Appearance.colors.colPrimary : Appearance.colors.colLayer0Border

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        MaterialSymbol {
            anchors.centerIn: parent
            iconSize: 18
            text: "neurology"
            color: popup.isOpen
                ? Appearance.colors.colOnPrimary
                : (mouseArea.containsMouse ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer0)
        }

        // Live status dot (green if all providers ok)
        Rectangle {
            anchors {
                bottom: parent.bottom
                right: parent.right
                bottomMargin: 2
                rightMargin: 2
            }
            width: 7
            height: 7
            radius: 3.5
            color: (AgentsUsage.ready && AgentsUsage.claudeInfo.ok && AgentsUsage.codexInfo.ok && AgentsUsage.antigravityInfo.ok)
                ? "#4ade80"
                : Appearance.colors.colPrimary
            border.width: 1
            border.color: Appearance.colors.colLayer0
        }
    }

    PopupToolTip {
        text: "AI Ajan Limitleri"
        anchorEdges: Edges.Top
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            popup.isOpen = !popup.isOpen;
            if (popup.isOpen) {
                AgentsUsage.refresh();
            }
        }
    }

    AgentsUsagePopup {
        id: popup
        targetItem: root
    }
}
