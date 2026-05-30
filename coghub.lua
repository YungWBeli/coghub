-- ====================================================================
-- COGHUB MM2 v1.2 - RED EDITION
-- Coded by: Beli!
-- ====================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ================================================================
--  GLOBALS & THEME
-- ================================================================
local BLUE      = Color3.fromRGB(52, 152, 219)
local BLUE_DARK = Color3.fromRGB(30, 90, 130)

local goldCD   = false
local normalCD = false

local BULLET_SPEED    = 250
local KNIFE_SPEED     = 65
local MAX_VELOCITY    = 200
local BASE_WALK_SPEED = 16
local SPEED_AMOUNT    = 200
local SUPER_JUMP_POWER = 150
local STRETCH_AMOUNT  = 50
local FARM_INTERVAL   = 0.4
local SAFE_DISTANCE   = 30

local autoPingPred         = false
local stretchEnabled       = false
local stretchConn          = nil
local crosshairActive      = false
local crosshairSpin        = false
local activeCursorId       = "11770890197"
local crosshairImg         = nil
local spinConn             = nil
local crosshairColor1      = BLUE
local crosshairColor2      = Color3.fromRGB(0, 255, 255)
local crosshairGradEnabled = false
local crosshairColorConn   = nil
local crosshairSize        = 42

local espEnabled   = false
local espConn      = nil
local rolesData    = {}
local lastEspTick  = 0
local espSettings  = { Murderer = true, Sheriff = true, Hero = true, Innocent = true, Self = true }
local ESP_COLORS   = {
    Murderer = Color3.fromRGB(255, 40,  40),
    Sheriff  = Color3.fromRGB(40,  130, 255),
    Hero     = Color3.fromRGB(255, 215, 0),
    Innocent = Color3.fromRGB(0,   220, 0),
}

local speedEnabled       = false
local speedConn          = nil
local antiFlingEnabled   = false
local antiFlingConn      = nil
local flickCD            = false
local wallhopCD          = false
local flingBusy          = false
local currentTarget      = nil
local flick360CD         = false
local autoFarmEnabled    = false
local farmConn           = nil
local coinHighlights     = {}
local noclipConn         = nil
local superJumpEnabled   = false
local superJumpConn      = nil
local INVIS_POS          = Vector3.new(-25.95, 84, 3537.55)
local invisEnabled       = false
local invisPlatform      = nil
local holdEveryoneEnabled = false
local holdEveryoneConn   = nil
local savedPositions     = {}
local cachedCoins        = {}
local lastCoinCacheTime  = 0
local COIN_CACHE_TTL     = 3
local droppedGunEspEnabled = true
local asmrEnabled        = false
local asmrConn           = nil
local lowGraphics        = false
local lgDescConn         = nil
local origLightData      = {
    GlobalShadows  = Lighting.GlobalShadows,
    Brightness     = Lighting.Brightness,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}
local origPartData = {}
local defaultSkyData = nil

local ASMR_MESH_ID    = "rbxassetid://17469067138"
local ASMR_BASE_SIZE  = Vector3.new(1.4, 0.7, 1.4)
local ASMR_MESH_SCALE = Vector3.new(1.4, 1.4, 1.4)
local ASMR_COOLDOWN   = 0.12
local ASMR_DESPAWN    = 2.5
local asmrLastTime    = 0
local asmrLastPos     = Vector3.new(0, 0, 0)
local ASMR_SOUNDS = {
    "rbxassetid://9116156314","rbxassetid://9113874638",
    "rbxassetid://9113145647","rbxassetid://9116154737",
    "rbxassetid://9116158538","rbxassetid://9113873548",
    "rbxassetid://9116156872"
}
local ASMR_COLORS = {
    Color3.fromRGB(255,182,193), Color3.fromRGB(255,218,185),
    Color3.fromRGB(255,255,205), Color3.fromRGB(204,255,204),
    Color3.fromRGB(218,235,255), Color3.fromRGB(230,210,255),
}
local ASMR_ALPHA = {"Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M"}

local DISCORD_INVITE = "https://discord.gg/RU5xWM483S"
local LANG_OPTIONS = {"English", "Türkçe", "Deutch", "Français", "Español"}

