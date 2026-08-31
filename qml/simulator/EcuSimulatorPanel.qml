import QtQuick
import QtQuick.Controls

Item {
    id: ecuRoot
    property bool isOpen: false

    signal btnUpPressed()
    signal btnDownPressed()
    signal btnOkPressed()
    signal btnBackPressed()
    signal btnInfoPressed()

    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.top: parent.top
    anchors.topMargin: 12
    width: isOpen ? 360 : 340
    height: isOpen ? Math.min(parent.height - 24, 580) : 42
    z: 99999

    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }

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
                    spacing: 6

                    Repeater {
                        model: [
                            { name: "1: Dark/ODO", state: 1 },
                            { name: "2: Check View", state: 2 },
                            { name: "3: Drive Trip", state: 3 }
                        ]

                        Rectangle {
                            width: (parent.width - 12) / 3
                            height: 28
                            radius: 5
                            color: (typeof controller !== "undefined" && controller && controller.clusterState === modelData.state) ? "#4000C8FF" : "#142030"
                            border.color: (typeof controller !== "undefined" && controller && controller.clusterState === modelData.state) ? "#00E5FF" : "#283848"

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
                                onClicked: ecuRoot.changeState(modelData.state)
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
                // 1.6 TPMS TYRE PRESSURE CONTROLS
                // -----------------------------------------------------
                Text {
                    text: "TPMS TYRE PRESSURE (PSI)"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    color: "#80A0C0"
                }

                Row {
                    width: parent.width
                    spacing: 6

                    Rectangle {
                        width: (parent.width - 6) / 2
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "#3000E5FF" : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "#00E5FF" : "#283848"

                        Text {
                            anchors.centerIn: parent
                            text: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "CALIBRATED (ACTIVE)" : "DRIVE TO DISPLAY"
                            font.pixelSize: 9
                            font.bold: true
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (typeof controller !== "undefined" && controller) controller.setTpmsCalibrated(!controller.tpmsCalibrated)
                        }
                    }

                    Rectangle {
                        width: (parent.width - 6) / 2
                        height: 26
                        radius: 4
                        color: "#142030"
                        border.color: "#283848"

                        Text {
                            anchors.centerIn: parent
                            text: "TEST LOW RR (31 PSI)"
                            font.pixelSize: 9
                            font.bold: true
                            color: "#FFD54F"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (typeof controller !== "undefined" && controller) {
                                    controller.setRrPsi(controller.rrPsi === 31 ? 35 : 31);
                                    controller.setTpmsCalibrated(true);
                                }
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
                // 3. VEHICLE DYNAMICS (Speed & RPM)
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
                // 4. TELLTALE WARNING FAULT INJECTORS
                // -----------------------------------------------------
                Text {
                    text: "TELLTALE FAULT INJECTORS"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    color: "#80A0C0"
                }

                Grid {
                    columns: 3
                    width: parent.width
                    spacing: 5

                    // Smart Key
                    Rectangle {
                        width: (parent.width - 10) / 3
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && !controller.parkBrakeActive) ? "#142030" : "#40FFA000"
                        border.color: "#FFA000"
                        Text { anchors.centerIn: parent; text: "Key"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                    }

                    // TPMS
                    Rectangle {
                        width: (parent.width - 10) / 3
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.tpmsActive) ? "#40FFA000" : "#142030"
                        border.color: "#FFA000"
                        Text { anchors.centerIn: parent; text: "TPMS"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; onClicked: if (typeof controller !== "undefined" && controller) controller.setTpmsActive(!controller.tpmsActive) }
                    }

                    // Seatbelt
                    Rectangle {
                        width: (parent.width - 10) / 3
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.seatbeltActive) ? "#40FF3D57" : "#142030"
                        border.color: "#FF3D57"
                        Text { anchors.centerIn: parent; text: "Seatbelt"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; onClicked: if (typeof controller !== "undefined" && controller) controller.setSeatbeltActive(!controller.seatbeltActive) }
                    }

                    // Brake
                    Rectangle {
                        width: (parent.width - 10) / 3
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.parkBrakeActive) ? "#40FF3D57" : "#142030"
                        border.color: "#FF3D57"
                        Text { anchors.centerIn: parent; text: "Brake [B]"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; onClicked: if (typeof controller !== "undefined" && controller) controller.setParkBrakeActive(!controller.parkBrakeActive) }
                    }

                    // ABS
                    Rectangle {
                        width: (parent.width - 10) / 3
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.absActive) ? "#40FFA000" : "#142030"
                        border.color: "#FFA000"
                        Text { anchors.centerIn: parent; text: "ABS"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; onClicked: if (typeof controller !== "undefined" && controller) controller.setAbsActive(!controller.absActive) }
                    }

                    // Check Engine
                    Rectangle {
                        width: (parent.width - 10) / 3
                        height: 26
                        radius: 4
                        color: (typeof controller !== "undefined" && controller && controller.checkEngineActive) ? "#40FFA000" : "#142030"
                        border.color: "#FFA000"
                        Text { anchors.centerIn: parent; text: "Engine"; font.pixelSize: 10; font.bold: true; color: "#FFFFFF" }
                        MouseArea { anchors.fill: parent; onClicked: if (typeof controller !== "undefined" && controller) controller.setCheckEngineActive(!controller.checkEngineActive) }
                    }
                }
            }
        }
    }
}
