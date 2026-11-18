#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QS_DIR="${HOME}/.config/quickshell/end4-pC"
II_CONFIG="${HOME}/.config/illogical-impulse/config.json"

echo "=== Hyprland & QuickShell Agents Usage Kurulumu ==="

if [ ! -d "$QS_DIR" ]; then
    echo "Hata: QuickShell yapılandırma dizini bulunamadı ($QS_DIR)"
    exit 1
fi

echo "1. Dosyalar kopyalanıyor..."
mkdir -p "$QS_DIR/services"
mkdir -p "$QS_DIR/modules/ii/background/widgets/agentsUsage"
mkdir -p "$QS_DIR/modules/ii/bar"
mkdir -p "$QS_DIR/assets/icons"

cp "$SCRIPT_DIR/quickshell/services/AgentsUsage.qml" "$QS_DIR/services/AgentsUsage.qml"
cp "$SCRIPT_DIR/quickshell/widgets/desktop/AgentsUsageWidget.qml" "$QS_DIR/modules/ii/background/widgets/agentsUsage/AgentsUsageWidget.qml"
cp "$SCRIPT_DIR/quickshell/widgets/bar/AgentsUsage.qml" "$QS_DIR/modules/ii/bar/AgentsUsage.qml"
cp "$SCRIPT_DIR/quickshell/widgets/bar/AgentsUsagePopup.qml" "$QS_DIR/modules/ii/bar/AgentsUsagePopup.qml"
cp "$SCRIPT_DIR/quickshell/assets/icons/"*.svg "$QS_DIR/assets/icons/"

echo "2. WidgetsLoader ve Config şeması kontrol ediliyor..."
# Config.qml şeması
if ! grep -q "property JsonObject agentsUsage:" "$QS_DIR/modules/common/Config.qml"; then
    python3 -c '
path = "'"$QS_DIR"'/modules/common/Config.qml"
with open(path) as f:
    c = f.read()
target = "property JsonObject resources: JsonObject {"
insert = """property JsonObject agentsUsage: JsonObject {
                        property bool enable: true
                        property string placementStrategy: \"free\"
                        property real x: 1488
                        property real y: 160
                        property real z: 26
                        property bool vertical: false
                    }

                    """
if target in c and "agentsUsage" not in c:
    c = c.replace(target, insert + target, 1)
    with open(path, "w") as f:
        f.write(c)
'
fi

# WidgetsLoader.qml kaydı
if ! grep -q "agentsUsageComp" "$QS_DIR/modules/ii/background/WidgetsLoader.qml"; then
    python3 -c '
path = "'"$QS_DIR"'/modules/ii/background/WidgetsLoader.qml"
with open(path) as f:
    c = f.read()
if "agentsUsage" not in c:
    c = c.replace("import qs.modules.ii.background.widgets.customtext", "import qs.modules.ii.background.widgets.customtext\nimport qs.modules.ii.background.widgets.agentsUsage")
    c = c.replace("{ key: \"customText\" },", "{ key: \"customText\" },\n            { key: \"agentsUsage\" },")
    c = c.replace("case \"customText\":  return customTextComp", "case \"customText\":  return customTextComp\n                    case \"agentsUsage\": return agentsUsageComp")
    comp = """    Component {
        id: agentsUsageComp
        AgentsUsageWidget {
            screenWidth: root.screen.width
            screenHeight: root.screen.height
            scaledScreenWidth: root.screen.width
            scaledScreenHeight: root.screen.height
            wallpaperScale: 1
            wallpaperItem: root.wallpaperItem
        }
    }
}"""
    c = c.rsplit("}", 1)[0] + comp
    with open(path, "w") as f:
        f.write(c)
'
fi

echo "3. illogical-impulse ayarları güncelleniyor..."
if [ -f "$II_CONFIG" ]; then
    python3 -c '
import json
path = "'"$II_CONFIG"'"
with open(path) as f:
    c = json.load(f)

# Masaüstü widgeti etkinleştir
c.setdefault("background", {}).setdefault("widgets", {})["agentsUsage"] = {
    "enable": True,
    "placementStrategy": "free",
    "vertical": False,
    "x": 1488,
    "y": 160,
    "z": 26
}

# Görev çubuğunun sağ tarafına butonu ekle
right = c.setdefault("bar", {}).setdefault("layouts", {}).get("rightLayout", [])
if "agentsUsage" not in right:
    if "batteryIndicator" in right:
        idx = right.index("batteryIndicator")
        right.insert(idx, "agentsUsage")
    else:
        right.append("agentsUsage")
    c["bar"]["layouts"]["rightLayout"] = right

# Sol tarafta varsa temizle
left = c.setdefault("bar", {}).setdefault("layouts", {}).get("leftLayout", [])
if "agentsUsage" in left:
    left.remove("agentsUsage")
    c["bar"]["layouts"]["leftLayout"] = left

with open(path, "w") as f:
    json.dump(c, f, indent=4)
'
fi

echo "4. QuickShell yeniden başlatılıyor..."
killall qs quickshell 2>/dev/null || true
sleep 0.5
nohup qs -d -c end4-pC >/dev/null 2>&1 &

echo "✓ Kurulum tamamlandı! Hyprland masaüstü widgetı ve görev çubuğu butonu aktif."