-- ================================================================
--  LOCALIZATION SYSTEM
-- ================================================================
local currentLang = "English"
local LOC = {
    ["English"] = {
        ["wait"] = "WAIT...", ["gold_jump"] = "GOLD\nJUMP", ["bomb_jump"] = "BOMB\nJUMP",
        ["throw_knife"] = "THROW\nKNIFE", ["shoot"] = "SHOOT", ["esp_on"] = "ESP ON", ["esp_off"] = "ESP OFF",
        ["flick"] = "FLICK", ["wall_hop"] = "WALL\nHOP", ["speed_on"] = "SPEED\nON", ["speed_glitch"] = "SPEED\nGLITCH",
        ["stretch_on"] = "STRETCH\nON", ["stretch"] = "STRETCH", ["grab_gun"] = "GRAB\nGUN", ["no_gun"] = "NO\nGUN",
        ["flinging"] = "FLINGING...", ["fling_m"] = "FLING\nMURDERER", ["no_m"] = "NO\nMURDERER",
        ["fling_s"] = "FLING\nSHERIFF", ["no_s"] = "NO\nSHERIFF", ["hold_on"] = "HOLD\nEVERYONE ON", ["hold"] = "HOLD\nEVERYONE",
        ["invis_on"] = "INVISIBLE\nON", ["invis_off"] = "INVISIBLE\nOFF", ["super_on"] = "SUPER\nJUMP ON", ["super"] = "SUPER\nJUMP",
        ["farm_on"] = "AUTO\nFARM ON", ["farm_off"] = "AUTO\nFARM OFF", ["anti_on"] = "ANTI\nFLING ON", ["anti_off"] = "ANTI\nFLING OFF",
        ["low_on"] = "LOW\nGRAPHICS ON", ["low"] = "LOW\nGRAPHICS",
        ["discord"] = "Discord invite copied to clipboard!", ["lang_changed"] = "Language changed!",
        ["popup_title"] = "CogHub MM2", ["popup_content"] = "v1.2  |  Red Edition  |  by Beli!", ["ok"] = "OK",
        ["window_author"] = "Beli!  |  MM2 v1.2", ["section_title"] = "CogHub v1.2  |  Red Edition", ["tab_main"] = "Main",
        ["load_buttons_title"] = "Load Buttons", ["load_buttons_desc"] = "Enable floating buttons one by one. Disable to remove them from screen.",
        ["gui_gold_jump"] = "Gold Jump", ["gui_bomb_jump"] = "Bomb Jump", ["gui_shoot_throw"] = "Shoot / Throw",
        ["gui_esp"] = "ESP", ["gui_flick"] = "Flick", ["gui_speed_glitch"] = "Speed Glitch",
        ["gui_speed_amount"] = "Speed Amount", ["gui_speed_amount_desc"] = "Set glitch speed (16-500)",
        ["gui_stretch"] = "Stretch", ["gui_stretch_amount"] = "Stretch Amount", ["gui_stretch_amount_desc"] = "Set stretch amount (1-200)",
        ["gui_grab_gun"] = "Grab Gun", ["gui_wall_hop"] = "Wall Hop", ["gui_fling_murderer"] = "Fling Murderer",
        ["gui_fling_sheriff"] = "Fling Sheriff", ["gui_hold_everyone"] = "Hold Everyone", ["gui_invisible"] = "Invisible",
        ["gui_super_jump"] = "Super Jump", ["gui_super_jump_power"] = "Super Jump Power", ["gui_super_jump_power_desc"] = "Set jump power (50-500)",
        ["gui_auto_farm"] = "Auto Farm", ["gui_anti_fling"] = "Anti-Fling", ["gui_low_graphics"] = "Low Graphics",
        ["esp_settings_title"] = "ESP Settings", ["esp_settings_desc"] = "Which roles should be shown?",
        ["show_murderer"] = "Show Murderer", ["show_sheriff"] = "Show Sheriff", ["show_hero"] = "Show Hero",
        ["show_innocents"] = "Show Innocents", ["show_self"] = "Show Self", ["dropped_gun_esp"] = "Dropped Gun ESP",
        ["crosshair_title"] = "Crosshair", ["crosshair_desc"] = "Custom crosshair + color + gradient. ShiftLock must be enabled.",
        ["custom_crosshair"] = "Custom Crosshair", ["crosshair_picker"] = "Crosshair Picker + Colors",
        ["crosshair_picker_desc"] = "Preset cursor + Spin + Color + Gradient",
        ["crosshair_size"] = "Crosshair Size", ["crosshair_size_desc"] = "16px - 96px",
        ["crosshair_on"] = "Crosshair ON - Enable ShiftLock!", ["skybox_title"] = "Skybox", ["skybox_desc"] = "7 presets + custom ID.",
        ["skybox_picker_btn"] = "Skybox Picker", ["asmr_title"] = "ASMR Keyboard Walk", ["asmr_desc"] = "Keyboard keys appear under your feet.",
        ["asmr_toggle"] = "ASMR Keyboard Walk Mode", ["asmr_on"] = "ASMR Keyboard ON",
        ["settings_support_title"] = "Settings & Support", ["settings_support_desc"] = "Change language or join our Discord community.",
        ["language_label"] = "Language", ["discord_menu"] = "Discord", ["support_server"] = "Support Server",
        ["creator_line"] = "Creator", ["creator_desc"] = "Made with love by Beli!",
        ["ready_msg"] = "CogHub v1.2 ready!",
        ["apply"] = "Apply", ["reset_default"] = "Reset Default", ["apply_color"] = "Apply Color", ["preview"] = "Preview",
        ["skybox_picker"] = "Skybox Picker", ["restore_sky"] = "Restore Default Sky", ["skybox_id_ph"] = "Custom Skybox ID, press Enter...",
        ["cursor_picker"] = "Cursor Picker", ["cursor_id_ph"] = "Custom Cursor ID, press Enter...",
        ["spin_crosshair"] = "Spin Crosshair", ["gradient_mode"] = "Gradient Color Mode", ["color1"] = "Color 1", ["color2"] = "Color 2 (Gradient)",
        ["rgb_ph"] = "R,G,B example: 52,152,219", ["applied_suffix"] = " applied!", ["value_arrow"] = " -> ",
        ["gun_dropped"] = "Gun dropped on the map!", ["esp_remote_missing"] = "ESP remote not found!",
        ["no_gun_msg"] = "No gun!", ["no_knife"] = "No knife!", ["no_target"] = "No target.", ["no_bomb"] = "No bomb!",
        ["no_gun_map"] = "No gun on map!", ["gun_pos_missing"] = "Gun position not found!", ["tp_gun"] = "Teleporting to gun...",
        ["is_sitting"] = " is sitting.", ["returned_pos"] = "Returned to position.", ["fling_progress"] = "Fling in progress.",
        ["flinging_player"] = "Flinging: ", ["no_target_found"] = "No target found.", ["skybox_restored"] = "Skybox restored.",
        ["custom_skybox"] = "Custom skybox: ", ["skybox_set"] = "Skybox: ", ["custom_cursor"] = "Custom cursor set!",
        ["cursor_set"] = "Cursor: ", ["gun_on_map"] = "GUN ON MAP",
    },
    ["Türkçe"] = {
        ["wait"] = "BEKLE...", ["gold_jump"] = "ALTIN\nZIPLA", ["bomb_jump"] = "BOMBA\nZIPLA",
        ["throw_knife"] = "BIÇAK\nFIRLAT", ["shoot"] = "ATEŞ ET", ["esp_on"] = "ESP AÇIK", ["esp_off"] = "ESP KAPALI",
        ["flick"] = "FLICK", ["wall_hop"] = "DUVAR\nZIPLA", ["speed_on"] = "HIZ\nAÇIK", ["speed_glitch"] = "HIZ\nHİLESİ",
        ["stretch_on"] = "UZATMA\nAÇIK", ["stretch"] = "UZATMA", ["grab_gun"] = "SİLAHI\nAL", ["no_gun"] = "SİLAH\nYOK",
        ["flinging"] = "FIRLATIYOR...", ["fling_m"] = "KATİLİ\nFIRLAT", ["no_m"] = "KATİL\nYOK",
        ["fling_s"] = "ŞERİFİ\nFIRLAT", ["no_s"] = "ŞERİF\nYOK", ["hold_on"] = "HERKESİ\nTUT AÇIK", ["hold"] = "HERKESİ\nTUT",
        ["invis_on"] = "GÖRÜNMEZ\nAÇIK", ["invis_off"] = "GÖRÜNMEZ\nKAPALI", ["super_on"] = "SÜPER\nZIPLA AÇIK", ["super"] = "SÜPER\nZIPLA",
        ["farm_on"] = "OTO\nFARM AÇIK", ["farm_off"] = "OTO\nFARM KAPALI", ["anti_on"] = "ANTİ\nFIRLATMA AÇIK", ["anti_off"] = "ANTİ\nFIRLATMA KAPALI",
        ["low_on"] = "DÜŞÜK\nGRAFİK AÇIK", ["low"] = "DÜŞÜK\nGRAFİK",
        ["discord"] = "Discord davet bağlantısı kopyalandı!", ["lang_changed"] = "Dil değiştirildi!",
        ["popup_title"] = "CogHub MM2", ["popup_content"] = "v1.2  |  Red Edition  |  Yapımcı: Beli!", ["ok"] = "Tamam",
        ["window_author"] = "Beli!  |  MM2 v1.2", ["section_title"] = "CogHub v1.2  |  Red Edition", ["tab_main"] = "Ana Menü",
        ["load_buttons_title"] = "Butonları Yükle", ["load_buttons_desc"] = "İstediğin yüzen butonları tek tek aç. Kapatınca ekrandan kalkar.",
        ["gui_gold_jump"] = "Altın Zıpla", ["gui_bomb_jump"] = "Bomba Zıpla", ["gui_shoot_throw"] = "Ateş Et / Fırlat",
        ["gui_esp"] = "ESP", ["gui_flick"] = "Flick", ["gui_speed_glitch"] = "Hız Hilesi",
        ["gui_speed_amount"] = "Hız Miktarı", ["gui_speed_amount_desc"] = "Glitch hızını ayarla (16-500)",
        ["gui_stretch"] = "Uzatma", ["gui_stretch_amount"] = "Uzatma Miktarı", ["gui_stretch_amount_desc"] = "Uzatma miktarını ayarla (1-200)",
        ["gui_grab_gun"] = "Silahı Al", ["gui_wall_hop"] = "Duvar Zıpla", ["gui_fling_murderer"] = "Katili Fırlat",
        ["gui_fling_sheriff"] = "Şerifi Fırlat", ["gui_hold_everyone"] = "Herkesi Tut", ["gui_invisible"] = "Görünmezlik",
        ["gui_super_jump"] = "Süper Zıpla", ["gui_super_jump_power"] = "Süper Zıpla Gücü", ["gui_super_jump_power_desc"] = "Zıplama gücünü ayarla (50-500)",
        ["gui_auto_farm"] = "Oto Farm", ["gui_anti_fling"] = "Anti-Fling", ["gui_low_graphics"] = "Düşük Grafik",
        ["esp_settings_title"] = "ESP Ayarları", ["esp_settings_desc"] = "Hangi roller gösterilsin?",
        ["show_murderer"] = "Katili Göster", ["show_sheriff"] = "Şerifi Göster", ["show_hero"] = "Kahramanı Göster",
        ["show_innocents"] = "Masumları Göster", ["show_self"] = "Kendini Göster", ["dropped_gun_esp"] = "Düşen Silah ESP",
        ["crosshair_title"] = "Nişangah", ["crosshair_desc"] = "Özel nişangah + renk + gradient. ShiftLock açık olmalı.",
        ["custom_crosshair"] = "Özel Nişangah", ["crosshair_picker"] = "Nişangah Seçici + Renkler",
        ["crosshair_picker_desc"] = "Hazır imleç + Döndürme + Renk + Gradient",
        ["crosshair_size"] = "Nişangah Boyutu", ["crosshair_size_desc"] = "16px - 96px",
        ["crosshair_on"] = "Nişangah AÇIK - ShiftLock'u aç!", ["skybox_title"] = "Skybox", ["skybox_desc"] = "7 hazır + özel ID.",
        ["skybox_picker_btn"] = "Skybox Seçici", ["asmr_title"] = "ASMR Klavye Yürüyüşü", ["asmr_desc"] = "Ayaklarının altında klavye tuşları belirir.",
        ["asmr_toggle"] = "ASMR Klavye Modu", ["asmr_on"] = "ASMR Klavye AÇIK",
        ["settings_support_title"] = "Ayarlar & Destek", ["settings_support_desc"] = "Dili değiştir veya Discord topluluğumuza katıl.",
        ["language_label"] = "Dil", ["discord_menu"] = "Discord", ["support_server"] = "Destek Sunucusu",
        ["creator_line"] = "Yapımcı", ["creator_desc"] = "Sevgilerle Beli! tarafından yapıldı.",
        ["ready_msg"] = "CogHub v1.2 hazır!",
        ["apply"] = "Uygula", ["reset_default"] = "Varsayılana Dön", ["apply_color"] = "Rengi Uygula", ["preview"] = "Önizleme",
        ["skybox_picker"] = "Skybox Seçici", ["restore_sky"] = "Varsayılan Skybox", ["skybox_id_ph"] = "Özel Skybox ID, Enter'a bas...",
        ["cursor_picker"] = "İmleç Seçici", ["cursor_id_ph"] = "Özel İmleç ID, Enter'a bas...",
        ["spin_crosshair"] = "Nişangahı Döndür", ["gradient_mode"] = "Gradient Renk Modu", ["color1"] = "Renk 1", ["color2"] = "Renk 2 (Gradient)",
        ["rgb_ph"] = "R,G,B örnek: 52,152,219", ["applied_suffix"] = " uygulandı!", ["value_arrow"] = " -> ",
        ["gun_dropped"] = "Haritaya silah düştü!", ["esp_remote_missing"] = "ESP remote bulunamadı!",
        ["no_gun_msg"] = "Silah yok!", ["no_knife"] = "Bıçak yok!", ["no_target"] = "Hedef yok.", ["no_bomb"] = "Bomba yok!",
        ["no_gun_map"] = "Haritada silah yok!", ["gun_pos_missing"] = "Silah konumu bulunamadı!", ["tp_gun"] = "Silaha ışınlanılıyor...",
        ["is_sitting"] = " oturuyor.", ["returned_pos"] = "Konuma dönüldü.", ["fling_progress"] = "Fırlatma devam ediyor.",
        ["flinging_player"] = "Fırlatılıyor: ", ["no_target_found"] = "Hedef bulunamadı.", ["skybox_restored"] = "Skybox geri yüklendi.",
        ["custom_skybox"] = "Özel skybox: ", ["skybox_set"] = "Skybox: ", ["custom_cursor"] = "Özel imleç ayarlandı!",
        ["cursor_set"] = "İmleç: ", ["gun_on_map"] = "HARİTADA SİLAH",
    },
    ["Deutch"] = {
        ["wait"] = "WARTEN...", ["gold_jump"] = "GOLD\nSPRUNG", ["bomb_jump"] = "BOMBEN\nSPRUNG",
        ["throw_knife"] = "MESSER\nWERFEN", ["shoot"] = "SCHIESSEN", ["esp_on"] = "ESP AN", ["esp_off"] = "ESP AUS",
        ["flick"] = "FLICK", ["wall_hop"] = "WAND\nSPRUNG", ["speed_on"] = "TEMPO\nAN", ["speed_glitch"] = "TEMPO\nGLITCH",
        ["stretch_on"] = "STRECKEN\nAN", ["stretch"] = "STRECKEN", ["grab_gun"] = "WAFFE\nNEHMEN", ["no_gun"] = "KEINE\nWAFFE",
        ["flinging"] = "WERFEN...", ["fling_m"] = "MÖRDER\nWERFEN", ["no_m"] = "KEIN\nMÖRDER",
        ["fling_s"] = "SHERIFF\nWERFEN", ["no_s"] = "KEIN\nSHERIFF", ["hold_on"] = "ALLE\nHALTEN AN", ["hold"] = "ALLE\nHALTEN",
        ["invis_on"] = "UNSICHTBAR\nAN", ["invis_off"] = "UNSICHTBAR\nAUS", ["super_on"] = "SUPER\nSPRUNG AN", ["super"] = "SUPER\nSPRUNG",
        ["farm_on"] = "AUTO\nFARM AN", ["farm_off"] = "AUTO\nFARM AUS", ["anti_on"] = "ANTI\nFLING AN", ["anti_off"] = "ANTI\nFLING AUS",
        ["low_on"] = "NIEDRIGE\nGRAFIK AN", ["low"] = "NIEDRIGE\nGRAFIK",
        ["discord"] = "Discord-Einladung in die Zwischenablage kopiert!", ["lang_changed"] = "Sprache geändert!",
        ["popup_title"] = "CogHub MM2", ["popup_content"] = "v1.2  |  Red Edition  |  von Beli!", ["ok"] = "OK",
        ["window_author"] = "Beli!  |  MM2 v1.2", ["section_title"] = "CogHub v1.2  |  Red Edition", ["tab_main"] = "Hauptmenü",
        ["load_buttons_title"] = "Buttons Laden", ["load_buttons_desc"] = "Schwebende Buttons einzeln aktivieren. Deaktivieren entfernt sie vom Bildschirm.",
        ["gui_gold_jump"] = "Gold Sprung", ["gui_bomb_jump"] = "Bomben Sprung", ["gui_shoot_throw"] = "Schießen / Werfen",
        ["gui_esp"] = "ESP", ["gui_flick"] = "Flick", ["gui_speed_glitch"] = "Tempo Glitch",
        ["gui_speed_amount"] = "Tempo Menge", ["gui_speed_amount_desc"] = "Glitch-Geschwindigkeit (16-500)",
        ["gui_stretch"] = "Strecken", ["gui_stretch_amount"] = "Streck Menge", ["gui_stretch_amount_desc"] = "Streckmenge (1-200)",
        ["gui_grab_gun"] = "Waffe Nehmen", ["gui_wall_hop"] = "Wand Sprung", ["gui_fling_murderer"] = "Mörder Werfen",
        ["gui_fling_sheriff"] = "Sheriff Werfen", ["gui_hold_everyone"] = "Alle Halten", ["gui_invisible"] = "Unsichtbar",
        ["gui_super_jump"] = "Super Sprung", ["gui_super_jump_power"] = "Super Sprung Kraft", ["gui_super_jump_power_desc"] = "Sprungkraft (50-500)",
        ["gui_auto_farm"] = "Auto Farm", ["gui_anti_fling"] = "Anti-Fling", ["gui_low_graphics"] = "Niedrige Grafik",
        ["esp_settings_title"] = "ESP Einstellungen", ["esp_settings_desc"] = "Welche Rollen sollen angezeigt werden?",
        ["show_murderer"] = "Mörder Zeigen", ["show_sheriff"] = "Sheriff Zeigen", ["show_hero"] = "Held Zeigen",
        ["show_innocents"] = "Unschuldige Zeigen", ["show_self"] = "Sich Selbst Zeigen", ["dropped_gun_esp"] = "Fallende Waffe ESP",
        ["crosshair_title"] = "Fadenkreuz", ["crosshair_desc"] = "Eigenes Fadenkreuz + Farbe + Verlauf. ShiftLock muss an sein.",
        ["custom_crosshair"] = "Eigenes Fadenkreuz", ["crosshair_picker"] = "Fadenkreuz Auswahl + Farben",
        ["crosshair_picker_desc"] = "Voreinstellung + Drehen + Farbe + Verlauf",
        ["crosshair_size"] = "Fadenkreuz Größe", ["crosshair_size_desc"] = "16px - 96px",
        ["crosshair_on"] = "Fadenkreuz AN - ShiftLock aktivieren!", ["skybox_title"] = "Skybox", ["skybox_desc"] = "7 Voreinstellungen + eigene ID.",
        ["skybox_picker_btn"] = "Skybox Auswahl", ["asmr_title"] = "ASMR Tastatur Gehen", ["asmr_desc"] = "Tasten erscheinen unter deinen Füßen.",
        ["asmr_toggle"] = "ASMR Tastatur Modus", ["asmr_on"] = "ASMR Tastatur AN",
        ["settings_support_title"] = "Einstellungen & Support", ["settings_support_desc"] = "Sprache ändern oder Discord beitreten.",
        ["language_label"] = "Sprache", ["discord_menu"] = "Discord", ["support_server"] = "Support Server",
        ["creator_line"] = "Ersteller", ["creator_desc"] = "Mit Liebe gemacht von Beli!",
        ["ready_msg"] = "CogHub v1.2 bereit!",
        ["apply"] = "Anwenden", ["reset_default"] = "Standard", ["apply_color"] = "Farbe Anwenden", ["preview"] = "Vorschau",
        ["skybox_picker"] = "Skybox Auswahl", ["restore_sky"] = "Standard Skybox", ["skybox_id_ph"] = "Eigene Skybox ID, Enter...",
        ["cursor_picker"] = "Cursor Auswahl", ["cursor_id_ph"] = "Eigene Cursor ID, Enter...",
        ["spin_crosshair"] = "Fadenkreuz Drehen", ["gradient_mode"] = "Farbverlauf Modus", ["color1"] = "Farbe 1", ["color2"] = "Farbe 2 (Verlauf)",
        ["rgb_ph"] = "R,G,B Beispiel: 52,152,219", ["applied_suffix"] = " angewendet!", ["value_arrow"] = " -> ",
        ["gun_dropped"] = "Waffe auf der Karte gefallen!", ["esp_remote_missing"] = "ESP Remote nicht gefunden!",
        ["no_gun_msg"] = "Keine Waffe!", ["no_knife"] = "Kein Messer!", ["no_target"] = "Kein Ziel.", ["no_bomb"] = "Keine Bombe!",
        ["no_gun_map"] = "Keine Waffe auf der Karte!", ["gun_pos_missing"] = "Waffenposition nicht gefunden!", ["tp_gun"] = "Zur Waffe teleportieren...",
        ["is_sitting"] = " sitzt.", ["returned_pos"] = "Zur Position zurückgekehrt.", ["fling_progress"] = "Wurf läuft.",
        ["flinging_player"] = "Werfe: ", ["no_target_found"] = "Kein Ziel gefunden.", ["skybox_restored"] = "Skybox wiederhergestellt.",
        ["custom_skybox"] = "Eigene Skybox: ", ["skybox_set"] = "Skybox: ", ["custom_cursor"] = "Eigener Cursor gesetzt!",
        ["cursor_set"] = "Cursor: ", ["gun_on_map"] = "WAFFE AUF KARTE",
    },
    ["Français"] = {
        ["wait"] = "ATTENDRE...", ["gold_jump"] = "SAUT\nD'OR", ["bomb_jump"] = "SAUT\nBOMBE",
        ["throw_knife"] = "LANCER\nCOUTEAU", ["shoot"] = "TIRER", ["esp_on"] = "ESP ACTIF", ["esp_off"] = "ESP INACTIF",
        ["flick"] = "FLICK", ["wall_hop"] = "SAUT\nMURAL", ["speed_on"] = "VITESSE\nON", ["speed_glitch"] = "GLITCH\nVITESSE",
        ["stretch_on"] = "ETIRER\nON", ["stretch"] = "ETIRER", ["grab_gun"] = "PRENDRE\nARME", ["no_gun"] = "PAS\nD'ARME",
        ["flinging"] = "ÉJECTION...", ["fling_m"] = "ÉJECTER\nTUEUR", ["no_m"] = "PAS DE\nTUEUR",
        ["fling_s"] = "ÉJECTER\nSHÉRIF", ["no_s"] = "PAS DE\nSHÉRIF", ["hold_on"] = "GELER\nTOUS ON", ["hold"] = "GELER\nTOUS",
        ["invis_on"] = "INVISIBLE\nON", ["invis_off"] = "INVISIBLE\nOFF", ["super_on"] = "SUPER\nSAUT ON", ["super"] = "SUPER\nSAUT",
        ["farm_on"] = "FARM\nAUTO ON", ["farm_off"] = "FARM\nAUTO OFF", ["anti_on"] = "ANTI\nÉJECTION ON", ["anti_off"] = "ANTI\nÉJECTION OFF",
        ["low_on"] = "GRAPHISMES\nBAS ON", ["low"] = "GRAPHISMES\nBAS",
        ["discord"] = "Invitation Discord copiée!", ["lang_changed"] = "Langue changée!",
        ["popup_title"] = "CogHub MM2", ["popup_content"] = "v1.2  |  Red Edition  |  par Beli!", ["ok"] = "OK",
        ["window_author"] = "Beli!  |  MM2 v14", ["section_title"] = "CogHub v1.2  |  Red Edition", ["tab_main"] = "Principal",
        ["load_buttons_title"] = "Charger les Boutons", ["load_buttons_desc"] = "Activez les boutons flottants un par un. Désactiver les retire de l'écran.",
        ["gui_gold_jump"] = "Saut d'Or", ["gui_bomb_jump"] = "Saut Bombe", ["gui_shoot_throw"] = "Tirer / Lancer",
        ["gui_esp"] = "ESP", ["gui_flick"] = "Flick", ["gui_speed_glitch"] = "Glitch Vitesse",
        ["gui_speed_amount"] = "Montant Vitesse", ["gui_speed_amount_desc"] = "Vitesse du glitch (16-500)",
        ["gui_stretch"] = "Étirer", ["gui_stretch_amount"] = "Montant Étirement", ["gui_stretch_amount_desc"] = "Montant d'étirement (1-200)",
        ["gui_grab_gun"] = "Prendre Arme", ["gui_wall_hop"] = "Saut Mural", ["gui_fling_murderer"] = "Éjecter Tueur",
        ["gui_fling_sheriff"] = "Éjecter Shérif", ["gui_hold_everyone"] = "Geler Tous", ["gui_invisible"] = "Invisible",
        ["gui_super_jump"] = "Super Saut", ["gui_super_jump_power"] = "Puissance Super Saut", ["gui_super_jump_power_desc"] = "Puissance de saut (50-500)",
        ["gui_auto_farm"] = "Farm Auto", ["gui_anti_fling"] = "Anti-Éjection", ["gui_low_graphics"] = "Graphismes Bas",
        ["esp_settings_title"] = "Paramètres ESP", ["esp_settings_desc"] = "Quels rôles afficher?",
        ["show_murderer"] = "Afficher Tueur", ["show_sheriff"] = "Afficher Shérif", ["show_hero"] = "Afficher Héros",
        ["show_innocents"] = "Afficher Innocents", ["show_self"] = "Afficher Soi", ["dropped_gun_esp"] = "ESP Arme Tombée",
        ["crosshair_title"] = "Viseur", ["crosshair_desc"] = "Viseur personnalisé + couleur + dégradé. ShiftLock requis.",
        ["custom_crosshair"] = "Viseur Personnalisé", ["crosshair_picker"] = "Sélecteur Viseur + Couleurs",
        ["crosshair_picker_desc"] = "Curseur preset + Rotation + Couleur + Dégradé",
        ["crosshair_size"] = "Taille Viseur", ["crosshair_size_desc"] = "16px - 96px",
        ["crosshair_on"] = "Viseur ON - Activez ShiftLock!", ["skybox_title"] = "Skybox", ["skybox_desc"] = "7 presets + ID personnalisé.",
        ["skybox_picker_btn"] = "Sélecteur Skybox", ["asmr_title"] = "Marche Clavier ASMR", ["asmr_desc"] = "Des touches apparaissent sous vos pieds.",
        ["asmr_toggle"] = "Mode Clavier ASMR", ["asmr_on"] = "Clavier ASMR ON",
        ["settings_support_title"] = "Paramètres & Support", ["settings_support_desc"] = "Changer la langue ou rejoindre Discord.",
        ["language_label"] = "Langue", ["discord_menu"] = "Discord", ["support_server"] = "Serveur Support",
        ["creator_line"] = "Créateur", ["creator_desc"] = "Fait avec amour par Beli!",
        ["ready_msg"] = "CogHub v1.2 prêt!",
        ["apply"] = "Appliquer", ["reset_default"] = "Par Défaut", ["apply_color"] = "Appliquer Couleur", ["preview"] = "Aperçu",
        ["skybox_picker"] = "Sélecteur Skybox", ["restore_sky"] = "Skybox Par Défaut", ["skybox_id_ph"] = "ID Skybox personnalisé, Entrée...",
        ["cursor_picker"] = "Sélecteur Curseur", ["cursor_id_ph"] = "ID Curseur personnalisé, Entrée...",
        ["spin_crosshair"] = "Rotation Viseur", ["gradient_mode"] = "Mode Dégradé", ["color1"] = "Couleur 1", ["color2"] = "Couleur 2 (Dégradé)",
        ["rgb_ph"] = "R,G,B exemple: 52,152,219", ["applied_suffix"] = " appliqué!", ["value_arrow"] = " -> ",
        ["gun_dropped"] = "Arme tombée sur la carte!", ["esp_remote_missing"] = "Remote ESP introuvable!",
        ["no_gun_msg"] = "Pas d'arme!", ["no_knife"] = "Pas de couteau!", ["no_target"] = "Pas de cible.", ["no_bomb"] = "Pas de bombe!",
        ["no_gun_map"] = "Pas d'arme sur la carte!", ["gun_pos_missing"] = "Position de l'arme introuvable!", ["tp_gun"] = "Téléportation vers l'arme...",
        ["is_sitting"] = " est assis.", ["returned_pos"] = "Retour à la position.", ["fling_progress"] = "Éjection en cours.",
        ["flinging_player"] = "Éjection: ", ["no_target_found"] = "Aucune cible trouvée.", ["skybox_restored"] = "Skybox restaurée.",
        ["custom_skybox"] = "Skybox personnalisée: ", ["skybox_set"] = "Skybox: ", ["custom_cursor"] = "Curseur personnalisé défini!",
        ["cursor_set"] = "Curseur: ", ["gun_on_map"] = "ARME SUR CARTE",
    },
    ["Español"] = {
        ["wait"] = "ESPERAR...", ["gold_jump"] = "SALTO\nDORADO", ["bomb_jump"] = "SALTO\nBOMBA",
        ["throw_knife"] = "TIRAR\nCUCHILLO", ["shoot"] = "DISPARAR", ["esp_on"] = "ESP ON", ["esp_off"] = "ESP OFF",
        ["flick"] = "FLICK", ["wall_hop"] = "SALTO\nMURO", ["speed_on"] = "VELOCIDAD\nON", ["speed_glitch"] = "GLITCH\nVELOCIDAD",
        ["stretch_on"] = "ESTIRAR\nON", ["stretch"] = "ESTIRAR", ["grab_gun"] = "TOMAR\nARMA", ["no_gun"] = "SIN\nARMA",
        ["flinging"] = "LANZANDO...", ["fling_m"] = "LANZAR\nASESINO", ["no_m"] = "SIN\nASESINO",
        ["fling_s"] = "LANZAR\nSHERIFF", ["no_s"] = "SIN\nSHERIFF", ["hold_on"] = "CONGELAR\nTODOS ON", ["hold"] = "CONGELAR\nTODOS",
        ["invis_on"] = "INVISIBLE\nON", ["invis_off"] = "INVISIBLE\nOFF", ["super_on"] = "SÚPER\nSALTO ON", ["super"] = "SÚPER\nSALTO",
        ["farm_on"] = "FARM\nAUTO ON", ["farm_off"] = "FARM\nAUTO OFF", ["anti_on"] = "ANTI\nLANZAR ON", ["anti_off"] = "ANTI\nLANZAR OFF",
        ["low_on"] = "GRÁFICOS\nBAJOS ON", ["low"] = "GRÁFICOS\nBAJOS",
        ["discord"] = "¡Invitación de Discord copiada!", ["lang_changed"] = "¡Idioma cambiado!",
        ["popup_title"] = "CogHub MM2", ["popup_content"] = "v1.2  |  Red Edition  |  por Beli!", ["ok"] = "OK",
        ["window_author"] = "Beli!  |  MM2 v14", ["section_title"] = "CogHub v1.2  |  Red Edition", ["tab_main"] = "Principal",
        ["load_buttons_title"] = "Cargar Botones", ["load_buttons_desc"] = "Activa botones flotantes uno por uno. Desactivar los quita de pantalla.",
        ["gui_gold_jump"] = "Salto Dorado", ["gui_bomb_jump"] = "Salto Bomba", ["gui_shoot_throw"] = "Disparar / Lanzar",
        ["gui_esp"] = "ESP", ["gui_flick"] = "Flick", ["gui_speed_glitch"] = "Glitch Velocidad",
        ["gui_speed_amount"] = "Cantidad Velocidad", ["gui_speed_amount_desc"] = "Velocidad del glitch (16-500)",
        ["gui_stretch"] = "Estirar", ["gui_stretch_amount"] = "Cantidad Estirar", ["gui_stretch_amount_desc"] = "Cantidad de estiramiento (1-200)",
        ["gui_grab_gun"] = "Tomar Arma", ["gui_wall_hop"] = "Salto Muro", ["gui_fling_murderer"] = "Lanzar Asesino",
        ["gui_fling_sheriff"] = "Lanzar Sheriff", ["gui_hold_everyone"] = "Congelar Todos", ["gui_invisible"] = "Invisible",
        ["gui_super_jump"] = "Súper Salto", ["gui_super_jump_power"] = "Poder Súper Salto", ["gui_super_jump_power_desc"] = "Poder de salto (50-500)",
        ["gui_auto_farm"] = "Farm Auto", ["gui_anti_fling"] = "Anti-Lanzar", ["gui_low_graphics"] = "Gráficos Bajos",
        ["esp_settings_title"] = "Ajustes ESP", ["esp_settings_desc"] = "¿Qué roles mostrar?",
        ["show_murderer"] = "Mostrar Asesino", ["show_sheriff"] = "Mostrar Sheriff", ["show_hero"] = "Mostrar Héroe",
        ["show_innocents"] = "Mostrar Inocentes", ["show_self"] = "Mostrarse a Sí", ["dropped_gun_esp"] = "ESP Arma Caída",
        ["crosshair_title"] = "Mira", ["crosshair_desc"] = "Mira personalizada + color + gradiente. ShiftLock debe estar activo.",
        ["custom_crosshair"] = "Mira Personalizada", ["crosshair_picker"] = "Selector Mira + Colores",
        ["crosshair_picker_desc"] = "Cursor preset + Giro + Color + Gradiente",
        ["crosshair_size"] = "Tamaño Mira", ["crosshair_size_desc"] = "16px - 96px",
        ["crosshair_on"] = "Mira ON - ¡Activa ShiftLock!", ["skybox_title"] = "Skybox", ["skybox_desc"] = "7 presets + ID personalizado.",
        ["skybox_picker_btn"] = "Selector Skybox", ["asmr_title"] = "Caminata Teclado ASMR", ["asmr_desc"] = "Teclas aparecen bajo tus pies.",
        ["asmr_toggle"] = "Modo Teclado ASMR", ["asmr_on"] = "Teclado ASMR ON",
        ["settings_support_title"] = "Ajustes y Soporte", ["settings_support_desc"] = "Cambia idioma o únete a Discord.",
        ["language_label"] = "Idioma", ["discord_menu"] = "Discord", ["support_server"] = "Servidor de Soporte",
        ["creator_line"] = "Creador", ["creator_desc"] = "Hecho con amor por Beli!",
        ["ready_msg"] = "¡CogHub v1.2 listo!",
        ["apply"] = "Aplicar", ["reset_default"] = "Restablecer", ["apply_color"] = "Aplicar Color", ["preview"] = "Vista Previa",
        ["skybox_picker"] = "Selector Skybox", ["restore_sky"] = "Skybox Predeterminado", ["skybox_id_ph"] = "ID Skybox personalizado, Enter...",
        ["cursor_picker"] = "Selector Cursor", ["cursor_id_ph"] = "ID Cursor personalizado, Enter...",
        ["spin_crosshair"] = "Girar Mira", ["gradient_mode"] = "Modo Gradiente", ["color1"] = "Color 1", ["color2"] = "Color 2 (Gradiente)",
        ["rgb_ph"] = "R,G,B ejemplo: 52,152,219", ["applied_suffix"] = " aplicado!", ["value_arrow"] = " -> ",
        ["gun_dropped"] = "¡Arma caída en el mapa!", ["esp_remote_missing"] = "¡Remote ESP no encontrado!",
        ["no_gun_msg"] = "¡Sin arma!", ["no_knife"] = "¡Sin cuchillo!", ["no_target"] = "Sin objetivo.", ["no_bomb"] = "¡Sin bomba!",
        ["no_gun_map"] = "¡Sin arma en el mapa!", ["gun_pos_missing"] = "¡Posición del arma no encontrada!", ["tp_gun"] = "Teletransportando al arma...",
        ["is_sitting"] = " está sentado.", ["returned_pos"] = "Regresado a la posición.", ["fling_progress"] = "Lanzamiento en progreso.",
        ["flinging_player"] = "Lanzando: ", ["no_target_found"] = "Objetivo no encontrado.", ["skybox_restored"] = "Skybox restaurado.",
        ["custom_skybox"] = "Skybox personalizado: ", ["skybox_set"] = "Skybox: ", ["custom_cursor"] = "¡Cursor personalizado establecido!",
        ["cursor_set"] = "Cursor: ", ["gun_on_map"] = "ARMA EN MAPA",
    },
}
local function T(key)
    if LOC[currentLang] and LOC[currentLang][key] then return LOC[currentLang][key] end
    return LOC["English"][key] or key
