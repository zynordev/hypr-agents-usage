import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

RippleButton {
    id: root
    property bool vertical: Config.options.bar.vertical
    property bool isMaterial: Config.options.bar.cornerStyle === 3
    property bool mirrored: false

    implicitWidth: 26
    implicitHeight: 26

    buttonRadius: Appearance.rounding.full
    colBackground: isMaterial ? Appearance.colors.colPrimaryContainer : (popup.isOpen ? Appearance.colors.colLayer1Active : "transparent")
    colBackgroundHover: isMaterial ? Appearance.colors.colPrimaryContainerHover : Appearance.colors.colLayer1Hover
    colRipple: Appearance.colors.colLayer1Active
    colBackgroundToggled: Appearance.colors.colSecondaryContainer
    colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
    colRippleToggled: Appearance.colors.colSecondaryContainerActive
    toggled: popup.isOpen

    onPressed: {
        popup.isOpen = !popup.isOpen;
        if (popup.isOpen) {
            AgentsUsage.refresh();
        }
    }

    Item {
        anchors.centerIn: parent
        width: 20
        height: 20

        MaterialSymbol {
            anchors.centerIn: parent
            iconSize: 18
            text: "neurology"
            color: popup.isOpen ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer0
        }

        // Tiny status dot (green if all ok, red if error)
        Rectangle {
            anchors {
                bottom: parent.bottom
                right: parent.right
                bottomMargin: 0
                rightMargin: 0
            }
            width: 5
            height: 5
            radius: 2.5
            color: (AgentsUsage.ready && AgentsUsage.claudeInfo.ok && AgentsUsage.codexInfo.ok && AgentsUsage.antigravityInfo.ok) ? "#4ade80" : Appearance.colors.colPrimary
        }
    }

    AgentsUsagePopup {
        id: popup
        targetItem: root
    }
}
