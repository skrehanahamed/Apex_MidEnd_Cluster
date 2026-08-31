import QtQuick

Item {
    id: centerRoot
    property string gearValue: controller ? controller.gear : "N"
    property int dteKm: controller ? controller.dteKm : 52
    property double tripKm: controller ? controller.tripKm : 0.0
    property string tripTime: controller ? controller.tripTime : "0:00"
    property double tripEconomy: controller ? controller.tripEconomy : 0.0
    property int tripPage: controller ? controller.tripPage : 1
    readonly property string tripTitle: tripPage === 1 ? "Since refuelling" : (tripPage === 2 ? "Since last reset" : "Current trip")
    readonly property double activeTripKm: tripPage === 1 ? (controller ? controller.refuelKm : 154.9) : (tripPage === 2 ? (controller ? controller.accumKm : 3454.0) : (controller ? controller.tripKm : 0.0))
    readonly property string activeTripTime: tripPage === 1 ? (controller ? controller.refuelTime : "10:21") : (tripPage === 2 ? (controller ? controller.accumTime : "84:12") : (controller ? controller.tripTime : "0:00"))
    readonly property double activeTripEconomy: tripPage === 1 ? (controller ? controller.refuelEconomy : 12.5) : (tripPage === 2 ? (controller ? controller.accumEconomy : 14.2) : (controller ? controller.tripEconomy : 0.0))
    property int ambientTemp: controller ? controller.ambientTemp : 25
    property int odoKm: controller ? controller.odoKm : 3454
    property bool showResetPrompt: false

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

    // Dynamic Line Theme Colors: "blue", "green", "red"
    property string themeColor: controller ? controller.themeColor : "blue"
    readonly property color themeCoreColor: themeColor === "green" ? "#D0FFE0" : (themeColor === "red" ? "#FFD0D0" : "#D0E0FF")
    readonly property color themePrimaryColor: themeColor === "green" ? "#00E676" : (themeColor === "red" ? "#FF5252" : "#00E5FF")
    readonly property color themeGlowGradient: themeColor === "green" ? "#5000C853" : (themeColor === "red" ? "#50FF1744" : "#5000C8FF")
    readonly property color themeUnderGlow: themeColor === "green" ? "#2500E676" : (themeColor === "red" ? "#25FF5252" : "#2500E5FF")

    implicitWidth: 198
    implicitHeight: 366

    // =================================================================
    // 🔤 HYUNDAI SANS HEAD FONT LOADERS
    // =================================================================
    FontLoader { id: hyundaiRegular; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Regular.ttf" }
    FontLoader { id: hyundaiMedium; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Medium.ttf" }
    FontLoader { id: hyundaiBold; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Bold.ttf" }

    readonly property string fontHeadRegular: hyundaiRegular.status === FontLoader.Ready ? hyundaiRegular.name : "Hyundai Sans Head Regular"
    readonly property string fontHeadMedium: hyundaiMedium.status === FontLoader.Ready ? hyundaiMedium.name : "Hyundai Sans Head Medium"
    readonly property string fontHeadBold: hyundaiBold.status === FontLoader.Ready ? hyundaiBold.name : "Hyundai Sans Head Bold"

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
    Item {
        id: topDteSection
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 48

        // Top Header Row (Gear Indicator on Left, Center Tabs / Right DTE)
        Item {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            height: 32

            // 1. TRANSMISSION GEAR INDICATOR (Always visible on the left)
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
                    color: "#FFFFFF"
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
                        source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/menu_tab_car.png"
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
                        source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/menu_tab_settings.png"
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
                        source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/menu_tab_info.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        opacity: centerRoot.menuTab === 2 ? 1.0 : 0.35
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }
                }
            }

            // 3. FUEL PUMP & DTE RANGE or HOLD [OK] : HELP (Visible when tabs are hidden)
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
                        text: "Hold"
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
                        text: ": Help"
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
                        width: 28
                        height: 28
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/fuel_pump.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        id: dteValueText
                        anchors.verticalCenter: parent.verticalCenter
                        text: centerRoot.dteKm
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
    UserSettingsView {
        id: userSettingsView
        anchors.top: topDteSection.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        themeColor: centerRoot.themeColor
        visible: centerRoot.menuTab === 1
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
        visible: centerRoot.menuTab === 2
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
        visible: centerRoot.menuTab === 0

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
                height: 32

                Image {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 34
                    height: 30
                    source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/trip_car.png"
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
                    text: centerRoot.activeTripKm.toFixed(1)
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
                height: 32

                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: 30
                    source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/trip_clock.png"
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
                    text: centerRoot.activeTripTime
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
                height: 32

                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: 30
                    source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/trip_fuel.png"
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
                    text: centerRoot.activeTripEconomy.toFixed(1)
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
                    text: "km/L"
                    font.pixelSize: 14
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

        // 3 Occupant Seatbelt Icons (Sitting directly on top of the lower divider line)
        Row {
            id: occupantRow
            anchors.bottom: bottomDividerLine.top
            anchors.bottomMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 1
            z: 10

            Repeater {
                model: 3
                Image {
                    width: 20
                    height: 22
                    source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/seatbelt.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }
            }
        }

        // 3D Instantaneous Fuel Economy (ECO) Gauge (Visible only in Trip mode)
        InstantEcoGauge {
            id: instantEcoGauge
            anchors.bottom: occupantRow.top
            anchors.bottomMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            themeColor: centerRoot.themeColor
            value: (controller && controller.speed > 0) ? controller.instantEconomy : 0.0
            visible: centerRoot.menuTab === 0 && !centerRoot.showResetPrompt
            z: 10
        }

        // Action Prompt: Hold [OK] : Reset (Visible only in Trip mode)
        Row {
            id: resetPrompt
            anchors.bottom: occupantRow.top
            anchors.bottomMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5
            visible: centerRoot.menuTab === 0 && centerRoot.showResetPrompt
            z: 10

            Text {
                text: "Hold"
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
                text: ": Reset"
                font.pixelSize: 13
                font.family: centerRoot.fontHeadRegular
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Right-Aligned Column for Temperature and Odometer (Number and unit on same line)
        Column {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 4
            spacing: 2

            // Ambient Temperature (Top Right)
            Row {
                anchors.right: parent.right
                spacing: 1

                Text {
                    id: tempNum
                    anchors.verticalCenter: parent.verticalCenter
                    text: centerRoot.ambientTemp
                    font.pixelSize: 18
                    font.family: centerRoot.fontHeadMedium
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 1
                    text: "°c"
                    font.pixelSize: 12
                    font.family: centerRoot.fontHeadRegular
                    color: "#FFFFFF"
                }
            }

            // Odometer (Bottom Right)
            Row {
                anchors.right: parent.right
                spacing: 1

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
}
