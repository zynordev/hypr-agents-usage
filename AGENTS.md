# AGENTS.md — Agents Usage (KDE Plasma & Hyprland)

## 📌 Proje Genel Bakışı
Bu depo, **Claude Code**, **OpenAI Codex** ve **Google Antigravity** yapay zeka araçlarının kullanım limitlerini, kalan kotalarını ve maliyetlerini hem **KDE Plasma 6** hem de **Hyprland (QuickShell)** masaüstü ortamlarında görselleştiren widget ve servis ekosistemidir.

Bu depo, [yusufipk/kde-agents-usage](https://github.com/yusufipk/kde-agents-usage) projesinin geliştirilmiş ve Hyprland desteği eklenmiş fork'udur.

---

## 🛠️ Desteklenen AI Araçları (3 Sağlayıcı)
1. **Claude Code (`claude`):**
   - 5 saatlik kayan oturum limiti (`five_hour` / `session`)
   - 7 günlük haftalık limit (`seven_day` / `weekly`)
   - Canlı OAuth API ve yerel `~/.config/Claude/plan-usage-history.json` güvenli fallback desteği
2. **OpenAI Codex (`codex`):**
   - Haftalık limit (`weekly`) ve aktif oturum limiti
   - `~/.codex/auth.json` otomatik token yenileme desteği
3. **Google Antigravity (`agy`):**
   - Gemini Modelleri (Haftalık & 5 Saatlik Limit)
   - Claude & GPT Modelleri (Haftalık & 5 Saatlik Limit)
   - Gemini 4 Argon Modeli (Haftalık Limit)
   - `agy -p /usage` entegrasyonu ve dil sunucusu plan tespiti

---

## 🚀 Çalışma Ortamları ve Kurulum

### 1. Hyprland (QuickShell / end-4 dots)
- **Masaüstü Widgetı:** Masaüstünde 3 ajanın (Claude, Codex, Antigravity) anlık kullanım yüzdelerini Material You kartlarıyla gösterir.
- **Görev Çubuğu (Bar) Butonu & Popup:** Sol alt köşedeki nöroloji/AI butonuna tıklandığında açılan detaylı panel:
  - *Limitler Sekmesi:* Sağlayıcı rozetleri (Pro, Plus), kalan/kullanılan çubukları, sıfırlanma geri sayımları.
  - *Tokenlar & Maliyet Sekmesi:* 1g / 7g / 30g / 1y dönem filtreleri, model bazında token sayıları ve tahmini API maliyetleri.

**Kurulum:**
```bash
./install-hyprland.sh
```

### 2. KDE Plasma 6
- Orijinal Plasmoid sistem tepsisinde veya masaüstünde çalışır.
```bash
./install.sh
```

---

## 📁 Dizin Yapısı
- `package/contents/code/`:
  - `fetch_usage.py`: 3 sağlayıcıdan canlı kota verilerini çeken çekirdek Python betiği.
  - `token_stats.py`: Yerel günlükleri tarayarak token ve maliyet hesaplayan betik.
  - `prices.py`: LiteLLM güncel model fiyatlandırma tablosu.
- `quickshell/`:
  - `services/AgentsUsage.qml`: QuickShell arka plan singleton servisi (5 dk otomatik yenileme).
  - `widgets/desktop/AgentsUsageWidget.qml`: Hyprland masaüstü 3'lü yüzde widgetı.
  - `widgets/bar/AgentsUsage.qml`: Görev çubuğu butonu.
  - `widgets/bar/AgentsUsagePopup.qml`: Detaylı açılır menü paneli.
- `install-hyprland.sh`: Hyprland tek tıkla kurulum ve servis entegrasyon betiği.
- `install.sh`: KDE Plasma 6 kurulum betiği.

---

## 🔒 Güvenlik & İlkeler
- OAuth anahtarları veya oturum tokenları asla dışarı sızdırılmaz.
- Tüm veri çekme ve hesaplama işlemleri yerel sistem üzerinde çalışır.
