# Agents Usage (KDE Plasma 6 & Hyprland)

A multi-desktop widget that tracks remaining 5-hour and weekly limits for **Claude Code**, **OpenAI Codex**, and **Google Antigravity**, plus token usage and cost estimations.

This project is a fork of [yusufipk/kde-agents-usage](https://github.com/yusufipk/kde-agents-usage) with added **Antigravity** support and native **Hyprland (QuickShell / end-4 dots)** desktop and taskbar integration.

---

## 🌟 Features

- **3 Major AI Providers Supported:**
  - **Claude Code:** 5-hour session & weekly limits with local history fallback.
  - **OpenAI Codex:** Weekly & session limits with auto-refreshing OAuth.
  - **Google Antigravity:** Gemini Models, Claude & GPT Models, and Gemini 4 Argon weekly/session quotas read via `agy -p /usage`.
- **Hyprland Desktop & Panel Integration:**
  - **Desktop Widget:** 3 beautiful Material You stat cards on the wallpaper showing active percentage usage for Claude, Codex, and Antigravity.
  - **Taskbar Button (Bottom-Left):** Quick launcher icon in the bottom taskbar with status dot.
  - **Interactive Popup:** Clean Hyprland-style floating popup with:
    - *Limits Tab:* Progress bars, percentage badges, plan labels (Pro, Plus), and countdown timers until reset.
    - *Tokens & Cost Tab:* 1-day, 7-day, 30-day, and 365-day breakdowns with estimated API list prices and token counts.
- **KDE Plasma 6 Plasmoid:** Full original Plasma 6 tray and desktop plasmoid support.

---

## 🚀 Installation

### Hyprland (QuickShell / end-4 dots)
Run the automated installation script:
```bash
git clone https://github.com/zynordev/kde-agents-usage.git
cd kde-agents-usage
./install-hyprland.sh
```

This script automatically installs the service, desktop widget, and taskbar button, registers them in `WidgetsLoader.qml` and `config.json`, and reloads QuickShell.

### KDE Plasma 6
```bash
git clone https://github.com/zynordev/kde-agents-usage.git
cd kde-agents-usage
./install.sh
```
Then add "Agents Usage" to your panel or system tray.

---

## 📄 License & Attribution
Based on [kde-agents-usage](https://github.com/yusufipk/kde-agents-usage) by Yusuf İpek (MIT License).  
Antigravity CLI integration inspired by [agents-usage-plus](https://github.com/ktarxhun/agents-usage-plus).  
Licensed under the MIT License.
