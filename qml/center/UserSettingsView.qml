/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           UserSettingsView.qml
 * Author:         SK Rehan Ahamed
 * Description:    Hierarchical OEM User Settings & Multi-Language Localization
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick
import QtQuick.Controls

Item {
    id: settingsRoot
    width: parent.width
    height: 204
    clip: true

    property string themeColor: "blue"

    readonly property bool isGreen: themeColor === "green" || themeColor === "#00E676" || themeColor.indexOf("green") !== -1 || themeColor.indexOf("E676") !== -1
    readonly property bool isRed: themeColor === "red" || themeColor === "#FF5252" || themeColor.indexOf("red") !== -1 || themeColor.indexOf("5252") !== -1

    readonly property color boxGradTop: isGreen ? "#7300C853" : (isRed ? "#73E53935" : "#73008CF0")
    readonly property color boxGradMid: isGreen ? "#59007E33" : (isRed ? "#59B71C1C" : "#590050B4")
    readonly property color boxGradBottom: isGreen ? "#7300C853" : (isRed ? "#73E53935" : "#73008CF0")
    readonly property color neonEdgeColor: isGreen ? "#00E676" : (isRed ? "#FF5252" : "#00E5FF")

    // State Stack: "main", "driver", "warning_methods", "warning_volume", "cluster", "lights", "door", "auto_lock", "auto_unlock", "convenience", "service_interval", "adjust_interval", "reset_interval", "welcome_mirror", "unit", "temp_unit", "fuel_economy_unit", "tyre_pressure_unit", "language", "reset"
    property var menuStack: ["main"]
    readonly property string currentMenu: menuStack[menuStack.length - 1]
    property int selectedIndex: 0

    // Returns whether top header should show "Hold [OK] : Help"
    readonly property bool showHelpHint: (currentMenu === "unit" && selectedIndex > 0) || (currentMenu === "service_interval" && selectedIndex === 1) || (currentMenu === "door" && selectedIndex > 0) || ((currentMenu === "driver" || currentMenu === "warning_methods" || currentMenu === "warning_volume") && selectedIndex > 0) || (currentMenu === "lights" && selectedIndex === 1)

    // Settings State Values
    property string warningVolume: "Medium"
    property bool wiperLightMode: true
    property bool roadIcingAlert: true
    property bool welcomeSound: true
    property int lightBrightness: 20
    property string oneTouchIndicator: "3 flashes"
    property bool headlampEscort: true
    property string autoLockSetting: "Enable on speed"   // "Enable on speed" | "Off"
    property string autoUnlockSetting: "On key out"      // "On key out" | "Off"
    property bool enableServiceInterval: true
    property int serviceIntervalKm: 10000
    property int serviceIntervalMonths: 12
    property int serviceRemainingKm: 9969
    property int serviceRemainingDays: 365
    property bool welcomeMirrorUnlock: true
    property int adjustField: 0 // 0: km, 1: months
    property int resetChoice: 0 // 0: Yes, 1: No
    property string tempUnitSetting: "°C"              // "°C" | "°F"
    property string fuelEconUnitSetting: "km/L"        // "km/L" | "L/100km"
    property string tyrePressureUnitSetting: "psi"     // "psi" | "kPa" | "bar"
    property string languageSetting: controller ? controller.language : "English"
    readonly property bool isHindi: languageSetting === "हिन्दी" || languageSetting === "Hindi" || (controller && (controller.language === "हिन्दी" || controller.language === "Hindi"))

    FontLoader { id: clusterRegular; source: "qrc:/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Regular.ttf" }
    FontLoader { id: clusterMedium; source: "qrc:/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Medium.ttf" }
    FontLoader { id: clusterBold; source: "qrc:/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Bold.ttf" }
    FontLoader { id: notoDevanagari; source: "qrc:/qt/qml/ApexCluster/resources/fonts/NotoSansDevanagari-Regular.ttf" }

    readonly property string fontHeadRegular: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (clusterRegular.status === FontLoader.Ready ? clusterRegular.name : "Cluster Sans Head")
    readonly property string fontHeadMedium: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (clusterMedium.status === FontLoader.Ready ? clusterMedium.name : "Cluster Sans Head")
    readonly property string fontHeadBold: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (clusterBold.status === FontLoader.Ready ? clusterBold.name : "Cluster Sans Head")

    function getDevanagariFont(str) {
        if (!str) return isHindi ? "Noto Sans Devanagari" : (clusterMedium.status === FontLoader.Ready ? clusterMedium.name : "Cluster Sans Head");
        var s = String(str);
        for (var i = 0; i < s.length; ++i) {
            var code = s.charCodeAt(i);
            if (code >= 0x0900 && code <= 0x097F) {
                return "Noto Sans Devanagari";
            }
        }
        return isHindi ? "Noto Sans Devanagari" : (clusterMedium.status === FontLoader.Ready ? clusterMedium.name : "Cluster Sans Head");
    }

    function tr(key) {
        if (!isHindi) return key;
        var map = {
            "User settings": "उपयोगकर्ता सेटिंग्स",
            "Driver assistance": "ड्राइवर सहायता",
            "Warning methods": "चेतावनी विधियाँ",
            "Warning volume": "चेतावनी वॉल्यूम",
            "Cluster": "क्लस्टर",
            "Cluster theme": "क्लस्टर थीम",
            "Lights": "लाइट्स",
            "Illumination": "रोशनी की तीव्रता",
            "One touch turn indi...": "वन टच टर्न इंडिकेटर",
            "Door": "दरवाजे",
            "Auto lock": "ऑटो लॉक",
            "Auto unlock": "ऑटो अनलॉक",
            "Convenience": "सुविधा",
            "Service interval": "सर्विस अंतराल",
            "Adjust interval": "अंतराल समायोजित करें",
            "Welcome mirror": "वेलकम मिरर",
            "Unit": "इकाइयाँ",
            "Temperature unit": "तापमान इकाई",
            "Fuel economy unit": "माइलेज इकाई",
            "Tyre pressure unit": "टायर प्रेशर इकाई",
            "Language": "भाषा",
            "Reset settings": "सेटिंग्स रीसेट करें",
            "Back": "वापस",
            "Wiper/Lights display": "वाइपर/लाइट्स डिस्प्ले",
            "Icy road warning": "बर्फीली सड़क चेतावनी",
            "Welcome sound": "वेलकम साउंड",
            "One touch turn i...": "वन टच टर्न इंडिकेटर",
            "Headlight time-...": "हेडलाइट टाइम-आउट",
            "Enable service interva...": "सर्विस अंतराल सक्षम करें",
            "Reset": "रीसेट",
            "On door unlock": "डोर अनलॉक होने पर",
            "Restore default settings": "फ़ैक्टरी सेटिंग्स रीसेट करें",
            "Yes": "हाँ",
            "No": "नहीं"
        };
        return map[key] || key;
    }

    onLightBrightnessChanged: {
        if (controller) controller.setIllumination(lightBrightness);
    }
    onTempUnitSettingChanged: {
        if (controller) controller.setTempUnit(tempUnitSetting);
    }
    onFuelEconUnitSettingChanged: {
        if (controller) controller.setFuelUnit(fuelEconUnitSetting);
    }
    onTyrePressureUnitSettingChanged: {
        if (controller) controller.setTpmsUnit(tyrePressureUnitSetting);
    }

    function adjustBrightness(delta) {
        lightBrightness = Math.max(1, Math.min(20, lightBrightness + delta));
    }

    // Reset popup state
    property bool showResetResult: false
    property string resetPopupText: ""

    Timer {
        id: resetResultTimer
        interval: 1800
        repeat: false
        onTriggered: {
            settingsRoot.showResetResult = false;
            if (settingsRoot.currentMenu === "reset") {
                settingsRoot.menuStack = ["main"];
                settingsRoot.selectedIndex = 0;
            } else if (settingsRoot.currentMenu === "reset_interval") {
                settingsRoot.goBack();
            }
        }
    }

    function resetAllToDefault() {
        warningVolume = "Medium";
        wiperLightMode = true;
        roadIcingAlert = true;
        welcomeSound = true;
        lightBrightness = 20;
        oneTouchIndicator = "3 flashes";
        headlampEscort = true;
        autoLockSetting = "Enable on speed";
        autoUnlockSetting = "On key out";
        enableServiceInterval = true;
        serviceIntervalKm = 10000;
        serviceIntervalMonths = 12;
        serviceRemainingKm = 10000;
        serviceRemainingDays = 365;
        welcomeMirrorUnlock = true;
        tempUnitSetting = "°C";
        fuelEconUnitSetting = "km/L";
        tyrePressureUnitSetting = "psi";
        languageSetting = "English";
        if (controller) {
            controller.setLanguage("English");
            controller.setThemeColor("blue");
            controller.setTempUnit("°C");
            controller.setFuelUnit("km/L");
            controller.setTpmsUnit("psi");
            controller.setIllumination(20);
        }
    }

    function getMenuItems() {
        if (currentMenu === "main") {
            return [
                { id: "driver", label: "Driver assistance", hasSub: true },
                { id: "cluster", label: "Cluster", hasSub: true },
                { id: "lights", label: "Lights", hasSub: true },
                { id: "door", label: "Door", hasSub: true },
                { id: "convenience", label: "Convenience", hasSub: true },
                { id: "unit", label: "Unit", hasSub: true },
                { id: "language", label: "Language", hasSub: true },
                { id: "reset", label: "Reset settings", hasSub: true }
            ];
        } else if (currentMenu === "driver") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "warning_methods", label: "Warning methods", hasSub: true }
            ];
        } else if (currentMenu === "warning_methods") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "warning_volume", label: "Warning volume", hasSub: true }
            ];
        } else if (currentMenu === "warning_volume") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "High", label: "High", isRadio: true, checked: warningVolume === "High" },
                { id: "Medium", label: "Medium", isRadio: true, checked: warningVolume === "Medium" },
                { id: "Low", label: "Low", isRadio: true, checked: warningVolume === "Low" }
            ];
        } else if (currentMenu === "cluster") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "cluster_theme", label: "Cluster theme", hasSub: true },
                { id: "wiper", label: "Wiper/Lights display", isCheckbox: true, checked: wiperLightMode },
                { id: "icing", label: "Icy road warning", isCheckbox: true, checked: roadIcingAlert },
                { id: "welcome", label: "Welcome sound", isCheckbox: true, checked: welcomeSound }
            ];
        } else if (currentMenu === "cluster_theme") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "theme_a", label: "Theme A", isRadio: true, checked: themeColor === "blue" },
                { id: "theme_b", label: "Theme B", isRadio: true, checked: themeColor === "green" },
                { id: "theme_c", label: "Theme C", isRadio: true, checked: themeColor === "red" }
            ];
        } else if (currentMenu === "lights") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "illumination", label: "Illumination", hasSub: true },
                { id: "one_touch_turn", label: "One touch turn i...", hasSub: true },
                { id: "escort", label: "Headlight time-...", isCheckbox: true, checked: headlampEscort }
            ];
        } else if (currentMenu === "one_touch_turn") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "7 flashes", label: "7 flashes", isRadio: true, checked: oneTouchIndicator === "7 flashes" },
                { id: "5 flashes", label: "5 flashes", isRadio: true, checked: oneTouchIndicator === "5 flashes" },
                { id: "3 flashes", label: "3 flashes", isRadio: true, checked: oneTouchIndicator === "3 flashes" },
                { id: "Off", label: "Off", isRadio: true, checked: oneTouchIndicator === "Off" }
            ];
        } else if (currentMenu === "door") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "auto_lock", label: "Auto lock", hasSub: true },
                { id: "auto_unlock", label: "Auto unlock", hasSub: true }
            ];
        } else if (currentMenu === "auto_lock") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "Enable on speed", label: "Enable on speed", isRadio: true, checked: autoLockSetting === "Enable on speed" },
                { id: "Off", label: "Off", isRadio: true, checked: autoLockSetting === "Off" }
            ];
        } else if (currentMenu === "auto_unlock") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "On key out", label: "On key out", isRadio: true, checked: autoUnlockSetting === "On key out" },
                { id: "Off", label: "Off", isRadio: true, checked: autoUnlockSetting === "Off" }
            ];
        } else if (currentMenu === "convenience") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "service_interval", label: "Service interval", hasSub: true },
                { id: "welcome_mirror", label: "Welcome mirror", hasSub: true }
            ];
        } else if (currentMenu === "service_interval") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "enable_service", label: "Enable service interva...", isCheckbox: true, checked: enableServiceInterval },
                { id: "adjust_interval", label: "Adjust interval", hasSub: true },
                { id: "reset_interval", label: "Reset", hasSub: true }
            ];
        } else if (currentMenu === "welcome_mirror") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "welcome_mirror_unlock", label: "On door unlock", isCheckbox: true, checked: welcomeMirrorUnlock }
            ];
        } else if (currentMenu === "unit") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "temp_unit", label: "Temperature unit", hasSub: true },
                { id: "fuel_economy_unit", label: "Fuel economy unit", hasSub: true },
                { id: "tyre_pressure_unit", label: "Tyre pressure unit", hasSub: true }
            ];
        } else if (currentMenu === "temp_unit") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "°C", label: "°C", isRadio: true, checked: tempUnitSetting === "°C" },
                { id: "°F", label: "°F", isRadio: true, checked: tempUnitSetting === "°F" }
            ];
        } else if (currentMenu === "fuel_economy_unit") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "km/L", label: "km/L", isRadio: true, checked: fuelEconUnitSetting === "km/L" },
                { id: "L/100km", label: "L/100km", isRadio: true, checked: fuelEconUnitSetting === "L/100km" }
            ];
        } else if (currentMenu === "tyre_pressure_unit") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "psi", label: "psi", isRadio: true, checked: tyrePressureUnitSetting === "psi" },
                { id: "kPa", label: "kPa", isRadio: true, checked: tyrePressureUnitSetting === "kPa" },
                { id: "bar", label: "bar", isRadio: true, checked: tyrePressureUnitSetting === "bar" }
            ];
        } else if (currentMenu === "language") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "English", label: "English", isRadio: true, checked: languageSetting === "English" },
                { id: "हिन्दी", label: "हिन्दी", isRadio: true, checked: languageSetting === "हिन्दी" }
            ];
        }
        return [];
    }

    function getMenuTitle() {
        if (currentMenu === "main") return tr("User settings");
        if (currentMenu === "driver") return tr("Driver assistance");
        if (currentMenu === "warning_methods") return tr("Warning methods");
        if (currentMenu === "warning_volume") return tr("Warning volume");
        if (currentMenu === "cluster") return tr("Cluster");
        if (currentMenu === "cluster_theme") return tr("Cluster theme");
        if (currentMenu === "lights") return tr("Lights");
        if (currentMenu === "illumination") return tr("Illumination");
        if (currentMenu === "one_touch_turn") return tr("One touch turn indi...");
        if (currentMenu === "door") return tr("Door");
        if (currentMenu === "auto_lock") return tr("Auto lock");
        if (currentMenu === "auto_unlock") return tr("Auto unlock");
        if (currentMenu === "convenience") return tr("Convenience");
        if (currentMenu === "service_interval") return tr("Service interval");
        if (currentMenu === "adjust_interval") return tr("Adjust interval");
        if (currentMenu === "reset_interval" || currentMenu === "reset") return "";
        if (currentMenu === "welcome_mirror") return tr("Welcome mirror");
        if (currentMenu === "unit") return tr("Unit");
        if (currentMenu === "temp_unit") return tr("Temperature unit");
        if (currentMenu === "fuel_economy_unit") return tr("Fuel economy unit");
        if (currentMenu === "tyre_pressure_unit") return tr("Tyre pressure unit");
        if (currentMenu === "language") return tr("Language");
        return tr("User settings");
    }

    function goBack() {
        if (menuStack.length > 1) {
            var newStack = menuStack.slice(0, menuStack.length - 1);
            menuStack = newStack;
            selectedIndex = (currentMenu === "main" ? 0 : 1);
        }
    }

    function selectCurrent() {
        if (currentMenu === "adjust_interval") {
            adjustField = (adjustField === 0 ? 1 : 0);
            return;
        }
        if (currentMenu === "reset") {
            if (resetChoice === 0) {
                // YES -> Reset all to factory default
                resetAllToDefault();
                resetPopupText = isHindi ? "सेटिंग्स रीसेट\nकर दी गई हैं" : "Settings have\nbeen reset";
            } else {
                // NO -> Do NOT reset
                resetPopupText = isHindi ? "सेटिंग्स रीसेट\nनहीं की गई हैं" : "Settings have\nnot been reset";
            }
            showResetResult = true;
            resetResultTimer.restart();
            return;
        }
        if (currentMenu === "reset_interval") {
            if (resetChoice === 0) {
                // YES -> Reset time and distance
                serviceRemainingKm = serviceIntervalKm;
                serviceRemainingDays = serviceIntervalMonths * 30;
                resetPopupText = isHindi ? "सेटिंग्स रीसेट\nकर दी गई हैं" : "Settings have\nbeen reset";
            } else {
                // NO -> Do NOT reset
                resetPopupText = isHindi ? "सेटिंग्स रीसेट\nनहीं की गई हैं" : "Settings have\nnot been reset";
            }
            showResetResult = true;
            resetResultTimer.restart();
            return;
        }

        var items = getMenuItems();
        if (selectedIndex < 0 || selectedIndex >= items.length) return;
        var item = items[selectedIndex];

        if (item.isBack) {
            goBack();
            return;
        }

        if (item.hasSub) {
            var newStack = menuStack.slice();
            newStack.push(item.id);
            menuStack = newStack;
            resetChoice = 0; // Default to YES on dialogs
            selectedIndex = (item.id === "adjust_interval" || item.id === "reset_interval" || item.id === "reset" ? 0 : 1);
            return;
        }

        if (item.isRadio) {
            if (currentMenu === "warning_volume") {
                warningVolume = item.id;
            } else if (currentMenu === "cluster_theme") {
                if (item.id === "theme_a") { if (controller) controller.setThemeColor("blue"); }
                else if (item.id === "theme_b") { if (controller) controller.setThemeColor("green"); }
                else if (item.id === "theme_c") { if (controller) controller.setThemeColor("red"); }
            } else if (currentMenu === "one_touch_turn") {
                oneTouchIndicator = item.id;
            } else if (currentMenu === "auto_lock") {
                autoLockSetting = item.id;
            } else if (currentMenu === "auto_unlock") {
                autoUnlockSetting = item.id;
            } else if (currentMenu === "temp_unit") {
                tempUnitSetting = item.id;
            } else if (currentMenu === "fuel_economy_unit") {
                fuelEconUnitSetting = item.id;
            } else if (currentMenu === "tyre_pressure_unit") {
                tyrePressureUnitSetting = item.id;
            } else if (currentMenu === "language") {
                languageSetting = item.id;
                if (controller) controller.setLanguage(item.id);
            }
            return;
        }

        if (item.isCheckbox) {
            if (item.id === "wiper") wiperLightMode = !wiperLightMode;
            else if (item.id === "icing") roadIcingAlert = !roadIcingAlert;
            else if (item.id === "welcome") welcomeSound = !welcomeSound;
            else if (item.id === "escort") headlampEscort = !headlampEscort;
            else if (item.id === "enable_service") enableServiceInterval = !enableServiceInterval;
            else if (item.id === "welcome_mirror_unlock") welcomeMirrorUnlock = !welcomeMirrorUnlock;
            return;
        }
    }

    function navUp() {
        if (currentMenu === "illumination") {
            adjustBrightness(1);
            return;
        }
        if (currentMenu === "adjust_interval") {
            if (adjustField === 0) {
                serviceIntervalKm = Math.min(30000, serviceIntervalKm + 1000);
            } else {
                serviceIntervalMonths = Math.min(36, serviceIntervalMonths + 1);
            }
            return;
        }
        if (currentMenu === "reset_interval" || currentMenu === "reset") {
            resetChoice = (resetChoice === 0 ? 1 : 0);
            return;
        }
        var count = getMenuItems().length;
        if (count > 0) {
            selectedIndex = (selectedIndex - 1 + count) % count;
        }
    }

    function navDown() {
        if (currentMenu === "illumination") {
            adjustBrightness(-1);
            return;
        }
        if (currentMenu === "adjust_interval") {
            if (adjustField === 0) {
                serviceIntervalKm = Math.max(1000, serviceIntervalKm - 1000);
            } else {
                serviceIntervalMonths = Math.max(1, serviceIntervalMonths - 1);
            }
            return;
        }
        if (currentMenu === "reset_interval" || currentMenu === "reset") {
            resetChoice = (resetChoice === 0 ? 1 : 0);
            return;
        }
        var count = getMenuItems().length;
        if (count > 0) {
            selectedIndex = (selectedIndex + 1) % count;
        }
    }

    // =================================================================
    // 1. TOP TITLE HEADER: Exact OEM Typography
    // =================================================================
    Item {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 28
        visible: settingsRoot.currentMenu !== "reset_interval" && settingsRoot.currentMenu !== "reset" && !settingsRoot.showResetResult

        Text {
            anchors.centerIn: parent
            text: settingsRoot.getMenuTitle()
            font.pixelSize: 18
            font.family: settingsRoot.getDevanagariFont(text)
            font.weight: Font.DemiBold
            color: "#FFFFFF"
        }
    }

    // =================================================================
    // 2. SCROLLABLE MENU ITEMS VIEW (OEM Layout & Selection Box)
    // =================================================================
    Item {
        id: menuViewContainer
        anchors.top: headerBar.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        visible: settingsRoot.currentMenu !== "illumination" && settingsRoot.currentMenu !== "adjust_interval" && settingsRoot.currentMenu !== "reset_interval" && settingsRoot.currentMenu !== "reset" && !settingsRoot.showResetResult

        property var currentItems: settingsRoot.getMenuItems()

        // Right Edge Scrollbar Track & Thumb
        Item {
            id: scrollbar
            anchors.right: parent.right
            anchors.rightMargin: -1
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            width: 3
            visible: menuViewContainer.currentItems.length > 5

            Rectangle {
                anchors.fill: parent
                radius: 1.5
                color: "#20FFFFFF"
            }

            Rectangle {
                width: 3
                height: Math.max(20, parent.height * (5.0 / Math.max(1, menuViewContainer.currentItems.length)))
                radius: 1.5
                color: "#FFFFFF"
                y: (parent.height - height) * (settingsRoot.selectedIndex / Math.max(1, menuViewContainer.currentItems.length - 1))
                Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
            }
        }

        // Sliding Items Container
        Item {
            id: slidingList
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.right: scrollbar.visible ? scrollbar.left : parent.right
            anchors.rightMargin: scrollbar.visible ? 6 : 2
            height: menuViewContainer.currentItems.length * 31

            // Dynamic smooth auto-centering
            y: {
                var itemH = 31;
                var viewH = menuViewContainer.height;
                var targetY = -(settingsRoot.selectedIndex * itemH) + (viewH - itemH) * 0.5;
                var minY = viewH - height;
                if (height <= viewH) return 0;
                return Math.max(minY, Math.min(0, targetY));
            }
            Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

            Column {
                anchors.fill: parent
                spacing: 2

                Repeater {
                    model: menuViewContainer.currentItems

                    Item {
                        width: parent.width
                        height: 29

                        property bool isSelected: settingsRoot.selectedIndex === index

                        // Selected Illuminated Glowing Capsule Box
                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            visible: isSelected
                            opacity: isSelected ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            gradient: Gradient {
                                orientation: Gradient.Vertical
                                GradientStop { position: 0.0; color: settingsRoot.boxGradTop }
                                GradientStop { position: 0.5; color: settingsRoot.boxGradMid }
                                GradientStop { position: 1.0; color: settingsRoot.boxGradBottom }
                            }

                            // Top Neon Highlight Line
                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1.2
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.2; color: settingsRoot.neonEdgeColor }
                                    GradientStop { position: 0.8; color: settingsRoot.neonEdgeColor }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }

                            // Bottom Neon Highlight Line
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 1.2
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.2; color: settingsRoot.neonEdgeColor }
                                    GradientStop { position: 0.8; color: settingsRoot.neonEdgeColor }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }
                        }

                        // 1. Back Item Layout: ↩ Back (Exact OEM Arrow Icon from Photo 1)
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 7
                            visible: modelData.isBack === true

                            Canvas {
                                id: backArrowCanvas
                                width: 14
                                height: 12
                                anchors.verticalCenter: parent.verticalCenter
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.strokeStyle = isSelected ? "#FFFFFF" : "#CCD8E8";
                                    ctx.lineWidth = 1.6;
                                    ctx.lineCap = "round";
                                    ctx.lineJoin = "round";

                                    // Return Shaft: starts at arrow base, goes right, loops 180° down, ends left
                                    ctx.beginPath();
                                    ctx.moveTo(3.5, 3.5);
                                    ctx.lineTo(8.5, 3.5);
                                    ctx.arc(8.5, 6.5, 3.0, -Math.PI / 2, Math.PI / 2, false);
                                    ctx.lineTo(5.5, 9.5);
                                    ctx.stroke();

                                    // Arrowhead pointing Left
                                    ctx.beginPath();
                                    ctx.moveTo(5.5, 1.2);
                                    ctx.lineTo(2.0, 3.5);
                                    ctx.lineTo(5.5, 5.8);
                                    ctx.stroke();
                                }
                                Connections {
                                    target: settingsRoot
                                    function onSelectedIndexChanged() { backArrowCanvas.requestPaint(); }
                                }
                            }

                            Text {
                                text: settingsRoot.tr("Back")
                                font.pixelSize: 14
                                font.family: settingsRoot.getDevanagariFont(text)
                                font.weight: isSelected ? Font.Bold : Font.DemiBold
                                color: isSelected ? "#FFFFFF" : "#CCD8E8"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // 2. Regular Item / Submenu Label
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !modelData.isBack
                            text: settingsRoot.tr(modelData.label)
                            font.pixelSize: 14
                            font.family: settingsRoot.getDevanagariFont(text)
                            font.weight: isSelected ? Font.Bold : Font.DemiBold
                            color: isSelected ? "#FFFFFF" : "#D0E0F0"
                        }

                        // 3. Submenu Chevron '>'
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: modelData.hasSub === true
                            text: ">"
                            font.pixelSize: 14
                            font.family: settingsRoot.fontHeadBold
                            font.weight: Font.Bold
                            color: isSelected ? settingsRoot.neonEdgeColor : "#80A0C0"
                        }

                        // 4. Toggle or Value Text
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: (modelData.isToggle === true || modelData.isValue === true)
                            text: modelData.value ? settingsRoot.tr(modelData.value) : ""
                            font.pixelSize: 12
                            font.family: settingsRoot.getDevanagariFont(text)
                            font.bold: true
                            color: (modelData.value === "On" || isSelected) ? settingsRoot.neonEdgeColor : "#80A0C0"
                        }

                        // 5. Circular Radio Button: Matches Photo 2 & 3 1:1
                        Item {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 15
                            height: 15
                            visible: modelData.isRadio === true

                            // Outer Circle
                            Rectangle {
                                anchors.fill: parent
                                radius: 7.5
                                color: "transparent"
                                border.color: isSelected ? settingsRoot.neonEdgeColor : "#7090A8"
                                border.width: 1.5
                            }

                            // Inner Filled Dot when Checked
                            Rectangle {
                                anchors.centerIn: parent
                                width: 7
                                height: 7
                                radius: 3.5
                                visible: modelData.checked === true
                                color: settingsRoot.neonEdgeColor
                            }
                        }

                        // 6. Rounded Square Checkbox: Matches Photo 1:1
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            radius: 2.5
                            visible: modelData.isCheckbox === true
                            color: modelData.checked === true ? settingsRoot.neonEdgeColor : "#101824"
                            border.color: modelData.checked === true ? settingsRoot.neonEdgeColor : "#7088A0"
                            border.width: 1.2

                            Text {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -0.5
                                visible: modelData.checked === true
                                text: "✓"
                                font.pixelSize: 11
                                font.family: settingsRoot.fontHeadBold
                                font.bold: true
                                color: "#000000"
                            }
                        }
                    }
                }
            }
        }

        // Bottom Preview for Service Interval: 9969 km / 365 days (Matches Photo 2)
        Item {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            anchors.left: parent.left
            anchors.right: parent.right
            height: 28
            visible: settingsRoot.currentMenu === "service_interval"

            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 24
                height: 1
                color: "#25FFFFFF"
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 2
                text: settingsRoot.serviceRemainingKm + " km / " + settingsRoot.serviceRemainingDays + " " + settingsRoot.tr("days")
                font.pixelSize: 13
                font.family: settingsRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#CCD8E8"
            }
        }
    }

    // =================================================================
    // 3. ILLUMINATION ARC GAUGE VIEW (Matches Photos 2 & 3 1:1)
    // =================================================================
    Item {
        id: illuminationGaugeView
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: settingsRoot.currentMenu === "illumination"

        // Center 3D Arc Canvas
        Canvas {
            id: arcCanvas
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -4
            width: 140
            height: 140

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var cx = width / 2;
                var cy = height / 2;
                var radius = 50;
                var startAngle = 0.75 * Math.PI; // 135 deg
                var totalSweep = 1.5 * Math.PI;  // 270 deg
                var endAngle = startAngle + totalSweep;

                var fraction = Math.max(0.05, Math.min(1.0, (settingsRoot.lightBrightness - 1) / 19.0));
                var activeEnd = startAngle + totalSweep * fraction;

                // =========================================================
                // 1. GROUND PLANE 3D REFLECTION (Bottom Sheen)
                // =========================================================
                ctx.save();
                ctx.beginPath();
                ctx.arc(cx, cy + 12, radius, startAngle, endAngle, false);
                ctx.strokeStyle = settingsRoot.isGreen ? "rgba(0, 230, 118, 0.12)" : (settingsRoot.isRed ? "rgba(255, 82, 82, 0.12)" : "rgba(0, 160, 255, 0.12)");
                ctx.lineWidth = 6;
                ctx.stroke();
                ctx.restore();

                // =========================================================
                // 2. 3D TRACK CHANNEL (Dark Glass Trench)
                // =========================================================
                ctx.beginPath();
                ctx.arc(cx, cy, radius, startAngle, endAngle, false);
                ctx.strokeStyle = "#0E1824";
                ctx.lineWidth = 14;
                ctx.stroke();

                // Trench Outer Bevel Highlight
                ctx.beginPath();
                ctx.arc(cx, cy, radius + 7.5, startAngle, endAngle, false);
                ctx.strokeStyle = "rgba(255, 255, 255, 0.4)";
                ctx.lineWidth = 1.2;
                ctx.stroke();

                // Trench Inner Bevel Rim
                ctx.beginPath();
                ctx.arc(cx, cy, radius - 7.5, startAngle, endAngle, false);
                ctx.strokeStyle = "rgba(255, 255, 255, 0.25)";
                ctx.lineWidth = 1.0;
                ctx.stroke();

                // =========================================================
                // 3. 3D ACTIVE GLOWING TORUS CYLINDER (Theme Reactive 3D Tube)
                // =========================================================
                // A. Volumetric Ambient Glow Halo
                ctx.beginPath();
                ctx.arc(cx, cy, radius, startAngle, activeEnd, false);
                ctx.strokeStyle = settingsRoot.isGreen ? "rgba(0, 230, 118, 0.35)" : (settingsRoot.isRed ? "rgba(255, 82, 82, 0.35)" : "rgba(0, 180, 255, 0.35)");
                ctx.lineWidth = 20;
                ctx.stroke();

                // B. Core 3D Cylindrical Extruded Arc Body (Dynamic Theme Colors)
                var gradCore = ctx.createLinearGradient(0, height, width, 0);
                if (settingsRoot.isGreen) {
                    gradCore.addColorStop(0.0, "#004D20");
                    gradCore.addColorStop(0.4, "#008B38");
                    gradCore.addColorStop(0.85, "#00E676");
                    gradCore.addColorStop(1.0, "#69F0AE");
                } else if (settingsRoot.isRed) {
                    gradCore.addColorStop(0.0, "#600A0A");
                    gradCore.addColorStop(0.4, "#C62828");
                    gradCore.addColorStop(0.85, "#FF5252");
                    gradCore.addColorStop(1.0, "#FF8A80");
                } else {
                    gradCore.addColorStop(0.0, "#004899");
                    gradCore.addColorStop(0.4, "#0088EE");
                    gradCore.addColorStop(0.85, "#00C8FF");
                    gradCore.addColorStop(1.0, "#40E5FF");
                }

                ctx.beginPath();
                ctx.arc(cx, cy, radius, startAngle, activeEnd, false);
                ctx.strokeStyle = gradCore;
                ctx.lineWidth = 13;
                ctx.stroke();

                // C. 3D Convex Specular Ridge Highlight (Top Glass Ridge)
                ctx.beginPath();
                ctx.arc(cx, cy, radius + 2.5, startAngle, activeEnd, false);
                var gradSpec = ctx.createLinearGradient(0, height, width, 0);
                gradSpec.addColorStop(0.0, "rgba(255, 255, 255, 0.2)");
                gradSpec.addColorStop(0.5, "rgba(255, 255, 255, 0.7)");
                gradSpec.addColorStop(1.0, "rgba(255, 255, 255, 0.95)");
                ctx.strokeStyle = gradSpec;
                ctx.lineWidth = 2.0;
                ctx.stroke();

                // D. Shadow Floor on Inner Edge of Tube
                ctx.beginPath();
                ctx.arc(cx, cy, radius - 4, startAngle, activeEnd, false);
                ctx.strokeStyle = "rgba(0, 20, 60, 0.5)";
                ctx.lineWidth = 2.5;
                ctx.stroke();

                // =========================================================
                // 4. RADIAL 3D GLASS SEGMENT ETCHES (Visible in Photo 2 & 3)
                // =========================================================
                var segmentFracs = [0.333, 0.50, 0.666];
                for (var s = 0; s < segmentFracs.length; s++) {
                    var sAngle = startAngle + totalSweep * segmentFracs[s];
                    var cosA = Math.cos(sAngle);
                    var sinA = Math.sin(sAngle);

                    // Dark engraved groove
                    ctx.beginPath();
                    ctx.moveTo(cx + (radius - 7) * cosA, cy + (radius - 7) * sinA);
                    ctx.lineTo(cx + (radius + 7) * cosA, cy + (radius + 7) * sinA);
                    ctx.strokeStyle = "rgba(0, 10, 30, 0.75)";
                    ctx.lineWidth = 1.6;
                    ctx.stroke();

                    // Specular catch light on groove edge
                    var sAngleOffset = sAngle + 0.02;
                    ctx.beginPath();
                    ctx.moveTo(cx + (radius - 6.5) * Math.cos(sAngleOffset), cy + (radius - 6.5) * Math.sin(sAngleOffset));
                    ctx.lineTo(cx + (radius + 6.5) * Math.cos(sAngleOffset), cy + (radius + 6.5) * Math.sin(sAngleOffset));
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.5)";
                    ctx.lineWidth = 0.8;
                    ctx.stroke();
                }

                // =========================================================
                // 5. 3D LEADING EDGE TERMINATOR BEVEL (Bright White Cap)
                // =========================================================
                var angle = activeEnd;
                ctx.beginPath();
                ctx.moveTo(cx + (radius - 7.5) * Math.cos(angle), cy + (radius - 7.5) * Math.sin(angle));
                ctx.lineTo(cx + (radius + 7.5) * Math.cos(angle), cy + (radius + 7.5) * Math.sin(angle));
                ctx.strokeStyle = "#FFFFFF";
                ctx.lineWidth = 2.0;
                ctx.stroke();
            }

            Connections {
                target: settingsRoot
                function onLightBrightnessChanged() { arcCanvas.requestPaint(); }
                function onCurrentMenuChanged() { arcCanvas.requestPaint(); }
                function onThemeColorChanged() { arcCanvas.requestPaint(); }
            }
        }

        // Center Dial Lightbulb Icon & Value
        Column {
            anchors.centerIn: arcCanvas
            anchors.verticalCenterOffset: -2
            spacing: 2

            // Dial / Lightbulb Vector Icon
            Canvas {
                id: bulbIconCanvas
                width: 26
                height: 18
                anchors.horizontalCenter: parent.horizontalCenter
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = "#FFFFFF";
                    ctx.fillStyle = "#FFFFFF";
                    ctx.lineWidth = 1.4;
                    ctx.lineCap = "round";

                    // Speedometer / Dial Arc
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2 + 3, 9, Math.PI, 2 * Math.PI, false);
                    ctx.stroke();

                    // Dial Ticks
                    ctx.beginPath();
                    ctx.moveTo(width / 2, height / 2 - 6);
                    ctx.lineTo(width / 2, height / 2 - 4);
                    ctx.stroke();

                    // Bulb Outline in Center
                    ctx.beginPath();
                    ctx.arc(width / 2, height / 2 + 1, 3, 0, 2 * Math.PI, false);
                    ctx.stroke();

                    ctx.fillRect(width / 2 - 1.5, height / 2 + 4, 3, 2);
                }
            }

            // Brightness Digit / "Max" (Matches Photos 2 & 3)
            Text {
                id: brightnessText
                anchors.horizontalCenter: parent.horizontalCenter
                text: settingsRoot.lightBrightness === 20 ? "Max" : settingsRoot.lightBrightness.toString()
                font.pixelSize: settingsRoot.lightBrightness === 20 ? 24 : 26
                font.family: settingsRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
            }
        }

        // Left Stepper Indicator: — (Minus)
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: arcCanvas.verticalCenter
            anchors.verticalCenterOffset: 12
            text: "—"
            font.pixelSize: 24
            font.family: settingsRoot.fontHeadBold
            font.bold: true
            color: settingsRoot.lightBrightness > 1 ? "#CCD8E8" : "#406080"
        }

        // Right Stepper Indicator: + (Plus)
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: arcCanvas.verticalCenter
            anchors.verticalCenterOffset: 12
            text: "+"
            font.pixelSize: 26
            font.family: settingsRoot.fontHeadBold
            font.bold: true
            color: settingsRoot.lightBrightness < 20 ? "#CCD8E8" : "#406080"
        }
    }

    // =================================================================
    // 4. ADJUST INTERVAL VIEW (Matches Photo 3 1:1)
    // =================================================================
    Item {
        id: adjustIntervalView
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: settingsRoot.currentMenu === "adjust_interval"

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -4
            spacing: 16

            // Distance row: [1] 0 0 0 0 km
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Item {
                    width: 26
                    height: 34
                    anchors.verticalCenter: parent.verticalCenter

                    // Top Chevron
                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: -8
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "▲"
                        font.pixelSize: 8
                        color: settingsRoot.adjustField === 0 ? settingsRoot.neonEdgeColor : "transparent"
                    }

                    // Cyan Selector Box
                    Rectangle {
                        anchors.fill: parent
                        radius: 3
                        color: settingsRoot.adjustField === 0 ? settingsRoot.boxGradMid : "transparent"
                        border.color: settingsRoot.adjustField === 0 ? settingsRoot.neonEdgeColor : "transparent"
                        border.width: 1.5

                        Text {
                            anchors.centerIn: parent
                            text: Math.floor(settingsRoot.serviceIntervalKm / 10000).toString()
                            font.pixelSize: 22
                            font.family: settingsRoot.fontHeadBold
                            font.bold: true
                            color: "#FFFFFF"
                        }
                    }

                    // Bottom Chevron
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -8
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "▼"
                        font.pixelSize: 8
                        color: settingsRoot.adjustField === 0 ? settingsRoot.neonEdgeColor : "transparent"
                    }
                }

                // Remaining digits + km
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (settingsRoot.serviceIntervalKm % 10000).toString().padStart(4, '0') + " km"
                    font.pixelSize: 22
                    font.family: settingsRoot.fontHeadMedium
                    font.bold: true
                    color: "#D0E0F0"
                }
            }

            // Duration row: [12] months
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Rectangle {
                    width: 44
                    height: 30
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: settingsRoot.adjustField === 1 ? settingsRoot.boxGradMid : "transparent"
                    border.color: settingsRoot.adjustField === 1 ? settingsRoot.neonEdgeColor : "transparent"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: settingsRoot.serviceIntervalMonths.toString()
                        font.pixelSize: 20
                        font.family: settingsRoot.fontHeadBold
                        font.bold: true
                        color: "#FFFFFF"
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: settingsRoot.tr("months")
                    font.pixelSize: 18
                    font.family: settingsRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#D0E0F0"
                }
            }
        }
    }

    // =================================================================
    // =================================================================
    // 5. RESET CONFIRMATION DIALOG (Factory Default & Service Interval)
    // =================================================================
    Item {
        id: resetConfirmDialog
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: (settingsRoot.currentMenu === "reset" || settingsRoot.currentMenu === "reset_interval") && !settingsRoot.showResetResult

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -4
            spacing: 14

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: settingsRoot.currentMenu === "reset" ?
                          (settingsRoot.isHindi ? "फ़ैक्टरी सेटिंग्स" : "Reset to") :
                          (settingsRoot.isHindi ? "समय और दूरी" : "Reset time")
                    font.pixelSize: 18
                    font.family: settingsRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: settingsRoot.currentMenu === "reset" ?
                          (settingsRoot.isHindi ? "रीसेट करें?" : "factory default?") :
                          (settingsRoot.isHindi ? "रीसेट करें?" : "and distance?")
                    font.pixelSize: 18
                    font.family: settingsRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6

                // Yes Button
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 90
                    height: 28
                    radius: 4
                    color: settingsRoot.resetChoice === 0 ? settingsRoot.boxGradMid : "transparent"
                    border.color: settingsRoot.resetChoice === 0 ? settingsRoot.neonEdgeColor : "transparent"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: settingsRoot.tr("Yes")
                        font.pixelSize: 15
                        font.family: settingsRoot.fontHeadMedium
                        font.weight: settingsRoot.resetChoice === 0 ? Font.Bold : Font.DemiBold
                        color: settingsRoot.resetChoice === 0 ? "#FFFFFF" : "#A0B8D0"
                    }
                }

                // No Button
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 90
                    height: 28
                    radius: 4
                    color: settingsRoot.resetChoice === 1 ? settingsRoot.boxGradMid : "transparent"
                    border.color: settingsRoot.resetChoice === 1 ? settingsRoot.neonEdgeColor : "transparent"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: settingsRoot.tr("No")
                        font.pixelSize: 15
                        font.family: settingsRoot.fontHeadMedium
                        font.weight: settingsRoot.resetChoice === 1 ? Font.Bold : Font.DemiBold
                        color: settingsRoot.resetChoice === 1 ? "#FFFFFF" : "#A0B8D0"
                    }
                }
            }
        }
    }

    // =================================================================
    // 6. POPUP RESULT VIEW ("Settings have been reset" / "Settings have not been reset")
    // =================================================================
    Item {
        id: resetResultPopup
        anchors.fill: parent
        visible: settingsRoot.showResetResult

        Column {
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: settingsRoot.resetPopupText.split("\n")
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData
                    font.pixelSize: 18
                    font.family: settingsRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }
            }
        }
    }
}