end

-- ================================================================
--  WINDUI
-- ================================================================
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"
))()
pcall(function() WindUI:SetTheme("Ocean") end)

local function Notify(content)
    WindUI:Notify({ Title = "CogHub", Content = tostring(content), Duration = 3, Icon = "bell" })
end

local guiRefs = {}
local Window, NavSec, Tab

local function OpenDiscord()
    pcall(function()
        if setclipboard then setclipboard(DISCORD_INVITE) end
    end)
    pcall(function()
        if typeof(openurl) == "function" then openurl(DISCORD_INVITE) end
    end)
    pcall(function()
        if syn and typeof(syn.open_url) == "function" then syn.open_url(DISCORD_INVITE) end
    end)
    Notify(T("discord"))
end

local function SetEl(el, titleKey, descKey)
    if not el then return end
    pcall(function()
        if titleKey and el.SetTitle then el:SetTitle(T(titleKey)) end
        if descKey and el.SetDesc then el:SetDesc(T(descKey)) end
    end)
end

local function RefreshGUILanguage()
    pcall(function()
        if Window and Window.SetTitle then Window:SetTitle("CogHub") end
        if Window and Window.SetAuthor then Window:SetAuthor(T("window_author")) end
    end)
    SetEl(NavSec, "section_title")
    SetEl(Tab, "tab_main")
    for key, el in pairs(guiRefs) do
        if type(el) == "table" and el.titleKey then
            SetEl(el.ref, el.titleKey, el.descKey)
        end
    end
    pcall(function()
        if guiRefs.langDropdown and guiRefs.langDropdown.SetTitle then
            guiRefs.langDropdown:SetTitle(T("language_label"))
        end
        if guiRefs.discordDropdown and guiRefs.discordDropdown.SetTitle then
            guiRefs.discordDropdown:SetTitle(T("discord_menu"))
        end
    end)
end

local function ChangeLanguage(lang)
    if not LOC[lang] then return end
    currentLang = lang
    RefreshGUILanguage()
    Notify(T("lang_changed"))
end

local function Track(ref, titleKey, descKey)
    guiRefs[titleKey] = { ref = ref, titleKey = titleKey, descKey = descKey }
    return ref
end

local function MakeDraggable(handle, frame)
    local pd, ps, pp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            pd = true; ps = i.Position; pp = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(i)
        if not pd then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - ps
            frame.Position = UDim2.new(pp.X.Scale, pp.X.Offset + d.X, pp.Y.Scale, pp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pd = false end
    end)
end

-- Slider popup (genel amacli)
local function OpenSliderPopup(title, minVal, maxVal, defaultVal, step, onApply, onReset)
    local uid = "CogSlider_" .. title:gsub("[%s%/%(%)%%]", "_")
    local ex = game.CoreGui:FindFirstChild(uid); if ex then ex:Destroy(); return end
    local sg = Instance.new("ScreenGui", game.CoreGui); sg.Name = uid; sg.ResetOnSpawn = false; sg.DisplayOrder = 55
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 320, 0, 185)
    frame.Position = UDim2.new(0.5, -160, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local fs = Instance.new("UIStroke", frame); fs.Color = BLUE; fs.Thickness = 2
    -- Gradient on stroke
    local fsg = Instance.new("UIGradient", fs)
    fsg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   BLUE),
        ColorSequenceKeypoint.new(0.5, BLUE_DARK),
        ColorSequenceKeypoint.new(1,   BLUE),
    })
    task.spawn(function() local r=0; while frame and frame.Parent do r=(r+2)%360; fsg.Rotation=r; RunService.RenderStepped:Wait() end end)
    local hdr = Instance.new("TextLabel", frame); hdr.Size = UDim2.new(1,-44,0,36); hdr.Position = UDim2.new(0,14,0,0); hdr.BackgroundTransparency=1; hdr.Text="CogHub  |  "..title; hdr.TextColor3=Color3.fromRGB(255,255,255); hdr.Font=Enum.Font.GothamBold; hdr.TextSize=14; hdr.TextXAlignment=Enum.TextXAlignment.Left
    local xBtn = Instance.new("TextButton", frame); xBtn.Size=UDim2.new(0,28,0,28); xBtn.Position=UDim2.new(1,-34,0,4); xBtn.BackgroundColor3=BLUE_DARK; xBtn.Text="X"; xBtn.TextColor3=Color3.new(1,1,1); xBtn.Font=Enum.Font.GothamBold; xBtn.TextSize=13; Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,6)
    xBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    local currentVal = defaultVal
    local valLbl = Instance.new("TextLabel", frame); valLbl.Size=UDim2.new(1,0,0,22); valLbl.Position=UDim2.new(0,0,0,38); valLbl.BackgroundTransparency=1; valLbl.Text=title..":  "..tostring(currentVal); valLbl.TextColor3=Color3.fromRGB(210,210,210); valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=13
    local track = Instance.new("Frame", frame); track.Size=UDim2.new(1,-30,0,10); track.Position=UDim2.new(0,15,0,74); track.BackgroundColor3=Color3.fromRGB(40,40,40); track.BorderSizePixel=0; Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local r0 = (currentVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame", track); fill.Size=UDim2.new(r0,0,1,0); fill.BackgroundColor3=BLUE; fill.BorderSizePixel=0; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob = Instance.new("TextButton", track); knob.Size=UDim2.new(0,26,0,26); knob.Position=UDim2.new(r0,-13,0.5,-13); knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.Text=""; knob.AutoButtonColor=false; knob.BorderSizePixel=0; Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local function updateFromX(sx)
        local rel = math.clamp((sx - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        currentVal = math.round(minVal + rel * (maxVal - minVal))
        if step and step > 0 then currentVal = math.round(currentVal / step) * step end
        local r2 = (currentVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(r2,0,1,0); knob.Position = UDim2.new(r2,-13,0.5,-13)
        valLbl.Text = title..":  "..tostring(currentVal)
    end
    local dragging = false
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; updateFromX(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if not dragging then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then updateFromX(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    local btnRow = Instance.new("Frame", frame); btnRow.Size=UDim2.new(1,-20,0,36); btnRow.Position=UDim2.new(0,10,0,136); btnRow.BackgroundTransparency=1
    local applyBtn = Instance.new("TextButton", btnRow); applyBtn.Size=UDim2.new(0.48,0,1,0); applyBtn.BackgroundColor3=Color3.fromRGB(20,160,20); applyBtn.Text=T("apply"); applyBtn.TextColor3=Color3.new(1,1,1); applyBtn.Font=Enum.Font.GothamBold; applyBtn.TextSize=13; Instance.new("UICorner",applyBtn).CornerRadius=UDim.new(0,6)
    applyBtn.MouseButton1Click:Connect(function() onApply(currentVal); Notify(title..T("value_arrow")..currentVal) end)
    local resetBtn = Instance.new("TextButton", btnRow); resetBtn.Size=UDim2.new(0.48,0,1,0); resetBtn.Position=UDim2.new(0.52,0,0,0); resetBtn.BackgroundColor3=BLUE_DARK; resetBtn.Text=T("reset_default"); resetBtn.TextColor3=Color3.new(1,1,1); resetBtn.Font=Enum.Font.GothamBold; resetBtn.TextSize=13; Instance.new("UICorner",resetBtn).CornerRadius=UDim.new(0,6)
    resetBtn.MouseButton1Click:Connect(function() onReset(); sg:Destroy() end)
    MakeDraggable(frame, frame)
end

-- ================================================================
--  PREDICTION PART
-- ================================================================
local predPart = Instance.new("Part"); predPart.Name="CogPredPart"; predPart.Size=Vector3.new(0.5,0.5,0.5); predPart.Anchored=true; predPart.CanCollide=false; predPart.Transparency=1; predPart.Parent=Workspace

-- ================================================================
--  GUN DROP ESP
-- ================================================================
local gunMarker = nil
local function ClearGunMarker() if gunMarker then gunMarker:Destroy(); gunMarker=nil end end
local function FindGunDrop() return Workspace:FindFirstChild("GunDrop", true) end
local function PlaceGunMarker(pos)
    ClearGunMarker()
    local p = Instance.new("Part"); p.Name="CogGunMarker"; p.Size=Vector3.new(1.5,0.15,1.5); p.Anchored=true; p.CanCollide=false; p.CastShadow=false; p.Material=Enum.Material.Neon; p.Color=BLUE; p.Transparency=0.25; p.CFrame=CFrame.new(pos); p.Parent=Workspace
    task.spawn(function() while p and p.Parent do for t=0,1,0.05 do if not(p and p.Parent) then break end; p.Transparency=0.25+0.5*math.sin(t*math.pi); task.wait(0.03) end end end)
    gunMarker = p
end

local activeHL = nil; local activeBB = nil
local function ClearGunESP() if activeHL then activeHL:Destroy(); activeHL=nil end; if activeBB then activeBB:Destroy(); activeBB=nil end end
local function ApplyGunESP(gunDrop)
    if not droppedGunEspEnabled then return end; ClearGunESP()
    local hl = Instance.new("Highlight"); hl.Adornee=gunDrop; hl.FillColor=BLUE; hl.OutlineColor=Color3.fromRGB(255,255,255); hl.FillTransparency=0.35; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=gunDrop; activeHL=hl
    local handle = gunDrop:FindFirstChild("Handle") or (gunDrop:IsA("Model") and gunDrop.PrimaryPart) or gunDrop:FindFirstChildWhichIsA("BasePart")
    if not handle and gunDrop:IsA("BasePart") then handle = gunDrop end
    if handle then
        PlaceGunMarker(handle.Position + Vector3.new(0,0.1,0))
        local bb = Instance.new("BillboardGui"); bb.Adornee=handle; bb.Size=UDim2.new(0,130,0,36); bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true; bb.MaxDistance=300; bb.Parent=handle
        local bg = Instance.new("Frame", bb); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(0,0,0); bg.BackgroundTransparency=0.4; bg.BorderSizePixel=0; Instance.new("UICorner",bg).CornerRadius=UDim.new(0,6)
        local bgS = Instance.new("UIStroke", bg); bgS.Color=BLUE; bgS.Thickness=1.5
        local lbl = Instance.new("TextLabel", bg); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=T("gun_on_map"); lbl.TextColor3=BLUE; lbl.Font=Enum.Font.GothamBlack; lbl.TextSize=13; lbl.TextStrokeTransparency=0.4; activeBB=bb
    end
end
local function OnGunFound(gd) ApplyGunESP(gd); Notify(T("gun_dropped")) end
local function OnGunRemoved() ClearGunESP(); ClearGunMarker() end
local watchedFolders = {}
local function WatchFolder(folder)
    if watchedFolders[folder] then return end; watchedFolders[folder]=true
    folder.ChildAdded:Connect(function(obj)
        if obj.Name=="GunDrop" then task.wait(0.1); OnGunFound(obj) end
        if obj:IsA("Model") or obj:IsA("Folder") then WatchFolder(obj) end
    end)
    folder.ChildRemoved:Connect(function(obj) if obj.Name=="GunDrop" then OnGunRemoved() end end)
    for _,c in ipairs(folder:GetChildren()) do if c:IsA("Model") or c:IsA("Folder") then WatchFolder(c) end end
end
WatchFolder(Workspace)
Workspace.ChildAdded:Connect(function(obj)
    if obj:IsA("Model") or obj:IsA("Folder") then WatchFolder(obj) end
    if obj.Name=="GunDrop" then task.wait(0.1); OnGunFound(obj) end
end)
task.spawn(function() task.wait(1.5); local ex=FindGunDrop(); if ex then OnGunFound(ex) end end)
local function WatchSheriff(p)
    local function hook(char)
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 5); if not hum then return end
        hum.Died:Connect(function()
            if p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then
                task.delay(0.8, function() local gd=FindGunDrop(); if gd then OnGunFound(gd) end end)
            end
        end)
    end
    if p.Character then hook(p.Character) end
    p.CharacterAdded:Connect(hook)
end
for _,p in ipairs(Players:GetPlayers()) do if p~=player then task.spawn(WatchSheriff,p) end end
Players.PlayerAdded:Connect(function(p) if p~=player then WatchSheriff(p) end end)

-- ================================================================
--  ESP
-- ================================================================
local function GetRole(p)
    local role="Innocent"; local pData=rolesData[p.Name]
    if pData then
        local r = tostring(pData.Role or pData.role or pData.Team or ""):lower()
        if r:find("murd") then role="Murderer" elseif r:find("sheriff") or r:find("gun") then role="Sheriff" elseif r:find("hero") then role="Hero" end
    end
    return role
end
local function ApplyHL(char,color) local hl=char:FindFirstChild("CogHub_ESP") or Instance.new("Highlight"); hl.Name="CogHub_ESP"; hl.Parent=char; hl.FillColor=color; hl.FillTransparency=0.70; hl.OutlineColor=Color3.fromRGB(255,255,255); hl.OutlineTransparency=0.15; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end
local function RemoveHL(char) local hl=char:FindFirstChild("CogHub_ESP"); if hl then hl:Destroy() end end
local function ClearAllESP() for _,p in ipairs(Players:GetPlayers()) do if p.Character then RemoveHL(p.Character) end end; rolesData={}; lastEspTick=0 end
local function StartESP()
    local remote = ReplicatedStorage:FindFirstChild("GetCurrentPlayerData", true)
    if not remote or not remote:IsA("RemoteFunction") then Notify(T("esp_remote_missing")); espEnabled=false; return end
    if espConn then espConn:Disconnect(); espConn=nil end
    espConn = RunService.Heartbeat:Connect(function()
        if not espEnabled then return end
        if tick()-lastEspTick > 0.5 then
            local ok,data = pcall(function() return remote:InvokeServer() end)
            if ok and type(data)=="table" then rolesData=data end
            lastEspTick=tick()
        end
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local role=GetRole(p); local show=espSettings[role]
                if p==player and not espSettings.Self then show=false end
                if show then ApplyHL(p.Character, ESP_COLORS[role]) else RemoveHL(p.Character) end
            end
        end
    end)
end
local function StopESP() if espConn then espConn:Disconnect(); espConn=nil end; task.delay(0.1,ClearAllESP) end
local function SetESP(on) espEnabled=on; if on then StartESP() else StopESP() end end

-- ================================================================
--  WEAPONS & TARGET
-- ================================================================
local function HasKnife(p) return p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) end
local function HasGun(p) return p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) end
local function FindBestTarget()
    local myChar=player.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end
    local myHK=HasKnife(player); local myHG=HasGun(player); local best,bestDist=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            local c=p.Character; local hum=c:FindFirstChildOfClass("Humanoid")
            if not(hum and hum.Health>0) then continue end
            local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local thk=HasKnife(p); local thg=HasGun(p)
            local dist=(hrp.Position-myHRP.Position).Magnitude; local valid=false
            if myHK then if thk then valid=true end
            elseif myHG then if thg or thk then valid=true end
            else if thk then valid=true; dist=dist-1000 end; if thg then valid=true end end
            if valid and dist<bestDist then bestDist=dist; best=c end
        end
    end
    if not best then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player and p.Character then
                local c=p.Character; local hum=c:FindFirstChildOfClass("Humanoid"); local hrp=c:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health>0 and hrp then
                    local dist=(hrp.Position-myHRP.Position).Magnitude
                    if dist<bestDist then bestDist=dist; best=c end
                end
            end
        end
    end
    return best
end

-- ================================================================
--  PREDICTION LOOP (geliştirilmiş)
-- ================================================================
local prevVel = {}
local prevVelTime = {}
RunService.RenderStepped:Connect(function()
    local tgt=FindBestTarget(); currentTarget=tgt; if not tgt then return end
    local myChar=player.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local torso=tgt:FindFirstChild("UpperTorso") or tgt:FindFirstChild("Torso") or tgt:FindFirstChild("HumanoidRootPart")
    local hum=tgt:FindFirstChildOfClass("Humanoid"); if not torso then return end
    local tHRP=tgt:FindFirstChild("HumanoidRootPart") or torso
    local vel=tHRP.AssemblyLinearVelocity
    local aimPos=torso.Position
    local dist=(aimPos-myHRP.Position).Magnitude
    -- Mesafeye gore bullet/knife speed sec
    local speed=HasKnife(player) and KNIFE_SPEED or BULLET_SPEED
    local tt=dist/speed
    -- Ping ekle
    local ping=0
    if autoPingPred then pcall(function() ping=player:GetNetworkPing() end) end
    tt=tt+ping*0.5
    -- Acceleration tahmini (onceki frame ile karsilastir)
    local now=tick()
    local accel=Vector3.new(0,0,0)
    local uid=tHRP:GetDebugId()
    if prevVel[uid] and prevVelTime[uid] then
        local dt=now-prevVelTime[uid]
        if dt>0 and dt<0.5 then
            accel=(vel-prevVel[uid])/dt
            -- Sadece yatay ivme, Y'yi ignore et (jump/gravity)
            accel=Vector3.new(accel.X*0.3, 0, accel.Z*0.3)
        end
    end
    prevVel[uid]=vel; prevVelTime[uid]=now
    -- Jumping/falling durumunda Y velocity azalt
    local predVel=vel
    if hum then
        local state=hum:GetState()
        if state==Enum.HumanoidStateType.Freefall or state==Enum.HumanoidStateType.Jumping then
            predVel=Vector3.new(vel.X, vel.Y*0.25, vel.Z)
        end
    end
    -- Nihai prediction: vel * tt + 0.5 * accel * tt^2
    local predPos=aimPos + predVel*tt + accel*(tt*tt*0.5)
    predPart.CFrame=CFrame.new(predPos)
end)


-- ================================================================
--  SHOOT & KNIFE
-- ================================================================
local function AutoKill()
    local char=player.Character; if not char then return end
    local myHRP=char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local gun=player.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun"); if not gun then Notify(T("no_gun_msg")); return end
    if not currentTarget then Notify(T("no_target")); return end
    if gun.Parent~=char then char.Humanoid:EquipTool(gun); task.wait(0) end
    local tPos=predPart.CFrame.Position
    pcall(function() gun:WaitForChild("Shoot"):FireServer(CFrame.new(myHRP.Position+Vector3.new(0,1,0),tPos),CFrame.new(tPos)) end)
end
local function ThrowKnife()
    local char=player.Character; if not char then return end
    local myHRP=char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local knife=player.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife"); if not knife then Notify(T("no_knife")); return end
    if knife.Parent~=char then char.Humanoid:EquipTool(knife); task.wait(0) end
    local tgtChar=currentTarget
    if not tgtChar then
        local nd=math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart"); local hum=p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health>0 then local d=(hrp.Position-myHRP.Position).Magnitude; if d<nd then nd=d; tgtChar=p.Character end end
            end
        end
    end
    if not tgtChar then Notify(T("no_target")); return end
    local tHRP=tgtChar:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
    local torso=tgtChar:FindFirstChild("UpperTorso") or tgtChar:FindFirstChild("Torso") or tHRP
    local vel=tHRP.AssemblyLinearVelocity; local dist=(torso.Position-myHRP.Position).Magnitude; local extra=0
    if autoPingPred then local ok,ping=pcall(function() return player:GetNetworkPing() end); extra=ok and ping or 0 end
    local predPos=torso.Position+Vector3.new(vel.X,0,vel.Z)*(dist/KNIFE_SPEED+extra*0.5)
    pcall(function() knife:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(CFrame.new(myHRP.Position,predPos),CFrame.new(predPos)) end)
end
local function SmartShoot() if HasKnife(player) then ThrowKnife() else AutoKill() end end

local FLICK_ROTATION = 180

-- ================================================================
--  FLICK  (tek buton, rotation slider ile)
-- ================================================================
local function DoSmartFlick()
    if flickCD then return end
    local char=player.Character; if not char then return end
    local myHRP=char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    flickCD=true
    local rad=math.rad(FLICK_ROTATION)
    local isSL=UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter
    local STEPS=math.max(4, math.floor(FLICK_ROTATION/30))
    if not isSL then
        local s=myHRP.CFrame
        local t=s*CFrame.Angles(0,rad,0)
        for i=1,STEPS do myHRP.CFrame=s:Lerp(t,i/STEPS); RunService.RenderStepped:Wait() end
    else
        local camCF=Camera.CFrame; local look=camCF.LookVector
        local cosR=math.cos(rad); local sinR=math.sin(rad)
        local rx=cosR*look.X - sinR*look.Z; local rz=sinR*look.X + cosR*look.Z
        local nl=Vector3.new(rx, look.Y, rz)
        local tgt=CFrame.lookAt(camCF.Position, camCF.Position+nl)
        for i=1,STEPS do Camera.CFrame=camCF:Lerp(tgt,i/STEPS); RunService.RenderStepped:Wait() end
    end
    task.wait(0.15); flickCD=false
end

-- ================================================================
--  WALL HOP
-- ================================================================
local function DoWallHop()
    if wallhopCD then return end
    local char=player.Character; if not char then return end
    local myHRP=char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    wallhopCD=true
    local isSL=UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter
    local _,origYaw,_=myHRP.CFrame:ToEulerAnglesYXZ(); local origCamCF=Camera.CFrame; local STEPS=7
    if not isSL then
        local ty=origYaw-math.pi/2
        for i=1,STEPS do local e=1-(1-i/STEPS)^2; myHRP.CFrame=CFrame.new(myHRP.Position)*CFrame.fromEulerAnglesYXZ(0,origYaw+(ty-origYaw)*e,0); RunService.RenderStepped:Wait() end
    else
        local ol=Vector3.new(origCamCF.LookVector.X,0,origCamCF.LookVector.Z).Unit
        local tl=Vector3.new(origCamCF.RightVector.X,0,origCamCF.RightVector.Z).Unit
        for i=1,STEPS do local e=1-(1-i/STEPS)^2; Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,Camera.CFrame.Position+ol:Lerp(tl,e).Unit); RunService.RenderStepped:Wait() end
    end
    local v=myHRP.AssemblyLinearVelocity; myHRP.AssemblyLinearVelocity=Vector3.new(v.X,55,v.Z)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    task.wait(0.12)
    if not isSL then
        local _,cy,_=myHRP.CFrame:ToEulerAnglesYXZ()
        for i=1,5 do local e=1-(1-i/5)^2; myHRP.CFrame=CFrame.new(myHRP.Position)*CFrame.fromEulerAnglesYXZ(0,cy+(origYaw-cy)*e,0); RunService.RenderStepped:Wait() end
    else
        local ol=Vector3.new(origCamCF.LookVector.X,0,origCamCF.LookVector.Z).Unit
        local cl=Vector3.new(Camera.CFrame.LookVector.X,0,Camera.CFrame.LookVector.Z).Unit
        for i=1,5 do local e=1-(1-i/5)^2; Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,Camera.CFrame.Position+cl:Lerp(ol,e).Unit); RunService.RenderStepped:Wait() end
    end
    task.wait(0.10); wallhopCD=false
end

-- ================================================================
--  BOMB ENGINE
-- ================================================================
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer("FakeBomb")
            ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer("GoldBomb")
        end)
    end
