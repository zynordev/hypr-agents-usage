pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string scriptPath: "/home/halil/kde-agents-usage/package/contents/code/fetch_usage.py"
    readonly property string tokenScriptPath: "/home/halil/kde-agents-usage/package/contents/code/token_stats.py"

    property bool ready: false
    property bool loading: false
    property string lastUpdated: ""
    property var rawData: null
    property var providers: []

    // Primary % used (0 - 100)
    property real claudeUsed: 0
    property real codexUsed: 0
    property real antigravityUsed: 0

    // Detailed states
    property var claudeInfo: ({
        ok: false,
        plan: "Pro",
        sessionPercent: 0,
        weeklyPercent: 0,
        sessionReset: "",
        weeklyReset: "",
        error: ""
    })

    property var codexInfo: ({
        ok: false,
        plan: "Plus",
        sessionPercent: null,
        weeklyPercent: 0,
        sessionReset: "",
        weeklyReset: "",
        error: ""
    })

    property var antigravityInfo: ({
        ok: false,
        plan: "Pro",
        geminiWeekly: 0,
        geminiSession: 0,
        claudeWeekly: 0,
        claudeSession: 0,
        argonWeekly: 0,
        geminiSessionReset: "",
        geminiWeeklyReset: "",
        claudeSessionReset: "",
        claudeWeeklyReset: "",
        argonWeeklyReset: "",
        error: ""
    })

    // Token Stats
    property var tokenData: null
    property bool loadingTokens: false
    property string selectedPeriod: "30"

    function formatTimeRemaining(isoString) {
        if (!isoString) return "";
        try {
            var target = new Date(isoString);
            var now = new Date();
            var diffMs = target.getTime() - now.getTime();
            if (diffMs <= 0) return "Süresi doldu";
            var diffSec = Math.floor(diffMs / 1000);
            var days = Math.floor(diffSec / 86400);
            var hours = Math.floor((diffSec % 86400) / 3600);
            var mins = Math.floor((diffSec % 3600) / 60);
            if (days > 1) {
                var dayNames = ["Paz", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"];
                var hoursStr = String(target.getHours()).padStart(2, "0");
                var minsStr = String(target.getMinutes()).padStart(2, "0");
                return dayNames[target.getDay()] + " " + hoursStr + ":" + minsStr;
            }
            if (days === 1) {
                return "1g " + hours + "s";
            }
            if (hours > 0) {
                return hours + "s " + mins + "dk";
            }
            return mins + "dk";
        } catch (e) {
            return "";
        }
    }

    function formatTokenCount(num) {
        if (!num || isNaN(num)) return "0";
        if (num >= 1000000000) return (num / 1000000000).toFixed(1) + "B";
        if (num >= 1000000) return (num / 1000000).toFixed(1) + "M";
        if (num >= 1000) return (num / 1000).toFixed(1) + "k";
        return String(num);
    }

    function formatCost(cost) {
        if (!cost || isNaN(cost)) return "$0.00";
        return "$" + Number(cost).toFixed(2);
    }

    function refresh() {
        if (root.loading) return;
        root.loading = true;
        fetcher.running = true;
    }

    function refreshTokenStats() {
        if (root.loadingTokens) return;
        root.loadingTokens = true;
        tokenFetcher.running = true;
    }

    function parseUsageJson(jsonStr) {
        try {
            var data = JSON.parse(jsonStr);
            root.rawData = data;
            root.providers = data.providers || [];

            var now = new Date();
            var h = String(now.getHours()).padStart(2, "0");
            var m = String(now.getMinutes()).padStart(2, "0");
            root.lastUpdated = h + ":" + m;

            for (var i = 0; i < root.providers.length; i++) {
                var p = root.providers[i];
                if (p.id === "claude") {
                    var sWin = null;
                    var wWin = null;
                    for (var j = 0; j < (p.windows || []).length; j++) {
                        if (p.windows[j].key === "session") sWin = p.windows[j];
                        else if (p.windows[j].key === "weekly") wWin = p.windows[j];
                    }
                    root.claudeInfo = {
                        ok: p.ok,
                        plan: p.plan || "Pro",
                        sessionPercent: sWin ? sWin.usedPercent : 0,
                        weeklyPercent: wWin ? wWin.usedPercent : 0,
                        sessionReset: sWin ? sWin.resetsAt : "",
                        weeklyReset: wWin ? wWin.resetsAt : "",
                        error: p.errorCode || ""
                    };
                    root.claudeUsed = Math.round(root.claudeInfo.weeklyPercent || root.claudeInfo.sessionPercent || 0);
                } else if (p.id === "codex") {
                    var wWin = null;
                    var sWin = null;
                    for (var j = 0; j < (p.windows || []).length; j++) {
                        if (p.windows[j].key === "session") sWin = p.windows[j];
                        else if (p.windows[j].key === "weekly") wWin = p.windows[j];
                    }
                    root.codexInfo = {
                        ok: p.ok,
                        plan: p.plan || "Plus",
                        sessionPercent: sWin ? sWin.usedPercent : null,
                        weeklyPercent: wWin ? wWin.usedPercent : 0,
                        sessionReset: sWin ? sWin.resetsAt : "",
                        weeklyReset: wWin ? wWin.resetsAt : "",
                        error: p.errorCode || ""
                    };
                    root.codexUsed = Math.round(root.codexInfo.weeklyPercent || 0);
                } else if (p.id === "antigravity") {
                    var gW = 0, gS = 0, cW = 0, cS = 0, aW = 0;
                    var gWr = "", gSr = "", cWr = "", cSr = "", aWr = "";
                    for (var j = 0; j < (p.windows || []).length; j++) {
                        var w = p.windows[j];
                        if (w.model === "Gemini") {
                            if (w.key === "weekly") { gW = w.usedPercent || 0; gWr = w.resetsAt || ""; }
                            else if (w.key === "session") { gS = w.usedPercent || 0; gSr = w.resetsAt || ""; }
                        } else if (w.model === "Claude & GPT" || w.model === "Claude ve GPT") {
                            if (w.key === "weekly") { cW = w.usedPercent || 0; cWr = w.resetsAt || ""; }
                            else if (w.key === "session") { cS = w.usedPercent || 0; cSr = w.resetsAt || ""; }
                        } else if (w.model === "Gemini 4 Argon" || w.key === "weekly_scoped") {
                            aW = w.usedPercent || 0; aWr = w.resetsAt || "";
                        }
                    }
                    root.antigravityInfo = {
                        ok: p.ok,
                        plan: p.plan || "Pro",
                        geminiWeekly: gW,
                        geminiSession: gS,
                        claudeWeekly: cW,
                        claudeSession: cS,
                        argonWeekly: aW,
                        geminiSessionReset: gSr,
                        geminiWeeklyReset: gWr,
                        claudeSessionReset: cSr,
                        claudeWeeklyReset: cWr,
                        argonWeeklyReset: aWr,
                        error: p.errorCode || ""
                    };
                    root.antigravityUsed = Math.round(gW);
                }
            }
            root.ready = true;
        } catch (e) {
            console.error("[AgentsUsage] JSON parse error:", e);
        } finally {
            root.loading = false;
        }
    }

    Component.onCompleted: {
        root.refresh();
        root.refreshTokenStats();
    }

    // Refresh limits every 5 minutes
    Timer {
        interval: 300000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    // Refresh token stats every 15 minutes
    Timer {
        interval: 900000
        repeat: true
        running: true
        onTriggered: root.refreshTokenStats()
    }

    Process {
        id: fetcher
        command: ["python3", root.scriptPath]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0) {
                    root.parseUsageJson(text.trim());
                } else {
                    root.loading = false;
                }
            }
        }
        onExited: (code, status) => {
            if (code !== 0) {
                root.loading = false;
            }
        }
    }

    Process {
        id: tokenFetcher
        command: ["python3", root.tokenScriptPath]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    if (text && text.trim().length > 0) {
                        root.tokenData = JSON.parse(text.trim());
                    }
                } catch (e) {
                    console.error("[AgentsUsage] Token stats parse error:", e);
                } finally {
                    root.loadingTokens = false;
                }
            }
        }
        onExited: (code, status) => {
            root.loadingTokens = false;
        }
    }
}
