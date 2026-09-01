import QtQuick
import QtQuick.Controls

Item {
    id: ecuRoot
    property bool isOpen: true

    signal btnUpPressed()
    signal btnDownPressed()
    signal btnOkPressed()
    signal btnBackPressed()
    signal btnInfoPressed()

    // Helper functions that safely invoke the global controller
    function changeTheme(col) {
        if (typeof controller !== "undefined" && controller) {
            controller.setThemeColor(col);
        }
    }

    function changeState(st) {
        if (typeof controller !== "undefined" && controller) {
            controller.setClusterState(st);
        }
    }

    function changeGear(g) {
        if (typeof controller !== "undefined" && controller) {
            controller.setGear(g);
        }
    }

    function changeSpeed(spd) {
        if (typeof controller !== "undefined" && controller) {
            controller.setSpeed(spd);
        }
    }

    function changeRpm(r) {
        if (typeof controller !== "undefined" && controller) {
            controller.setRpm(r);
        }
    }

    function toggleDemo() {
        if (typeof controller !== "undefined" && controller) {
            controller.driveDemo();
        }
    }

    // Glass Background Container
    Rectangle {
        id: bgCard
        anchors.fill: parent
        radius: 10
        color: "#F0080F18"
        border.color: ecuRoot.isOpen ? "#4000E5FF" : "#304050"
        border.width: 1.2
        clip: true

        // Top Accent Glow Strip
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2.5
            color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#00E676" : ((typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#FF5252" : "#00E5FF")
        }

        // =============================================================
        // ALWAYS-VISIBLE QUICK TOOLBAR
        // =============================================================
        Item {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 42

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Status Indicator
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#00E676" : ((typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#FF5252" : "#00E5FF")
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "THEME:"
                    font.pixelSize: 10
                    font.bold: true
                    color: "#80A0C0"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // 🔵 Blue Theme Button
                Rectangle {
                    width: 48
                    height: 24
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: (typeof controller !== "undefined" && controller && controller.themeColor === "blue") ? "#4000E5FF" : "#142030"
                    border.color: (typeof controller !== "undefined" && controller && controller.themeColor === "blue") ? "#00E5FF" : "#283848"
                    border.width: 1.2

                    Row {
                        anchors.centerIn: parent
                        spacing: 3
                        Rectangle { width: 6; height: 6; radius: 3; color: "#00E5FF" }
                        Text { text: "Blue"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ecuRoot.changeTheme("blue")
                    }
                }

                // 🟢 Green Theme Button
                Rectangle {
                    width: 52
                    height: 24
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#4000E676" : "#142030"
                    border.color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#00E676" : "#283848"
                    border.width: 1.2

                    Row {
                        anchors.centerIn: parent
                        spacing: 3
                        Rectangle { width: 6; height: 6; radius: 3; color: "#00E676" }
                        Text { text: "Green"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ecuRoot.changeTheme("green")
                    }
                }

                // 🔴 Red Theme Button
                Rectangle {
                    width: 46
                    height: 24
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: (typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#40FF5252" : "#142030"
                    border.color: (typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#FF5252" : "#283848"
                    border.width: 1.2

                    Row {
                        anchors.centerIn: parent
                        spacing: 3
                        Rectangle { width: 6; height: 6; radius: 3; color: "#FF5252" }
                        Text { text: "Red"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ecuRoot.changeTheme("red")
                    }
                }

                // 🔑 IGNITION (ON / OFF) Quick Toggle
                Rectangle {
                    width: 86
                    height: 24
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    property bool isIgnOn: (typeof controller !== "undefined" && controller && controller.clusterState !== 5 && controller.clusterState !== 4)
                    color: isIgnOn ? "#3000E676" : "#40FF1744"
                    border.color: isIgnOn ? "#00E676" : "#FF1744"
                    border.width: 1.2

                    Text {
                        anchors.centerIn: parent
                        text: parent.isIgnOn ? "🟢 IGN: ON" : "🔴 IGN: OFF"
                        font.pixelSize: 9
                        font.bold: true
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof controller !== "undefined" && controller) {
                                if (parent.isIgnOn) {
                                    controller.setIgnitionOffDirect();
                                } else {
                                    controller.setIgnitionOnDirect();
                                }
                            }
                        }
                    }
                }
            }

            // Expand / Collapse Drawer Button
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 68
                height: 26
                radius: 4
                color: ecuRoot.isOpen ? "#3000E5FF" : "#182434"
                border.color: ecuRoot.isOpen ? "#00E5FF" : "#304860"

                Text {
                    anchors.centerIn: parent
                    text: ecuRoot.isOpen ? "✕ Close" : "⚙ ECU ▾"
                    font.pixelSize: 10
                    font.bold: true
                    color: "#FFFFFF"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ecuRoot.isOpen = !ecuRoot.isOpen
                }
            }
        }

        // =============================================================
        // EXPANDABLE FULL ECU CONTROL BENCH
        // =============================================================
        ScrollView {
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            visible: ecuRoot.isOpen
            clip: true

            Column {
                width: parent.width
                spacing: 12

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 1. CLUSTER DISPLAY STATE
                // -----------------------------------------------------
                Text {
                    text: "CLUSTER STATE MODE"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    color: "#80A0C0"
                }

                Row {
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: [
                            { name: "1: Startup", state: 1 },
                            { name: "2: Check", state: 2 },
                            { name: "3: Drive", state: 3 },
                            { name: "4: Goodbye", state: 4 },
                            { name: "5: IGN OFF", state: 5 }
                        ]

                        Rectangle {
                            width: (parent.width - 16) / 5
                            height: 28
                            radius: 5
                            color: (typeof controller !== "undefined" && controller && controller.clusterState === modelData.state) ? (modelData.state === 5 ? "#40FF1744" : "#4000C8FF") : "#142030"
                            border.color: (typeof controller !== "undefined" && controller && controller.clusterState === modelData.state) ? (modelData.state === 5 ? "#FF1744" : "#00E5FF") : "#283848"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                font.pixelSize: 9
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.state === 5) {
                                        if (typeof controller !== "undefined" && controller) controller.setIgnitionOffDirect();
                                    } else {
                                        ecuRoot.changeState(modelData.state);
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 1.35 RANDOM SIMULATION (AUTONOMOUS AUTO-DRIVE)
                // -----------------------------------------------------
                Rectangle {
                    width: parent.width
                    height: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? 76 : 58
                    radius: 6
                    color: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "#142838" : "#121A24"
                    border.color: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "#00E5FF" : "#283848"
                    border.width: 1.2

                    Column {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        Item {
                            width: parent.width
                            height: 14

                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: "🎲 RANDOM SIMULATION (AUTO-DRIVE)"
                                font.pixelSize: 10
                                font.bold: true
                                color: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "#00E5FF" : "#80A0C0"
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "● ACTIVE" : "○ STOPPED"
                                font.pixelSize: 9
                                font.bold: true
                                color: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "#00E676" : "#607080"
                            }
                        }

                        // Start / Stop Toggle Button
                        Rectangle {
                            width: parent.width
                            height: 26
                            radius: 4
                            color: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "#40FF9100" : "#3000E5FF"
                            border.color: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "#FF9100" : "#00E5FF"

                            Text {
                                anchors.centerIn: parent
                                text: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "⏸ STOP AUTO-SIMULATION" : "▶ START RANDOM AUTO-DRIVE"
                                font.pixelSize: 9
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (typeof controller !== "undefined" && controller) controller.toggleRandomSimulation()
                            }
                        }

                        // Live Scenario Status Bar (Visible when driving)
                        Row {
                            width: parent.width
                            visible: (typeof controller !== "undefined" && controller && controller.isDemoDriving)
                            spacing: 4

                            Text {
                                text: "Phase:"
                                font.pixelSize: 8
                                font.bold: true
                                color: "#80A0C0"
                            }
                            Text {
                                text: (typeof controller !== "undefined" && controller) ? controller.demoScenario : ""
                                font.pixelSize: 8
                                font.bold: true
                                color: "#FFD54F"
                                elide: Text.ElideRight
                                width: parent.width - 45
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 1.4 STEERING WHEEL CLUSTER SWITCHES (OEM Non-Touch Controller)
                // -----------------------------------------------------
                Text {
                    text: "STEERING WHEEL CLUSTER BUTTONS"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    color: "#80A0C0"
                }

                // D-Pad Grid: INFO, UP, DOWN, OK, BACK
                Grid {
                    columns: 3
                    width: parent.width
                    spacing: 6

                    // Button 1: [ 📄 INFO ]
                    Rectangle {
                        width: (parent.width - 12) / 3
                        height: 32
                        radius: 5
                        color: (typeof controller !== "undefined" && controller && controller.showMenuTabs) ? "#4000E5FF" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.showMenuTabs) ? "#00E5FF" : "#283848"
                        border.width: 1.2

                        Text {
                            anchors.centerIn: parent
                            text: "📄 INFO [I]"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ecuRoot.btnInfoPressed()
                        }
                    }

                    // Button 2: [ ▲ UP ]
                    Rectangle {
                        width: (parent.width - 12) / 3
                        height: 32
                        radius: 5
                        color: "#182838"
                        border.color: "#305070"
                        border.width: 1.2

                        Text {
                            anchors.centerIn: parent
                            text: "▲ UP [↑]"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#00E5FF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ecuRoot.btnUpPressed()
                        }
                    }

                    // Button 3: [ ↩ BACK ]
                    Rectangle {
                        width: (parent.width - 12) / 3
                        height: 32
                        radius: 5
                        color: "#182838"
                        border.color: "#305070"
                        border.width: 1.2

                        Text {
                            anchors.centerIn: parent
                            text: "↩ BACK [Esc]"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#FFA726"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ecuRoot.btnBackPressed()
                        }
                    }

                    // Row 2 Left Placeholder
                    Item {
                        width: (parent.width - 12) / 3
                        height: 32
                    }

                    // Button 4: [ ▼ DOWN ]
                    Rectangle {
                        width: (parent.width - 12) / 3
                        height: 32
                        radius: 5
                        color: "#182838"
                        border.color: "#305070"
                        border.width: 1.2

                        Text {
                            anchors.centerIn: parent
                            text: "▼ DOWN [↓]"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#00E5FF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ecuRoot.btnDownPressed()
                        }
                    }

                    // Button 5: [ OK / ENTER ]
                    Rectangle {
                        width: (parent.width - 12) / 3
                        height: 32
                        radius: 5
                        color: "#0A3858"
                        border.color: "#00E5FF"
                        border.width: 1.2

                        Text {
                            anchors.centerIn: parent
                            text: "OK [Enter]"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ecuRoot.btnOkPressed()
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 1.5 TRIP COMPUTER PAGES (Drive info, Since refuel, Accum info)
                // -----------------------------------------------------
                Text {
                    text: "TRIP COMPUTER PAGE (PRESS [↓] / [↑])"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    color: "#80A0C0"
                }

                Row {
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: [
                            { name: "Current trip", page: 0 },
                            { name: "Since refuel", page: 1 },
                            { name: "Last reset", page: 2 }
                        ]

                        Rectangle {
                            width: (parent.width - 12) / 3
                            height: 28
                            radius: 5
                            color: (typeof controller !== "undefined" && controller && controller.tripPage === modelData.page) ? "#4000E5FF" : "#142030"
                            border.color: (typeof controller !== "undefined" && controller && controller.tripPage === modelData.page) ? "#00E5FF" : "#283848"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                font.pixelSize: 10
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (typeof controller !== "undefined" && controller) controller.setTripPage(modelData.page)
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 1.6 FULL TPMS 4-WHEEL PRESSURE CONTROL STATION
                // -----------------------------------------------------
                Row {
                    width: parent.width
                    Text {
                        text: "🛞 TPMS 4-WHEEL TYRE PRESSURE CONTROLS"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 0.8
                        color: "#80A0C0"
                    }
                }

                // Row 1: Calibration Toggle & Unit Switcher & Master Presets
                Row {
                    width: parent.width
                    spacing: 4

                    // Calibration Mode
                    Rectangle {
                        width: (parent.width - 12) * 0.38
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "#3000E5FF" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "#00E5FF" : "#283848"

                        Text {
                            anchors.centerIn: parent
                            text: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "🟢 CALIBRATED" : "⚪ DRIVE TO DISPLAY"
                            font.pixelSize: 8
                            font.bold: true
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.setTpmsCalibrated(!controller.tpmsCalibrated)
                        }
                    }

                    // All 35 PSI OK Preset
                    Rectangle {
                        width: (parent.width - 12) * 0.31
                        height: 26
                        radius: 4
                        color: "#18281E"
                        border.color: "#00E676"

                        Text {
                            anchors.centerIn: parent
                            text: "✅ ALL 35 PSI (OK)"
                            font.pixelSize: 8
                            font.bold: true
                            color: "#00E676"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTiresOK()
                        }
                    }

                    // All 24 PSI Low Preset
                    Rectangle {
                        width: (parent.width - 12) * 0.31
                        height: 26
                        radius: 4
                        color: "#281E18"
                        border.color: "#FF9100"

                        Text {
                            anchors.centerIn: parent
                            text: "⚠️ ALL 24 PSI (LOW)"
                            font.pixelSize: 8
                            font.bold: true
                            color: "#FF9100"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTiresLow()
                        }
                    }
                }

                // Row 2: TPMS Unit Selector (psi / kPa / bar)
                Row {
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "Unit:"
                        font.pixelSize: 9
                        font.bold: true
                        color: "#80A0C0"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Repeater {
                        model: ["psi", "kPa", "bar"]

                        Rectangle {
                            width: 48
                            height: 22
                            radius: 3
                            color: (typeof controller !== "undefined" && controller && controller.tpmsUnit === modelData) ? "#4000E5FF" : "#142030"
                            border.color: (typeof controller !== "undefined" && controller && controller.tpmsUnit === modelData) ? "#00E5FF" : "#283848"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 9
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (typeof controller !== "undefined" && controller) controller.setTpmsUnit(modelData)
                            }
                        }
                    }
                }

                // 2x2 Individual Wheel Controller Grid
                Grid {
                    columns: 2
                    width: parent.width
                    spacing: 6

                    // Helper Wheel Card Component
                    Repeater {
                        model: [
                            { id: "FL", label: "🛞 FRONT LEFT (FL)", getVal: function() { return controller ? controller.flPsi : 35 }, setVal: function(v) { if (controller) { controller.setFlPsi(v); controller.setTpmsCalibrated(true); } } },
                            { id: "FR", label: "🛞 FRONT RIGHT (FR)", getVal: function() { return controller ? controller.frPsi : 35 }, setVal: function(v) { if (controller) { controller.setFrPsi(v); controller.setTpmsCalibrated(true); } } },
                            { id: "RL", label: "🛞 REAR LEFT (RL)", getVal: function() { return controller ? controller.rlPsi : 35 }, setVal: function(v) { if (controller) { controller.setRlPsi(v); controller.setTpmsCalibrated(true); } } },
                            { id: "RR", label: "🛞 REAR RIGHT (RR)", getVal: function() { return controller ? controller.rrPsi : 31 }, setVal: function(v) { if (controller) { controller.setRrPsi(v); controller.setTpmsCalibrated(true); } } }
                        ]

                        Rectangle {
                            width: (parent.width - 6) / 2
                            height: 70
                            radius: 5
                            property real val: modelData.getVal()
                            property color statusColor: val < 26.0 ? "#FF5252" : (val < 32.0 ? "#FFD54F" : "#00E676")
                            color: "#162030"
                            border.color: statusColor
                            border.width: 1.2

                            Column {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 3

                                // Wheel Label & Current PSI
                                Item {
                                    width: parent.width
                                    height: 14
                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.label
                                        font.pixelSize: 8
                                        font.bold: true
                                        color: "#CCD8E8"
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Math.round(parent.parent.parent.val) + " psi"
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: parent.parent.parent.statusColor
                                    }
                                }

                                // Stepper Row: [-] [val] [+]
                                Row {
                                    width: parent.width
                                    spacing: 4

                                    Rectangle {
                                        width: 24; height: 18; radius: 3; color: "#223348"; border.color: "#384E68"
                                        Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 12; font.bold: true; color: "#FFFFFF" }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.setVal(Math.max(15, parent.parent.parent.parent.val - 1)) }
                                    }

                                    Rectangle {
                                        width: (parent.width - 56); height: 18; radius: 3; color: "#0E1622"
                                        Text {
                                            anchors.centerIn: parent
                                            text: {
                                                var v = parent.parent.parent.parent.val;
                                                var u = controller ? controller.tpmsUnit : "psi";
                                                if (u === "bar") return (v * 0.0689476).toFixed(1) + " bar";
                                                if (u === "kPa") return Math.round(v * 6.89476) + " kPa";
                                                return Math.round(v) + " psi";
                                            }
                                            font.pixelSize: 9
                                            font.bold: true
                                            color: parent.parent.parent.parent.statusColor
                                        }
                                    }

                                    Rectangle {
                                        width: 24; height: 18; radius: 3; color: "#223348"; border.color: "#384E68"
                                        Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 12; font.bold: true; color: "#FFFFFF" }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.setVal(Math.min(50, parent.parent.parent.parent.val + 1)) }
                                    }
                                }

                                // Quick presets: [Low 24] [Flat 16] [OK 35]
                                Row {
                                    width: parent.width
                                    spacing: 3

                                    Rectangle {
                                        width: (parent.width - 6) / 3; height: 16; radius: 2; color: "#30FFA000"; border.color: "#FFA000"
                                        Text { anchors.centerIn: parent; text: "Low 24"; font.pixelSize: 7; font.bold: true; color: "#FFD54F" }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.setVal(24) }
                                    }

                                    Rectangle {
                                        width: (parent.width - 6) / 3; height: 16; radius: 2; color: "#30FF1744"; border.color: "#FF1744"
                                        Text { anchors.centerIn: parent; text: "Flat 16"; font.pixelSize: 7; font.bold: true; color: "#FF8A80" }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.setVal(16) }
                                    }

                                    Rectangle {
                                        width: (parent.width - 6) / 3; height: 16; radius: 2; color: "#3000E676"; border.color: "#00E676"
                                        Text { anchors.centerIn: parent; text: "OK 35"; font.pixelSize: 7; font.bold: true; color: "#B9F6CA" }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.setVal(35) }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 1.8 INFOTAINMENT & MEDIA PLAYER CONTROLS (5s Pop-down Banner)
                // -----------------------------------------------------
                Text {
                    text: "🎵 INFOTAINMENT & MEDIA PLAYER (5s TFT POPUP)"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    color: "#80A0C0"
                }

                // Row 1: Source Selector (USB, Bluetooth, CarPlay, Android Auto, FM Radio)
                Row {
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: [
                            { id: "USB", label: "💾 USB" },
                            { id: "Bluetooth", label: "ᛒ Bluetooth" },
                            { id: "Apple CarPlay", label: "📱 CarPlay" },
                            { id: "Android Auto", label: "🤖 Android" },
                            { id: "FM Radio", label: "📻 FM Radio" }
                        ]

                        Rectangle {
                            width: (parent.width - 16) / 5
                            height: 24
                            radius: 3
                            color: (typeof controller !== "undefined" && controller && controller.mediaSource === modelData.id) ? "#4000E5FF" : "#142030"
                            border.color: (typeof controller !== "undefined" && controller && controller.mediaSource === modelData.id) ? "#00E5FF" : "#283848"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                font.pixelSize: 8
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (typeof controller !== "undefined" && controller) {
                                        controller.setMediaSource(modelData.id);
                                        controller.triggerMediaPopup();
                                    }
                                }
                            }
                        }
                    }
                }

                // Row 2: Transport Playback Controls
                Row {
                    width: parent.width
                    spacing: 4

                    // Prev Track
                    Rectangle {
                        width: (parent.width - 12) / 4
                        height: 26
                        radius: 4
                        color: "#182638"
                        border.color: "#304860"
                        Text { anchors.centerIn: parent; text: "⏮ Prev Track"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.prevMediaTrack() }
                    }

                    // Play/Pause
                    Rectangle {
                        width: (parent.width - 12) / 4
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.isMediaPlaying) ? "#3000E676" : "#281820"
                        border.color: (typeof controller !== "undefined" && controller && controller.isMediaPlaying) ? "#00E676" : "#FF5252"
                        Text {
                            anchors.centerIn: parent
                            text: (typeof controller !== "undefined" && controller && controller.isMediaPlaying) ? "⏸ Pause" : "▶ Play"
                            font.pixelSize: 8
                            font.bold: true
                            color: (typeof controller !== "undefined" && controller && controller.isMediaPlaying) ? "#00E676" : "#FF8A80"
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleMediaPlayback() }
                    }

                    // Next Track
                    Rectangle {
                        width: (parent.width - 12) / 4
                        height: 26
                        radius: 4
                        color: "#182638"
                        border.color: "#304860"
                        Text { anchors.centerIn: parent; text: "⏭ Next Track"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.nextMediaTrack() }
                    }

                    // Trigger 5s Popup
                    Rectangle {
                        width: (parent.width - 12) / 4
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.showMediaPopup) ? "#40FF9100" : "#223042"
                        border.color: (typeof controller !== "undefined" && controller && controller.showMediaPopup) ? "#FF9100" : "#406080"
                        Text { anchors.centerIn: parent; text: "🔔 5s Popup"; font.pixelSize: 8; font.bold: true; color: (typeof controller !== "undefined" && controller && controller.showMediaPopup) ? "#FFD54F" : "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerMediaPopup() }
                    }
                }

                // Row 3: Quick Demo Song Library (Click to play & pop down banner)
                Grid {
                    columns: 2
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: [
                            { src: "USB", artist: "Revoic", title: "Sunset Drive" },
                            { src: "Bluetooth", artist: "The Weeknd", title: "Blinding Lights (After Hours)" },
                            { src: "Apple CarPlay", artist: "Dua Lipa", title: "Levitating (Club Future Nostalgia)" },
                            { src: "Android Auto", artist: "A.R. Rahman", title: "Dil Se Re (Original Soundtrack)" },
                            { src: "Bluetooth", artist: "Arijit Singh", title: "Kesariya (Brahmastra Audio)" },
                            { src: "USB", artist: "Coldplay", title: "Viva La Vida" }
                        ]

                        Rectangle {
                            width: (parent.width - 4) / 2
                            height: 24
                            radius: 3
                            color: (typeof controller !== "undefined" && controller && controller.mediaTitle === modelData.title) ? "#3000E5FF" : "#142030"
                            border.color: (typeof controller !== "undefined" && controller && controller.mediaTitle === modelData.title) ? "#00E5FF" : "#283848"

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "🎵"; font.pixelSize: 8 }
                                Text {
                                    text: modelData.artist + " - " + modelData.title
                                    font.pixelSize: 8
                                    font.bold: true
                                    color: (typeof controller !== "undefined" && controller && controller.mediaTitle === modelData.title) ? "#00E5FF" : "#CCD8E8"
                                    elide: Text.ElideRight
                                    width: (parent.parent.width - 24)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (typeof controller !== "undefined" && controller) controller.playTrack(modelData.src, modelData.artist, modelData.title)
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 2. TRANSMISSION GEAR SELECTOR
                // -----------------------------------------------------
                Text {
                    text: "TRANSMISSION GEAR (AUTO 1-5 / MANUAL M₁-M₅)"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    color: "#80A0C0"
                }

                Grid {
                    columns: 5
                    width: parent.width
                    spacing: 5

                    Repeater {
                        model: ["P", "R", "N", "D", "1", "2", "3", "4", "5", "M1", "M2", "M3", "M4", "M5"]

                        Rectangle {
                            width: (parent.width - 20) / 5
                            height: 26
                            radius: 4
                            color: (typeof controller !== "undefined" && controller && controller.gear === modelData) ? "#5000C8FF" : "#142030"
                            border.color: (typeof controller !== "undefined" && controller && controller.gear === modelData) ? "#00E5FF" : "#283848"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 11
                                font.bold: true
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: ecuRoot.changeGear(modelData)
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 3. CRUISE CONTROL (STEERING WHEEL CONTROLS)
                // -----------------------------------------------------
                Row {
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "CRUISE CONTROL:"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 0.8
                        color: "#80A0C0"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: (typeof controller !== "undefined" && controller && controller.cruiseActive) ?
                              ("ACTIVE (" + controller.cruiseSetSpeed + " km/h)") :
                              ((typeof controller !== "undefined" && controller && controller.cruiseEnabled) ? "STANDBY" : "OFF")
                        font.pixelSize: 10
                        font.bold: true
                        color: (typeof controller !== "undefined" && controller && controller.cruiseActive) ?
                               "#00E676" :
                               ((typeof controller !== "undefined" && controller && controller.cruiseEnabled) ? "#FFFFFF" : "#607890")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Grid {
                    columns: 4
                    width: parent.width
                    spacing: 5

                    // 1. Cruise Main Button
                    Rectangle {
                        width: (parent.width - 15) / 4
                        height: 28
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.cruiseEnabled) ?
                               ((controller && controller.cruiseActive) ? "#3000E676" : "#30FFFFFF") : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.cruiseEnabled) ?
                                      ((controller && controller.cruiseActive) ? "#00E676" : "#FFFFFF") : "#283848"

                        Text {
                            anchors.centerIn: parent
                            text: "CRUISE"
                            font.pixelSize: 10
                            font.bold: true
                            color: (typeof controller !== "undefined" && controller && controller.cruiseEnabled) ?
                                   ((controller && controller.cruiseActive) ? "#00E676" : "#FFFFFF") : "#80A0C0"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.toggleCruise()
                        }
                    }

                    // 2. SET / - Button
                    Rectangle {
                        width: (parent.width - 15) / 4
                        height: 28
                        radius: 4
                        color: "#142030"
                        border.color: "#283848"

                        Text {
                            anchors.centerIn: parent
                            text: "SET / -"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseSetMinus()
                        }
                    }

                    // 3. RES / + Button
                    Rectangle {
                        width: (parent.width - 15) / 4
                        height: 28
                        radius: 4
                        color: "#142030"
                        border.color: "#283848"

                        Text {
                            anchors.centerIn: parent
                            text: "RES / +"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseResPlus()
                        }
                    }

                    // 4. CANCEL Button
                    Rectangle {
                        width: (parent.width - 15) / 4
                        height: 28
                        radius: 4
                        color: "#142030"
                        border.color: "#283848"

                        Text {
                            anchors.centerIn: parent
                            text: "CANCEL"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#FFA726"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseCancel()
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 4. VEHICLE DYNAMICS (Speed & RPM)
                // -----------------------------------------------------
                Row {
                    width: parent.width
                    Text { text: "SPEED: " + (typeof controller !== "undefined" && controller ? controller.speed : 0) + " km/h"; font.pixelSize: 11; font.bold: true; color: "#00E5FF" }
                }

                Slider {
                    width: parent.width
                    from: 0
                    to: 180
                    stepSize: 1
                    value: typeof controller !== "undefined" && controller ? controller.speed : 0
                    onMoved: ecuRoot.changeSpeed(Math.round(value))
                }

                Row {
                    width: parent.width
                    Text { text: "RPM: " + (typeof controller !== "undefined" && controller ? controller.rpm.toFixed(1) : "0.0") + " x1000"; font.pixelSize: 11; font.bold: true; color: "#00E5FF" }
                }

                Slider {
                    width: parent.width
                    from: 0.0
                    to: 7.0
                    stepSize: 0.1
                    value: typeof controller !== "undefined" && controller ? controller.rpm : 0.0
                    onMoved: ecuRoot.changeRpm(value)
                }

                Row {
                    width: parent.width
                    Text { text: "INSTANT ECO: " + (typeof controller !== "undefined" && controller ? controller.instantEconomy.toFixed(1) : "26.1") + " km/L"; font.pixelSize: 11; font.bold: true; color: "#00E5FF" }
                }

                Slider {
                    width: parent.width
                    from: 0.0
                    to: 30.0
                    stepSize: 0.5
                    value: typeof controller !== "undefined" && controller ? controller.instantEconomy : 26.1
                    onMoved: if (typeof controller !== "undefined" && controller) controller.setInstantEconomy(value)
                }

                // Demo Drive Auto Button
                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "#3000E676" : "#2000E5FF"
                    border.color: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "#00E676" : "#00E5FF"
                    border.width: 1.2

                    Text {
                        anchors.centerIn: parent
                        text: (typeof controller !== "undefined" && controller && controller.isDemoDriving) ? "⏹ STOP DEMO DRIVE [A]" : "▶ START DEMO DRIVE [A]"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ecuRoot.toggleDemo()
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 4. TELLTALE WARNING FAULT INJECTORS (ON / OFF)
                // -----------------------------------------------------
                Item {
                    width: parent.width
                    height: 22

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "TELLTALE CONTROLS (ON / OFF)"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 0.8
                        color: "#80A0C0"
                    }

                    // Master All ON / All OFF buttons
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Rectangle {
                            width: 58
                            height: 20
                            radius: 3
                            color: "#183024"
                            border.color: "#00E676"
                            Text { anchors.centerIn: parent; text: "ALL ON"; font.pixelSize: 8; font.bold: true; color: "#00E676" }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTelltales(true)
                            }
                        }

                        Rectangle {
                            width: 58
                            height: 20
                            radius: 3
                            color: "#281820"
                            border.color: "#FF5252"
                            Text { anchors.centerIn: parent; text: "ALL OFF"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTelltales(false)
                            }
                        }
                    }
                }

                // -----------------------------------------------------
                // OEM LIGHT STALK SWITCH (OFF, AUTO, POSITION, HEADLIGHT)
                // -----------------------------------------------------
                Text { text: "OEM LIGHT STALK SWITCH (POPUPS ON CLUSTER)"; font.pixelSize: 9; font.bold: true; color: "#00E5FF" }

                Grid {
                    columns: 4
                    width: parent.width
                    spacing: 4

                    // OFF
                    Rectangle {
                        width: (parent.width - 12) / 4; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.lightMode === 0) ? "#4000E5FF" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.lightMode === 0) ? "#00E5FF" : "#283848"
                        Text { anchors.centerIn: parent; text: "OFF"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLightMode(0) }
                    }

                    // AUTO
                    Rectangle {
                        width: (parent.width - 12) / 4; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.lightMode === 1) ? "#4000E5FF" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.lightMode === 1) ? "#00E5FF" : "#283848"
                        Text { anchors.centerIn: parent; text: "AUTO"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLightMode(1) }
                    }

                    // POSITION LAMP
                    Rectangle {
                        width: (parent.width - 12) / 4; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.lightMode === 2) ? "#4000E676" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.lightMode === 2) ? "#00E676" : "#283848"
                        Text { anchors.centerIn: parent; text: "POSITION"; font.pixelSize: 9; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLightMode(2) }
                    }

                    // HEADLIGHT (LOW BEAM)
                    Rectangle {
                        width: (parent.width - 12) / 4; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.lightMode === 3) ? "#4000E676" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.lightMode === 3) ? "#00E676" : "#283848"
                        Text { anchors.centerIn: parent; text: "HEADLIGHT"; font.pixelSize: 9; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLightMode(3) }
                    }
                }

                // Group 1: Lighting & Indicators
                Text { text: "1. LIGHTING & INDICATORS (DIRECT OVERRIDE)"; font.pixelSize: 9; font.bold: true; color: "#80A0C0" }

                Grid {
                    columns: 3
                    width: parent.width
                    spacing: 5

                    // Turn Left
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.leftIndicator) ? "#4000E676" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.leftIndicator) ? "#00E676" : "#283848"
                        Text { anchors.centerIn: parent; text: "⬅ Turn Left"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLeftIndicator(!controller.leftIndicator) }
                    }

                    // Turn Right
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.rightIndicator) ? "#4000E676" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.rightIndicator) ? "#00E676" : "#283848"
                        Text { anchors.centerIn: parent; text: "Turn Right ➡"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setRightIndicator(!controller.rightIndicator) }
                    }

                    // High Beam
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.highBeam) ? "#4000B0FF" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.highBeam) ? "#00B0FF" : "#283848"
                        Text { anchors.centerIn: parent; text: "High Beam"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setHighBeam(!controller.highBeam) }
                    }

                    // Low Beam
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.lowBeam) ? "#4000E676" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.lowBeam) ? "#00E676" : "#283848"
                        Text { anchors.centerIn: parent; text: "Low Beam"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLowBeam(!controller.lowBeam) }
                    }

                    // Lamp ON / Position Lamp
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.positionLamp) ? "#4000E676" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.positionLamp) ? "#00E676" : "#283848"
                        Text { anchors.centerIn: parent; text: "Lamp ON"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setPositionLamp(!controller.positionLamp) }
                    }

                    // Master Warning (Bottom Line)
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.lightWarning) ? "#40FFA000" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.lightWarning) ? "#FFA000" : "#283848"
                        Text { anchors.centerIn: parent; text: "Master Warn"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLightWarning(!controller.lightWarning) }
                    }
                }

                // -----------------------------------------------------
                // REAR OCCUPANT SEATBELT SIMULATOR (10s Chime & Blink Alert)
                // -----------------------------------------------------
                Row {
                    width: parent.width
                    spacing: 4
                    Text { text: "REAR SEATBELTS:"; font.pixelSize: 9; font.bold: true; color: "#00E5FF"; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: (typeof controller !== "undefined" && controller && controller.rearAlarmActive) ? "⚠️ 10s ALARM ACTIVE" : "NORMAL"
                        font.pixelSize: 9; font.bold: true
                        color: (typeof controller !== "undefined" && controller && controller.rearAlarmActive) ? "#FF1744" : "#608098"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Grid {
                    columns: 3
                    width: parent.width
                    spacing: 5

                    // Rear Left
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && !controller.rearLeftBuckled) ? "#40FF1744" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && !controller.rearLeftBuckled) ? "#FF1744" : "#283848"
                        Text {
                            anchors.centerIn: parent
                            text: (typeof controller !== "undefined" && controller && !controller.rearLeftBuckled) ? "🔴 Rear Left" : "🟢 Rear Left"
                            font.pixelSize: 9; font.bold: true; color: "#FFFFFF"
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.setRearLeftBuckled(!controller.rearLeftBuckled)
                        }
                    }

                    // Rear Center
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && !controller.rearCenterBuckled) ? "#40FF1744" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && !controller.rearCenterBuckled) ? "#FF1744" : "#283848"
                        Text {
                            anchors.centerIn: parent
                            text: (typeof controller !== "undefined" && controller && !controller.rearCenterBuckled) ? "🔴 Rear Center" : "🟢 Rear Center"
                            font.pixelSize: 9; font.bold: true; color: "#FFFFFF"
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.setRearCenterBuckled(!controller.rearCenterBuckled)
                        }
                    }

                    // Rear Right
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && !controller.rearRightBuckled) ? "#40FF1744" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && !controller.rearRightBuckled) ? "#FF1744" : "#283848"
                        Text {
                            anchors.centerIn: parent
                            text: (typeof controller !== "undefined" && controller && !controller.rearRightBuckled) ? "🔴 Rear Right" : "🟢 Rear Right"
                            font.pixelSize: 9; font.bold: true; color: "#FFFFFF"
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.setRearRightBuckled(!controller.rearRightBuckled)
                        }
                    }
                }

                // Group 2: Safety & Warnings
                Text { text: "2. WARNINGS & SAFETY"; font.pixelSize: 9; font.bold: true; color: "#FF5252" }

                Grid {
                    columns: 3
                    width: parent.width
                    spacing: 5

                    // Bulb Fault (Far Left)
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.masterWarning) ? "#40FFA000" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.masterWarning) ? "#FFA000" : "#283848"
                        Text { anchors.centerIn: parent; text: "Bulb Fault"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setMasterWarning(!controller.masterWarning) }
                    }

                    // Brake
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.parkBrakeActive) ? "#40FF3D57" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.parkBrakeActive) ? "#FF3D57" : "#283848"
                        Text { anchors.centerIn: parent; text: "Brake [B]"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setParkBrakeActive(!controller.parkBrakeActive) }
                    }

                    // ABS
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.absActive) ? "#40FFA000" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.absActive) ? "#FFA000" : "#283848"
                        Text { anchors.centerIn: parent; text: "ABS"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setAbsActive(!controller.absActive) }
                    }

                    // Seatbelt
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.seatbeltActive) ? "#40FF3D57" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.seatbeltActive) ? "#FF3D57" : "#283848"
                        Text { anchors.centerIn: parent; text: "Seatbelt"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setSeatbeltActive(!controller.seatbeltActive) }
                    }

                    // Smart Key
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.smartKeyActive) ? "#40FFA000" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.smartKeyActive) ? "#FFA000" : "#283848"
                        Text { anchors.centerIn: parent; text: "Smart Key"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setSmartKeyActive(!controller.smartKeyActive) }
                    }

                    // Steering EPS
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.steeringActive) ? "#40FF3D57" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.steeringActive) ? "#FF3D57" : "#283848"
                        Text { anchors.centerIn: parent; text: "Steering EPS"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setSteeringActive(!controller.steeringActive) }
                    }

                    // Battery
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.batteryActive) ? "#40FF3D57" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.batteryActive) ? "#FF3D57" : "#283848"
                        Text { anchors.centerIn: parent; text: "Battery"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setBatteryActive(!controller.batteryActive) }
                    }

                    // Airbag
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.airbagActive) ? "#40FF3D57" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.airbagActive) ? "#FF3D57" : "#283848"
                        Text { anchors.centerIn: parent; text: "Airbag"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setAirbagActive(!controller.airbagActive) }
                    }

                    // Oil Pressure
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.oilActive) ? "#40FF3D57" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.oilActive) ? "#FF3D57" : "#283848"
                        Text { anchors.centerIn: parent; text: "Oil Pressure"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setOilActive(!controller.oilActive) }
                    }

                    // ESC Active
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.escActive) ? "#40FFA000" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.escActive) ? "#FFA000" : "#283848"
                        Text { anchors.centerIn: parent; text: "ESC Active"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setEscActive(!controller.escActive) }
                    }

                    // ESC OFF
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.escOffActive) ? "#40FFA000" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.escOffActive) ? "#FFA000" : "#283848"
                        Text { anchors.centerIn: parent; text: "ESC OFF"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setEscOffActive(!controller.escOffActive) }
                    }

                    // Check Engine / MIL
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.checkEngineActive) ? "#40FFA000" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.checkEngineActive) ? "#FFA000" : "#283848"
                        Text { anchors.centerIn: parent; text: "Check Engine"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setCheckEngineActive(!controller.checkEngineActive) }
                    }

                    // TPMS Fault
                    Rectangle {
                        width: (parent.width - 10) / 3; height: 26; radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.tpmsActive) ? "#40FFA000" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.tpmsActive) ? "#FFA000" : "#283848"
                        Text { anchors.centerIn: parent; text: "TPMS Fault"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setTpmsActive(!controller.tpmsActive) }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#203040" }

                // -----------------------------------------------------
                // 5. HYUNDAI MANUAL ADVANCED FEATURES & POPUP ALERTS
                // -----------------------------------------------------
                Text {
                    text: "HYUNDAI MANUAL ADVANCED FEATURES & ALERTS"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    color: "#00E5FF"
                }

                // Ignition OFF & Power Controls
                Row {
                    width: parent.width
                    spacing: 6

                    Rectangle {
                        width: (parent.width - 6) / 2
                        height: 30
                        radius: 4
                        color: "#1A2536"
                        border.color: "#00E5FF"
                        Text { anchors.centerIn: parent; text: "RESTART CLUSTER"; font.pixelSize: 9; font.bold: true; color: "#00E5FF" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerStartupSequence() }
                    }

                    Rectangle {
                        width: (parent.width - 6) / 2
                        height: 30
                        radius: 4
                        color: "#301520"
                        border.color: "#FF4081"
                        Text { anchors.centerIn: parent; text: "IGNITION OFF / GOODBYE"; font.pixelSize: 9; font.bold: true; color: "#FF4081" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerShutdown() }
                    }
                }

                // Press START / Clutch Pedal Prompts
                Text { text: "START & PEDAL PROMPTS (WHITE LINES)"; font.pixelSize: 9; font.bold: true; color: "#80A0C0" }

                Grid {
                    columns: 2
                    width: parent.width
                    spacing: 4

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && (controller.startPedalPrompt === 1 || controller.pressStartAgainAlert)) ? "#3000E5FF" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && (controller.startPedalPrompt === 1 || controller.pressStartAgainAlert)) ? "#00E5FF" : "#304560"
                        Text { anchors.centerIn: parent; text: "🔘 Press START Again"; font.pixelSize: 9; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showStartPedalAlert(1) }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.startPedalPrompt === 2) ? "#3000E5FF" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.startPedalPrompt === 2) ? "#00E5FF" : "#304560"
                        Text { anchors.centerIn: parent; text: "🦶 Press Clutch Pedal"; font.pixelSize: 9; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showStartPedalAlert(2) }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.startPedalPrompt === 3) ? "#3000E5FF" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.startPedalPrompt === 3) ? "#00E5FF" : "#304560"
                        Text { anchors.centerIn: parent; text: "🛑 Press Brake Pedal"; font.pixelSize: 9; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showStartPedalAlert(3) }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: "#281820"; border.color: "#FF5252"
                        Text { anchors.centerIn: parent; text: "❌ Clear Pedal Alert"; font.pixelSize: 9; color: "#FF5252" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showStartPedalAlert(0) }
                    }
                }

                // Speed Alert Toggle
                Row {
                    width: parent.width
                    spacing: 6

                    Rectangle {
                        width: parent.width
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.reduceSpeedAlert) ? "#40FF9E1B" : "#1A2230"
                        border.color: "#FF9E1B"
                        Text { anchors.centerIn: parent; text: "⚠️ SPEED ALERT (80/120)"; font.pixelSize: 9; font.bold: true; color: "#FF9E1B" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerReduceSpeedAlert() }
                    }
                }

                // Individual 4-Door Controls
                Text { text: "DOORS CONTROL (TOP-VIEW SPRITES)"; font.pixelSize: 9; font.bold: true; color: "#80A0C0" }

                Grid {
                    columns: 2
                    width: parent.width
                    spacing: 4

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.doorFrontRight) ? "#40FF5252" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.doorFrontRight) ? "#FF5252" : "#304560"
                        Text { anchors.centerIn: parent; text: "🚗 DRIVER (FR)"; font.pixelSize: 8; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleDoorFR() }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.doorFrontLeft) ? "#40FF5252" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.doorFrontLeft) ? "#FF5252" : "#304560"
                        Text { anchors.centerIn: parent; text: "👤 PASSENGER (FL)"; font.pixelSize: 8; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleDoorFL() }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.doorRearRight) ? "#40FF5252" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.doorRearRight) ? "#FF5252" : "#304560"
                        Text { anchors.centerIn: parent; text: "🚗 REAR RIGHT (RR)"; font.pixelSize: 8; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleDoorRR() }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.doorRearLeft) ? "#40FF5252" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.doorRearLeft) ? "#FF5252" : "#304560"
                        Text { anchors.centerIn: parent; text: "👤 REAR LEFT (RL)"; font.pixelSize: 8; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleDoorRL() }
                    }
                }

                // Quick Combos (Left Side / Right Side / All Doors)
                Row {
                    width: parent.width
                    spacing: 4

                    Rectangle {
                        width: (parent.width - 8) / 3; height: 24; radius: 3
                        color: "#1A2536"; border.color: "#304560"
                        Text { anchors.centerIn: parent; text: "🚪 Left Both"; font.pixelSize: 8; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleLeftDoors() }
                    }

                    Rectangle {
                        width: (parent.width - 8) / 3; height: 24; radius: 3
                        color: "#1A2536"; border.color: "#304560"
                        Text { anchors.centerIn: parent; text: "🚪 Right Both"; font.pixelSize: 8; color: "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleRightDoors() }
                    }
                }

                // Bonnet & Trunk Controls
                Row {
                    width: parent.width
                    spacing: 4

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.bonnetOpen) ? "#40FF2020" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.bonnetOpen) ? "#FF2020" : "#304560"
                        Text { anchors.centerIn: parent; text: "🚘 BONNET (HOOD)"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleBonnet() }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.trunkOpen) ? "#40FF2020" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.trunkOpen) ? "#FF2020" : "#304560"
                        Text { anchors.centerIn: parent; text: "🧳 TRUNK (BOOT)"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleTrunk() }
                    }
                }

                // Sunroof & ISG Toggles
                Row {
                    width: parent.width
                    spacing: 6

                    Rectangle {
                        width: (parent.width - 6) / 2
                        height: 28
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.sunroofOpen) ? "#40FF9100" : "#1A2230"
                        border.color: (typeof controller !== "undefined" && controller && controller.sunroofOpen) ? "#FF9100" : "#304050"
                        Text { anchors.centerIn: parent; text: "☀️ SUNROOF OPEN"; font.pixelSize: 9; font.bold: true; color: "#FF9100" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setSunroofOpen(!controller.sunroofOpen) }
                    }

                    Rectangle {
                        width: (parent.width - 6) / 2
                        height: 28
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.isgActive) ? "#4000E676" : "#1A2230"
                        border.color: (typeof controller !== "undefined" && controller && controller.isgActive) ? "#00E676" : "#304050"
                        Text { anchors.centerIn: parent; text: "🟢 ISG / AUTO STOP"; font.pixelSize: 9; font.bold: true; color: "#00E676" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleIsg() }
                    }
                }

                // -----------------------------------------------------
                // SMART KEY SYSTEM ALERTS
                // -----------------------------------------------------
                Text { text: "🔑 SMART KEY SYSTEM ALERTS"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 0.8; color: "#80A0C0" }

                Grid {
                    columns: 2
                    width: parent.width
                    spacing: 4

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 1) ? "#40FFA000" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 1) ? "#FFA000" : "#304560"
                        Text { anchors.centerIn: parent; text: "🔑 Key Not In Vehicle"; font.pixelSize: 8; font.bold: true; color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 1) ? "#FFD54F" : "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showSmartKeyAlert(controller.smartKeyPrompt === 1 ? 0 : 1) }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 2) ? "#40FFA000" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 2) ? "#FFA000" : "#304560"
                        Text { anchors.centerIn: parent; text: "🔍 Key Not Detected"; font.pixelSize: 8; font.bold: true; color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 2) ? "#FFD54F" : "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showSmartKeyAlert(controller.smartKeyPrompt === 2 ? 0 : 2) }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 3) ? "#40FFA000" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 3) ? "#FFA000" : "#304560"
                        Text { anchors.centerIn: parent; text: "🪫 Low Key Battery"; font.pixelSize: 8; font.bold: true; color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 3) ? "#FFD54F" : "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showSmartKeyAlert(controller.smartKeyPrompt === 3 ? 0 : 3) }
                    }

                    Rectangle {
                        width: (parent.width - 4) / 2; height: 26; radius: 3
                        color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 4) ? "#40FFA000" : "#1A2536"
                        border.color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 4) ? "#FFA000" : "#304560"
                        Text { anchors.centerIn: parent; text: "🔘 Press START w/ Key"; font.pixelSize: 8; font.bold: true; color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 4) ? "#FFD54F" : "#CCD8E8" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showSmartKeyAlert(controller.smartKeyPrompt === 4 ? 0 : 4) }
                    }
                }

                // Clear Alert Button
                Rectangle {
                    width: parent.width
                    height: 24
                    radius: 3
                    color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt > 0) ? "#40FF5252" : "#1A2230"
                    border.color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt > 0) ? "#FF5252" : "#304050"
                    Text { anchors.centerIn: parent; text: "❌ Clear Smart Key Alert"; font.pixelSize: 9; font.bold: true; color: "#FF5252" }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showSmartKeyAlert(0) }
                }
            }
        }
    }
}