end)
local function ExecuteJump(bombName, isGold)
    local char=player.Character; if not char then return end
    local bomb=player.Backpack:FindFirstChild(bombName) or char:FindFirstChild(bombName)
    if not bomb then Notify(T("no_bomb")); return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if bomb.Parent~=char then char.Humanoid:EquipTool(bomb); task.wait() end
    pcall(function() bomb.Remote:FireServer(CFrame.new(hrp.Position+hrp.CFrame.LookVector*1.5+Vector3.new(0,-3,0)),50) end)
    char.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,62,hrp.AssemblyLinearVelocity.Z)
    if isGold then task.spawn(function() goldCD=true; task.wait(4); goldCD=false end)
    else task.spawn(function() normalCD=true; task.wait(21); normalCD=false end) end
end

-- ================================================================
--  SPEED GLITCH
-- ================================================================
local function SetupSpeedGlitch(char)
    local hum=char:WaitForChild("Humanoid"); if speedConn then speedConn:Disconnect() end
    speedConn=RunService.RenderStepped:Connect(function()
        if not speedEnabled then hum.WalkSpeed=BASE_WALK_SPEED; return end
        local state=hum:GetState()
        local inAir = state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall
        hum.WalkSpeed = (inAir and hum.MoveDirection.Magnitude>0) and SPEED_AMOUNT or BASE_WALK_SPEED
    end)
end
player.CharacterAdded:Connect(SetupSpeedGlitch)
if player.Character then task.spawn(SetupSpeedGlitch, player.Character) end

-- ================================================================
--  STRETCH
-- ================================================================
local function SetStretch(on)
    stretchEnabled=on
    if on then
        if stretchConn then stretchConn:Disconnect() end
        stretchConn=RunService.RenderStepped:Connect(function()
            Camera.CFrame=Camera.CFrame*CFrame.new(0,0,0,1,0,0,0,STRETCH_AMOUNT/100,0,0,0,1)
        end)
    else
        if stretchConn then stretchConn:Disconnect(); stretchConn=nil end
    end
end

-- ================================================================
--  GRAB GUN
-- ================================================================
local function DoGrabGun()
    local gd=FindGunDrop(); if not gd then Notify(T("no_gun_map")); return end
    local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local targetPos
    if gd:IsA("BasePart") then targetPos=gd.Position
    else local part=gd:FindFirstChild("Handle") or gd:FindFirstChildWhichIsA("BasePart") or gd.PrimaryPart; targetPos=part and part.Position or gd:GetModelCFrame().Position end
    if not targetPos then Notify(T("gun_pos_missing")); return end
    local goal = { CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0)) }
    local tween = TweenService:Create(hrp, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play(); Notify(T("tp_gun"))
end

-- ================================================================
--  ANTI-FLING  (4-layer protection)
-- ================================================================
local function SetAntiFling(on)
    antiFlingEnabled=on
    if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn=nil end
    if not on then return end
    local lastSafePos=nil; local lastSafeTime=tick(); local consecutiveSafe=0
    antiFlingConn=RunService.Heartbeat:Connect(function()
        if not antiFlingEnabled then return end
        local c=player.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hum=c:FindFirstChildOfClass("Humanoid")
        local vel=hrp.AssemblyLinearVelocity; local speed=vel.Magnitude
        -- Layer 1: speed cap
        if speed > MAX_VELOCITY then
            hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
            if lastSafePos then pcall(function() hrp.CFrame=lastSafePos end) end
            return
        end
        -- Layer 2: rotation lock
        if hrp.AssemblyAngularVelocity.Magnitude > 10 then
            hrp.AssemblyAngularVelocity=Vector3.new(0,0,0)
        end
        -- Layer 3: height guard
        if lastSafePos then
            local heightDiff=hrp.Position.Y - lastSafePos.Position.Y
            if heightDiff > 80 then
                pcall(function() hrp.CFrame=lastSafePos end)
                hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
                return
            end
        end
        -- save safe pos
        local now=tick()
        if speed < 30 and hum and (hum:GetState()==Enum.HumanoidStateType.Running or hum:GetState()==Enum.HumanoidStateType.Standing) then
            consecutiveSafe=consecutiveSafe+1
            if consecutiveSafe>=3 and (now-lastSafeTime)>0.5 then
                lastSafePos=hrp.CFrame; lastSafeTime=now; consecutiveSafe=0
            end
        else consecutiveSafe=0 end
        -- Layer 4: remove injected body movers
        for _,v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyPosition") or v:IsA("BodyAngularVelocity") then
                if not v:GetAttribute("CogOwned") then v:Destroy() end
            end
        end
    end)
end

-- ================================================================
--  FLING ENGINE
-- ================================================================
getgenv().CogOldPos=nil; getgenv().CogFPDH=Workspace.FallenPartsDestroyHeight
local function SkidFling(targetPlayer)
    if flingBusy then return end
    local char=player.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local myHRP=hum.RootPart; if not myHRP then return end
    local tChar=targetPlayer.Character; if not tChar then return end
    local tHum=tChar:FindFirstChildOfClass("Humanoid"); local tHRP=tHum and tHum.RootPart
    local tHead=tChar:FindFirstChild("Head"); local acc=tChar:FindFirstChildOfClass("Accessory"); local aHandle=acc and acc:FindFirstChild("Handle")
    if myHRP.Velocity.Magnitude<50 then getgenv().CogOldPos=myHRP.CFrame end
    if tHum and tHum.Sit then Notify(targetPlayer.Name..T("is_sitting")); return end
    local camSubj=tHead or aHandle or tHum; if camSubj then Workspace.CurrentCamera.CameraSubject=camSubj end
    local function FPos(base,offset,ang)
        myHRP.CFrame=CFrame.new(base.Position)*offset*ang
        pcall(function() char:SetPrimaryPartCFrame(CFrame.new(base.Position)*offset*ang) end)
        myHRP.Velocity=Vector3.new(9e7,9e7*10,9e7); myHRP.RotVelocity=Vector3.new(9e8,9e8,9e8)
    end
    local function RunFling(basePart)
        local deadline=tick()+2.5; local angle=0
        repeat
            if not(myHRP and tHum) then break end
            local spd=basePart.Velocity.Magnitude
            if spd<40 then
                angle=angle+100
                FPos(basePart,CFrame.new(0,1.5,0)+tHum.MoveDirection*spd/1.25,CFrame.Angles(math.rad(angle),0,0)); task.wait()
                FPos(basePart,CFrame.new(0,-1.5,0)+tHum.MoveDirection*spd/1.25,CFrame.Angles(math.rad(angle),0,0)); task.wait()
            else
                local dir=tHum.MoveDirection; local ws=tHum.WalkSpeed
                FPos(basePart,CFrame.new(dir.X*ws*0.12,3,dir.Z*ws*0.12),CFrame.Angles(math.rad(90),0,0)); myHRP.Velocity=Vector3.new(9e8,9e8,9e8); task.wait()
                FPos(basePart,CFrame.new(-dir.X*ws*0.06,-3,-dir.Z*ws*0.06),CFrame.Angles(0,0,0)); myHRP.Velocity=Vector3.new(9e8,9e8,9e8); task.wait()
            end
        until tick()>deadline
    end
    flingBusy=true; Workspace.FallenPartsDestroyHeight=0/0
    local bv=Instance.new("BodyVelocity"); bv:SetAttribute("CogOwned",true); bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Parent=myHRP
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    local basePart=tHRP or tHead or aHandle; if basePart then RunFling(basePart) end
    bv:Destroy(); hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true); Workspace.CurrentCamera.CameraSubject=hum
    if getgenv().CogOldPos then
        local attempts=0
        repeat
            attempts=attempts+1
            myHRP.CFrame=getgenv().CogOldPos*CFrame.new(0,0.5,0)
            pcall(function() char:SetPrimaryPartCFrame(getgenv().CogOldPos*CFrame.new(0,0.5,0)) end)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            for _,p in ipairs(char:GetChildren()) do if p:IsA("BasePart") then p.Velocity=Vector3.new(); p.RotVelocity=Vector3.new() end end
            task.wait()
        until attempts>30 or (myHRP.Position-getgenv().CogOldPos.p).Magnitude<25
        Workspace.FallenPartsDestroyHeight=getgenv().CogFPDH; Notify(T("returned_pos"))
    end
    flingBusy=false
