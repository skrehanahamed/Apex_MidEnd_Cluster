/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           CenterTripDisplay.qml
 * Author:         SK Rehan Ahamed
 * Description:    Central 4.2-inch TFT Multi-Function Display (MFD) Controller
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick
import QtQuick.Effects

Item {
    id: centerRoot
    property string gearValue: controller ? controller.gear : "N"
    property int dteKm: controller ? controller.dteKm : 52
    readonly property string dteDisplay: (controller && (controller.fuelLevel === 0 || controller.dteKm <= 0)) ? "---" : (centerRoot.dteKm.toString())
    property double tripKm: controller ? controller.tripKm : 0.0
    property string tripTime: controller ? controller.tripTime : "0:00"
    property double tripEconomy: controller ? controller.tripEconomy : 0.0
    property int tripPage: controller ? controller.tripPage : 1
    readonly property bool isHindi: controller && (controller.language === "हिन्दी" || controller.language === "Hindi")
    readonly property string tripTitle: isHindi ?
                                        (tripPage === 1 ? "ईंधन भरने के बाद" : (tripPage === 2 ? "कुल संचित जानकारी" : "ड्राइव जानकारी")) :
                                        (tripPage === 1 ? "Since refuelling" : (tripPage === 2 ? "Accumulated info" : "Drive info"))
    readonly property double activeTripKm: tripPage === 1 ? (controller ? controller.refuelKm : 154.9) : (tripPage === 2 ? (controller ? controller.accumKm : 3454.0) : (controller ? controller.tripKm : 0.0))
    readonly property string activeTripTime: tripPage === 1 ? (controller ? controller.refuelTime : "10:21") : (tripPage === 2 ? (controller ? controller.accumTime : "84:12") : (controller ? controller.tripTime : "0:00"))
    readonly property double activeTripEconomy: tripPage === 1 ? (controller ? controller.refuelEconomy : 12.5) : (tripPage === 2 ? (controller ? controller.accumEconomy : 14.2) : (controller ? controller.tripEconomy : 0.0))
    property int ambientTemp: controller ? controller.ambientTemp : 25
    property int odoKm: controller ? controller.odoKm : 3454
    property bool showResetPrompt: false

    // 4-Second Initial Startup Seatbelt Display Timer
    property bool initialSeatbeltDone: false
    Timer {
        id: startupSeatbeltTimer
        interval: 4000
        running: controller && controller.clusterState === 3 && !centerRoot.initialSeatbeltDone
        repeat: false
        onTriggered: {
            centerRoot.initialSeatbeltDone = true;
        }
    }

    Connections {
        target: controller
        function onClusterStateChanged() {
            if (controller && controller.clusterState !== 3) {
                centerRoot.initialSeatbeltDone = false;
            }
        }
    }

    // 5-Second Timer to Show "Hold [OK] : Reset" when pressing Up/Down, then return to ECO
    Timer {
        id: resetPromptTimer
        interval: 5000
        repeat: false
        onTriggered: centerRoot.showResetPrompt = false
    }

    function triggerResetPrompt() {
        centerRoot.showResetPrompt = true;
        resetPromptTimer.restart();
    }

    onTripPageChanged: {
        triggerResetPrompt();
    }

    // Dynamic Line Theme Colors: "blue", "green", "red" (or Amber/Yellow for warnings, White for Press Start alert)
    property string themeColor: controller ? controller.themeColor : "blue"
    readonly property bool isReduceSpeedActive: controller && controller.reduceSpeedAlert
    readonly property bool isTpmsActive: controller && controller.tpmsActive
    readonly property bool isIgnitionOff: controller && (controller.clusterState === 4 || controller.clusterState === 5)

    // Warning Priority Hierarchy (Strictly ONE warning shown at a time):
    // 0 = None, 1 = Reduce Speed, 2 = Smart Key, 3 = Press START/Clutch Again, 4 = Door Open, 5 = Sunroof Open, 6 = Service Reminder, 7 = Low Fuel Alert
    readonly property int activeWarningId: {
        if (isIgnitionOff) {
            return (controller && controller.doorOpenAlert) ? 4 : 0;
        }
        if (!controller || controller.showLightPopup) return 0;
        if (controller.reduceSpeedAlert) return 1;
        if (controller.smartKeyPrompt > 0) return 2;
        if ((controller.startPedalPrompt > 0) || controller.pressStartAgainAlert) return 3;
        if (controller.doorOpenAlert) return 4;
        if (controller.sunroofAlertActive) return 5;
        if (controller.servicePopupActive) return 6;
        if (controller.fuelLevel <= 2 && controller.clusterState === 3) return 7;
        return 0;
    }
    readonly property bool isWarningActive: activeWarningId > 0
    readonly property bool isLineWhite: activeWarningId === 3 || activeWarningId === 4 || isIgnitionOff
    readonly property bool isLineAmber: (isReduceSpeedActive || isTpmsActive || isWarningActive) && !isLineWhite

    readonly property color themeCoreColor: isLineAmber ? "#FFE5B4" : (isLineWhite ? "#FFFFFF" : (themeColor === "green" ? "#D0FFE0" : (themeColor === "red" ? "#FFD0D0" : "#D0E0FF")))
    readonly property color themePrimaryColor: isLineAmber ? "#FF9800" : (isLineWhite ? "#E0F7FA" : (themeColor === "green" ? "#00E676" : (themeColor === "red" ? "#FF5252" : "#00E5FF")))
    readonly property color themeGlowGradient: isLineAmber ? "#50FF9800" : (isLineWhite ? "#50E0F7FA" : (themeColor === "green" ? "#5000C853" : (themeColor === "red" ? "#50FF1744" : "#5000C8FF")))
    readonly property color themeUnderGlow: isLineAmber ? "#35FF9800" : (isLineWhite ? "#30E0F7FA" : (themeColor === "green" ? "#2500E676" : (themeColor === "red" ? "#25FF5252" : "#2500E5FF")))

    // TPMS Silent Line Blinking (No Chime)
    property real tpmsBlinkOpacity: 1.0
    SequentialAnimation {
        running: centerRoot.isTpmsActive
        loops: Animation.Infinite
        NumberAnimation { target: centerRoot; property: "tpmsBlinkOpacity"; from: 1.0; to: 0.18; duration: 480; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerRoot; property: "tpmsBlinkOpacity"; from: 0.18; to: 1.0; duration: 480; easing.type: Easing.InOutQuad }
    }

    implicitWidth: 198
    implicitHeight: 366

    // =================================================================
    // 🔤 CLUSTER SANS HEAD & DEVANAGARI FONT LOADERS
    // =================================================================
    FontLoader { id: clusterRegular; source: "qrc:/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Regular.ttf" }
    FontLoader { id: clusterMedium; source: "qrc:/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Medium.ttf" }
    FontLoader { id: clusterBold; source: "qrc:/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Bold.ttf" }
    FontLoader { id: notoDevanagari; source: "qrc:/qt/qml/ApexCluster/resources/fonts/NotoSansDevanagari-Regular.ttf" }

    readonly property string fontHeadRegular: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (clusterRegular.status === FontLoader.Ready ? clusterRegular.name : "Cluster Sans Head")
    readonly property string fontHeadMedium: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (clusterMedium.status === FontLoader.Ready ? clusterMedium.name : "Cluster Sans Head")
    readonly property string fontHeadBold: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (clusterBold.status === FontLoader.Ready ? clusterBold.name : "Cluster Sans Head")

    // =================================================================
    // 🎛️ DUAL ACCENT LINE FAST ENTRANCE ANIMATION (Snappy 350ms)
    // =================================================================
    property real lineAnimProgress: 0.0

    NumberAnimation {
        id: lineEntranceAnim
        target: centerRoot
        property: "lineAnimProgress"
        from: 0.0
        to: 1.0
        duration: 350
        easing.type: Easing.OutQuad
        running: centerRoot.visible
    }

    // =================================================================
    // 1. TOP HEADER: FUEL PUMP ICON + RANGE (DTE) + ANIMATED BLUE DIVIDER
    property int menuTab: controller ? controller.menuTab : 0
    property bool showMenuTabs: controller ? controller.showMenuTabs : false

    // 5-Second Auto-Hide Timer for Info Menu Tabs
    Timer {
        id: infoMenuTimer
        interval: 5000
        repeat: false
        onTriggered: {
            if (controller) controller.setShowMenuTabs(false);
            centerRoot.showMenuTabs = false;
        }
    }

    Connections {
        target: controller
        function onShowMenuTabsChanged() {
            if (controller && controller.showMenuTabs) {
                centerRoot.showMenuTabs = true;
                infoMenuTimer.restart();
            } else {
                centerRoot.showMenuTabs = false;
            }
        }
        function onMenuTabChanged() {
            if (controller && controller.showMenuTabs) {
                centerRoot.showMenuTabs = true;
                infoMenuTimer.restart();
            }
        }
    }

    // =================================================================
    // 1. TOP HEADER SECTION: GEAR + MODE TABS / DTE
    // =================================================================
    // =================================================================
    // 1. TOP HEADER SECTION: GEAR + MODE TABS / DTE + CRUISE
    // =================================================================
    Item {
        id: topDteSection
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: (controller && controller.cruiseEnabled) ? 56 : 48
        visible: true

        // =============================================================
        // A. CRUISE CONTROL MODE ACTIVE:
        // Top Micro-Row: Gear on Left, Compact Small Fuel Icon + DTE on Top Right
        // Main Row: Cruise Icon + "CRUISE" on Left, Cruise Set Speed on Right
        // =============================================================
        // =============================================================
        // A. CRUISE CONTROL MODE ACTIVE (Matches OEM Photo 1:1):
        // Left: Transmission Gear (e.g. D5, D, P, R, N)
        // Right Stacked:
        //   Row 1 (Top): ⛽ Fuel Icon + DTE (e.g. 261 km)
        //   Row 2 (Bottom): [Cruise Icon] CRUISE [Set Speed] km/h (e.g. 🟢 CRUISE 110 km/h)
        // =============================================================
        Item {
            id: cruiseModeHeader
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.bottom: parent.bottom
            visible: !centerRoot.isIgnitionOff && controller && controller.cruiseEnabled

            // Left: Transmission Gear (Single letter or D1..D5 / S1..S5)
            Item {
                id: cruiseGearBlock
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 34
                height: 32

                // Single letter: P, R, N, D
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    visible: !centerRoot.gearValue.startsWith("M") && !centerRoot.gearValue.startsWith("S") && !(centerRoot.gearValue.startsWith("D") && centerRoot.gearValue.length > 1)
                    text: centerRoot.gearValue
                    font.pixelSize: 24
                    font.family: centerRoot.fontHeadBold
                    font.weight: Font.Bold
                    color: centerRoot.gearValue === "N" ? "#00E676" : "#FFFFFF"
                }

                // D1..D5, S1..S5, M1..M5
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    visible: centerRoot.gearValue.startsWith("M") || centerRoot.gearValue.startsWith("S") || (centerRoot.gearValue.startsWith("D") && centerRoot.gearValue.length > 1)
                    spacing: 1

                    Text {
                        id: cruiseMainLetter
                        text: centerRoot.gearValue.charAt(0)
                        font.pixelSize: 24
                        font.family: centerRoot.fontHeadBold
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    Text {
                        text: centerRoot.gearValue.substring(1)
                        font.pixelSize: 14
                        font.family: centerRoot.fontHeadBold
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        anchors.bottom: cruiseMainLetter.bottom
                        anchors.bottomMargin: 2
                    }
                }
            }

            // Right Stacked Container (DTE on Top, Cruise on Bottom)
            Column {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                // Row 1 (Top): Fuel Icon + DTE (e.g. ⛽ 261 km)
                Row {
                    anchors.right: parent.right
                    spacing: 4

                    Image {
                        width: 22
                        height: 22
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/qt/qml/ApexCluster/resources/icons/fuel_pump.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: centerRoot.dteDisplay
                        font.pixelSize: 15
                        font.family: centerRoot.fontHeadMedium
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 1
                        text: "km"
                        font.pixelSize: 10
                        font.family: centerRoot.fontHeadRegular
                        color: "#CCD8E8"
                    }
                }

                // Row 2 (Bottom): [Icon] CRUISE [Set Speed] km/h
                Row {
                    anchors.right: parent.right
                    spacing: 3

                    Image {
                        width: 15
                        height: 15
                        anchors.verticalCenter: parent.verticalCenter
                        source: (controller && controller.cruiseActive) ?
                                "qrc:/qt/qml/ApexCluster/resources/icons/cruise_green.png" :
                                "qrc:/qt/qml/ApexCluster/resources/icons/cruise_white.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: centerRoot.isHindi ? "क्रूज़" : "CRUISE"
                        font.pixelSize: 12
                        font.family: centerRoot.fontHeadBold
                        font.weight: Font.Bold
                        color: (controller && controller.cruiseActive) ? "#00E676" : "#CCD8E8"
                        font.letterSpacing: 0.3
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: (controller && controller.cruiseActive) ? controller.cruiseSetSpeed.toString() : "---"
                        font.pixelSize: 15
                        font.family: centerRoot.fontHeadMedium
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 1
                        text: "km/h"
                        font.pixelSize: 10
                        font.family: centerRoot.fontHeadRegular
                        color: "#CCD8E8"
                    }
                }
            }
        }

        // =============================================================
        // B. NORMAL MODE HEADER (Cruise Disabled)
        // Left Gear Indicator, Center Tabs, Right Normal DTE
        // =============================================================
        Item {
            id: normalModeHeader
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            height: 32
            visible: !centerRoot.isIgnitionOff && (!controller || !controller.cruiseEnabled)

            // 1. TRANSMISSION GEAR INDICATOR
            Item {
                id: gearIndicator
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 30

                // Single letter Gears: P, R, N, D
                Text {
                    id: gearText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    visible: !centerRoot.gearValue.startsWith("M") && !(centerRoot.gearValue.startsWith("D") && centerRoot.gearValue.length > 1)
                    text: centerRoot.gearValue
                    font.pixelSize: 22
                    font.family: centerRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: centerRoot.gearValue === "N" ? "#00E676" : "#FFFFFF"
                }

                // D1 to D5 / M1 to M5: Large Letter (22px) + Subscript Down Digit (12px)
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    visible: centerRoot.gearValue.startsWith("M") || (centerRoot.gearValue.startsWith("D") && centerRoot.gearValue.length > 1)
                    spacing: 1

                    // Main Letter ('D' or 'M')
                    Text {
                        id: mainLetterText
                        text: centerRoot.gearValue.charAt(0)
                        font.pixelSize: 22
                        font.family: centerRoot.fontHeadMedium
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }

                    // Subscript small down digit (1..5)
                    Text {
                        text: centerRoot.gearValue.substring(1)
                        font.pixelSize: 12
                        font.family: centerRoot.fontHeadMedium
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                        anchors.bottom: mainLetterText.bottom
                        anchors.bottomMargin: 1
                    }
                }
            }

            // 2. CENTER 3-MODE CATEGORY TABS (Shown when Info button is pressed for 5 seconds)
            Row {
                id: menuTabsRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                visible: centerRoot.showMenuTabs
                z: 20

                // Tab 0: Trip Computer (Car Icon)
                Item {
                    width: 22
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.centerIn: parent
                        width: 22
                        height: 14.5
                        source: "qrc:/qt/qml/ApexCluster/resources/icons/menu_tab_car.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        opacity: centerRoot.menuTab === 0 ? 1.0 : 0.35
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }
                }

                // Tab 1: User Settings (Gear Cog Icon)
                Item {
                    width: 22
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.centerIn: parent
                        width: 15
                        height: 15
                        source: "qrc:/qt/qml/ApexCluster/resources/icons/menu_tab_settings.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        opacity: centerRoot.menuTab === 1 ? 1.0 : 0.35
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }
                }

                // Tab 2: TPMS & Info (Circle-i Icon)
                Item {
                    width: 22
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.centerIn: parent
                        width: 15
                        height: 15
                        source: "qrc:/qt/qml/ApexCluster/resources/icons/menu_tab_info.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        opacity: centerRoot.menuTab === 2 ? 1.0 : 0.35
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }
                }
            }

            // 3. FUEL PUMP & DTE RANGE or HOLD [OK] : HELP (Visible when tabs & cruise are hidden)
            Item {
                id: topActionOrDteContainer
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 28
                visible: !centerRoot.showMenuTabs
                z: 10

                // State A: Inside Submenus with Help Available -> Hold [OK] : Help (Matches OEM Photos)
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    visible: centerRoot.menuTab === 1 && userSettingsView && userSettingsView.showHelpHint

                    Text {
                        text: centerRoot.isHindi ? "दबाए रखें" : "Hold"
                        font.pixelSize: 13
                        font.family: centerRoot.fontHeadRegular
                        color: "#CCD8E8"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 20
                        height: 15
                        radius: 3
                        color: "transparent"
                        border.color: "#CCD8E8"
                        border.width: 1.0
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "OK"
                            font.pixelSize: 9
                            font.family: centerRoot.fontHeadMedium
                            font.bold: true
                            color: "#CCD8E8"
                        }
                    }

                    Text {
                        text: centerRoot.isHindi ? " : सहायता" : ": Help"
                        font.pixelSize: 13
                        font.family: centerRoot.fontHeadRegular
                        color: "#CCD8E8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // State B: Main User Settings List, Cluster Theme, or Normal Mode -> Fuel Pump Icon + DTE Range
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6
                    visible: !(centerRoot.menuTab === 1 && userSettingsView && userSettingsView.showHelpHint)

                    Image {
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/qt/qml/ApexCluster/resources/icons/fuel_pump.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        id: dteValueText
                        anchors.verticalCenter: parent.verticalCenter
                        text: centerRoot.dteDisplay
                        font.pixelSize: 22
                        font.family: centerRoot.fontHeadMedium
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 1
                        text: "km"
                        font.pixelSize: 14
                        font.family: centerRoot.fontHeadRegular
                        color: "#FFFFFF"
                    }
                }
            }
        }

        // Top Animated Luminous Glowing Curved Divider Line with Rising Spotlight Flare Under Active Tab
        Item {
            id: topDividerContainer
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.92
            height: 14
            opacity: centerRoot.isTpmsActive ? (centerRoot.lineAnimProgress * centerRoot.tpmsBlinkOpacity) : centerRoot.lineAnimProgress

            // Canvas Spotlight Flare Rising Directly from the Line (Matches Image 2 1:1)
            Canvas {
                id: spotlightFlareCanvas
                anchors.fill: parent
                visible: centerRoot.showMenuTabs
                z: 15

                // Smooth animated X position of the active tab
                property real flareCenterX: parent.width * 0.5 + (centerRoot.menuTab === 0 ? -28.0 : (centerRoot.menuTab === 1 ? 0.0 : 28.0))
                Behavior on flareCenterX { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }

                onFlareCenterXChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var cx = flareCenterX;
                    var cy = height - 1.0; // on the horizontal line
                    var flareW = 9.0;
                    var flareH = 4.5;

                    // 1. Soft Cyan-Blue Light Dome Bloom Rising Up from Line
                    ctx.beginPath();
                    ctx.moveTo(cx - flareW, cy);
                    ctx.bezierCurveTo(cx - flareW * 0.5, cy, cx - flareW * 0.3, cy - flareH, cx, cy - flareH);
                    ctx.bezierCurveTo(cx + flareW * 0.3, cy - flareH, cx + flareW * 0.5, cy, cx + flareW, cy);
                    ctx.closePath();

                    var bloomGrad = ctx.createRadialGradient(cx, cy - 0.5, 0.5, cx, cy - 2.5, flareW);
                    bloomGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.85)");
                    if (centerRoot.themeColor === "green") {
                        bloomGrad.addColorStop(0.35, "rgba(0, 230, 118, 0.55)");
                        bloomGrad.addColorStop(0.7, "rgba(0, 160, 60, 0.20)");
                        bloomGrad.addColorStop(1.0, "rgba(0, 100, 40, 0.0)");
                    } else if (centerRoot.themeColor === "red") {
                        bloomGrad.addColorStop(0.35, "rgba(255, 82, 82, 0.55)");
                        bloomGrad.addColorStop(0.7, "rgba(200, 30, 40, 0.20)");
                        bloomGrad.addColorStop(1.0, "rgba(120, 15, 20, 0.0)");
                    } else {
                        bloomGrad.addColorStop(0.35, "rgba(0, 210, 255, 0.55)");
                        bloomGrad.addColorStop(0.7, "rgba(0, 100, 220, 0.20)");
                        bloomGrad.addColorStop(1.0, "rgba(0, 60, 180, 0.0)");
                    }
                    ctx.fillStyle = bloomGrad;
                    ctx.fill();

                    // 2. Bright Laser Crest Line
                    ctx.beginPath();
                    ctx.moveTo(cx - flareW * 0.75, cy);
                    ctx.bezierCurveTo(cx - flareW * 0.35, cy, cx - flareW * 0.2, cy - flareH * 0.85, cx, cy - flareH * 0.85);
                    ctx.bezierCurveTo(cx + flareW * 0.2, cy - flareH * 0.85, cx + flareW * 0.35, cy, cx + flareW * 0.75, cy);
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.85)";
                    ctx.lineWidth = 1.0;
                    ctx.stroke();
                }

                Connections {
                    target: centerRoot
                    function onShowMenuTabsChanged() { spotlightFlareCanvas.requestPaint(); }
                    function onMenuTabChanged() { spotlightFlareCanvas.requestPaint(); }
                    function onThemeColorChanged() { spotlightFlareCanvas.requestPaint(); }
                }
            }

            // Soft White Dim Ambient Under-Glow
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * centerRoot.lineAnimProgress * 0.96
                height: 5
                opacity: centerRoot.lineAnimProgress * 0.35
                color: "transparent"
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#40FFFFFF" }
                    GradientStop { position: 0.4; color: centerRoot.themeUnderGlow }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Crisp Core Line
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * centerRoot.lineAnimProgress
                height: 1.5
                radius: 0.75
                opacity: centerRoot.lineAnimProgress
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: centerRoot.themeGlowGradient }
                    GradientStop { position: 0.5; color: centerRoot.themeCoreColor }
                    GradientStop { position: 0.8; color: centerRoot.themeGlowGradient }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    function navSettingsUp() { if (userSettingsView) userSettingsView.navUp(); }
    function navSettingsDown() { if (userSettingsView) userSettingsView.navDown(); }
    function selectSettings() { if (userSettingsView) userSettingsView.selectCurrent(); }
    function backSettings() { if (userSettingsView) userSettingsView.goBack(); }

    // =================================================================
    // 2. MIDDLE CARD: USER SETTINGS VIEW (When menuTab === 1)
    // =================================================================
    // =================================================================
    // 🎵 MEDIA POPUP BANNER (Full-width, slides out from inside upper line)
    // =================================================================
    Item {
        id: mediaClippingViewport
        anchors.top: topDteSection.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 64
        clip: true
        z: 45

        Item {
            id: mediaPopupBanner
            anchors.left: parent.left
            anchors.right: parent.right
            height: 58

            readonly property bool isMediaActive: controller && controller.showMediaPopup && !centerRoot.isIgnitionOff
            property real currentY: -height
            y: currentY
            opacity: isMediaActive ? 1.0 : 0.0
            visible: opacity > 0.01 || slideExitAnim.running

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            SequentialAnimation {
                id: slideEntranceAnim
                NumberAnimation {
                    target: mediaPopupBanner
                    property: "currentY"
                    from: -mediaPopupBanner.height
                    to: 0
                    duration: 420
                    easing.type: Easing.OutCubic
                }
            }

            SequentialAnimation {
                id: slideExitAnim
                NumberAnimation {
                    target: mediaPopupBanner
                    property: "currentY"
                    to: -mediaPopupBanner.height
                    duration: 350
                    easing.type: Easing.InOutCubic
                }
            }

            function triggerEntrance() {
                slideExitAnim.stop();
                slideEntranceAnim.stop();
                mediaPopupBanner.currentY = -mediaPopupBanner.height;
                slideEntranceAnim.restart();
            }

            function triggerExit() {
                slideEntranceAnim.stop();
                slideExitAnim.restart();
            }

            Connections {
                target: controller
                function onShowMediaPopupChanged() {
                    if (controller && controller.showMediaPopup) {
                        mediaPopupBanner.triggerEntrance();
                    } else {
                        mediaPopupBanner.triggerExit();
                    }
                }
                function onMediaTitleChanged() {
                    if (controller && controller.showMediaPopup) {
                        mediaPopupBanner.triggerEntrance();
                    }
                }
                function onMediaArtistChanged() {
                    if (controller && controller.showMediaPopup) {
                        mediaPopupBanner.triggerEntrance();
                    }
                }
            }

            // Full-Width Sleek Banner Background
            Rectangle {
                anchors.fill: parent
                color: "#121A26"

                // Rich dark metallic glass gradient
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#1E2C3E" }
                    GradientStop { position: 0.6; color: "#141E2C" }
                    GradientStop { position: 1.0; color: "#0B111A" }
                }

                // Bottom Border Accent Line
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1.5
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.2; color: "#3A5270" }
                        GradientStop { position: 0.5; color: "#00E5FF" }
                        GradientStop { position: 0.8; color: "#3A5270" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 2

                    // Row 1 (Top): Media Source Info & Equalizer Indicator
                    Item {
                        width: parent.width
                        height: 22

                        // Left: Source Icon & Name
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Image {
                                width: 18
                                height: 18
                                anchors.verticalCenter: parent.verticalCenter
                                source: {
                                    var src = controller ? controller.mediaSource : "USB";
                                    if (src === "USB") return "qrc:/qt/qml/ApexCluster/resources/icons/media_usb.png";
                                    if (src === "Bluetooth") return "qrc:/qt/qml/ApexCluster/resources/icons/media_bluetooth.png";
                                    if (src === "Apple CarPlay") return "qrc:/qt/qml/ApexCluster/resources/icons/media_carplay.png";
                                    if (src === "Android Auto") return "qrc:/qt/qml/ApexCluster/resources/icons/media_android_auto.png";
                                    return "qrc:/qt/qml/ApexCluster/resources/icons/media_note.png";
                                }
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: controller ? controller.mediaSource : "Apple CarPlay"
                                font.pixelSize: 13
                                font.family: centerRoot.fontHeadMedium
                                font.weight: Font.DemiBold
                                color: (controller && controller.mediaSource === "Apple CarPlay") ? "#30D158" : "#FFFFFF"
                            }
                        }

                        // Right: Live Animated Equalizer Bars
                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Repeater {
                                model: 4
                                Rectangle {
                                    id: eqBar
                                    width: 2.5
                                    height: 4 + (index === 0 ? 8 : (index === 1 ? 12 : (index === 2 ? 6 : 10)))
                                    radius: 1
                                    color: (controller && controller.mediaSource === "Apple CarPlay") ? "#30D158" : "#00E5FF"
                                    anchors.bottom: parent.bottom

                                    SequentialAnimation on height {
                                        running: mediaPopupBanner.isMediaActive
                                        loops: Animation.Infinite
                                        NumberAnimation {
                                            to: (index % 2 === 0) ? 14 : 6
                                            duration: 380 + index * 90
                                            easing.type: Easing.InOutSine
                                        }
                                        NumberAnimation {
                                            to: (index % 2 === 0) ? 5 : 13
                                            duration: 420 + index * 70
                                            easing.type: Easing.InOutSine
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Thin Divider Line
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 24
                        height: 1
                        color: "#1E2B3C"
                    }

                    // Row 2 (Bottom): Marquee Track Text Container
                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 24
                        height: 24

                        // Clipped Container for Song & Artist Marquee Text
                        Item {
                            id: trackTextContainer
                            anchors.fill: parent
                            clip: true

                            property string fullTrackText: {
                                if (!controller) return "Revoic - Sunset Drive";
                                return (controller.mediaArtist ? (controller.mediaArtist + " - ") : "") + controller.mediaTitle;
                            }

                            onFullTrackTextChanged: resetMarquee()

                            function resetMarquee() {
                                marqueeAnim.stop();
                                trackTitleText.x = 0;
                                if (trackTitleText.needsScroll && mediaPopupBanner.isMediaActive) {
                                    marqueeAnim.restart();
                                }
                            }

                            Connections {
                                target: controller
                                function onShowMediaPopupChanged() {
                                    if (controller && controller.showMediaPopup) {
                                        trackTextContainer.resetMarquee();
                                    }
                                }
                                function onMediaTitleChanged() {
                                    trackTextContainer.resetMarquee();
                                }
                            }

                            Text {
                                id: trackTitleText
                                anchors.verticalCenter: parent.verticalCenter
                                text: trackTextContainer.fullTrackText
                                font.pixelSize: 13
                                font.family: centerRoot.fontHeadRegular
                                color: "#E0E8F0"

                                readonly property real overflow: Math.max(0, implicitWidth - trackTextContainer.width)
                                readonly property bool needsScroll: overflow > 4

                                x: 0

                                SequentialAnimation {
                                    id: marqueeAnim
                                    running: trackTitleText.needsScroll && mediaPopupBanner.isMediaActive
                                    loops: Animation.Infinite

                                    PauseAnimation { duration: 1400 }
                                    NumberAnimation {
                                        target: trackTitleText
                                        property: "x"
                                        to: -trackTitleText.overflow - 6
                                        duration: Math.max(2000, trackTitleText.overflow * 32)
                                        easing.type: Easing.InOutQuad
                                    }
                                    PauseAnimation { duration: 1400 }
                                    NumberAnimation {
                                        target: trackTitleText
                                        property: "x"
                                        to: 0
                                        duration: Math.max(2000, trackTitleText.overflow * 32)
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // =================================================================
    // 2. LIGHTS SELECTOR POPUP CARD (Smooth Animated Stalk Carousel)
    // =================================================================
    Item {
        id: lightsPopupCard
        anchors.top: topDteSection.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 204
        opacity: (controller && controller.showLightPopup) ? 1.0 : 0.0
        scale: (controller && controller.showLightPopup) ? 1.0 : 0.95
        visible: opacity > 0.01
        z: 35

        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }

        Timer {
            id: lightPopupTimer
            interval: 3000
            repeat: false
            onTriggered: {
                if (controller) controller.setShowLightPopup(false);
            }
        }

        Connections {
            target: controller
            function onShowLightPopupChanged() {
                if (controller && controller.showLightPopup) {
                    lightPopupTimer.restart();
                }
            }
            function onLightModeChanged() {
                if (controller) {
                    controller.setShowLightPopup(true);
                    lightPopupTimer.restart();
                }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 12
            width: parent.width

            // Title: "Lights"
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: centerRoot.isHindi ? "लाइट्स" : "Lights"
                font.pixelSize: 18
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
            }

            // Stalk Selector Box with Left/Right Vertical Brackets & Sliding Cyan Selector
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 130
                height: 124

                // Left vertical bracket line
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1.2
                    color: "#506880"
                }

                // Right vertical bracket line
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1.2
                    color: "#506880"
                }

                // Smooth Gliding Active Cyan Selector Bracket (Top & Bottom Glowing Bars)
                Item {
                    id: slidingSelectorBracket
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    height: 28
                    z: 5

                    // Target Y calculated based on active mode (3 = Low beam, 2 = Position, 1 = Auto, 0 = Off)
                    y: {
                        var mode = controller ? controller.lightMode : 0;
                        if (mode === 3) return 0;   // Low beam
                        if (mode === 2) return 30;  // Position lamp
                        if (mode === 1) return 60;  // Auto
                        return 90;                  // Off
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Top Cyan Glowing Line
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1.8
                        color: "#00E5FF"
                        radius: 0.9

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 6
                            color: "#3300E5FF"
                            z: -1
                        }
                    }

                    // Bottom Cyan Glowing Line
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1.8
                        color: "#00E5FF"
                        radius: 0.9

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 6
                            color: "#3300E5FF"
                            z: -1
                        }
                    }
                }

                // 4 Vertical Mode Slots: 3 = Headlight (Low beam), 2 = Position Lamp, 1 = AUTO, 0 = OFF
                Column {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    spacing: 2

                    // Slot 3: Headlight / Low Beam
                    Item {
                        width: parent.width
                        height: 28

                        Image {
                            anchors.centerIn: parent
                            width: 22
                            height: 18
                            source: "qrc:/qt/qml/ApexCluster/resources/icons/low_beam.png"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            opacity: (controller && controller.lightMode === 3) ? 1.0 : 0.35
                            scale: (controller && controller.lightMode === 3) ? 1.08 : 0.95
                            Behavior on opacity { NumberAnimation { duration: 180 } }
                            Behavior on scale { NumberAnimation { duration: 180 } }
                        }
                    }

                    // Slot 2: Position Lamp
                    Item {
                        width: parent.width
                        height: 28

                        Image {
                            anchors.centerIn: parent
                            width: 24
                            height: 18
                            source: "qrc:/qt/qml/ApexCluster/resources/icons/position_lamp.png"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            opacity: (controller && controller.lightMode === 2) ? 1.0 : 0.35
                            scale: (controller && controller.lightMode === 2) ? 1.08 : 0.95
                            Behavior on opacity { NumberAnimation { duration: 180 } }
                            Behavior on scale { NumberAnimation { duration: 180 } }
                        }
                    }

                    // Slot 1: AUTO
                    Item {
                        width: parent.width
                        height: 28

                        Text {
                            anchors.centerIn: parent
                            text: centerRoot.isHindi ? "ऑटो" : "AUTO"
                            font.pixelSize: 14
                            font.family: centerRoot.fontHeadMedium
                            font.bold: true
                            color: (controller && controller.lightMode === 1) ? "#FFFFFF" : "#708898"
                            scale: (controller && controller.lightMode === 1) ? 1.05 : 0.95
                            Behavior on color { ColorAnimation { duration: 180 } }
                            Behavior on scale { NumberAnimation { duration: 180 } }
                        }
                    }

                    // Slot 0: OFF
                    Item {
                        width: parent.width
                        height: 28

                        Text {
                            anchors.centerIn: parent
                            text: centerRoot.isHindi ? "बंद" : "OFF"
                            font.pixelSize: 14
                            font.family: centerRoot.fontHeadMedium
                            font.bold: true
                            color: (controller && controller.lightMode === 0) ? "#FFFFFF" : "#708898"
                            scale: (controller && controller.lightMode === 0) ? 1.05 : 0.95
                            Behavior on color { ColorAnimation { duration: 180 } }
                            Behavior on scale { NumberAnimation { duration: 180 } }
                        }
                    }
                }
            }
        }
    }

    // =================================================================
    // REDUCE SPEED OVERSPEED WARNING CARD (Matches OEM Photo 1:1)
    // =================================================================
    Item {
        id: reduceSpeedWarningCard
        anchors.top: topDteSection.bottom
        anchors.topMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 204
        visible: centerRoot.activeWarningId === 1
        z: 40

        Column {
            anchors.centerIn: parent
            spacing: 20
            width: parent.width

            // Title: "Reduce speed" (or "गति कम करें" in Hindi)
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: centerRoot.isHindi ? "गति कम करें" : "Reduce speed"
                font.pixelSize: 18
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
                font.letterSpacing: 0.3
            }

            // Glowing Amber 3D Warning Triangle with Gloss Shine & Floor Reflection
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 80
                height: 80

                Canvas {
                    id: warningTriangleCanvas
                    anchors.fill: parent

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);

                        var cx = width * 0.5;
                        var topY = 6;
                        var botY = 56;
                        var halfBase = 32;

                        // 1. Soft Warm Radial Ambient Shine Behind Triangle
                        var bgGlow = ctx.createRadialGradient(cx, 32, 2, cx, 32, 38);
                        bgGlow.addColorStop(0.0, "rgba(255, 167, 38, 0.28)");
                        bgGlow.addColorStop(0.6, "rgba(255, 111, 0, 0.10)");
                        bgGlow.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                        ctx.fillStyle = bgGlow;
                        ctx.beginPath();
                        ctx.arc(cx, 32, 38, 0, Math.PI * 2);
                        ctx.fill();

                        // Helper function to draw triangle path
                        function drawTrianglePath(c, apexY, baseOffset) {
                            c.beginPath();
                            c.moveTo(cx, apexY);
                            c.lineTo(cx + halfBase - baseOffset, botY - baseOffset);
                            c.lineTo(cx - halfBase + baseOffset, botY - baseOffset);
                            c.closePath();
                        }

                        // 2. Main 3D Outer Bevel with Linear Metallic Amber Gradient
                        var amberGrad = ctx.createLinearGradient(cx - halfBase, topY, cx + halfBase, botY);
                        amberGrad.addColorStop(0.0, "#FFE082"); // Bright top-left golden specular
                        amberGrad.addColorStop(0.35, "#FFA726"); // Vibrant amber body
                        amberGrad.addColorStop(0.8, "#FF6F00"); // Rich deep warm orange
                        amberGrad.addColorStop(1.0, "#E65100"); // Bottom shadow rim

                        ctx.save();
                        drawTrianglePath(ctx, topY, 0);
                        ctx.strokeStyle = amberGrad;
                        ctx.lineWidth = 5.8;
                        ctx.lineJoin = "round";
                        ctx.lineCap = "round";
                        ctx.stroke();

                        // 3. Crisp Top Apex Specular Gloss Shine Highlight
                        var shineGrad = ctx.createLinearGradient(cx, topY, cx, topY + 22);
                        shineGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.95)");
                        shineGrad.addColorStop(0.4, "rgba(255, 236, 179, 0.65)");
                        shineGrad.addColorStop(1.0, "rgba(255, 167, 38, 0.0)");

                        ctx.beginPath();
                        ctx.moveTo(cx - 14, topY + 22);
                        ctx.lineTo(cx, topY);
                        ctx.lineTo(cx + 14, topY + 22);
                        ctx.strokeStyle = shineGrad;
                        ctx.lineWidth = 3.2;
                        ctx.lineJoin = "round";
                        ctx.lineCap = "round";
                        ctx.stroke();

                        // 4. 3D Exclamation Bar with Top Gloss
                        var barGrad = ctx.createLinearGradient(cx, 22, cx, 40);
                        barGrad.addColorStop(0.0, "#FFFFFF");
                        barGrad.addColorStop(0.3, "#FFE082");
                        barGrad.addColorStop(1.0, "#FF8F00");
                        ctx.fillStyle = barGrad;
                        ctx.beginPath();
                        ctx.rect(cx - 2.6, 22, 5.2, 16);
                        ctx.fill();

                        // 5. 3D Exclamation Dot with Gloss Sphere
                        var dotGrad = ctx.createRadialGradient(cx - 0.8, 44.5, 0.5, cx, 45.5, 3.0);
                        dotGrad.addColorStop(0.0, "#FFFFFF");
                        dotGrad.addColorStop(0.4, "#FFD54F");
                        dotGrad.addColorStop(1.0, "#FF6F00");
                        ctx.fillStyle = dotGrad;
                        ctx.beginPath();
                        ctx.arc(cx, 45.5, 3.0, 0, Math.PI * 2);
                        ctx.fill();
                        ctx.restore();

                        // 6. Smooth Inverted Floor Mirror Reflection with Fade
                        ctx.save();
                        ctx.globalAlpha = 0.22;
                        ctx.translate(0, height + 10);
                        ctx.scale(1, -0.35);

                        drawTrianglePath(ctx, topY, 0);
                        ctx.strokeStyle = amberGrad;
                        ctx.lineWidth = 5.8;
                        ctx.lineJoin = "round";
                        ctx.stroke();

                        ctx.fillStyle = barGrad;
                        ctx.beginPath();
                        ctx.rect(cx - 2.6, 22, 5.2, 16);
                        ctx.fill();

                        ctx.beginPath();
                        ctx.arc(cx, 45.5, 3.0, 0, Math.PI * 2);
                        ctx.fill();
                        ctx.restore();
                    }

                    Connections {
                        target: controller
                        function onReduceSpeedAlertChanged() {
                            if (controller && controller.reduceSpeedAlert) warningTriangleCanvas.requestPaint();
                        }
                    }
                }
            }
        }
    }

    // =================================================================
    // SMART KEY / PUSH-BUTTON START WARNING CARD (Matches OEM Photo 1:1)
    // =================================================================
    Item {
        id: smartKeyWarningCard
        anchors.top: topDteSection.bottom
        anchors.topMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 204
        visible: centerRoot.activeWarningId === 2
        z: 40

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width

            // Title: Dynamic based on 4 exact OEM Smart Key Prompts
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    var p = controller ? controller.smartKeyPrompt : 0;
                    var hindi = centerRoot.isHindi;
                    if (p === 1) return hindi ? "चाबी वाहन में नहीं है" : "Key not in vehicle";
                    if (p === 2) return hindi ? "चाबी नहीं मिली" : "Key not detected";
                    if (p === 3) return hindi ? "चाबी की बैटरी कम है" : "Low key battery";
                    if (p === 4) return hindi ? "चाबी से START बटन दबाएं" : "Press START with key";
                    return "";
                }
                font.pixelSize: 16
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width
            }

            // 3D Cluster Smart Key Fob Graphic with Ground Shadow & Floor Reflection
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 90
                height: 136

                // 1. High-Res Cluster Smart Key Fob Image
                Image {
                    id: keyFobImage
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 68
                    height: 98
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/smart_key_fob.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                // 2. Ground Contact Shadow Oval
                Rectangle {
                    id: keyGroundShadow
                    anchors.horizontalCenter: keyFobImage.horizontalCenter
                    anchors.top: keyFobImage.bottom
                    anchors.topMargin: 2
                    width: 46
                    height: 5
                    radius: 23
                    color: "#A0000000"
                }

                // 3. Inverted Floor Mirror Reflection of the Key Fob (With subtle gap)
                Item {
                    id: reflectionContainer
                    anchors.top: keyFobImage.bottom
                    anchors.topMargin: 4
                    anchors.horizontalCenter: keyFobImage.horizontalCenter
                    width: keyFobImage.width
                    height: 44
                    clip: true

                    Image {
                        id: reflectionImage
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: keyFobImage.width
                        height: keyFobImage.height
                        source: keyFobImage.source
                        fillMode: Image.PreserveAspectFit
                        rotation: 180
                        mirror: true
                        opacity: 0.50
                        smooth: true
                        mipmap: true
                    }

                    // Mirror Reflection Gradient Fade Mask
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.60; color: "#CC03060C" }
                            GradientStop { position: 1.0; color: "#03060C" }
                        }
                    }
                }
            }
        }
    }

    // =================================================================
    // PRESS START BUTTON AGAIN WARNING CARD (Matches OEM Photo 1:1)
    // =================================================================
    Item {
        id: pressStartAgainWarningCard
        anchors.top: topDteSection.bottom
        anchors.topMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 204
        visible: centerRoot.activeWarningId === 3
        z: 40

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width

            // Title: Dynamic for Press clutch pedal to start / Press START button again
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (controller && controller.startPedalPrompt === 2) {
                        return centerRoot.isHindi ? "स्टार्ट करने के लिए\nक्लच पेडल दबाएं" : "Press clutch pedal\nto start";
                    } else if (controller && controller.startPedalPrompt === 3) {
                        return centerRoot.isHindi ? "स्टार्ट करने के लिए\nब्रेक पेडल दबाएं" : "Press brake pedal\nto start";
                    } else {
                        return centerRoot.isHindi ? "फिर से START\nबटन दबाएं" : "Press START\nbutton again";
                    }
                }
                font.pixelSize: 18
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.15
            }

            // 3D Graphic with Ground Shadow & Inverted Floor Reflection (Dynamic: Start Button vs Pedal)
            Item {
                id: pedalGraphicItem
                readonly property bool isPedalPrompt: controller && (controller.startPedalPrompt === 2 || controller.startPedalPrompt === 3)
                anchors.horizontalCenter: parent.horizontalCenter
                width: isPedalPrompt ? 104 : 90
                height: 124

                // 1. High-Res 3D Graphic Image
                Image {
                    id: pedalImage
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: pedalGraphicItem.isPedalPrompt ? 98 : 82
                    height: pedalGraphicItem.isPedalPrompt ? 72 : 82
                    source: pedalGraphicItem.isPedalPrompt ?
                            "qrc:/qt/qml/ApexCluster/resources/icons/pedal_press_indicator.png" :
                            "qrc:/qt/qml/ApexCluster/resources/icons/engine_start_button_fob.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                // 2. Ground Contact Shadow Oval
                Rectangle {
                    id: pedalGroundShadow
                    anchors.horizontalCenter: pedalImage.horizontalCenter
                    anchors.top: pedalImage.bottom
                    anchors.topMargin: 2
                    width: pedalGraphicItem.isPedalPrompt ? 74 : 56
                    height: 5
                    radius: 2.5
                    color: "#A0000000"
                }

                // 3. Inverted Floor Mirror Reflection (With subtle gap)
                Item {
                    id: pedalReflectionContainer
                    anchors.top: pedalImage.bottom
                    anchors.topMargin: 4
                    anchors.horizontalCenter: pedalImage.horizontalCenter
                    width: pedalImage.width
                    height: pedalGraphicItem.isPedalPrompt ? 36 : 40
                    clip: true

                    Image {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: pedalImage.width
                        height: pedalImage.height
                        source: pedalImage.source
                        fillMode: Image.PreserveAspectFit
                        rotation: 180
                        mirror: true
                        opacity: 0.45
                        smooth: true
                        mipmap: true
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.60; color: "#CC03060C" }
                            GradientStop { position: 1.0; color: "#03060C" }
                        }
                    }
                }
            }
        }
    }

    // =================================================================
    // DOOR OPEN WARNING CARD (Centered Big Car with Smooth 3-Stage Door Opening Animation)
    // =================================================================
    Item {
        id: doorOpenWarningCard
        anchors.top: topDteSection.bottom
        anchors.bottom: bottomFooterSection.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: centerRoot.activeWarningId === 4
        z: 40

        // Top-Down 3D Vehicle with Smooth Door Opening Sequence (Large & Centered)
        Item {
            id: doorAnimItem
            anchors.centerIn: parent
            width: 140
            height: 210

            property int currentStep: 2 // 0 = Closed, 1 = Half-Open, 2 = Fully-Open
            readonly property bool fl: controller ? controller.doorFrontLeft : false
            readonly property bool fr: controller ? controller.doorFrontRight : false
            readonly property bool rl: controller ? controller.doorRearLeft : false
            readonly property bool rr: controller ? controller.doorRearRight : false
            readonly property bool bonnet: controller ? controller.bonnetOpen : false
            readonly property bool trunk: controller ? controller.trunkOpen : false

            Timer {
                id: doorSwingTimer
                interval: 140
                repeat: true
                running: centerRoot.activeWarningId === 4 && doorAnimItem.currentStep < 2
                onTriggered: {
                    if (doorAnimItem.currentStep < 2) {
                        doorAnimItem.currentStep++;
                    }
                }
            }

            Connections {
                target: centerRoot
                function onActiveWarningIdChanged() {
                    if (centerRoot.activeWarningId === 4) {
                        doorAnimItem.currentStep = 0;
                        doorSwingTimer.restart();
                    }
                }
            }

            Connections {
                target: controller
                function onDoorFrontRightChanged() { doorAnimItem.triggerAnim(); }
                function onDoorFrontLeftChanged() { doorAnimItem.triggerAnim(); }
                function onDoorRearRightChanged() { doorAnimItem.triggerAnim(); }
                function onDoorRearLeftChanged() { doorAnimItem.triggerAnim(); }
                function onBonnetOpenChanged() { doorAnimItem.triggerAnim(); }
                function onTrunkOpenChanged() { doorAnimItem.triggerAnim(); }
            }

            function triggerAnim() {
                if (controller && controller.isAnyDoorOpen) {
                    doorAnimItem.currentStep = 0;
                    doorSwingTimer.restart();
                }
            }

            Image {
                id: doorCarImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                source: {
                    var fl = doorAnimItem.fl;
                    var fr = doorAnimItem.fr;
                    var rl = doorAnimItem.rl;
                    var rr = doorAnimItem.rr;
                    var step = doorAnimItem.currentStep;

                    if (!fl && !fr && !rl && !rr) {
                        return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_closed.png";
                    }

                    // Step 0: Initial closed car
                    if (step === 0) {
                        return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_closed.png";
                    }

                    // Step 1: Smooth half-open intermediate swing
                    if (step === 1) {
                        if (fl && fr && rl && rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_all_half.png";
                        if (fl && fr && !rl && !rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_front_both_half.png";
                        if (!fl && !fr && rl && rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_rear_both_half.png";
                        if (fl && !fr && rl && !rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_left_both_half.png";
                        if (!fl && fr && !rl && rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_right_both_half.png";
                        if ((fl?1:0) + (fr?1:0) + (rl?1:0) + (rr?1:0) >= 3) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_all_half.png";

                        if (fr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_door_fr_half.png";
                        if (fl) return "qrc:/qt/qml/ApexCluster/resources/icons/car_door_fl_half.png";
                        if (rl) return "qrc:/qt/qml/ApexCluster/resources/icons/car_door_rl_half.png";
                        if (rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_door_rr_half.png";
                        return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_closed.png";
                    }

                    // Step 2: Fully-open state
                    if (fl && fr && rl && rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_all_open.png";
                    if (fl && fr && !rl && !rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_front_both.png";
                    if (!fl && !fr && rl && rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_rear_both.png";
                    if (fl && !fr && rl && !rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_left_both.png";
                    if (!fl && fr && !rl && rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_right_both.png";
                    if ((fl?1:0) + (fr?1:0) + (rl?1:0) + (rr?1:0) >= 3) return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_all_open.png";

                    if (fr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_door_fr.png";
                    if (fl) return "qrc:/qt/qml/ApexCluster/resources/icons/car_door_fl.png";
                    if (rl) return "qrc:/qt/qml/ApexCluster/resources/icons/car_door_rl.png";
                    if (rr) return "qrc:/qt/qml/ApexCluster/resources/icons/car_door_rr.png";

                    return "qrc:/qt/qml/ApexCluster/resources/icons/car_doors_closed.png";
                }
            }

            // Red Blinking Bonnet (Hood) Hazard Overlay
            Image {
                id: bonnetRedGlow
                anchors.fill: parent
                source: "qrc:/qt/qml/ApexCluster/resources/icons/car_bonnet_red_glow.png"
                fillMode: Image.PreserveAspectFit
                visible: doorAnimItem.bonnet
                opacity: 1.0

                SequentialAnimation on opacity {
                    running: doorAnimItem.bonnet
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.15; duration: 400; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.15; to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                }
            }

            // Red Blinking Trunk (Boot) Hazard Overlay
            Image {
                id: trunkRedGlow
                anchors.fill: parent
                source: "qrc:/qt/qml/ApexCluster/resources/icons/car_trunk_red_glow.png"
                fillMode: Image.PreserveAspectFit
                visible: doorAnimItem.trunk
                opacity: 1.0

                SequentialAnimation on opacity {
                    running: doorAnimItem.trunk
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.15; duration: 400; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.15; to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                }
            }
        }
    }

    // =================================================================
    // SUNROOF OPEN WARNING CARD (3D Sunroof + Sun Rays + Reflection)
    // =================================================================
    Item {
        id: sunroofWarningCard
        anchors.top: topDteSection.bottom
        anchors.topMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 204
        visible: centerRoot.activeWarningId === 5
        z: 40

        Column {
            anchors.centerIn: parent
            spacing: 12
            width: parent.width

            // Title: "Sunroof open"
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: centerRoot.isHindi ? "सनरूफ खुला है" : "Sunroof open"
                font.pixelSize: 16
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
            }

            // 3D Sunroof Graphic with Sun Rays & Reflection
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 60
                height: 54

                Canvas {
                    id: sunroofCanvas
                    anchors.fill: parent

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);

                        var cx = width * 0.5;
                        var cy = 24;

                        // 1. Radiant Ambient Sun Glow
                        var glow = ctx.createRadialGradient(cx, cy, 2, cx, cy, 26);
                        glow.addColorStop(0.0, "rgba(255, 167, 38, 0.35)");
                        glow.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                        ctx.fillStyle = glow;
                        ctx.beginPath();
                        ctx.arc(cx, cy, 26, 0, Math.PI * 2);
                        ctx.fill();

                        // 2. 3D Sun Graphic with Rays
                        var sunGrad = ctx.createRadialGradient(cx - 2, cy - 2, 1, cx, cy, 12);
                        sunGrad.addColorStop(0.0, "#FFFFFF");
                        sunGrad.addColorStop(0.4, "#FFE082");
                        sunGrad.addColorStop(1.0, "#FF8F00");

                        ctx.save();
                        // Sun Circle
                        ctx.fillStyle = sunGrad;
                        ctx.beginPath();
                        ctx.arc(cx, cy, 10, 0, Math.PI * 2);
                        ctx.fill();

                        // Sun Rays
                        ctx.strokeStyle = "#FFA726";
                        ctx.lineWidth = 2.2;
                        ctx.lineCap = "round";
                        for (var i = 0; i < 8; i++) {
                            var angle = i * (Math.PI / 4);
                            ctx.beginPath();
                            ctx.moveTo(cx + Math.cos(angle) * 13, cy + Math.sin(angle) * 13);
                            ctx.lineTo(cx + Math.cos(angle) * 18, cy + Math.sin(angle) * 18);
                            ctx.stroke();
                        }

                        // Sunroof Glass Tilt Line
                        ctx.strokeStyle = "#00E5FF";
                        ctx.lineWidth = 2.5;
                        ctx.beginPath();
                        ctx.moveTo(cx - 20, cy + 16);
                        ctx.lineTo(cx + 20, cy + 12);
                        ctx.stroke();
                        ctx.restore();

                        // 3. Floor Reflection
                        ctx.save();
                        ctx.globalAlpha = 0.20;
                        ctx.translate(0, height + 6);
                        ctx.scale(1, -0.30);
                        ctx.fillStyle = sunGrad;
                        ctx.beginPath();
                        ctx.arc(cx, cy, 10, 0, Math.PI * 2);
                        ctx.fill();
                        ctx.restore();
                    }

                    Connections {
                        target: controller
                        function onSunroofAlertActiveChanged() {
                            if (controller && controller.sunroofAlertActive) sunroofCanvas.requestPaint();
                        }
                    }
                }
            }

            // Subtitle: "Check sunroof before leaving vehicle"
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: centerRoot.isHindi ? "कृपया सनरूफ बंद करें" : "Check sunroof before\nleaving vehicle"
                font.pixelSize: 12
                font.family: centerRoot.fontHeadRegular
                color: "#CCD8E8"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // =================================================================
    // 2. MIDDLE CARD: WARNING 7 - LOW FUEL ALERT (Matches OEM Photo 1:1)
    // =================================================================
    Item {
        id: lowFuelWarningItem
        anchors.top: topDteSection.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 204
        visible: centerRoot.activeWarningId === 7
        z: 40

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width

            // Title: "Low fuel" (or "ईंधन कम है" in Hindi)
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: centerRoot.isHindi ? "ईंधन कम है" : "Low fuel"
                font.pixelSize: 19
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
                font.letterSpacing: 0.3
            }

            // 3D Low Fuel Warning Icon with Ground Shadow & Connected Floor Mirror Reflection
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 110
                height: 125

                // 1. Primary High-Res 3D Amber Fuel Pump Image (Direct PNG)
                Image {
                    id: pumpWarningImage
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 92
                    height: 69
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/low_fuel_warning_3d.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                // 2. Ground Contact Shadow Oval
                Rectangle {
                    id: pumpGroundShadow
                    anchors.horizontalCenter: pumpWarningImage.horizontalCenter
                    anchors.top: pumpWarningImage.bottom
                    anchors.topMargin: -1
                    width: 64
                    height: 4
                    radius: 32
                    color: "#90000000"
                }

                // 3. Inverted Floor Mirror Reflection directly touching base (No far gap)
                Item {
                    id: pumpReflectionContainer
                    anchors.top: pumpWarningImage.bottom
                    anchors.topMargin: 0
                    anchors.horizontalCenter: pumpWarningImage.horizontalCenter
                    width: pumpWarningImage.width
                    height: 28
                    clip: true

                    Image {
                        id: pumpReflectionImage
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: pumpWarningImage.width
                        height: pumpWarningImage.height
                        source: pumpWarningImage.source
                        fillMode: Image.PreserveAspectFit
                        rotation: 180
                        mirror: true
                        opacity: 0.35
                        smooth: true
                        mipmap: true
                    }

                    // Mirror Reflection Gradient Fade Mask
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.50; color: "#D003060C" }
                            GradientStop { position: 1.0; color: "#03060C" }
                        }
                    }
                }
            }
        }
    }

    UserSettingsView {
        id: userSettingsView
        anchors.top: topDteSection.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        themeColor: centerRoot.themeColor
        visible: centerRoot.menuTab === 1 && (!controller || (!controller.showLightPopup && !centerRoot.isWarningActive))
    }

    // =================================================================
    // 2. MIDDLE CARD: TPMS / TYRE PRESSURE VIEW (When menuTab === 2)
    // =================================================================
    TpmsDisplayView {
        id: tpmsDisplayView
        anchors.top: topDteSection.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        visible: centerRoot.menuTab === 2 && (!controller || (!controller.showLightPopup && !centerRoot.isWarningActive))
    }

    // =================================================================
    // 2. MIDDLE CARD: CURRENT TRIP (When menuTab === 0)
    // =================================================================
    Item {
        id: tripCardSection
        anchors.top: topDteSection.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 204
        clip: true
        visible: centerRoot.menuTab === 0 && (!controller || (!controller.showLightPopup && !centerRoot.isWarningActive))

        property int lastPage: centerRoot.tripPage

        // Smooth Page Scroll Animation
        ParallelAnimation {
            id: pageSlideAnim
            NumberAnimation { target: cardContent; property: "yOffset"; to: 0; duration: 240; easing.type: Easing.OutCubic }
            NumberAnimation { target: cardContent; property: "opacity"; to: 1.0; duration: 240; easing.type: Easing.OutQuad }
        }

        Connections {
            target: centerRoot
            function onTripPageChanged() {
                var goingDown = (centerRoot.tripPage > tripCardSection.lastPage);
                if (tripCardSection.lastPage === 2 && centerRoot.tripPage === 0) goingDown = true;
                if (tripCardSection.lastPage === 0 && centerRoot.tripPage === 2) goingDown = false;
                tripCardSection.lastPage = centerRoot.tripPage;

                cardContent.yOffset = goingDown ? 18 : -18;
                cardContent.opacity = 0.2;
                pageSlideAnim.restart();
            }
        }

        // Right Edge 3-Segment Vertical Page Indicator (Dot 1, Dot 2 [Highlighted], Dot 3)
        Column {
            anchors.right: parent.right
            anchors.rightMargin: -2
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 6
            spacing: 3
            z: 10

            // Dot 1: Drive info
            Rectangle {
                width: 3
                height: centerRoot.tripPage === 0 ? 14 : 5
                radius: 1.5
                color: centerRoot.tripPage === 0 ? "#FFFFFF" : "#5080A0"
                anchors.horizontalCenter: parent.horizontalCenter
                Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 220 } }
            }

            // Dot 2: Since refuelling (Highlighted in OEM Photo)
            Rectangle {
                width: 3
                height: centerRoot.tripPage === 1 ? 14 : 5
                radius: 1.5
                color: centerRoot.tripPage === 1 ? "#FFFFFF" : "#5080A0"
                anchors.horizontalCenter: parent.horizontalCenter
                Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 220 } }
            }

            // Dot 3: Accumulated info
            Rectangle {
                width: 3
                height: centerRoot.tripPage === 2 ? 14 : 5
                radius: 1.5
                color: centerRoot.tripPage === 2 ? "#FFFFFF" : "#5080A0"
                anchors.horizontalCenter: parent.horizontalCenter
                Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 220 } }
            }
        }

        // Animated Card Content (Title + 3 Data Rows)
        Item {
            id: cardContent
            anchors.fill: parent
            property real yOffset: 0.0
            transform: Translate { y: cardContent.yOffset }

            // "Drive info" / "Since refuelling" / "Accumulated info" Header
            Text {
                id: currentTripTitle
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text: centerRoot.tripTitle
                font.pixelSize: 19
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
            }

            // 3 Data Rows (Distance, Time, Economy)
            Column {
                anchors.top: currentTripTitle.bottom
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 8
                spacing: 12

            // Row 1: Distance
            Item {
                width: parent.width
                height: 34

                Image {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 34
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/trip_car.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                // Number Value (Right aligned to fixed column)
                Text {
                    id: row1Val
                    anchors.right: parent.right
                    anchors.rightMargin: 46
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!controller) return "0.0";
                        if (controller.tripPage === 1) return controller.refuelKm.toFixed(1);
                        if (controller.tripPage === 2) return controller.accumKm.toFixed(1);
                        return controller.tripKm.toFixed(1);
                    }
                    font.pixelSize: 24
                    font.family: centerRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                // Unit Label
                Text {
                    anchors.left: row1Val.right
                    anchors.leftMargin: 3
                    anchors.bottom: row1Val.bottom
                    anchors.bottomMargin: 2
                    text: "km"
                    font.pixelSize: 14
                    font.family: centerRoot.fontHeadRegular
                    color: "#FFFFFF"
                }
            }

            // Row 2: Elapsed Time (0:00 h:m)
            Item {
                width: parent.width
                height: 34

                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 34
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/trip_clock.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                // Number Value (Right aligned to exact same column)
                Text {
                    id: row2Val
                    anchors.right: parent.right
                    anchors.rightMargin: 46
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!controller) return "0:00";
                        if (controller.tripPage === 1) return controller.refuelTime;
                        if (controller.tripPage === 2) return controller.accumTime;
                        return controller.tripTime;
                    }
                    font.pixelSize: 24
                    font.family: centerRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                // Unit Label
                Text {
                    anchors.left: row2Val.right
                    anchors.leftMargin: 3
                    anchors.bottom: row2Val.bottom
                    anchors.bottomMargin: 2
                    text: "h:m"
                    font.pixelSize: 14
                    font.family: centerRoot.fontHeadRegular
                    color: "#FFFFFF"
                }
            }

            // Row 3: Fuel Economy
            Item {
                width: parent.width
                height: 34

                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 34
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/trip_fuel.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                // Number Value (Right aligned to exact same column)
                Text {
                    id: row3Val
                    anchors.right: parent.right
                    anchors.rightMargin: 46
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!controller) return "0.0";
                        var econ = (controller.tripPage === 1) ? controller.refuelEconomy : ((controller.tripPage === 2) ? controller.accumEconomy : controller.tripEconomy);
                        if (controller.fuelUnit === "L/100km") {
                            return econ > 0.1 ? (100.0 / econ).toFixed(1) : "0.0";
                        }
                        return econ.toFixed(1);
                    }
                    font.pixelSize: 24
                    font.family: centerRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                // Unit Label
                Text {
                    anchors.left: row3Val.right
                    anchors.leftMargin: 3
                    anchors.bottom: row3Val.bottom
                    anchors.bottomMargin: 2
                    text: (controller && controller.fuelUnit === "L/100km") ? "L/100km" : "km/L"
                    font.pixelSize: (controller && controller.fuelUnit === "L/100km") ? 11 : 14
                    font.family: centerRoot.fontHeadRegular
                    color: "#FFFFFF"
                }
            }
        }
    }
}

    // =================================================================
    // 3. BOTTOM FOOTER: TEMPERATURE & ODOMETER (Matches OEM Photo 1:1)
    // =================================================================
    Item {
        id: bottomFooterSection
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 52

        // Bottom Animated Luminous Glowing Blue Curved Divider Line with Dim White Underglow
        Item {
            id: bottomDividerLine
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.92
            height: 8
            opacity: centerRoot.isTpmsActive ? (centerRoot.lineAnimProgress * centerRoot.tpmsBlinkOpacity) : centerRoot.lineAnimProgress

            // Soft Dim White Ambient Light shining below the line
            Rectangle {
                anchors.top: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * centerRoot.lineAnimProgress * 0.96
                height: 7
                opacity: centerRoot.lineAnimProgress * 0.40
                color: "transparent"
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#55FFFFFF" }
                    GradientStop { position: 0.4; color: centerRoot.themeUnderGlow }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Crisp Core Line
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * centerRoot.lineAnimProgress
                height: 1.5
                radius: 0.75
                opacity: centerRoot.lineAnimProgress
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: centerRoot.themeGlowGradient }
                    GradientStop { position: 0.5; color: centerRoot.themeCoreColor }
                    GradientStop { position: 0.8; color: centerRoot.themeGlowGradient }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // 3 Occupant Seatbelt Icons (Shows for 4s after startup in solid red, then vanishes unless unbuckled)
        Row {
            id: occupantRow
            anchors.bottom: bottomDividerLine.top
            anchors.bottomMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 3

            property bool inStartup4s: !centerRoot.initialSeatbeltDone && controller && (controller.clusterState === 3)
            property bool hasUnbuckledSeat: controller && (!controller.rearLeftBuckled || !controller.rearCenterBuckled || !controller.rearRightBuckled || controller.rearAlarmActive)
            property bool shouldShow: inStartup4s || hasUnbuckledSeat

            visible: shouldShow && centerRoot.menuTab === 0 && (!controller || (!controller.showLightPopup && !controller.reduceSpeedAlert && !controller.driverAttentionActive && !controller.servicePopupActive && !controller.sunroofAlertActive && controller.smartKeyPrompt === 0))
            opacity: shouldShow ? 1.0 : 0.0
            z: 10

            Behavior on opacity { NumberAnimation { duration: 300 } }

            Repeater {
                model: 3
                Item {
                    width: 22
                    height: 24

                    property bool isUnbuckled: {
                        if (!controller) return false;
                        if (index === 0) return !controller.rearLeftBuckled;
                        if (index === 1) return !controller.rearCenterBuckled;
                        if (index === 2) return !controller.rearRightBuckled;
                        return false;
                    }
                    property bool isStartupSolidRed: occupantRow.inStartup4s
                    property bool isAlarming: isUnbuckled || (controller && controller.rearAlarmActive && (controller.rearAlarmSeat === index))

                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 22
                        source: "qrc:/qt/qml/ApexCluster/resources/icons/seatbelt.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        opacity: isStartupSolidRed ? 1.0 : (isAlarming ? (controller && controller.rearSeatBlinkState ? 1.0 : 0.15) : 1.0)

                        layer.enabled: !isStartupSolidRed && !isAlarming
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: "#FFFFFF"
                        }
                    }
                }
            }
        }

        // 3D Instantaneous Fuel Economy (ECO) Gauge (Hidden during ANY warning/popup)
        InstantEcoGauge {
            id: instantEcoGauge
            anchors.bottom: bottomDividerLine.top
            anchors.bottomMargin: 28
            anchors.horizontalCenter: parent.horizontalCenter
            themeColor: centerRoot.themeColor
            value: (controller && controller.speed > 0) ? controller.instantEconomy : 0.0
            visible: centerRoot.menuTab === 0 && !centerRoot.showResetPrompt && !centerRoot.isWarningActive && (!controller || !controller.showLightPopup)
            z: 10
        }

        // Action Prompt: Hold [OK] : Reset (Only for Since refuelling & Accumulated info, hidden on Drive info)
        Row {
            id: resetPrompt
            anchors.bottom: bottomDividerLine.top
            anchors.bottomMargin: 28
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5
            visible: centerRoot.menuTab === 0 && centerRoot.tripPage !== 0 && centerRoot.showResetPrompt && !centerRoot.isWarningActive && (!controller || !controller.showLightPopup)
            z: 10

            Text {
                text: centerRoot.isHindi ? "दबाए रखें" : "Hold"
                font.pixelSize: 13
                font.family: centerRoot.fontHeadRegular
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 22
                height: 16
                radius: 3
                color: "transparent"
                border.color: "#FFFFFF"
                border.width: 1.2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "OK"
                    font.pixelSize: 10
                    font.family: centerRoot.fontHeadMedium
                    font.bold: true
                    color: "#FFFFFF"
                }
            }

            Text {
                text: centerRoot.isHindi ? " : रीसेट" : ": Reset"
                font.pixelSize: 13
                font.family: centerRoot.fontHeadRegular
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Ambient Temperature (Top Right, hidden in Ignition OFF)
        Row {
            id: tempRow
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: bottomDividerLine.bottom
            anchors.topMargin: 2
            spacing: 1
            visible: !centerRoot.isIgnitionOff

            Text {
                id: tempNum
                anchors.verticalCenter: parent.verticalCenter
                text: (controller && controller.tempUnit === "°F") ? Math.round(centerRoot.ambientTemp * 9 / 5 + 32).toString() : centerRoot.ambientTemp.toString()
                font.pixelSize: 18
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.Medium
                color: "#FFFFFF"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
                text: (controller && controller.tempUnit === "°F") ? "°F" : "°c"
                font.pixelSize: 12
                font.family: centerRoot.fontHeadRegular
                color: "#FFFFFF"
            }
        }

        // Odometer (Permanently at Bottom Right)
        Row {
            id: odoRow
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            spacing: 1
            visible: true

            Text {
                id: odoNum
                anchors.verticalCenter: parent.verticalCenter
                text: centerRoot.odoKm
                font.pixelSize: 18
                font.family: centerRoot.fontHeadMedium
                font.weight: Font.Medium
                color: "#FFFFFF"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
                text: "km"
                font.pixelSize: 12
                font.family: centerRoot.fontHeadRegular
                color: "#FFFFFF"
            }
        }
    }
}
