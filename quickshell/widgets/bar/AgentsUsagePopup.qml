pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

LazyLoader {
    id: root
    property Item targetItem
    property bool isOpen: false

    active: isOpen

    readonly property bool barVertical: Config.options.bar.vertical
    readonly property string barEdge: {
        if (!barVertical) return Config.options.bar.bottom ? "bottom" : "top"
        return Config.options.bar.bottom ? "right" : "left"
    }
    readonly property real barThickness: barVertical ? Appearance.sizes.verticalBarWidth : Appearance.sizes.barHeight

    component: PanelWindow {
        id: popupWindow

        color: "transparent"
        anchors.left: true
        anchors.top: true

        implicitWidth: 390 + Appearance.sizes.elevationMargin * 2
        implicitHeight: Math.min(600, popupContent.implicitHeight + 28) + Appearance.sizes.elevationMargin * 2

        readonly property real centerOffsetX: {
            if (!root.targetItem) return 100;
            const mapped = root.targetItem.QsWindow?.mapFromItem(root.targetItem, 0, 0);
            const targetX = mapped ? mapped.x : 1500;
            const margin = Appearance.sizes.elevationMargin;
            const w = 390;
            // Align right edge of popup with targetItem
            const idealX = targetX + root.targetItem.width - w;
            return Math.max(margin, Math.min(idealX, popupWindow.screen.width - w - margin - 10));
        }

        readonly property real centerOffsetY: {
            if (!root.targetItem) return 100;
            const margin = Appearance.sizes.elevationMargin;
            const h = popupWindow.implicitHeight;
            // Position above the bottom bar
            return Math.max(margin, popupWindow.screen.height - h - root.barThickness - 6);
        }

        mask: Region {
            item: bgRect
        }
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        margins {
            left: popupWindow.centerOffsetX
            top: popupWindow.centerOffsetY
        }

        WlrLayershell.namespace: "quickshell:popup"
        WlrLayershell.layer: WlrLayer.Overlay

        property int activeTab: 0 // 0: Limitler, 1: Tokenlar

        function toneColor(used) {
            if (used === null || used === undefined) return Appearance.colors.colOutline;
            if (used >= 85) return Appearance.m3colors.m3error || "#ff5449";
            if (used >= 60) return Appearance.m3colors.m3tertiary || "#e5a000";
            return Appearance.colors.colPrimary;
        }

        StyledRectangularShadow {
            target: bgRect
        }

        Rectangle {
            id: bgRect
            anchors.fill: parent
            anchors.margins: Appearance.sizes.elevationMargin
            radius: Appearance.rounding.windowRounding
            color: Appearance.colors.colLayer0
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            clip: true

            ColumnLayout {
                id: popupContent
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                // Header Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MaterialShapeWrappedMaterialSymbol {
                        shape: MaterialShape.Shape.Cookie12Sided
                        text: "neurology"
                        iconSize: 20
                        implicitSize: 34
                        color: Appearance.colors.colPrimaryContainer
                        colSymbol: Appearance.colors.colPrimary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: -2
                        StyledText {
                            text: "AI Ajan Limitleri"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnLayer0
                        }
                        StyledText {
                            text: AgentsUsage.lastUpdated ? ("Son güncelleme: " + AgentsUsage.lastUpdated) : "Yükleniyor..."
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: Appearance.colors.colOnSurfaceVariant
                            opacity: 0.7
                        }
                    }

                    // Refresh Button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: Appearance.rounding.full
                        color: refreshArea.containsMouse ? Appearance.colors.colLayer1Hover : "transparent"

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "refresh"
                            iconSize: 18
                            color: Appearance.colors.colPrimary

                            RotationAnimation on rotation {
                                running: AgentsUsage.loading || AgentsUsage.loadingTokens
                                from: 0
                                to: 360
                                duration: 800
                                loops: Animation.Infinite
                            }
                        }

                        MouseArea {
                            id: refreshArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                AgentsUsage.refresh();
                                AgentsUsage.refreshTokenStats();
                            }
                        }
                    }

                    // Close Button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: Appearance.rounding.full
                        color: closeArea.containsMouse ? Appearance.colors.colLayer1Hover : "transparent"

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "close"
                            iconSize: 16
                            color: Appearance.colors.colOnSurfaceVariant
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.isOpen = false
                        }
                    }
                }

                // Tab Buttons
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: Appearance.rounding.full
                    color: Appearance.colors.colLayer1Base

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Appearance.rounding.full
                            color: popupWindow.activeTab === 0 ? Appearance.colors.colPrimary : "transparent"

                            StyledText {
                                anchors.centerIn: parent
                                text: "Limitler"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: popupWindow.activeTab === 0 ? Font.Bold : Font.Normal
                                color: popupWindow.activeTab === 0 ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSurfaceVariant
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popupWindow.activeTab = 0
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Appearance.rounding.full
                            color: popupWindow.activeTab === 1 ? Appearance.colors.colPrimary : "transparent"

                            StyledText {
                                anchors.centerIn: parent
                                text: "Tokenlar & Maliyet"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: popupWindow.activeTab === 1 ? Font.Bold : Font.Normal
                                color: popupWindow.activeTab === 1 ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSurfaceVariant
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    popupWindow.activeTab = 1;
                                    if (!AgentsUsage.tokenData) AgentsUsage.refreshTokenStats();
                                }
                            }
                        }
                    }
                }

                // Scrollable Content
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 440
                    contentHeight: mainStack.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        width: 4
                        policy: ScrollBar.AsNeeded
                    }

                    Item {
                        id: mainStack
                        width: parent.width
                        implicitHeight: popupWindow.activeTab === 0 ? limitsTabContent.implicitHeight : tokensTabContent.implicitHeight

                        // ==========================================
                        // TAB 1: LIMITLER
                        // ==========================================
                        ColumnLayout {
                            id: limitsTabContent
                            width: parent.width
                            visible: popupWindow.activeTab === 0
                            spacing: 12

                            // --- CLAUDE CARD ---
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: claudeCol.implicitHeight + 20
                                radius: Appearance.rounding.normal
                                color: Appearance.colors.colLayer1Base
                                border.width: 1
                                border.color: Appearance.colors.colLayer0Border

                                ColumnLayout {
                                id: claudeCol
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                    margins: 10
                                }
                                spacing: 8

                                // Title Row
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    MaterialSymbol {
                                        text: "psychology"
                                        iconSize: 18
                                        color: Appearance.colors.colPrimary
                                    }
                                    StyledText {
                                        text: "Claude Code"
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    Rectangle {
                                        implicitWidth: planText.implicitWidth + 10
                                        implicitHeight: 18
                                        radius: 4
                                        color: Appearance.colors.colPrimaryContainer
                                        StyledText {
                                            id: planText
                                            anchors.centerIn: parent
                                            text: AgentsUsage.claudeInfo.plan || "Pro"
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                            color: Appearance.colors.colPrimary
                                        }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: AgentsUsage.claudeInfo.ok ? "#4ade80" : "#f87171"
                                    }
                                }

                                // 5-Hour Limit
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    RowLayout {
                                        Layout.fillWidth: true
                                        StyledText {
                                            text: "5 Saatlik Oturum"
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }
                                        Item { Layout.fillWidth: true }
                                        StyledText {
                                            text: `%${AgentsUsage.claudeInfo.sessionPercent} kullanıldı`
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.DemiBold
                                            color: popupWindow.toneColor(AgentsUsage.claudeInfo.sessionPercent)
                                        }
                                    }
                                    ProgressBar {
                                        Layout.fillWidth: true
                                        implicitHeight: 6
                                        value: (AgentsUsage.claudeInfo.sessionPercent || 0) / 100
                                        background: Rectangle {
                                            radius: 3
                                            color: Appearance.colors.colLayer2
                                        }
                                        contentItem: Item {
                                            Rectangle {
                                                width: parent.width * parent.parent.visualPosition
                                                height: parent.height
                                                radius: 3
                                                color: popupWindow.toneColor(AgentsUsage.claudeInfo.sessionPercent)
                                            }
                                        }
                                    }
                                    StyledText {
                                        visible: AgentsUsage.claudeInfo.sessionReset !== ""
                                        text: "Sıfırlanma: " + AgentsUsage.formatTimeRemaining(AgentsUsage.claudeInfo.sessionReset)
                                        font.pixelSize: 10
                                        color: Appearance.colors.colOnSurfaceVariant
                                        opacity: 0.6
                                    }
                                }

                                // Weekly Limit
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    RowLayout {
                                        Layout.fillWidth: true
                                        StyledText {
                                            text: "Haftalık Limit"
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }
                                        Item { Layout.fillWidth: true }
                                        StyledText {
                                            text: `%${AgentsUsage.claudeInfo.weeklyPercent} kullanıldı`
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.DemiBold
                                            color: popupWindow.toneColor(AgentsUsage.claudeInfo.weeklyPercent)
                                        }
                                    }
                                    ProgressBar {
                                        Layout.fillWidth: true
                                        implicitHeight: 6
                                        value: (AgentsUsage.claudeInfo.weeklyPercent || 0) / 100
                                        background: Rectangle {
                                            radius: 3
                                            color: Appearance.colors.colLayer2
                                        }
                                        contentItem: Item {
                                            Rectangle {
                                                width: parent.width * parent.parent.visualPosition
                                                height: parent.height
                                                radius: 3
                                                color: popupWindow.toneColor(AgentsUsage.claudeInfo.weeklyPercent)
                                            }
                                        }
                                    }
                                    StyledText {
                                        visible: AgentsUsage.claudeInfo.weeklyReset !== ""
                                        text: "Sıfırlanma: " + AgentsUsage.formatTimeRemaining(AgentsUsage.claudeInfo.weeklyReset)
                                        font.pixelSize: 10
                                        color: Appearance.colors.colOnSurfaceVariant
                                        opacity: 0.6
                                    }
                                }
                            }
                        }

                        // --- CODEX CARD ---
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: codexCol.implicitHeight + 20
                            radius: Appearance.rounding.normal
                            color: Appearance.colors.colLayer1Base
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border

                            ColumnLayout {
                                id: codexCol
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                    margins: 10
                                }
                                spacing: 8

                                // Title Row
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    MaterialSymbol {
                                        text: "terminal"
                                        iconSize: 18
                                        color: Appearance.colors.colSecondary
                                    }
                                    StyledText {
                                        text: "OpenAI Codex"
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    Rectangle {
                                        implicitWidth: codexPlanText.implicitWidth + 10
                                        implicitHeight: 18
                                        radius: 4
                                        color: Appearance.colors.colSecondaryContainer
                                        StyledText {
                                            id: codexPlanText
                                            anchors.centerIn: parent
                                            text: AgentsUsage.codexInfo.plan || "Plus"
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                            color: Appearance.colors.colSecondary
                                        }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: AgentsUsage.codexInfo.ok ? "#4ade80" : "#f87171"
                                    }
                                }

                                // Weekly Limit
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    RowLayout {
                                        Layout.fillWidth: true
                                        StyledText {
                                            text: "Haftalık Limit"
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }
                                        Item { Layout.fillWidth: true }
                                        StyledText {
                                            text: `%${AgentsUsage.codexInfo.weeklyPercent} kullanıldı`
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.DemiBold
                                            color: popupWindow.toneColor(AgentsUsage.codexInfo.weeklyPercent)
                                        }
                                    }
                                    ProgressBar {
                                        Layout.fillWidth: true
                                        implicitHeight: 6
                                        value: (AgentsUsage.codexInfo.weeklyPercent || 0) / 100
                                        background: Rectangle {
                                            radius: 3
                                            color: Appearance.colors.colLayer2
                                        }
                                        contentItem: Item {
                                            Rectangle {
                                                width: parent.width * parent.parent.visualPosition
                                                height: parent.height
                                                radius: 3
                                                color: popupWindow.toneColor(AgentsUsage.codexInfo.weeklyPercent)
                                            }
                                        }
                                    }
                                    StyledText {
                                        visible: AgentsUsage.codexInfo.weeklyReset !== ""
                                        text: "Sıfırlanma: " + AgentsUsage.formatTimeRemaining(AgentsUsage.codexInfo.weeklyReset)
                                        font.pixelSize: 10
                                        color: Appearance.colors.colOnSurfaceVariant
                                        opacity: 0.6
                                    }
                                }
                            }
                        }

                        // --- ANTIGRAVITY CARD ---
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: agCol.implicitHeight + 20
                            radius: Appearance.rounding.normal
                            color: Appearance.colors.colLayer1Base
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border

                            ColumnLayout {
                                id: agCol
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                    margins: 10
                                }
                                spacing: 8

                                // Title Row
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    MaterialSymbol {
                                        text: "spark"
                                        iconSize: 18
                                        color: Appearance.colors.colTertiary
                                    }
                                    StyledText {
                                        text: "Antigravity"
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    Rectangle {
                                        implicitWidth: agPlanText.implicitWidth + 10
                                        implicitHeight: 18
                                        radius: 4
                                        color: Appearance.colors.colTertiaryContainer
                                        StyledText {
                                            id: agPlanText
                                            anchors.centerIn: parent
                                            text: AgentsUsage.antigravityInfo.plan || "Pro"
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                            color: Appearance.colors.colTertiary
                                        }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: AgentsUsage.antigravityInfo.ok ? "#4ade80" : "#f87171"
                                    }
                                }

                                // Gemini Weekly
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    RowLayout {
                                        Layout.fillWidth: true
                                        StyledText {
                                            text: "Gemini Modelleri (Haftalık)"
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }
                                        Item { Layout.fillWidth: true }
                                        StyledText {
                                            text: `%${AgentsUsage.antigravityInfo.geminiWeekly} kullanıldı`
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.DemiBold
                                            color: popupWindow.toneColor(AgentsUsage.antigravityInfo.geminiWeekly)
                                        }
                                    }
                                    ProgressBar {
                                        Layout.fillWidth: true
                                        implicitHeight: 6
                                        value: (AgentsUsage.antigravityInfo.geminiWeekly || 0) / 100
                                        background: Rectangle {
                                            radius: 3
                                            color: Appearance.colors.colLayer2
                                        }
                                        contentItem: Item {
                                            Rectangle {
                                                width: parent.width * parent.parent.visualPosition
                                                height: parent.height
                                                radius: 3
                                                color: popupWindow.toneColor(AgentsUsage.antigravityInfo.geminiWeekly)
                                            }
                                        }
                                    }
                                    StyledText {
                                        visible: AgentsUsage.antigravityInfo.geminiWeeklyReset !== ""
                                        text: "Sıfırlanma: " + AgentsUsage.formatTimeRemaining(AgentsUsage.antigravityInfo.geminiWeeklyReset)
                                        font.pixelSize: 10
                                        color: Appearance.colors.colOnSurfaceVariant
                                        opacity: 0.6
                                    }
                                }

                                // Gemini 5-Hour
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    RowLayout {
                                        Layout.fillWidth: true
                                        StyledText {
                                            text: "Gemini Modelleri (5 Saatlik)"
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }
                                        Item { Layout.fillWidth: true }
                                        StyledText {
                                            text: `%${AgentsUsage.antigravityInfo.geminiSession} kullanıldı`
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.DemiBold
                                            color: popupWindow.toneColor(AgentsUsage.antigravityInfo.geminiSession)
                                        }
                                    }
                                    ProgressBar {
                                        Layout.fillWidth: true
                                        implicitHeight: 6
                                        value: (AgentsUsage.antigravityInfo.geminiSession || 0) / 100
                                        background: Rectangle {
                                            radius: 3
                                            color: Appearance.colors.colLayer2
                                        }
                                        contentItem: Item {
                                            Rectangle {
                                                width: parent.width * parent.parent.visualPosition
                                                height: parent.height
                                                radius: 3
                                                color: popupWindow.toneColor(AgentsUsage.antigravityInfo.geminiSession)
                                            }
                                        }
                                    }
                                }

                                // Claude & GPT Models
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    RowLayout {
                                        Layout.fillWidth: true
                                        StyledText {
                                            text: "Claude & GPT Modelleri"
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }
                                        Item { Layout.fillWidth: true }
                                        StyledText {
                                            text: `%${AgentsUsage.antigravityInfo.claudeWeekly} kullanıldı`
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.DemiBold
                                            color: popupWindow.toneColor(AgentsUsage.antigravityInfo.claudeWeekly)
                                        }
                                    }
                                    ProgressBar {
                                        Layout.fillWidth: true
                                        implicitHeight: 6
                                        value: (AgentsUsage.antigravityInfo.claudeWeekly || 0) / 100
                                        background: Rectangle {
                                            radius: 3
                                            color: Appearance.colors.colLayer2
                                        }
                                        contentItem: Item {
                                            Rectangle {
                                                width: parent.width * parent.parent.visualPosition
                                                height: parent.height
                                                radius: 3
                                                color: popupWindow.toneColor(AgentsUsage.antigravityInfo.claudeWeekly)
                                            }
                                        }
                                    }
                                }

                                // Gemini 4 Argon
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    RowLayout {
                                        Layout.fillWidth: true
                                        StyledText {
                                            text: "Gemini 4 Argon"
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }
                                        Item { Layout.fillWidth: true }
                                        StyledText {
                                            text: `%${AgentsUsage.antigravityInfo.argonWeekly} kullanıldı`
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.DemiBold
                                            color: popupWindow.toneColor(AgentsUsage.antigravityInfo.argonWeekly)
                                        }
                                    }
                                    ProgressBar {
                                        Layout.fillWidth: true
                                        implicitHeight: 6
                                        value: (AgentsUsage.antigravityInfo.argonWeekly || 0) / 100
                                        background: Rectangle {
                                            radius: 3
                                            color: Appearance.colors.colLayer2
                                        }
                                        contentItem: Item {
                                            Rectangle {
                                                width: parent.width * parent.parent.visualPosition
                                                height: parent.height
                                                radius: 3
                                                color: popupWindow.toneColor(AgentsUsage.antigravityInfo.argonWeekly)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ==========================================
                    // TAB 2: TOKENLAR & MALIYET
                    // ==========================================
                    ColumnLayout {
                        id: tokensTabContent
                        width: parent.width
                        visible: popupWindow.activeTab === 1
                        spacing: 12

                        readonly property var currentPeriodData: AgentsUsage.tokenData?.periods?.[AgentsUsage.selectedPeriod]

                        // Period Pills
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Repeater {
                                model: [
                                    { label: "1 Gün", key: "1" },
                                    { label: "7 Gün", key: "7" },
                                    { label: "30 Gün", key: "30" },
                                    { label: "1 Yıl", key: "365" }
                                ]
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 26
                                    radius: Appearance.rounding.full
                                    color: AgentsUsage.selectedPeriod === modelData.key ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer1Base
                                    border.width: 1
                                    border.color: AgentsUsage.selectedPeriod === modelData.key ? Appearance.colors.colPrimary : Appearance.colors.colLayer0Border

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        font.pixelSize: Appearance.font.pixelSize.smallest
                                        font.weight: AgentsUsage.selectedPeriod === modelData.key ? Font.Bold : Font.Normal
                                        color: AgentsUsage.selectedPeriod === modelData.key ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: AgentsUsage.selectedPeriod = modelData.key
                                    }
                                }
                            }
                        }

                        // Summary Cards (Claude & Codex)
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            // Claude Summary
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 70
                                radius: Appearance.rounding.normal
                                color: Appearance.colors.colLayer1Base
                                border.width: 1
                                border.color: Appearance.colors.colLayer0Border

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    StyledText {
                                        text: "Claude"
                                        font.pixelSize: Appearance.font.pixelSize.smallest
                                        color: Appearance.colors.colPrimary
                                        font.weight: Font.Bold
                                    }
                                    StyledText {
                                        text: AgentsUsage.formatCost(tokensTabContent.currentPeriodData?.cost?.claude)
                                        font.pixelSize: Appearance.font.pixelSize.large
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: AgentsUsage.formatTokenCount(tokensTabContent.currentPeriodData?.claude) + " token"
                                        font.pixelSize: Appearance.font.pixelSize.smallest
                                        color: Appearance.colors.colOnSurfaceVariant
                                    }
                                }
                            }

                            // Codex Summary
                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 70
                                radius: Appearance.rounding.normal
                                color: Appearance.colors.colLayer1Base
                                border.width: 1
                                border.color: Appearance.colors.colLayer0Border

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    StyledText {
                                        text: "Codex"
                                        font.pixelSize: Appearance.font.pixelSize.smallest
                                        color: Appearance.colors.colSecondary
                                        font.weight: Font.Bold
                                    }
                                    StyledText {
                                        text: AgentsUsage.formatCost(tokensTabContent.currentPeriodData?.cost?.codex)
                                        font.pixelSize: Appearance.font.pixelSize.large
                                        font.weight: Font.Bold
                                        color: Appearance.colors.colOnLayer0
                                    }
                                    StyledText {
                                        text: AgentsUsage.formatTokenCount(tokensTabContent.currentPeriodData?.codex) + " token"
                                        font.pixelSize: Appearance.font.pixelSize.smallest
                                        color: Appearance.colors.colOnSurfaceVariant
                                    }
                                }
                            }
                        }

                        // Models Breakdown List
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            StyledText {
                                text: "Model Bazında Kullanım"
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnLayer0
                                opacity: 0.8
                            }

                            Repeater {
                                model: tokensTabContent.currentPeriodData?.models || []
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 36
                                    radius: Appearance.rounding.small
                                    color: Appearance.colors.colLayer1Base

                                    RowLayout {
                                        anchors {
                                            fill: parent
                                            leftMargin: 8
                                            rightMargin: 8
                                        }
                                        spacing: 6

                                        MaterialSymbol {
                                            text: modelData.provider === "claude" ? "psychology" : "terminal"
                                            iconSize: 14
                                            color: modelData.provider === "claude" ? Appearance.colors.colPrimary : Appearance.colors.colSecondary
                                        }

                                        StyledText {
                                            text: modelData.name
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.Medium
                                            color: Appearance.colors.colOnLayer0
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        StyledText {
                                            text: AgentsUsage.formatTokenCount(modelData.total)
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                        }

                                        StyledText {
                                            text: AgentsUsage.formatCost(modelData.cost)
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            font.weight: Font.Bold
                                            color: Appearance.colors.colOnLayer0
                                        }
                                    }
                                }
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: "Yerel Claude Code ve Codex günlüklerinden hesaplanır; liste API fiyatları baz alınmıştır."
                            font.pixelSize: 9
                            color: Appearance.colors.colOnSurfaceVariant
                            opacity: 0.6
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }
}
}