end
local function FlingMurderer()
    if flingBusy then Notify(T("fling_progress")); return end
    -- Sadece bıçak taşıyan ilk oyuncuyu fling et, silah bekleme
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            local c=p.Character; local hum=c:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 and HasKnife(p) then
                Notify(T("flinging_player")..p.Name); task.spawn(SkidFling,p); return
            end
        end
    end
    -- ESP ile tespit edilmis murderer yoksa en yakin oyuncuyu dene
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            local c=p.Character; local hum=c:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 then
                Notify(T("flinging_player")..p.Name); task.spawn(SkidFling,p); return
            end
        end
    end
    Notify(T("no_target_found"))
end
local function FlingSheriff()
    if flingBusy then Notify(T("fling_progress")); return end
    -- Sadece silah taşıyan ilk oyuncuyu fling et, bekleme yok
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            local c=p.Character; local hum=c:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 and HasGun(p) then
                Notify(T("flinging_player")..p.Name); task.spawn(SkidFling,p); return
            end
        end
    end
    -- Silah taşıyan yoksa en yakın oyuncuya dene
    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local best, bestDist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart"); local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 and myHRP then
                local d=(hrp.Position-myHRP.Position).Magnitude
                if d<bestDist then bestDist=d; best=p end
            end
        end
    end
    if best then Notify("Flinging: "..best.Name); task.spawn(SkidFling,best)
    else Notify(T("no_target_found")) end
end

-- ================================================================
--  LOW GRAPHICS
-- ================================================================
local lgStarGui=Instance.new("ScreenGui",game.CoreGui); lgStarGui.Name="CogLGStar"; lgStarGui.ResetOnSpawn=false; lgStarGui.DisplayOrder=40
local lgStarLbl=Instance.new("TextLabel",lgStarGui); lgStarLbl.Size=UDim2.new(0,28,0,28); lgStarLbl.Position=UDim2.new(1,-34,0,4); lgStarLbl.BackgroundTransparency=1; lgStarLbl.Text="*"; lgStarLbl.TextColor3=BLUE; lgStarLbl.Font=Enum.Font.GothamBold; lgStarLbl.TextSize=22; lgStarLbl.Visible=false
local function ApplyLGToInstance(v)
    if v:IsA("BasePart") then
        if not origPartData[v] then origPartData[v]={Material=v.Material,CastShadow=v.CastShadow} end
        v.Material=Enum.Material.SmoothPlastic; v.CastShadow=false
    end
    if v:IsA("Decal") or v:IsA("Texture") then
        if not origPartData[v] then origPartData[v]={Transparency=v.Transparency} end
        v.Transparency=1
    end
end
local function EnableLowGraphics()
    lowGraphics=true
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
    pcall(function() setfpscap(9999) end)
    Lighting.GlobalShadows=false; Lighting.Brightness=2
    for _,v in ipairs(Workspace:GetDescendants()) do pcall(function() ApplyLGToInstance(v) end) end
    if lgDescConn then lgDescConn:Disconnect() end
    lgDescConn=Workspace.DescendantAdded:Connect(function(v) task.wait(0.1); pcall(function() ApplyLGToInstance(v) end) end)
    lgStarLbl.Visible=true
end
local function DisableLowGraphics()
    lowGraphics=false
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end)
    Lighting.GlobalShadows=origLightData.GlobalShadows; Lighting.Brightness=origLightData.Brightness
    Lighting.Ambient=origLightData.Ambient; Lighting.OutdoorAmbient=origLightData.OutdoorAmbient
    if lgDescConn then lgDescConn:Disconnect(); lgDescConn=nil end
    for obj,data in pairs(origPartData) do
        if obj and obj.Parent then pcall(function() for k,v in pairs(data) do obj[k]=v end end) end
    end
    origPartData={}; lgStarLbl.Visible=false
end

-- ================================================================
--  SKYBOX
-- ================================================================
local SKYBOX_PRESETS={
    {name="Red",          id="98490421374360", color=Color3.fromRGB(200,50,50)},
    {name="Pink",         id="95000769820905", color=Color3.fromRGB(220,100,180)},
    {name="Green",        id="5036205687",     color=Color3.fromRGB(50,180,80)},
    {name="Black",        id="80807192441609", color=Color3.fromRGB(30,30,30)},
    {name="Cosmic",       id="77816282467771", color=Color3.fromRGB(80,40,160)},
    {name="Yellow",       id="2669948520",     color=Color3.fromRGB(220,190,40)},
    {name="Classic",      id="148970563",      color=Color3.fromRGB(100,160,220)},
}
local function SaveDefaultSky() local s=Lighting:FindFirstChildOfClass("Sky"); if s then defaultSkyData={SkyboxBk=s.SkyboxBk,SkyboxDn=s.SkyboxDn,SkyboxFt=s.SkyboxFt,SkyboxLf=s.SkyboxLf,SkyboxRt=s.SkyboxRt,SkyboxUp=s.SkyboxUp} end end
SaveDefaultSky()
local function RestoreDefaultSky() for _,obj in pairs(Lighting:GetChildren()) do if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then obj:Destroy() end end; if defaultSkyData then local s=Instance.new("Sky",Lighting); for k,v in pairs(defaultSkyData) do s[k]=v end end; Notify(T("skybox_restored")) end
local function ApplySkyboxById(id)
    for _,obj in pairs(Lighting:GetChildren()) do if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then obj:Destroy() end end
    local sky=Instance.new("Sky",Lighting); sky.Name="CogHub_CustomSky"
    local u="rbxassetid://"..tostring(id)
    sky.SkyboxBk=u; sky.SkyboxDn=u; sky.SkyboxFt=u; sky.SkyboxLf=u; sky.SkyboxRt=u; sky.SkyboxUp=u
    sky.SunTextureId=""; sky.MoonTextureId=""; sky.SunAngularSize=0; sky.StarCount=0
    Lighting.ClockTime=14; Lighting.Brightness=2; Lighting.GlobalShadows=false; Lighting.FogEnd=999999
