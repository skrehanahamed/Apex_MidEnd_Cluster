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

    // State Stack: "main", "driver", "warning_methods", "warning_volume", "cluster", "lights", "door", "convenience", "unit", "language", "reset"
    property var menuStack: ["main"]
    readonly property string currentMenu: menuStack[menuStack.length - 1]
    property int selectedIndex: 0

    // Returns whether top header should show "Hold [OK] : Help"
    readonly property bool showHelpHint: ((currentMenu === "driver" || currentMenu === "warning_methods" || currentMenu === "warning_volume") && selectedIndex > 0) || (currentMenu === "lights" && selectedIndex === 1)

    // Settings State Values
    property string warningVolume: "Medium"
    property bool wiperLightMode: true
    property bool roadIcingAlert: true
    property bool welcomeSound: true
    property int lightBrightness: 20
    property string oneTouchIndicator: "3 flashes"
    property bool headlampEscort: true
    property bool autoLock: true
    property bool autoUnlock: true
    property bool rearOccupantAlert: true

    function adjustBrightness(delta) {
        lightBrightness = Math.max(1, Math.min(20, lightBrightness + delta));
    }

    // Get current menu item list
    function getMenuItems() {
        if (currentMenu === "main") {
            return [
                { id: "driver", label: "Driver assistance", hasSub: true },
                { id: "cluster", label: "Cluster", hasSub: true },
                { id: "lights", label: "Lights", hasSub: true },
                { id: "door", label: "Door", hasSub: true },
                { id: "convenience", label: "Convenience", hasSub: true },
                { id: "unit", label: "Unit setting", hasSub: true },
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
                { id: "autolock", label: "Auto Lock", isToggle: true, value: autoLock ? "On (Speed)" : "Off" },
                { id: "autounlock", label: "Auto Unlock", isToggle: true, value: autoUnlock ? "On (Key Out)" : "Off" }
            ];
        } else if (currentMenu === "convenience") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "rear", label: "Rear Occupant Alert", isToggle: true, value: rearOccupantAlert ? "On" : "Off" },
                { id: "service", label: "Service Interval", isValue: true, value: "10,000 km" }
            ];
        } else if (currentMenu === "unit") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "econ", label: "Fuel Economy", isValue: true, value: "km/L" },
                { id: "temp", label: "Temperature", isValue: true, value: "°C" }
            ];
        } else if (currentMenu === "language") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "lang", label: "Language", isValue: true, value: "English" }
            ];
        } else if (currentMenu === "reset") {
            return [
                { id: "back", label: "Back", isBack: true },
                { id: "reset_all", label: "Reset all settings?", isReset: true }
            ];
        }
        return [];
    }

    function getMenuTitle() {
        if (currentMenu === "main") return "User settings";
        if (currentMenu === "driver") return "Driver assistance";
        if (currentMenu === "warning_methods") return "Warning methods";
        if (currentMenu === "warning_volume") return "Warning volume";
        if (currentMenu === "cluster") return "Cluster";
        if (currentMenu === "cluster_theme") return "Cluster theme";
        if (currentMenu === "lights") return "Lights";
        if (currentMenu === "illumination") return "Illumination";
        if (currentMenu === "one_touch_turn") return "One touch turn indi...";
        if (currentMenu === "door") return "Door";
        if (currentMenu === "convenience") return "Convenience";
        if (currentMenu === "unit") return "Unit setting";
        if (currentMenu === "language") return "Language";
        if (currentMenu === "reset") return "Reset settings";
        return "User settings";
    }

    function goBack() {
        if (menuStack.length > 1) {
            var newStack = menuStack.slice(0, menuStack.length - 1);
            menuStack = newStack;
            selectedIndex = (currentMenu === "main" ? 0 : 1);
        }
    }

    function selectCurrent() {
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
            selectedIndex = 1; // Highlight first real item below Back
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
            }
            return;
        }

        if (item.isCheckbox) {
            if (item.id === "wiper") wiperLightMode = !wiperLightMode;
            else if (item.id === "icing") roadIcingAlert = !roadIcingAlert;
            else if (item.id === "welcome") welcomeSound = !welcomeSound;
            else if (item.id === "escort") headlampEscort = !headlampEscort;
            return;
        }

        if (item.isToggle) {
            if (item.id === "wiper") wiperLightMode = !wiperLightMode;
            else if (item.id === "traffic") trafficSignInfo = !trafficSignInfo;
            else if (item.id === "icing") roadIcingAlert = !roadIcingAlert;
            else if (item.id === "welcome") welcomeSound = !welcomeSound;
            else if (item.id === "escort") headlampEscort = !headlampEscort;
            else if (item.id === "autolock") autoLock = !autoLock;
            else if (item.id === "autounlock") autoUnlock = !autoUnlock;
            else if (item.id === "rear") rearOccupantAlert = !rearOccupantAlert;
            return;
        }
    }

    function navUp() {
        if (currentMenu === "illumination") {
            adjustBrightness(1);
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
        var count = getMenuItems().length;
        if (count > 0) {
            selectedIndex = (selectedIndex + 1) % count;
        }
    }

    // =================================================================
    // 1. TOP TITLE HEADER: Exact OEM Hyundai Typography
    // =================================================================
    Item {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 28

        Text {
            anchors.centerIn: parent
            text: settingsRoot.getMenuTitle()
            font.pixelSize: 18
            font.family: "Hyundai Sans Head Medium"
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
        visible: settingsRoot.currentMenu !== "illumination"

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
                                text: "Back"
                                font.pixelSize: 14
                                font.family: "Hyundai Sans Head Medium"
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
                            text: modelData.label
                            font.pixelSize: 14
                            font.family: "Hyundai Sans Head Medium"
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
                            font.family: "Hyundai Sans Head Bold"
                            font.weight: Font.Bold
                            color: isSelected ? settingsRoot.neonEdgeColor : "#80A0C0"
                        }

                        // 4. Toggle or Value Text
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: (modelData.isToggle === true || modelData.isValue === true)
                            text: modelData.value ? modelData.value : ""
                            font.pixelSize: 12
                            font.family: "Hyundai Sans Head Medium"
                            font.bold: true
                            color: (modelData.value === "On" || isSelected) ? settingsRoot.neonEdgeColor : "#80A0C0"
                        }

                        // 5. Circular Radio Button: Matches Photo 3 1:1
                        Item {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            visible: modelData.isRadio === true

                            // Outer White Outline Circle
                            Rectangle {
                                anchors.fill: parent
                                radius: 7
                                color: "transparent"
                                border.color: "#FFFFFF"
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
                                font.family: "Hyundai Sans Head Bold"
                                font.bold: true
                                color: "#000000"
                            }
                        }
                    }
                }
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
                font.family: "Hyundai Sans Head Medium"
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
            font.family: "Hyundai Sans Head Bold"
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
            font.family: "Hyundai Sans Head Bold"
            font.bold: true
            color: settingsRoot.lightBrightness < 20 ? "#CCD8E8" : "#406080"
        }
    }
}