end
local function OpenSkyboxPicker()
    local uid="CogSkyboxPicker"; local ex=game.CoreGui:FindFirstChild(uid); if ex then ex:Destroy(); return end
    local sg=Instance.new("ScreenGui",game.CoreGui); sg.Name=uid; sg.ResetOnSpawn=false; sg.DisplayOrder=62
    local frame=Instance.new("Frame",sg); frame.Size=UDim2.new(0,310,0,400); frame.Position=UDim2.new(0.5,-155,0.04,0); frame.BackgroundColor3=Color3.fromRGB(10,10,10); frame.BackgroundTransparency=0.06; frame.BorderSizePixel=0; Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
    local fs=Instance.new("UIStroke",frame); fs.Color=BLUE; fs.Thickness=2
    local fsg=Instance.new("UIGradient",fs); fsg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,BLUE),ColorSequenceKeypoint.new(0.5,BLUE_DARK),ColorSequenceKeypoint.new(1,BLUE)})
    task.spawn(function() local r=0; while frame and frame.Parent do r=(r+2)%360; fsg.Rotation=r; RunService.RenderStepped:Wait() end end)
    local hdr=Instance.new("TextLabel",frame); hdr.Size=UDim2.new(1,-44,0,38); hdr.Position=UDim2.new(0,12,0,0); hdr.BackgroundTransparency=1; hdr.Text="CogHub  |  "..T("skybox_picker"); hdr.TextColor3=Color3.fromRGB(255,255,255); hdr.Font=Enum.Font.GothamBold; hdr.TextSize=14; hdr.TextXAlignment=Enum.TextXAlignment.Left
    local xBtn=Instance.new("TextButton",frame); xBtn.Size=UDim2.new(0,28,0,28); xBtn.Position=UDim2.new(1,-34,0,5); xBtn.BackgroundColor3=BLUE_DARK; xBtn.Text="X"; xBtn.TextColor3=Color3.new(1,1,1); xBtn.Font=Enum.Font.GothamBold; xBtn.TextSize=13; Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,6)
    xBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    local idBox=Instance.new("TextBox",frame); idBox.Size=UDim2.new(1,-20,0,30); idBox.Position=UDim2.new(0,10,0,44); idBox.BackgroundColor3=Color3.fromRGB(22,22,22); idBox.Text=""; idBox.PlaceholderText=T("skybox_id_ph"); idBox.TextColor3=Color3.new(1,1,1); idBox.PlaceholderColor3=Color3.fromRGB(120,120,120); idBox.Font=Enum.Font.Gotham; idBox.TextSize=13; idBox.ClearTextOnFocus=false; Instance.new("UICorner",idBox).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",idBox).Color=Color3.fromRGB(80,80,80)
    idBox.FocusLost:Connect(function(enter) if enter and idBox.Text~="" then ApplySkyboxById(idBox.Text); Notify(T("custom_skybox")..idBox.Text); idBox.Text="" end end)
    local restoreBtn=Instance.new("TextButton",frame); restoreBtn.Size=UDim2.new(1,-20,0,26); restoreBtn.Position=UDim2.new(0,10,0,80); restoreBtn.BackgroundColor3=Color3.fromRGB(35,35,35); restoreBtn.Text=T("restore_sky"); restoreBtn.TextColor3=Color3.fromRGB(200,200,200); restoreBtn.Font=Enum.Font.GothamBold; restoreBtn.TextSize=12; Instance.new("UICorner",restoreBtn).CornerRadius=UDim.new(0,6)
    restoreBtn.MouseButton1Click:Connect(function() RestoreDefaultSky(); sg:Destroy() end)
    local scroll=Instance.new("ScrollingFrame",frame); scroll.Size=UDim2.new(1,-14,1,-114); scroll.Position=UDim2.new(0,7,0,112); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=4; scroll.CanvasSize=UDim2.new(0,0,0,#SKYBOX_PRESETS*56)
    Instance.new("UIListLayout",scroll).Padding=UDim.new(0,6)
    local pp=Instance.new("UIPadding",scroll); pp.PaddingLeft=UDim.new(0,6); pp.PaddingRight=UDim.new(0,6); pp.PaddingTop=UDim.new(0,4)
    for i,preset in ipairs(SKYBOX_PRESETS) do
        local row=Instance.new("TextButton",scroll); row.Size=UDim2.new(1,0,0,48); row.BackgroundColor3=Color3.fromRGB(18,18,18); row.Text=""; row.AutoButtonColor=false; row.LayoutOrder=i; Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local rs=Instance.new("UIStroke",row); rs.Color=preset.color; rs.Thickness=1
        local colorBox=Instance.new("Frame",row); colorBox.Size=UDim2.new(0,34,0,34); colorBox.Position=UDim2.new(0,8,0.5,-17); colorBox.BackgroundColor3=preset.color; colorBox.BorderSizePixel=0; Instance.new("UICorner",colorBox).CornerRadius=UDim.new(0,6)
        local nameLbl=Instance.new("TextLabel",row); nameLbl.Size=UDim2.new(1,-58,0,22); nameLbl.Position=UDim2.new(0,50,0,6); nameLbl.BackgroundTransparency=1; nameLbl.Text=preset.name; nameLbl.TextColor3=Color3.fromRGB(210,210,210); nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=14; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
        local idLbl=Instance.new("TextLabel",row); idLbl.Size=UDim2.new(1,-58,0,14); idLbl.Position=UDim2.new(0,50,1,-18); idLbl.BackgroundTransparency=1; idLbl.Text="ID: "..preset.id; idLbl.TextColor3=Color3.fromRGB(100,100,100); idLbl.Font=Enum.Font.Gotham; idLbl.TextSize=10; idLbl.TextXAlignment=Enum.TextXAlignment.Left
        row.MouseButton1Click:Connect(function() ApplySkyboxById(preset.id); Notify(T("skybox_set")..preset.name) end)
    end
    MakeDraggable(frame,frame)
end

-- ================================================================
--  ASMR KEYBOARD
-- ================================================================
local function asmrPlaySound() local cam=Workspace.CurrentCamera; if not cam then return end; local snd=Instance.new("Sound"); snd.SoundId=ASMR_SOUNDS[math.random(1,#ASMR_SOUNDS)]; snd.Volume=0.65; snd.Parent=cam; snd:Play(); snd.Ended:Connect(function() snd:Destroy() end) end
local function asmrTriggerAnim(part,origCF) local dT=TweenService:Create(part,TweenInfo.new(0.04,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=origCF*CFrame.new(0,0,-0.2)}); local uT=TweenService:Create(part,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{CFrame=origCF+Vector3.new(0,0.5,0)}); dT:Play(); dT.Completed:Connect(function() uT:Play() end) end
local function asmrCreateKey(targetCF)
    local part=Instance.new("Part"); part.Name="CogKey"; part.Size=ASMR_BASE_SIZE; part.CFrame=targetCF*CFrame.Angles(math.rad(-90),0,0); part.Color=ASMR_COLORS[math.random(1,#ASMR_COLORS)]; part.Material=Enum.Material.SmoothPlastic; part.Anchored=true; part.CanCollide=false; part.Parent=Workspace
    local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.FileMesh; mesh.MeshId=ASMR_MESH_ID; mesh.Scale=ASMR_MESH_SCALE; mesh.Parent=part
    local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Back; gui.LightInfluence=0; gui.CanvasSize=Vector2.new(150,150); gui.Parent=part
    local lbl=Instance.new("TextLabel",gui); lbl.Size=UDim2.new(0.95,0,0.95,0); lbl.Position=UDim2.new(0.025,0,0.025,0); lbl.BackgroundTransparency=1; lbl.TextScaled=true; lbl.Font=Enum.Font.FredokaOne; lbl.TextColor3=Color3.fromRGB(35,35,35); lbl.Text=ASMR_ALPHA[math.random(1,#ASMR_ALPHA)]
    local baseCF=part.CFrame; local isCd=false
    part.Touched:Connect(function(hit) local char=player.Character; if char and hit:IsDescendantOf(char) and not isCd then isCd=true; asmrPlaySound(); asmrTriggerAnim(part,baseCF); task.wait(0.2); isCd=false end end)
    return part
end
local function StartAsmrKeyboard()
    if asmrConn then asmrConn:Disconnect(); asmrConn=nil end
    asmrLastTime=0; asmrLastPos=Vector3.new(0,0,0)
    asmrConn=RunService.Heartbeat:Connect(function()
        if not asmrEnabled then return end
        local char=player.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local now=os.clock(); if now-asmrLastTime<ASMR_COOLDOWN then return end
        local spawnPos=root.Position-Vector3.new(0,2.5,0)
        if (spawnPos-asmrLastPos).Magnitude>2.2 then
            asmrLastTime=now; asmrLastPos=spawnPos
            local spawnCF=CFrame.new(spawnPos)*CFrame.Angles(0,math.rad(root.Orientation.Y),0)
            local keyPart=asmrCreateKey(spawnCF); asmrPlaySound(); asmrTriggerAnim(keyPart,keyPart.CFrame)
            task.delay(ASMR_DESPAWN,function()
                if keyPart and keyPart.Parent then TweenService:Create(keyPart,TweenInfo.new(0.5),{Transparency=1}):Play(); task.wait(0.5); if keyPart then keyPart:Destroy() end end
            end)
        end
    end)
end
local function StopAsmrKeyboard() asmrEnabled=false; if asmrConn then asmrConn:Disconnect(); asmrConn=nil end; for _,v in ipairs(Workspace:GetChildren()) do if v.Name=="CogKey" then v:Destroy() end end end

-- ================================================================
--  COIN FARM  (Tween teleport, hizli)
-- ================================================================
local function DisableNoclip() if noclipConn then noclipConn:Disconnect(); noclipConn=nil end; local char=player.Character; if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end end end end
local function EnableNoclip()
    if noclipConn then return end
    noclipConn=RunService.Stepped:Connect(function()
        if not autoFarmEnabled then DisableNoclip(); return end
        local char=player.Character; if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end end end
    end)
end
local function GetMurdererHRP() for _,p in ipairs(Players:GetPlayers()) do if p~=player and p.Character and HasKnife(p) then return p.Character:FindFirstChild("HumanoidRootPart") end end end
local function FindAllCoins()
    local now=tick()
    if now-lastCoinCacheTime<COIN_CACHE_TTL and #cachedCoins>0 then
        local valid={}; for _,c in ipairs(cachedCoins) do if c and c.Parent then table.insert(valid,c) end end
        cachedCoins=valid; return cachedCoins
    end
    local coins={}
    for _,desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("BasePart") or desc:IsA("MeshPart") then
            local n=desc.Name:lower(); if n=="coin" or n=="coinvisual" or n=="goldcoin" then table.insert(coins,desc) end
        end
    end
    cachedCoins=coins; lastCoinCacheTime=now; return coins
end
local function IsSafe(coinPos) local mHRP=GetMurdererHRP(); if not mHRP then return true end; return (mHRP.Position-coinPos).Magnitude>=SAFE_DISTANCE end
local function GetSafestCoin()
    local myChar=player.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end
    local coins=FindAllCoins(); local best,bestScore=nil,math.huge; local mHRP=GetMurdererHRP()
    for _,coin in ipairs(coins) do
        if coin and coin.Parent then
            local coinPos=coin.Position; local dtm=(coinPos-myHRP.Position).Magnitude; local mp=0
            if mHRP then local dm=(coinPos-mHRP.Position).Magnitude; if dm<SAFE_DISTANCE then mp=9999 else mp=-dm*0.5 end end
            local score=dtm+mp; if score<bestScore then bestScore=score; best=coin end
        end
    end
    return best
end
local farmLastTime=0
local function StartAutoFarm()
    if farmConn then farmConn:Disconnect(); farmConn=nil end; EnableNoclip()
    farmConn=RunService.Heartbeat:Connect(function()
        if not autoFarmEnabled then return end
        local now=tick(); if now-farmLastTime<0.05 then return end; farmLastTime=now
        local coin=GetSafestCoin(); if not coin then return end
        local myChar=player.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP and IsSafe(coin.Position) then
            pcall(function()
                myHRP.CFrame=CFrame.new(coin.Position)
                myHRP.AssemblyLinearVelocity=Vector3.new(0,0,0)
            end)
        end
    end)
end
local function StopAutoFarm()
    if farmConn then farmConn:Disconnect(); farmConn=nil end
    DisableNoclip()
    for coin,hl in pairs(coinHighlights) do pcall(function() hl:Destroy() end) end; coinHighlights={}
end

-- ================================================================
--  SUPER JUMP
-- ================================================================
local function SetSuperJump(on)
    superJumpEnabled=on
    if superJumpConn then superJumpConn:Disconnect(); superJumpConn=nil end
    if on then
        superJumpConn=UserInputService.JumpRequest:Connect(function()
            local char=player.Character; if char then local hrp=char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,SUPER_JUMP_POWER,hrp.AssemblyLinearVelocity.Z) end end
        end)
    end
end

-- ================================================================
--  INVISIBLE
-- ================================================================
local function setCharTransparency(char,t) for _,d in pairs(char:GetDescendants()) do if (d:IsA("BasePart") or d:IsA("Decal")) and d.Name~="HumanoidRootPart" then d.Transparency=t end end end
local function ToggleInvisible()
    local char=player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local torso=char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"); if not torso then return end
    invisEnabled=not invisEnabled
    if invisEnabled then
        local hrp=char.HumanoidRootPart; local savedCF=hrp.CFrame; char:MoveTo(INVIS_POS); task.wait(0.15)
        invisPlatform=Instance.new("Part"); invisPlatform.Name="CogHub_InvisPlatform"; invisPlatform.Size=Vector3.new(1,0.2,1); invisPlatform.Transparency=1; invisPlatform.CanCollide=true; invisPlatform.Friction=0; invisPlatform.CustomPhysicalProperties=PhysicalProperties.new(0,0,0,0,0); invisPlatform.CFrame=savedCF; invisPlatform.Parent=Workspace
        local seat=Instance.new("Seat"); seat.Name="CogHub_InvisChair"; seat.Anchored=false; seat.CanCollide=false; seat.Transparency=1; seat.CFrame=invisPlatform.CFrame; seat.Parent=invisPlatform
        local pw=Instance.new("WeldConstraint"); pw.Part0=invisPlatform; pw.Part1=seat; pw.Parent=invisPlatform
        local weld=Instance.new("Weld"); weld.Name="InvisWeld"; weld.Part0=seat; weld.Part1=torso; weld.Parent=seat
        setCharTransparency(char,0.5); Notify(T("invis_on"))
    else
        if invisPlatform then invisPlatform:Destroy(); invisPlatform=nil end
        if char then setCharTransparency(char,0) end; Notify(T("invis_off"))
    end
end

-- ================================================================
--  HOLD EVERYONE
-- ================================================================
local function ToggleHoldEveryone()
    holdEveryoneEnabled=not holdEveryoneEnabled
    if holdEveryoneEnabled then
        table.clear(savedPositions)
        for _,p in pairs(Players:GetPlayers()) do
            if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then savedPositions[p.UserId]=p.Character.HumanoidRootPart.CFrame end
        end
        holdEveryoneConn=RunService.RenderStepped:Connect(function()
            local char=player.Character; if not(char and char:FindFirstChild("HumanoidRootPart")) then return end
            local targetPos=char.HumanoidRootPart.CFrame*CFrame.new(0,-1,-3)
            for _,p in pairs(Players:GetPlayers()) do
                if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not savedPositions[p.UserId] then savedPositions[p.UserId]=p.Character.HumanoidRootPart.CFrame end
                    p.Character.HumanoidRootPart.CFrame=targetPos; p.Character.HumanoidRootPart.Velocity=Vector3.new(0,0,0)
                end
            end
        end)
        Notify(T("hold_on"))
    else
        if holdEveryoneConn then holdEveryoneConn:Disconnect(); holdEveryoneConn=nil end
        for _,p in pairs(Players:GetPlayers()) do
            if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local old=savedPositions[p.UserId]; if old then p.Character.HumanoidRootPart.CFrame=old end
                p.Character.HumanoidRootPart.Velocity=Vector3.new(0,0,0)
            end
        end
        table.clear(savedPositions); Notify(T("hold"))
    end
end

-- ================================================================
--  CROSSHAIR
-- ================================================================
local function ApplyCrosshairColor()
    if not crosshairImg then return end
    if crosshairColorConn then crosshairColorConn:Disconnect(); crosshairColorConn=nil end
    if crosshairGradEnabled then
        local t=0
        crosshairColorConn=RunService.RenderStepped:Connect(function(dt)
            if not(crosshairImg and crosshairImg.Parent) then return end
            t=(t+dt*0.8)%1
            local lerped
            if t<0.5 then lerped=crosshairColor1:Lerp(crosshairColor2,t*2)
            else lerped=crosshairColor2:Lerp(crosshairColor1,(t-0.5)*2) end
            crosshairImg.ImageColor3=lerped
        end)
    else
        crosshairImg.ImageColor3=crosshairColor1
    end
end

local function UpdateCrosshairSpin()
    if spinConn then spinConn:Disconnect(); spinConn=nil end
    if crosshairSpin and crosshairImg and crosshairImg.Parent then
        spinConn=RunService.RenderStepped:Connect(function()
            if crosshairImg and crosshairImg.Parent and crosshairImg.Visible then crosshairImg.Rotation=crosshairImg.Rotation+4 end
        end)
    else
        if crosshairImg then crosshairImg.Rotation=0 end
    end
end

local function HideGameCrosshair(hide)
    pcall(function()
        for _,gui in pairs(player.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local tb = gui:FindFirstChild("GameTopbar")
                if tb then
                    local ch = tb:FindFirstChild("Crosshair")
                    if ch then ch.Visible = not hide end
                end
            end
        end
    end)
end

local function SetupCrosshairDisplay()
    local old=game.CoreGui:FindFirstChild("CogCrosshairDisplay"); if old then old:Destroy() end
    if spinConn then spinConn:Disconnect(); spinConn=nil end
    if crosshairColorConn then crosshairColorConn:Disconnect(); crosshairColorConn=nil end
    local sg=Instance.new("ScreenGui",game.CoreGui); sg.Name="CogCrosshairDisplay"; sg.ResetOnSpawn=false; sg.DisplayOrder=25; sg.IgnoreGuiInset=true
    crosshairImg=Instance.new("ImageLabel",sg)
    crosshairImg.AnchorPoint=Vector2.new(0.5,0.5)
    crosshairImg.Position=UDim2.new(0.5,0,0.5,0)
    crosshairImg.Size=UDim2.new(0,crosshairSize,0,crosshairSize)
    crosshairImg.BackgroundTransparency=1
    crosshairImg.Image="rbxassetid://"..activeCursorId
    crosshairImg.ZIndex=10
    crosshairImg.Visible=false
    RunService.RenderStepped:Connect(function()
        if not(crosshairImg and crosshairImg.Parent) then return end
        local locked=UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter
        local show=crosshairActive and locked
        crosshairImg.Visible=show
        UserInputService.MouseIconEnabled=not show
        if show then HideGameCrosshair(true) else HideGameCrosshair(false) end
    end)
    UpdateCrosshairSpin()
    ApplyCrosshairColor()
end

local CURSORS={
    {name="Neon Cyan",       id="11770890197"},
    {name="Electric Purple", id="11770691141"},
    {name="Precision Dot",   id="10878218308"},
    {name="Aim Cross",       id="10891594349"},
    {name="Blue Spec",       id="11720475063"},
    {name="Circle Dot",      id="10831379335"},
    {name="Green Hit",       id="8375241602"},
    {name="Custom 1",        id="9524023207"},
    {name="Custom 2",        id="4941755392"},
}

local COLOR_PRESETS={
    {name="Blue",   c=BLUE},
    {name="Cyan",   c=Color3.fromRGB(0,220,255)},
    {name="Red",    c=Color3.fromRGB(255,30,30)},
    {name="Green",  c=Color3.fromRGB(0,255,80)},
    {name="White",  c=Color3.fromRGB(255,255,255)},
    {name="Yellow", c=Color3.fromRGB(255,220,0)},
    {name="Orange", c=Color3.fromRGB(255,140,0)},
    {name="Pink",   c=Color3.fromRGB(255,80,200)},
    {name="Purple", c=Color3.fromRGB(160,60,255)},
    {name="Black",  c=Color3.fromRGB(10,10,10)},
}

local function OpenColorPicker(title, currentColor, onApply)
    local uid="CogColorPick_"..title:gsub("%s","_")
    local ex=game.CoreGui:FindFirstChild(uid); if ex then ex:Destroy(); return end
    local sg=Instance.new("ScreenGui",game.CoreGui); sg.Name=uid; sg.ResetOnSpawn=false; sg.DisplayOrder=70
    local frame=Instance.new("Frame",sg); frame.Size=UDim2.new(0,260,0,330); frame.Position=UDim2.new(0.5,-130,0.2,0); frame.BackgroundColor3=Color3.fromRGB(10,10,10); frame.BackgroundTransparency=0.06; frame.BorderSizePixel=0; Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
    local fs=Instance.new("UIStroke",frame); fs.Color=BLUE; fs.Thickness=2
    local fsg=Instance.new("UIGradient",fs); fsg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,BLUE),ColorSequenceKeypoint.new(0.5,BLUE_DARK),ColorSequenceKeypoint.new(1,BLUE)})
    task.spawn(function() local r=0; while frame and frame.Parent do r=(r+2)%360; fsg.Rotation=r; RunService.RenderStepped:Wait() end end)
    local hdr=Instance.new("TextLabel",frame); hdr.Size=UDim2.new(1,-44,0,36); hdr.Position=UDim2.new(0,12,0,0); hdr.BackgroundTransparency=1; hdr.Text="CogHub  |  "..title; hdr.TextColor3=Color3.fromRGB(255,255,255); hdr.Font=Enum.Font.GothamBold; hdr.TextSize=13; hdr.TextXAlignment=Enum.TextXAlignment.Left
    local xBtn=Instance.new("TextButton",frame); xBtn.Size=UDim2.new(0,28,0,28); xBtn.Position=UDim2.new(1,-34,0,4); xBtn.BackgroundColor3=BLUE_DARK; xBtn.Text="X"; xBtn.TextColor3=Color3.new(1,1,1); xBtn.Font=Enum.Font.GothamBold; xBtn.TextSize=13; Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,6)
    xBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    local preview=Instance.new("Frame",frame); preview.Size=UDim2.new(1,-20,0,26); preview.Position=UDim2.new(0,10,0,42); preview.BackgroundColor3=currentColor; preview.BorderSizePixel=0; Instance.new("UICorner",preview).CornerRadius=UDim.new(0,8)
    local previewLbl=Instance.new("TextLabel",preview); previewLbl.Size=UDim2.new(1,0,1,0); previewLbl.BackgroundTransparency=1; previewLbl.Text=T("preview"); previewLbl.TextColor3=Color3.fromRGB(200,200,200); previewLbl.Font=Enum.Font.GothamBold; previewLbl.TextSize=11
    local selected=currentColor
    local grid=Instance.new("Frame",frame); grid.Size=UDim2.new(1,-20,0,160); grid.Position=UDim2.new(0,10,0,76); grid.BackgroundTransparency=1
    local uiGrid=Instance.new("UIGridLayout",grid); uiGrid.CellSize=UDim2.new(0,38,0,38); uiGrid.CellPadding=UDim2.new(0,6,0,6); uiGrid.HorizontalAlignment=Enum.HorizontalAlignment.Left
    for _,preset in ipairs(COLOR_PRESETS) do
        local btn=Instance.new("TextButton",grid); btn.Size=UDim2.new(0,38,0,38); btn.BackgroundColor3=preset.c; btn.Text=""; btn.AutoButtonColor=false; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
        btn.MouseButton1Click:Connect(function() selected=preset.c; preview.BackgroundColor3=selected end)
    end
    local rgbBox=Instance.new("TextBox",frame); rgbBox.Size=UDim2.new(1,-20,0,26); rgbBox.Position=UDim2.new(0,10,0,244); rgbBox.BackgroundColor3=Color3.fromRGB(20,20,20); rgbBox.Text=""; rgbBox.PlaceholderText=T("rgb_ph"); rgbBox.TextColor3=Color3.fromRGB(220,220,220); rgbBox.PlaceholderColor3=Color3.fromRGB(90,90,90); rgbBox.Font=Enum.Font.Gotham; rgbBox.TextSize=11; rgbBox.ClearTextOnFocus=false; Instance.new("UICorner",rgbBox).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",rgbBox).Color=Color3.fromRGB(80,80,80)
    rgbBox.FocusLost:Connect(function(enter) if enter then local r,g,b=rgbBox.Text:match("(%d+)[,%s]+(%d+)[,%s]+(%d+)"); if r and g and b then selected=Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b)); preview.BackgroundColor3=selected end; rgbBox.Text="" end end)
    local applyBtn=Instance.new("TextButton",frame); applyBtn.Size=UDim2.new(1,-20,0,28); applyBtn.Position=UDim2.new(0,10,0,278); applyBtn.BackgroundColor3=Color3.fromRGB(20,150,20); applyBtn.Text=T("apply_color"); applyBtn.TextColor3=Color3.new(1,1,1); applyBtn.Font=Enum.Font.GothamBold; applyBtn.TextSize=13; Instance.new("UICorner",applyBtn).CornerRadius=UDim.new(0,6)
    applyBtn.MouseButton1Click:Connect(function() onApply(selected); Notify(title..T("applied_suffix")); sg:Destroy() end)
    MakeDraggable(frame,frame)
end

local function OpenCursorPicker()
    local uid="CogCursorPicker"; local ex=game.CoreGui:FindFirstChild(uid); if ex then ex:Destroy(); return end
    local sg=Instance.new("ScreenGui",game.CoreGui); sg.Name=uid; sg.ResetOnSpawn=false; sg.DisplayOrder=60
    local frame=Instance.new("Frame",sg); frame.Size=UDim2.new(0,310,0,560); frame.Position=UDim2.new(0.5,-155,0.02,0); frame.BackgroundColor3=Color3.fromRGB(10,10,10); frame.BackgroundTransparency=0.06; frame.BorderSizePixel=0; Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
    local fs=Instance.new("UIStroke",frame); fs.Color=BLUE; fs.Thickness=2
    local fsg=Instance.new("UIGradient",fs); fsg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,BLUE),ColorSequenceKeypoint.new(0.5,BLUE_DARK),ColorSequenceKeypoint.new(1,BLUE)})
    task.spawn(function() local r=0; while frame and frame.Parent do r=(r+2)%360; fsg.Rotation=r; RunService.RenderStepped:Wait() end end)
    local hdr=Instance.new("TextLabel",frame); hdr.Size=UDim2.new(1,-44,0,38); hdr.Position=UDim2.new(0,12,0,0); hdr.BackgroundTransparency=1; hdr.Text="CogHub  |  "..T("cursor_picker"); hdr.TextColor3=Color3.fromRGB(255,255,255); hdr.Font=Enum.Font.GothamBold; hdr.TextSize=14; hdr.TextXAlignment=Enum.TextXAlignment.Left
    local xBtn=Instance.new("TextButton",frame); xBtn.Size=UDim2.new(0,28,0,28); xBtn.Position=UDim2.new(1,-34,0,5); xBtn.BackgroundColor3=BLUE_DARK; xBtn.Text="X"; xBtn.TextColor3=Color3.new(1,1,1); xBtn.Font=Enum.Font.GothamBold; xBtn.TextSize=13; Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,6)
    xBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    -- Custom ID box
    local idBox=Instance.new("TextBox",frame); idBox.Size=UDim2.new(1,-20,0,30); idBox.Position=UDim2.new(0,10,0,44); idBox.BackgroundColor3=Color3.fromRGB(22,22,22); idBox.Text=""; idBox.PlaceholderText=T("cursor_id_ph"); idBox.TextColor3=Color3.new(1,1,1); idBox.PlaceholderColor3=Color3.fromRGB(120,120,120); idBox.Font=Enum.Font.Gotham; idBox.TextSize=13; idBox.ClearTextOnFocus=false; Instance.new("UICorner",idBox).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",idBox).Color=Color3.fromRGB(80,80,80)
    idBox.FocusLost:Connect(function(enter) if enter and idBox.Text~="" then activeCursorId=idBox.Text; if crosshairActive and crosshairImg then crosshairImg.Image="rbxassetid://"..idBox.Text end; Notify(T("custom_cursor")); idBox.Text="" end end)
    -- Spin toggle
    local spinRow=Instance.new("Frame",frame); spinRow.Size=UDim2.new(1,-20,0,26); spinRow.Position=UDim2.new(0,10,0,80); spinRow.BackgroundTransparency=1
    local spinLbl=Instance.new("TextLabel",spinRow); spinLbl.Size=UDim2.new(1,-64,1,0); spinLbl.BackgroundTransparency=1; spinLbl.Text=T("spin_crosshair"); spinLbl.TextColor3=Color3.fromRGB(200,200,200); spinLbl.Font=Enum.Font.GothamBold; spinLbl.TextSize=12; spinLbl.TextXAlignment=Enum.TextXAlignment.Left
    local spinPill=Instance.new("Frame",spinRow); spinPill.Size=UDim2.new(0,40,0,20); spinPill.Position=UDim2.new(1,-42,0.5,-10); spinPill.BackgroundColor3=crosshairSpin and BLUE or Color3.fromRGB(55,55,70); Instance.new("UICorner",spinPill).CornerRadius=UDim.new(1,0)
    local spinKnob=Instance.new("Frame",spinPill); spinKnob.Size=UDim2.new(0,14,0,14); spinKnob.Position=crosshairSpin and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7); spinKnob.BackgroundColor3=Color3.fromRGB(255,255,255); spinKnob.BorderSizePixel=0; Instance.new("UICorner",spinKnob).CornerRadius=UDim.new(1,0)
    local spinClick=Instance.new("TextButton",spinRow); spinClick.Size=UDim2.new(1,0,1,0); spinClick.BackgroundTransparency=1; spinClick.Text=""
    spinClick.MouseButton1Click:Connect(function()
        crosshairSpin=not crosshairSpin; UpdateCrosshairSpin()
        TweenService:Create(spinPill,TweenInfo.new(0.2),{BackgroundColor3=crosshairSpin and BLUE or Color3.fromRGB(55,55,70)}):Play()
        TweenService:Create(spinKnob,TweenInfo.new(0.2),{Position=crosshairSpin and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
    end)
    -- Gradient toggle
    local gradRow=Instance.new("Frame",frame); gradRow.Size=UDim2.new(1,-20,0,26); gradRow.Position=UDim2.new(0,10,0,112); gradRow.BackgroundTransparency=1
    local gradLbl=Instance.new("TextLabel",gradRow); gradLbl.Size=UDim2.new(1,-64,1,0); gradLbl.BackgroundTransparency=1; gradLbl.Text=T("gradient_mode"); gradLbl.TextColor3=Color3.fromRGB(200,200,200); gradLbl.Font=Enum.Font.GothamBold; gradLbl.TextSize=12; gradLbl.TextXAlignment=Enum.TextXAlignment.Left
    local gradPill=Instance.new("Frame",gradRow); gradPill.Size=UDim2.new(0,40,0,20); gradPill.Position=UDim2.new(1,-42,0.5,-10); gradPill.BackgroundColor3=crosshairGradEnabled and BLUE or Color3.fromRGB(55,55,70); Instance.new("UICorner",gradPill).CornerRadius=UDim.new(1,0)
    local gradKnob=Instance.new("Frame",gradPill); gradKnob.Size=UDim2.new(0,14,0,14); gradKnob.Position=crosshairGradEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7); gradKnob.BackgroundColor3=Color3.fromRGB(255,255,255); gradKnob.BorderSizePixel=0; Instance.new("UICorner",gradKnob).CornerRadius=UDim.new(1,0)
    local gradClick=Instance.new("TextButton",gradRow); gradClick.Size=UDim2.new(1,0,1,0); gradClick.BackgroundTransparency=1; gradClick.Text=""
    gradClick.MouseButton1Click:Connect(function()
        crosshairGradEnabled=not crosshairGradEnabled; ApplyCrosshairColor()
        TweenService:Create(gradPill,TweenInfo.new(0.2),{BackgroundColor3=crosshairGradEnabled and BLUE or Color3.fromRGB(55,55,70)}):Play()
        TweenService:Create(gradKnob,TweenInfo.new(0.2),{Position=crosshairGradEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
    end)
    -- Color 1 & 2
    local col1Btn=Instance.new("TextButton",frame); col1Btn.Size=UDim2.new(0.47,-5,0,26); col1Btn.Position=UDim2.new(0,10,0,144); col1Btn.BackgroundColor3=crosshairColor1; col1Btn.Text=T("color1"); col1Btn.TextColor3=Color3.new(1,1,1); col1Btn.Font=Enum.Font.GothamBold; col1Btn.TextSize=11; Instance.new("UICorner",col1Btn).CornerRadius=UDim.new(0,6)
    col1Btn.MouseButton1Click:Connect(function() OpenColorPicker("Crosshair Color 1",crosshairColor1,function(c) crosshairColor1=c; col1Btn.BackgroundColor3=c; ApplyCrosshairColor() end) end)
    local col2Btn=Instance.new("TextButton",frame); col2Btn.Size=UDim2.new(0.47,-5,0,26); col2Btn.Position=UDim2.new(0.53,-5,0,144); col2Btn.BackgroundColor3=crosshairColor2; col2Btn.Text=T("color2"); col2Btn.TextColor3=Color3.new(1,1,1); col2Btn.Font=Enum.Font.GothamBold; col2Btn.TextSize=11; Instance.new("UICorner",col2Btn).CornerRadius=UDim.new(0,6)
    col2Btn.MouseButton1Click:Connect(function() OpenColorPicker("Crosshair Color 2",crosshairColor2,function(c) crosshairColor2=c; col2Btn.BackgroundColor3=c; ApplyCrosshairColor() end) end)
    -- Preset list
    local scroll=Instance.new("ScrollingFrame",frame); scroll.Size=UDim2.new(1,-14,1,-180); scroll.Position=UDim2.new(0,7,0,178); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=4; scroll.CanvasSize=UDim2.new(0,0,0,#CURSORS*64)
    Instance.new("UIListLayout",scroll).Padding=UDim.new(0,6)
    local pp2=Instance.new("UIPadding",scroll); pp2.PaddingLeft=UDim.new(0,6); pp2.PaddingRight=UDim.new(0,6); pp2.PaddingTop=UDim.new(0,4)
    for i,cur in ipairs(CURSORS) do
        local row=Instance.new("TextButton",scroll); row.Size=UDim2.new(1,0,0,56); row.BackgroundColor3=Color3.fromRGB(18,18,18); row.Text=""; row.AutoButtonColor=false; row.LayoutOrder=i; Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local rs=Instance.new("UIStroke",row); rs.Color=BLUE; rs.Thickness=1
        local prev=Instance.new("ImageLabel",row); prev.Size=UDim2.new(0,40,0,40); prev.Position=UDim2.new(0,8,0.5,-20); prev.BackgroundTransparency=1; prev.Image="rbxassetid://"..cur.id; prev.ImageColor3=crosshairColor1
        local nameLbl=Instance.new("TextLabel",row); nameLbl.Size=UDim2.new(1,-64,0,20); nameLbl.Position=UDim2.new(0,56,0,8); nameLbl.BackgroundTransparency=1; nameLbl.Text=cur.name; nameLbl.TextColor3=Color3.fromRGB(210,210,210); nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=13; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
        local idLbl=Instance.new("TextLabel",row); idLbl.Size=UDim2.new(1,-64,0,14); idLbl.Position=UDim2.new(0,56,1,-18); idLbl.BackgroundTransparency=1; idLbl.Text="ID: "..cur.id; idLbl.TextColor3=Color3.fromRGB(100,100,100); idLbl.Font=Enum.Font.Gotham; idLbl.TextSize=10; idLbl.TextXAlignment=Enum.TextXAlignment.Left
        row.MouseButton1Click:Connect(function() activeCursorId=cur.id; if crosshairActive and crosshairImg then crosshairImg.Image="rbxassetid://"..cur.id end; Notify(T("cursor_set")..cur.name) end)
    end
    MakeDraggable(frame,frame)
end

-- ================================================================
--  FLOATING BUTTON FACTORY
-- ================================================================
local btnGui = (function()
    local old=game.CoreGui:FindFirstChild("CogHub_BtnLayer"); if old then old:Destroy() end
    local sg=Instance.new("ScreenGui",game.CoreGui); sg.Name="CogHub_BtnLayer"; sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.DisplayOrder=99; sg.IgnoreGuiInset=true; return sg
end)()
local btnRefs = {}

local function AddDragBtn(btn)
    local dragging,dStart,dPos
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; dStart=i.Position; dPos=btn.Position end
    end)
    btn.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-dStart; btn.Position=UDim2.new(dPos.X.Scale,dPos.X.Offset+d.X,dPos.Y.Scale,dPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

-- Yeni Tema: Blue Gradient Spinning
local function NewBtn(key, pos, size, label, iconId)
    if btnRefs[key] then btnRefs[key].btn:Destroy(); btnRefs[key]=nil end

    local btn = Instance.new("TextButton", btnGui)
    btn.Name      = "CogBtn_"..key
    btn.Size      = size
    btn.Position  = pos
    btn.BackgroundColor3     = Color3.fromRGB(5, 10, 15) -- Koyu lacivert zemin
    btn.BackgroundTransparency = 0.45
    btn.Text      = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 2.5
    stroke.Color     = BLUE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local gradient = Instance.new("UIGradient", stroke)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(41, 128, 185)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 50, 80)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(41, 128, 185)),
    })

    local iconImg = nil
    if iconId then
        iconImg = Instance.new("ImageLabel", btn)
        iconImg.Size                = UDim2.new(0.50, 0, 0.50, 0)
        iconImg.AnchorPoint         = Vector2.new(0.5, 0.5)
        iconImg.Position            = UDim2.new(0.5, 0, 0.40, 0)
        iconImg.BackgroundTransparency = 1
        iconImg.Image               = "rbxassetid://"..tostring(iconId)
        iconImg.ScaleType           = Enum.ScaleType.Fit
        iconImg.ImageColor3         = BLUE
    end

    local lbl = Instance.new("TextLabel", btn)
    lbl.Name = "Lbl"
    lbl.BackgroundTransparency = 1
    lbl.TextColor3  = Color3.fromRGB(255, 255, 255)
    lbl.Font        = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 0.5
    if iconId then
        lbl.Size     = UDim2.new(1, 0, 0.28, 0)
        lbl.Position = UDim2.new(0, 0, 0.72, 0)
        lbl.TextSize = math.max(9, size.Y.Offset * 0.12)
    else
        lbl.Size     = UDim2.new(1, 0, 1, 0)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.TextSize = math.max(10, size.Y.Offset * 0.15)
    end
    lbl.Text = label
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    local lblGrad = Instance.new("UIGradient", lbl)
    lblGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(173, 216, 230)),
        ColorSequenceKeypoint.new(0.5, BLUE),
        ColorSequenceKeypoint.new(1,   BLUE_DARK),
    })
    lblGrad.Rotation = 90

    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size=UDim2.new(0, size.X.Offset-6, 0, size.Y.Offset-6)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size=size}):Play()
    end)

    local currentRotation = 0
    RunService.RenderStepped:Connect(function()
        currentRotation = (currentRotation + 1.5) % 360
        if gradient.Parent then gradient.Rotation = currentRotation end
        if iconImg and iconImg.Parent then iconImg.Rotation = -currentRotation end
    end)

    AddDragBtn(btn)
    btnRefs[key] = { btn=btn, stroke=stroke, gradient=gradient, lbl=lbl, img=iconImg }
    return btnRefs[key]
end

-- ================================================================
--  BUTTON LAYOUT POSITIONS
-- ================================================================
local BIG   = UDim2.new(0, 88, 0, 88)
local MED   = UDim2.new(0, 72, 0, 72)
local SMALL = UDim2.new(0, 60, 0, 60)

local DP = {
    GoldBomb       = UDim2.new(0.5, -220, 0.78,  0),
    NormalBomb     = UDim2.new(0.5, -116, 0.78,  0),
    Shoot          = UDim2.new(0.5, -12,  0.78,  0),
    ESP            = UDim2.new(0.5,  100, 0.78, 14),
    Flick          = UDim2.new(0.5,  170, 0.78, 14),
    Flick360       = UDim2.new(0.5,  240, 0.78, 14),
    SpeedGlitch    = UDim2.new(0.5, -290, 0.78, 14),
    Stretch        = UDim2.new(0.5, -220, 0.78, 14),
    GrabGun        = UDim2.new(0.5,  100, 0.68, 14),
    WallHop        = UDim2.new(0.5,  170, 0.68, 14),
    FlingMurderer  = UDim2.new(0.5, -290, 0.68, 14),
    FlingSheriff   = UDim2.new(0.5, -220, 0.68, 14),
    HoldEveryone   = UDim2.new(0.5, -290, 0.58, 14),
    Invisible      = UDim2.new(0.5, -220, 0.58, 14),
    SuperJump      = UDim2.new(0.5, -150, 0.58, 14),
    AutoFarm       = UDim2.new(0.5,  -80, 0.58, 14),
    AntiFling      = UDim2.new(0.5,  -10, 0.58, 14),
    LowGraphics    = UDim2.new(0.5,   60, 0.58, 14),
}

-- ================================================================
--  INDIVIDUAL LOAD FUNCTIONS
-- ================================================================
local function LoadGoldBomb(v)
    if not v then if btnRefs.GoldBomb then btnRefs.GoldBomb.btn:Destroy(); btnRefs.GoldBomb=nil end; return end
    NewBtn("GoldBomb", DP.GoldBomb, BIG, "GOLD\nJUMP", 79307715382513)
    btnRefs.GoldBomb.btn.MouseButton1Click:Connect(function() if goldCD then Notify(T("wait")) else ExecuteJump("GoldBomb",true) end end)
end
local function LoadNormalBomb(v)
    if not v then if btnRefs.NormalBomb then btnRefs.NormalBomb.btn:Destroy(); btnRefs.NormalBomb=nil end; return end
    NewBtn("NormalBomb", DP.NormalBomb, BIG, "BOMB\nJUMP")
    btnRefs.NormalBomb.btn.MouseButton1Click:Connect(function() if normalCD then Notify(T("wait")) else ExecuteJump("FakeBomb",false) end end)
end
local function LoadShoot(v)
    if not v then if btnRefs.Shoot then btnRefs.Shoot.btn:Destroy(); btnRefs.Shoot=nil end; return end
    NewBtn("Shoot", DP.Shoot, BIG, "SHOOT", 79307715382513)
    btnRefs.Shoot.btn.MouseButton1Click:Connect(SmartShoot)
end
local function LoadESP(v)
    if not v then if btnRefs.ESP then btnRefs.ESP.btn:Destroy(); btnRefs.ESP=nil end; return end
    NewBtn("ESP", DP.ESP, SMALL, "ESP OFF")
    btnRefs.ESP.btn.MouseButton1Click:Connect(function() SetESP(not espEnabled) end)
end
local flickSliderGui = nil
local function OpenFlickRotationSlider()
    local uid="CogFlickRotSlider"
    local ex=game.CoreGui:FindFirstChild(uid); if ex then ex:Destroy(); flickSliderGui=nil; return end
    local sg=Instance.new("ScreenGui",game.CoreGui); sg.Name=uid; sg.ResetOnSpawn=false; sg.DisplayOrder=56
    flickSliderGui=sg
    local frame=Instance.new("Frame",sg)
    frame.Size=UDim2.new(0,280,0,110)
    local flickBtn=btnRefs.Flick and btnRefs.Flick.btn
    if flickBtn then
        local ap=flickBtn.AbsolutePosition; local as=flickBtn.AbsoluteSize
        frame.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+6)
    else
        frame.Position=UDim2.new(0.5,-140,0.72,0)
    end
    frame.BackgroundColor3=Color3.fromRGB(10,10,10); frame.BackgroundTransparency=0.05; frame.BorderSizePixel=0
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,10)
    local fs=Instance.new("UIStroke",frame); fs.Color=BLUE; fs.Thickness=2
    local fsg=Instance.new("UIGradient",fs); fsg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,BLUE),ColorSequenceKeypoint.new(0.5,BLUE_DARK),ColorSequenceKeypoint.new(1,BLUE)})
    task.spawn(function() local r=0; while frame and frame.Parent do r=(r+2)%360; fsg.Rotation=r; RunService.RenderStepped:Wait() end end)
    local hdr=Instance.new("TextLabel",frame); hdr.Size=UDim2.new(1,-36,0,28); hdr.Position=UDim2.new(0,10,0,0); hdr.BackgroundTransparency=1; hdr.Text="Flick Rotation"; hdr.TextColor3=Color3.fromRGB(255,255,255); hdr.Font=Enum.Font.GothamBold; hdr.TextSize=13; hdr.TextXAlignment=Enum.TextXAlignment.Left
    local xBtn=Instance.new("TextButton",frame); xBtn.Size=UDim2.new(0,24,0,24); xBtn.Position=UDim2.new(1,-28,0,2); xBtn.BackgroundColor3=BLUE_DARK; xBtn.Text="X"; xBtn.TextColor3=Color3.new(1,1,1); xBtn.Font=Enum.Font.GothamBold; xBtn.TextSize=12; Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,5)
    xBtn.MouseButton1Click:Connect(function() sg:Destroy(); flickSliderGui=nil end)
    local valLbl=Instance.new("TextLabel",frame); valLbl.Size=UDim2.new(1,0,0,18); valLbl.Position=UDim2.new(0,0,0,30); valLbl.BackgroundTransparency=1; valLbl.Text="Rotation: "..FLICK_ROTATION.."°"; valLbl.TextColor3=Color3.fromRGB(200,200,200); valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=12
    local track=Instance.new("Frame",frame); track.Size=UDim2.new(1,-24,0,8); track.Position=UDim2.new(0,12,0,56); track.BackgroundColor3=Color3.fromRGB(40,40,40); track.BorderSizePixel=0; Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local minV,maxV=10,360
    local r0=(FLICK_ROTATION-minV)/(maxV-minV)
    local fill=Instance.new("Frame",track); fill.Size=UDim2.new(r0,0,1,0); fill.BackgroundColor3=BLUE; fill.BorderSizePixel=0; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("TextButton",track); knob.Size=UDim2.new(0,22,0,22); knob.Position=UDim2.new(r0,-11,0.5,-11); knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.Text=""; knob.AutoButtonColor=false; knob.BorderSizePixel=0; Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local dragging=false
    local function updateFromX(sx)
        local rel=math.clamp((sx-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        FLICK_ROTATION=math.round(minV+rel*(maxV-minV))
        local r2=(FLICK_ROTATION-minV)/(maxV-minV)
        fill.Size=UDim2.new(r2,0,1,0); knob.Position=UDim2.new(r2,-11,0.5,-11)
        valLbl.Text="Rotation: "..FLICK_ROTATION.."°"
    end
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; updateFromX(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if not dragging then return end; if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then updateFromX(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    local resetBtn=Instance.new("TextButton",frame); resetBtn.Size=UDim2.new(0.45,0,0,22); resetBtn.Position=UDim2.new(0.27,0,0,82); resetBtn.BackgroundColor3=BLUE_DARK; resetBtn.Text="Reset (180°)"; resetBtn.TextColor3=Color3.new(1,1,1); resetBtn.Font=Enum.Font.GothamBold; resetBtn.TextSize=11; Instance.new("UICorner",resetBtn).CornerRadius=UDim.new(0,5)
    resetBtn.MouseButton1Click:Connect(function() FLICK_ROTATION=180; updateFromX(track.AbsolutePosition.X+track.AbsoluteSize.X*0.5) end)
    MakeDraggable(frame,frame)
end

local function LoadFlick(v)
    if not v then
        if btnRefs.Flick then btnRefs.Flick.btn:Destroy(); btnRefs.Flick=nil end
        local ex=game.CoreGui:FindFirstChild("CogFlickRotSlider"); if ex then ex:Destroy() end
        return
    end
    NewBtn("Flick", DP.Flick, SMALL, "FLICK")
    btnRefs.Flick.btn.MouseButton1Click:Connect(DoSmartFlick)
    btnRefs.Flick.btn.MouseButton2Click:Connect(OpenFlickRotationSlider)
    local subLbl=Instance.new("TextLabel",btnRefs.Flick.btn)
    subLbl.Size=UDim2.new(1,0,0,12); subLbl.Position=UDim2.new(0,0,1,2)
    subLbl.BackgroundTransparency=1; subLbl.Text="[RMB: Rotation]"
    subLbl.TextColor3=Color3.fromRGB(180,180,180); subLbl.Font=Enum.Font.Gotham; subLbl.TextSize=8
end
local function LoadSpeedGlitch(v)
    if not v then if btnRefs.SpeedGlitch then btnRefs.SpeedGlitch.btn:Destroy(); btnRefs.SpeedGlitch=nil end; return end
    NewBtn("SpeedGlitch", DP.SpeedGlitch, SMALL, "SPEED\nGLITCH")
    btnRefs.SpeedGlitch.btn.MouseButton1Click:Connect(function() speedEnabled=not speedEnabled end)
end
local function LoadStretch(v)
    if not v then if btnRefs.Stretch then btnRefs.Stretch.btn:Destroy(); btnRefs.Stretch=nil end; return end
    NewBtn("Stretch", DP.Stretch, SMALL, "STRETCH")
    btnRefs.Stretch.btn.MouseButton1Click:Connect(function() stretchEnabled=not stretchEnabled; SetStretch(stretchEnabled) end)
end
local function LoadGrabGun(v)
    if not v then if btnRefs.GrabGun then btnRefs.GrabGun.btn:Destroy(); btnRefs.GrabGun=nil end; return end
    NewBtn("GrabGun", DP.GrabGun, SMALL, "GRAB\nGUN")
    btnRefs.GrabGun.btn.MouseButton1Click:Connect(DoGrabGun)
end
local function LoadWallHop(v)
    if not v then if btnRefs.WallHop then btnRefs.WallHop.btn:Destroy(); btnRefs.WallHop=nil end; return end
    NewBtn("WallHop", DP.WallHop, SMALL, "WALL\nHOP")
    btnRefs.WallHop.btn.MouseButton1Click:Connect(DoWallHop)
end
local function LoadFlingMurderer(v)
    if not v then if btnRefs.FlingMurderer then btnRefs.FlingMurderer.btn:Destroy(); btnRefs.FlingMurderer=nil end; return end
    NewBtn("FlingMurderer", DP.FlingMurderer, SMALL, "FLING\nMURDERER")
    btnRefs.FlingMurderer.btn.MouseButton1Click:Connect(FlingMurderer)
end
local function LoadFlingSheriff(v)
    if not v then if btnRefs.FlingSheriff then btnRefs.FlingSheriff.btn:Destroy(); btnRefs.FlingSheriff=nil end; return end
    NewBtn("FlingSheriff", DP.FlingSheriff, SMALL, "FLING\nSHERIFF")
    btnRefs.FlingSheriff.btn.MouseButton1Click:Connect(FlingSheriff)
end
local function LoadHoldEveryone(v)
    if not v then if btnRefs.HoldEveryone then btnRefs.HoldEveryone.btn:Destroy(); btnRefs.HoldEveryone=nil end; return end
    NewBtn("HoldEveryone", DP.HoldEveryone, SMALL, "HOLD\nEVERYONE")
    btnRefs.HoldEveryone.btn.MouseButton1Click:Connect(ToggleHoldEveryone)
end
local function LoadInvisible(v)
    if not v then if btnRefs.Invisible then btnRefs.Invisible.btn:Destroy(); btnRefs.Invisible=nil end; return end
    NewBtn("Invisible", DP.Invisible, SMALL, "INVISIBLE\nOFF")
    btnRefs.Invisible.btn.MouseButton1Click:Connect(ToggleInvisible)
end
local function LoadSuperJump(v)
    if not v then if btnRefs.SuperJump then btnRefs.SuperJump.btn:Destroy(); btnRefs.SuperJump=nil end; return end
    NewBtn("SuperJump", DP.SuperJump, SMALL, "SUPER\nJUMP")
    btnRefs.SuperJump.btn.MouseButton1Click:Connect(function() SetSuperJump(not superJumpEnabled) end)
end
local function LoadAutoFarm(v)
    if not v then if btnRefs.AutoFarm then btnRefs.AutoFarm.btn:Destroy(); btnRefs.AutoFarm=nil end; return end
    NewBtn("AutoFarm", DP.AutoFarm, SMALL, "AUTO\nFARM OFF")
    btnRefs.AutoFarm.btn.MouseButton1Click:Connect(function() autoFarmEnabled=not autoFarmEnabled; if autoFarmEnabled then StartAutoFarm() else StopAutoFarm() end end)
end
local function LoadAntiFling(v)
    if not v then if btnRefs.AntiFling then btnRefs.AntiFling.btn:Destroy(); btnRefs.AntiFling=nil end; return end
    NewBtn("AntiFling", DP.AntiFling, SMALL, "ANTI\nFLING OFF")
    btnRefs.AntiFling.btn.MouseButton1Click:Connect(function() antiFlingEnabled=not antiFlingEnabled; SetAntiFling(antiFlingEnabled) end)
end
local function LoadLowGraphics(v)
    lowGraphics=v
    if v then EnableLowGraphics() else DisableLowGraphics() end
end

-- ================================================================
--  HEARTBEAT: DYNAMIC TRANSLATION UPDATES
-- ================================================================
RunService.Heartbeat:Connect(function()
    if btnRefs.GoldBomb       then btnRefs.GoldBomb.lbl.Text       = goldCD             and T("wait") or T("gold_jump") end
    if btnRefs.NormalBomb     then btnRefs.NormalBomb.lbl.Text     = normalCD           and T("wait") or T("bomb_jump") end
    if btnRefs.Shoot          then
        local hasK=HasKnife(player)
        if btnRefs.Shoot.img  then btnRefs.Shoot.img.Image=hasK and "rbxassetid://9695655416" or "rbxassetid://5159914132" end
        btnRefs.Shoot.lbl.Text = hasK and T("throw_knife") or T("shoot")
    end
    if btnRefs.ESP            then btnRefs.ESP.lbl.Text            = espEnabled         and T("esp_on") or T("esp_off") end
    if btnRefs.Flick          then btnRefs.Flick.lbl.Text          = flickCD            and T("wait") or T("flick") end
    if btnRefs.WallHop        then btnRefs.WallHop.lbl.Text        = wallhopCD          and T("wait") or T("wall_hop") end
    if btnRefs.SpeedGlitch    then btnRefs.SpeedGlitch.lbl.Text    = speedEnabled       and T("speed_on") or T("speed_glitch") end
    if btnRefs.Stretch        then btnRefs.Stretch.lbl.Text        = stretchEnabled     and T("stretch_on") or T("stretch") end
    if btnRefs.GrabGun        then btnRefs.GrabGun.lbl.Text        = FindGunDrop()      and T("grab_gun") or T("no_gun") end
    if btnRefs.FlingMurderer  then
        local hm=false; for _,p in ipairs(Players:GetPlayers()) do if p~=player and HasKnife(p) then hm=true; break end end
        btnRefs.FlingMurderer.lbl.Text = flingBusy and T("flinging") or hm and T("fling_m") or T("no_m")
    end
    if btnRefs.FlingSheriff   then
        local hs=false; for _,p in ipairs(Players:GetPlayers()) do if p~=player and HasGun(p) then hs=true; break end end
        btnRefs.FlingSheriff.lbl.Text  = flingBusy and T("flinging") or hs and T("fling_s") or T("no_s")
    end
    if btnRefs.HoldEveryone   then btnRefs.HoldEveryone.lbl.Text   = holdEveryoneEnabled and T("hold_on") or T("hold") end
    if btnRefs.Invisible      then btnRefs.Invisible.lbl.Text      = invisEnabled        and T("invis_on") or T("invis_off") end
    if btnRefs.SuperJump      then btnRefs.SuperJump.lbl.Text      = superJumpEnabled    and T("super_on") or T("super") end
    if btnRefs.AutoFarm       then btnRefs.AutoFarm.lbl.Text       = autoFarmEnabled     and T("farm_on") or T("farm_off") end
    if btnRefs.AntiFling      then btnRefs.AntiFling.lbl.Text      = antiFlingEnabled    and T("anti_on") or T("anti_off") end
    if btnRefs.LowGraphics    then btnRefs.LowGraphics.lbl.Text    = lowGraphics         and T("low_on") or T("low") end
end)

-- ================================================================
--  WINDUI MENU
-- ================================================================
WindUI:Popup({
    Title = T("popup_title"), Icon = "sparkles", Content = T("popup_content"),
    Buttons = {{ Title = T("ok"), Icon = "check", Variant = "Primary", Callback = function() end }}
})

Window = WindUI:CreateWindow({
    Title = "CogHub", Icon = "sparkles", Author = T("window_author"), Folder = "CogHub",
    Size = UDim2.fromOffset(560, 580), Theme = "Ocean", Acrylic = false, HideSearchBar = true,
    OpenButton = {
        Title = "CogHub", CornerRadius = UDim.new(1, 0), StrokeThickness = 2,
        Enabled = true, OnlyMobile = false,
        Color = ColorSequence.new(Color3.fromHex("#3498db"), Color3.fromHex("#1f618d")),
    },
})
NavSec = Window:Section({ Title = T("section_title"), Opened = true })
Tab = NavSec:Tab({ Title = T("tab_main"), Icon = "zap" })

Track(Tab:Paragraph({ Title = T("load_buttons_title"), Content = T("load_buttons_desc") }), "load_buttons_title", "load_buttons_desc")
Track(Tab:Toggle({ Title = T("gui_gold_jump"), Default = false, Callback = function(v) LoadGoldBomb(v) end }), "gui_gold_jump")
Track(Tab:Toggle({ Title = T("gui_bomb_jump"), Default = false, Callback = function(v) LoadNormalBomb(v) end }), "gui_bomb_jump")
Track(Tab:Toggle({ Title = T("gui_shoot_throw"), Default = false, Callback = function(v) LoadShoot(v) end }), "gui_shoot_throw")
Track(Tab:Toggle({ Title = T("gui_esp"), Default = false, Callback = function(v) LoadESP(v) end }), "gui_esp")
Track(Tab:Toggle({ Title = T("gui_flick"), Default = false, Callback = function(v) LoadFlick(v) end }), "gui_flick")
Track(Tab:Toggle({ Title = T("gui_speed_glitch"), Default = false, Callback = function(v) LoadSpeedGlitch(v) end }), "gui_speed_glitch")
Track(Tab:Button({ Title = T("gui_speed_amount"), Description = T("gui_speed_amount_desc"), Callback = function()
    OpenSliderPopup(T("gui_speed_amount"), 16, 500, SPEED_AMOUNT, 8,
        function(val) SPEED_AMOUNT = val end,
        function() SPEED_AMOUNT = 200 end)
end }), "gui_speed_amount", "gui_speed_amount_desc")
Track(Tab:Toggle({ Title = T("gui_stretch"), Default = false, Callback = function(v) LoadStretch(v) end }), "gui_stretch")
Track(Tab:Button({ Title = T("gui_stretch_amount"), Description = T("gui_stretch_amount_desc"), Callback = function()
    OpenSliderPopup(T("gui_stretch_amount"), 1, 200, STRETCH_AMOUNT, 5,
        function(val) STRETCH_AMOUNT = val end,
        function() STRETCH_AMOUNT = 50 end)
end }), "gui_stretch_amount", "gui_stretch_amount_desc")
Track(Tab:Toggle({ Title = T("gui_grab_gun"), Default = false, Callback = function(v) LoadGrabGun(v) end }), "gui_grab_gun")
Track(Tab:Toggle({ Title = T("gui_wall_hop"), Default = false, Callback = function(v) LoadWallHop(v) end }), "gui_wall_hop")
Track(Tab:Toggle({ Title = T("gui_fling_murderer"), Default = false, Callback = function(v) LoadFlingMurderer(v) end }), "gui_fling_murderer")
Track(Tab:Toggle({ Title = T("gui_fling_sheriff"), Default = false, Callback = function(v) LoadFlingSheriff(v) end }), "gui_fling_sheriff")
Track(Tab:Toggle({ Title = T("gui_hold_everyone"), Default = false, Callback = function(v) LoadHoldEveryone(v) end }), "gui_hold_everyone")
Track(Tab:Toggle({ Title = T("gui_invisible"), Default = false, Callback = function(v) LoadInvisible(v) end }), "gui_invisible")
Track(Tab:Toggle({ Title = T("gui_super_jump"), Default = false, Callback = function(v) LoadSuperJump(v) end }), "gui_super_jump")
Track(Tab:Button({ Title = T("gui_super_jump_power"), Description = T("gui_super_jump_power_desc"), Callback = function()
    OpenSliderPopup(T("gui_super_jump_power"), 50, 500, SUPER_JUMP_POWER, 10,
        function(val) SUPER_JUMP_POWER = val end,
        function() SUPER_JUMP_POWER = 150 end)
end }), "gui_super_jump_power", "gui_super_jump_power_desc")
Track(Tab:Toggle({ Title = T("gui_auto_farm"), Default = false, Callback = function(v) LoadAutoFarm(v) end }), "gui_auto_farm")
Track(Tab:Toggle({ Title = T("gui_anti_fling"), Default = false, Callback = function(v) LoadAntiFling(v) end }), "gui_anti_fling")
Track(Tab:Toggle({ Title = T("gui_low_graphics"), Default = false, Callback = function(v) LoadLowGraphics(v) end }), "gui_low_graphics")
Tab:Divider()

Track(Tab:Paragraph({ Title = T("esp_settings_title"), Content = T("esp_settings_desc") }), "esp_settings_title", "esp_settings_desc")
Track(Tab:Toggle({ Title = T("show_murderer"), Default = true, Callback = function(v) espSettings.Murderer = v end }), "show_murderer")
Track(Tab:Toggle({ Title = T("show_sheriff"), Default = true, Callback = function(v) espSettings.Sheriff = v end }), "show_sheriff")
Track(Tab:Toggle({ Title = T("show_hero"), Default = true, Callback = function(v) espSettings.Hero = v end }), "show_hero")
Track(Tab:Toggle({ Title = T("show_innocents"), Default = true, Callback = function(v) espSettings.Innocent = v end }), "show_innocents")
Track(Tab:Toggle({ Title = T("show_self"), Default = true, Callback = function(v) espSettings.Self = v end }), "show_self")
Track(Tab:Toggle({ Title = T("dropped_gun_esp"), Default = true, Callback = function(v) droppedGunEspEnabled = v; if not v then ClearGunESP(); ClearGunMarker() end end }), "dropped_gun_esp")
Tab:Divider()

Track(Tab:Paragraph({ Title = T("crosshair_title"), Content = T("crosshair_desc") }), "crosshair_title", "crosshair_desc")
Track(Tab:Toggle({ Title = T("custom_crosshair"), Default = false, Callback = function(v)
    crosshairActive = v
    if v then
        SetupCrosshairDisplay(); Notify(T("crosshair_on"))
    else
        local old = game.CoreGui:FindFirstChild("CogCrosshairDisplay"); if old then old:Destroy(); crosshairImg = nil end
        if spinConn then spinConn:Disconnect(); spinConn = nil end
        if crosshairColorConn then crosshairColorConn:Disconnect(); crosshairColorConn = nil end
        UserInputService.MouseIconEnabled = true
        HideGameCrosshair(false)
    end
end }), "custom_crosshair")
Track(Tab:Button({ Title = T("crosshair_picker"), Description = T("crosshair_picker_desc"), Callback = OpenCursorPicker }), "crosshair_picker", "crosshair_picker_desc")
Track(Tab:Button({ Title = T("crosshair_size"), Description = T("crosshair_size_desc"), Callback = function()
    OpenSliderPopup(T("crosshair_size"), 16, 96, crosshairSize, 4,
        function(val) crosshairSize = val; if crosshairImg then crosshairImg.Size = UDim2.new(0, val, 0, val) end end,
        function() crosshairSize = 42; if crosshairImg then crosshairImg.Size = UDim2.new(0, 42, 0, 42) end end)
end }), "crosshair_size", "crosshair_size_desc")
Tab:Divider()

Track(Tab:Paragraph({ Title = T("skybox_title"), Content = T("skybox_desc") }), "skybox_title", "skybox_desc")
Track(Tab:Button({ Title = T("skybox_picker_btn"), Callback = OpenSkyboxPicker }), "skybox_picker_btn")
Tab:Divider()

Track(Tab:Paragraph({ Title = T("asmr_title"), Content = T("asmr_desc") }), "asmr_title", "asmr_desc")
Track(Tab:Toggle({ Title = T("asmr_toggle"), Default = false, Callback = function(v)
    asmrEnabled = v
    if v then StartAsmrKeyboard(); Notify(T("asmr_on")) else StopAsmrKeyboard() end
end }), "asmr_toggle")
Tab:Divider()

Track(Tab:Paragraph({ Title = T("settings_support_title"), Content = T("settings_support_desc") }), "settings_support_title", "settings_support_desc")

guiRefs.discordDropdown = Tab:Dropdown({
    Title = T("discord_menu"),
    Icon = "messages-square",
    Values = { T("support_server") },
    Value = T("support_server"),
    Callback = function()
        OpenDiscord()
    end,
})

guiRefs.langDropdown = Tab:Dropdown({
    Title = T("language_label"),
    Values = LANG_OPTIONS,
    Value = currentLang,
    Callback = function(val)
        ChangeLanguage(val)
    end,
})

Track(Tab:Paragraph({ Title = T("creator_line"), Content = T("creator_desc") }), "creator_line", "creator_desc")

-- ================================================================
--  CHARACTER ADDED - CLEANUP
-- ================================================================
player.CharacterAdded:Connect(function(char)
    invisEnabled=false; holdEveryoneEnabled=false; table.clear(savedPositions)
    if invisPlatform then invisPlatform:Destroy(); invisPlatform=nil end
    if holdEveryoneConn then holdEveryoneConn:Disconnect(); holdEveryoneConn=nil end
    if superJumpConn then superJumpConn:Disconnect(); superJumpConn=nil end
    superJumpEnabled=false
    if noclipConn and not autoFarmEnabled then DisableNoclip() end
    if asmrEnabled then
        if asmrConn then asmrConn:Disconnect(); asmrConn=nil end
        asmrLastTime=0; asmrLastPos=Vector3.new(0,0,0)
        task.wait(1); StartAsmrKeyboard()
    end
    task.spawn(SetupSpeedGlitch, char)
    if autoFarmEnabled then task.wait(1); EnableNoclip() end
end)

Notify(T("ready_msg"))
print("[CogHub] v1.2 loaded by Beli!")
