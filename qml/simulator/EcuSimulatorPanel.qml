/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           EcuSimulatorPanel.qml
 * Author:         SK Rehan Ahamed
 * Description:    High-Density Dynamic ECU Telemetry Diagnostic Test Bench
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick
import QtQuick.Controls

Item {
    id: ecuRoot
    property bool isOpen: true
    property int activeTab: 0 // 0=All, 1=Powertrain, 2=Steering/Trip, 3=TPMS/Body, 4=Lighting, 5=Safety, 6=Infotainment

    signal btnUpPressed()
    signal btnDownPressed()
    signal btnOkPressed()
    signal btnBackPressed()
    signal btnInfoPressed()

    function changeTheme(col) {
        if (typeof controller !== "undefined" && controller) controller.setThemeColor(col);
    }
    function changeState(st) {
        if (typeof controller !== "undefined" && controller) controller.setClusterState(st);
    }
    function changeGear(g) {
        if (typeof controller !== "undefined" && controller) controller.setGear(g);
    }
    function changeSpeed(spd) {
        if (typeof controller !== "undefined" && controller) controller.setSpeed(spd);
    }
    function changeRpm(r) {
        if (typeof controller !== "undefined" && controller) controller.setRpm(r);
    }

    // Main Card Background
    Rectangle {
        id: bgCard
        anchors.fill: parent
        color: "#070D16"
        border.color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#2500E676" : ((typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#25FF5252" : "#2500E5FF")
        border.width: 1
        clip: true

        // Top Accent Laser Line
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.2; color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#00E676" : ((typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#FF5252" : "#00E5FF") }
                GradientStop { position: 0.8; color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#00E676" : ((typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#FF5252" : "#00E5FF") }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // =============================================================
        // 1. TOP MASTER TOOLBAR (Theme, Ignition, Master Shortcuts)
        // =============================================================
        Rectangle {
            id: masterHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 36
            color: "#0A1320"
            border.color: "#162232"
            border.width: 1

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Live Pulse Status LED
                Rectangle {
                    width: 7; height: 7; radius: 3.5
                    anchors.verticalCenter: parent.verticalCenter
                    color: (typeof controller !== "undefined" && controller && controller.clusterState !== 5 && controller.clusterState !== 4) ? "#00E676" : "#FF3D57"
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                    }
                }

                Text {
                    text: "ECU TESTBENCH"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1.0
                    color: "#7E9AB8"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Theme Presets
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Repeater {
                        model: [
                            { name: "CYAN", col: "blue", hex: "#00E5FF" },
                            { name: "EMERALD", col: "green", hex: "#00E676" },
                            { name: "CRIMSON", col: "red", hex: "#FF5252" }
                        ]
                        Rectangle {
                            width: 50; height: 20; radius: 3
                            property bool isActive: typeof controller !== "undefined" && controller && controller.themeColor === modelData.col
                            color: isActive ? "#28" + modelData.hex.substring(1) : "#101A26"
                            border.color: isActive ? modelData.hex : "#203042"
                            border.width: isActive ? 1.2 : 1
                            scale: thmMouse.pressed ? 0.96 : 1.0
                            Behavior on scale { NumberAnimation { duration: 80 } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                Rectangle { width: 4; height: 4; radius: 2; color: modelData.hex }
                                Text { text: modelData.name; font.pixelSize: 8; font.bold: true; color: parent.parent.isActive ? "#FFFFFF" : "#7E9AB8" }
                            }
                            MouseArea {
                                id: thmMouse
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: ecuRoot.changeTheme(modelData.col)
                            }
                        }
                    }
                }

                // Ignition Main Toggle
                Rectangle {
                    width: 78; height: 20; radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    property bool isIgnOn: (typeof controller !== "undefined" && controller && controller.clusterState !== 5 && controller.clusterState !== 4)
                    color: isIgnOn ? "#2800E676" : "#28FF1744"
                    border.color: isIgnOn ? "#00E676" : "#FF1744"
                    scale: ignMouse.pressed ? 0.96 : 1.0
                    Behavior on scale { NumberAnimation { duration: 80 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        Rectangle { width: 5; height: 5; radius: 2.5; color: parent.parent.isIgnOn ? "#00E676" : "#FF1744" }
                        Text {
                            text: parent.parent.isIgnOn ? "PWR: ON" : "PWR: OFF"
                            font.pixelSize: 8; font.bold: true; color: "#FFFFFF"
                        }
                    }
                    MouseArea {
                        id: ignMouse
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof controller !== "undefined" && controller) {
                                if (parent.isIgnOn) controller.setIgnitionOffDirect();
                                else controller.setIgnitionOnDirect();
                            }
                        }
                    }
                }
            }

            // Quick Shortcut Actions
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Rectangle {
                    width: 54; height: 20; radius: 3
                    color: "#12241A"; border.color: "#00E676"
                    scale: allOnMouse.pressed ? 0.96 : 1.0
                    Text { anchors.centerIn: parent; text: "ALL TELL"; font.pixelSize: 8; font.bold: true; color: "#00E676" }
                    MouseArea { id: allOnMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTelltales(true) }
                }

                Rectangle {
                    width: 54; height: 20; radius: 3
                    color: "#24141A"; border.color: "#FF5252"
                    scale: allOffMouse.pressed ? 0.96 : 1.0
                    Text { anchors.centerIn: parent; text: "CLEAR ALL"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                    MouseArea { id: allOffMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTelltales(false) }
                }

                Rectangle {
                    width: 62; height: 20; radius: 3
                    color: "#101E2E"; border.color: "#00E5FF"
                    scale: restartMouse.pressed ? 0.96 : 1.0
                    Text { anchors.centerIn: parent; text: "BOOT RESET"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                    MouseArea { id: restartMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerStartupSequence() }
                }
            }
        }

        // =============================================================
        // 2. SUBSYSTEM CATEGORY TABS (Compact Space-Saving Filter)
        // =============================================================
        Rectangle {
            id: tabBar
            anchors.top: masterHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 28
            color: "#08101A"
            border.color: "#142030"
            border.width: 1

            ListView {
                id: tabListView
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                orientation: ListView.Horizontal
                spacing: 3
                boundsBehavior: Flickable.StopAtBounds

                model: [
                    { id: 0, tag: "ALL", name: "Overview" },
                    { id: 1, tag: "SYS-01", name: "Powertrain" },
                    { id: 2, tag: "SYS-02", name: "Transmission" },
                    { id: 3, tag: "SYS-03", name: "Steering/Trip" },
                    { id: 4, tag: "SYS-04", name: "Chassis/TPMS" },
                    { id: 5, tag: "SYS-05", name: "Doors/Body" },
                    { id: 6, tag: "SYS-06", name: "Safety/Belts" },
                    { id: 7, tag: "SYS-07", name: "Infotainment" }
                ]

                delegate: Rectangle {
                    height: 20
                    width: tabLabelRow.implicitWidth + 14
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 3
                    property bool isSelected: ecuRoot.activeTab === modelData.id
                    color: isSelected ? "#3000E5FF" : (tabM.containsMouse ? "#142232" : "#0D1622")
                    border.color: isSelected ? "#00E5FF" : "#1E2E40"
                    border.width: isSelected ? 1.2 : 1
                    scale: tabM.pressed ? 0.96 : 1.0

                    Row {
                        id: tabLabelRow
                        anchors.centerIn: parent
                        spacing: 4
                        Rectangle {
                            width: 3; height: 3; radius: 1.5
                            color: parent.parent.isSelected ? "#00E5FF" : "#5A7288"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: modelData.tag
                            font.pixelSize: 8
                            font.bold: true
                            color: parent.parent.isSelected ? "#00E5FF" : "#5A7288"
                        }
                        Text {
                            text: modelData.name
                            font.pixelSize: 8
                            font.bold: parent.parent.isSelected
                            color: parent.parent.isSelected ? "#FFFFFF" : "#8AA2B8"
                        }
                    }

                    MouseArea {
                        id: tabM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ecuRoot.activeTab = modelData.id
                    }
                }
            }
        }

        // =============================================================
        // 3. COMPACT DYNAMIC MODULES SCROLL AREA
        // =============================================================
        ScrollView {
            id: mainScroll
            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 6
            clip: true

            Flow {
                id: modulesFlow
                width: mainScroll.width - 10
                spacing: 6

                readonly property int gridCols: width > 980 ? 3 : (width > 640 ? 2 : 1)
                readonly property real cardWidth: (width - (gridCols - 1) * spacing) / gridCols

                // -----------------------------------------------------
                // CARD 1: POWERTRAIN & IGNITION (SYS-01)
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 1
                    width: modulesFlow.cardWidth; height: 215; radius: 5
                    color: "#0C1624"; border.color: "#1A2C40"; border.width: 1

                    Column {
                        anchors.fill: parent; anchors.margins: 7; spacing: 5

                        // Header
                        Row {
                            width: parent.width; spacing: 4
                            Rectangle { width: 3; height: 10; radius: 1.5; color: "#00E5FF"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "SYS-01: POWERTRAIN & ENGINE"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                        }

                        // State Buttons (5 States)
                        Grid {
                            columns: 5; width: parent.width; spacing: 2
                            Repeater {
                                model: [
                                    { name: "INIT", state: 0 },
                                    { name: "LOGO", state: 1 },
                                    { name: "CHECK", state: 2 },
                                    { name: "DRIVE", state: 3 },
                                    { name: "OFF", state: 5 }
                                ]
                                Rectangle {
                                    width: (parent.width - 8) / 5; height: 20; radius: 2.5
                                    property bool isCur: typeof controller !== "undefined" && controller && controller.clusterState === modelData.state
                                    color: isCur ? "#3500E5FF" : "#121E2C"
                                    border.color: isCur ? "#00E5FF" : "#223448"
                                    Text { anchors.centerIn: parent; text: modelData.name; font.pixelSize: 8; font.bold: true; color: parent.isCur ? "#FFFFFF" : "#7E9AB8" }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (typeof controller !== "undefined" && controller) {
                                                if (modelData.state === 5) controller.triggerShutdown();
                                                else if (modelData.state === 1) controller.triggerStartupSequence();
                                                else controller.setClusterState(modelData.state);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Speed Control Slider
                        Column {
                            width: parent.width; spacing: 2
                            Item {
                                width: parent.width; height: 12
                                Text { anchors.left: parent.left; text: "SPEED:"; font.pixelSize: 8; font.bold: true; color: "#7E9AB8" }
                                Text { anchors.right: parent.right; text: (typeof controller !== "undefined" && controller ? controller.speed : 0) + " km/h"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                            }
                            Slider {
                                width: parent.width; height: 16
                                from: 0; to: 180; stepSize: 1
                                value: typeof controller !== "undefined" && controller ? controller.speed : 0
                                onMoved: if (typeof controller !== "undefined" && controller) controller.setSpeed(Math.round(value))
                            }
                        }

                        // RPM Control Slider
                        Column {
                            width: parent.width; spacing: 2
                            Item {
                                width: parent.width; height: 12
                                Text { anchors.left: parent.left; text: "ENGINE RPM:"; font.pixelSize: 8; font.bold: true; color: "#7E9AB8" }
                                Text { anchors.right: parent.right; text: (typeof controller !== "undefined" && controller ? controller.rpm.toFixed(1) : "0.0") + "k"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                            }
                            Slider {
                                width: parent.width; height: 16
                                from: 0.0; to: 6.5; stepSize: 0.1
                                value: typeof controller !== "undefined" && controller ? controller.rpm : 0.0
                                onMoved: if (typeof controller !== "undefined" && controller) controller.setRpm(value)
                            }
                        }

                        // Quick Speed Presets
                        Row {
                            width: parent.width; spacing: 3
                            Repeater {
                                model: [
                                    { name: "0", spd: 0, rpm: 0.8 },
                                    { name: "40", spd: 40, rpm: 2.1 },
                                    { name: "80", spd: 80, rpm: 2.8 },
                                    { name: "120", spd: 120, rpm: 3.6 }
                                ]
                                Rectangle {
                                    width: (parent.width - 9) / 4; height: 18; radius: 2
                                    color: "#121E2C"; border.color: "#223448"
                                    Text { anchors.centerIn: parent; text: modelData.name + " km/h"; font.pixelSize: 7; font.bold: true; color: "#8AA2B8" }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (typeof controller !== "undefined" && controller) {
                                                controller.setSpeed(modelData.spd);
                                                controller.setRpm(modelData.rpm);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Autonomous Drive Demo Toggle
                        Rectangle {
                            width: parent.width; height: 20; radius: 2.5
                            property bool isDemo: typeof controller !== "undefined" && controller && controller.isDemoDriving
                            color: isDemo ? "#3000E676" : "#121E2C"
                            border.color: isDemo ? "#00E676" : "#223448"
                            Row {
                                anchors.centerIn: parent; spacing: 4
                                Rectangle { width: 5; height: 5; radius: 2.5; color: parent.parent.isDemo ? "#00E676" : "#5A7288" }
                                Text { text: parent.parent.isDemo ? "DEMO ACTIVE: " + (controller ? controller.demoScenario : "") : "RUN AUTO DRIVE DEMO"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.toggleDemo() }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 2: TRANSMISSION & AMT GEARBOX (SYS-02)
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 2
                    width: modulesFlow.cardWidth; height: 215; radius: 5
                    color: "#0C1624"; border.color: "#1A2C40"; border.width: 1

                    Column {
                        anchors.fill: parent; anchors.margins: 7; spacing: 5

                        Item {
                            width: parent.width; height: 14
                            Row {
                                anchors.left: parent.left; spacing: 4
                                Rectangle { width: 3; height: 10; radius: 1.5; color: "#00E5FF"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "SYS-02: AMT GEAR SELECTOR"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                            }
                            Text {
                                text: "[" + (typeof controller !== "undefined" && controller ? controller.gear : "N") + "]"
                                font.pixelSize: 8; font.bold: true
                                color: (typeof controller !== "undefined" && controller && controller.gear === "N") ? "#00E676" : "#FFFFFF"
                                anchors.right: parent.right
                            }
                        }

                        // Primary PRND Selector
                        Grid {
                            columns: 4; width: parent.width; spacing: 3
                            Repeater {
                                model: ["P", "R", "N", "D"]
                                Rectangle {
                                    width: (parent.width - 9) / 4; height: 24; radius: 3
                                    property bool isCur: typeof controller !== "undefined" && controller && controller.gear === modelData
                                    color: isCur ? (modelData === "N" ? "#3500E676" : "#3500E5FF") : "#121E2C"
                                    border.color: isCur ? (modelData === "N" ? "#00E676" : "#00E5FF") : "#223448"
                                    border.width: isCur ? 1.5 : 1
                                    Text {
                                        anchors.centerIn: parent; text: modelData
                                        font.pixelSize: 9; font.bold: true
                                        color: parent.isCur ? (modelData === "N" ? "#00E676" : "#00E5FF") : "#8AA2B8"
                                    }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.changeGear(modelData) }
                                }
                            }
                        }

                        // Drive Ratio (D1..D5)
                        Row {
                            width: parent.width; spacing: 2
                            Repeater {
                                model: ["D1", "D2", "D3", "D4", "D5"]
                                Rectangle {
                                    width: (parent.width - 8) / 5; height: 20; radius: 2.5
                                    property bool isCur: typeof controller !== "undefined" && controller && controller.gear === modelData
                                    color: isCur ? "#3500E5FF" : "#101824"
                                    border.color: isCur ? "#00E5FF" : "#203042"
                                    Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 8; font.bold: true; color: parent.isCur ? "#FFFFFF" : "#7A92A8" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.changeGear(modelData) }
                                }
                            }
                        }

                        // Manual Tiptronic (M1..M5)
                        Row {
                            width: parent.width; spacing: 2
                            Repeater {
                                model: ["M1", "M2", "M3", "M4", "M5"]
                                Rectangle {
                                    width: (parent.width - 8) / 5; height: 20; radius: 2.5
                                    property bool isCur: typeof controller !== "undefined" && controller && controller.gear === modelData
                                    color: isCur ? "#35FFA000" : "#101824"
                                    border.color: isCur ? "#FFA000" : "#203042"
                                    Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 8; font.bold: true; color: parent.isCur ? "#FFA000" : "#7A92A8" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.changeGear(modelData) }
                                }
                            }
                        }

                        // Fluid Levels (Fuel & Coolant)
                        Row {
                            width: parent.width; spacing: 4
                            Column {
                                width: (parent.width - 4) / 2; spacing: 1
                                Text { text: "FUEL: " + (typeof controller !== "undefined" && controller ? controller.fuelLevel : 9) + "/12"; font.pixelSize: 7; font.bold: true; color: "#7E9AB8" }
                                Slider {
                                    width: parent.width; height: 16
                                    from: 0; to: 12; stepSize: 1
                                    value: typeof controller !== "undefined" && controller ? controller.fuelLevel : 9
                                    onMoved: if (typeof controller !== "undefined" && controller) controller.setFuelLevel(Math.round(value))
                                }
                            }
                            Column {
                                width: (parent.width - 4) / 2; spacing: 1
                                Text { text: "TEMP: " + (typeof controller !== "undefined" && controller ? controller.tempLevel : 6) + "/12"; font.pixelSize: 7; font.bold: true; color: "#7E9AB8" }
                                Slider {
                                    width: parent.width; height: 16
                                    from: 0; to: 12; stepSize: 1
                                    value: typeof controller !== "undefined" && controller ? controller.tempLevel : 6
                                    onMoved: if (typeof controller !== "undefined" && controller) controller.setTempLevel(Math.round(value))
                                }
                            }
                        }

                        // Cruise Control Bar
                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 18; radius: 2
                                property bool isCrOn: typeof controller !== "undefined" && controller && controller.cruiseEnabled
                                color: isCrOn ? "#2800E676" : "#121E2C"; border.color: isCrOn ? "#00E676" : "#223448"
                                Text { anchors.centerIn: parent; text: "CRUISE"; font.pixelSize: 7; font.bold: true; color: parent.isCrOn ? "#00E676" : "#7E9AB8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleCruise() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 18; radius: 2; color: "#121E2C"; border.color: "#223448"
                                Text { anchors.centerIn: parent; text: "SET -"; font.pixelSize: 7; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseSetMinus() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 18; radius: 2; color: "#121E2C"; border.color: "#223448"
                                Text { anchors.centerIn: parent; text: "RES +"; font.pixelSize: 7; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseResPlus() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 18; radius: 2; color: "#121E2C"; border.color: "#223448"
                                Text { anchors.centerIn: parent; text: "CANCEL"; font.pixelSize: 7; font.bold: true; color: "#FF5252" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseCancel() }
                            }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 3: STEERING WHEEL HMI & TRIP (SYS-03)
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 3
                    width: modulesFlow.cardWidth; height: 215; radius: 5
                    color: "#0C1624"; border.color: "#1A2C40"; border.width: 1

                    Column {
                        anchors.fill: parent; anchors.margins: 7; spacing: 5

                        Row {
                            width: parent.width; spacing: 4
                            Rectangle { width: 3; height: 10; radius: 1.5; color: "#00E5FF"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "SYS-03: STEERING D-PAD & TRIP"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                        }

                        // Steering Wheel Physical D-Pad Buttons
                        Grid {
                            columns: 3; width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 3; color: "#142232"; border.color: "#283C50"
                                Text { anchors.centerIn: parent; text: "UP [▲]"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnUpPressed() }
                            }
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 3; color: "#142838"; border.color: "#00E5FF"
                                Text { anchors.centerIn: parent; text: "OK / ENTER"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnOkPressed() }
                            }
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 3; color: "#142232"; border.color: "#283C50"
                                Text { anchors.centerIn: parent; text: "DOWN [▼]"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnDownPressed() }
                            }
                        }

                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 20; radius: 3; color: "#121E2C"; border.color: "#223448"
                                Text { anchors.centerIn: parent; text: "BACK / RETURN"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnBackPressed() }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 20; radius: 3; color: "#121E2C"; border.color: "#223448"
                                Text { anchors.centerIn: parent; text: "MENU TAB"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnInfoPressed() }
                            }
                        }

                        // Trip Sub-Pages (Drive Info, Since Refueling, Accumulated, Auto Stop)
                        Text { text: "TRIP COMPUTER SUB-PAGES:"; font.pixelSize: 8; font.bold: true; color: "#7E9AB8" }
                        Grid {
                            columns: 2; width: parent.width; spacing: 2
                            Repeater {
                                model: [
                                    { name: "DRIVE INFO", page: 0 },
                                    { name: "SINCE REFUEL", page: 1 },
                                    { name: "ACCUMULATED", page: 2 },
                                    { name: "AUTO STOP (ISG)", page: 3 }
                                ]
                                Rectangle {
                                    width: (parent.width - 2) / 2; height: 18; radius: 2.5
                                    property bool isCur: typeof controller !== "undefined" && controller && controller.tripPage === modelData.page
                                    color: isCur ? "#3500E5FF" : "#101824"
                                    border.color: isCur ? "#00E5FF" : "#203042"
                                    Text { anchors.centerIn: parent; text: modelData.name; font.pixelSize: 7; font.bold: true; color: parent.isCur ? "#FFFFFF" : "#7E9AB8" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setTripPage(modelData.page) }
                                }
                            }
                        }

                        // Trip Reset
                        Rectangle {
                            width: parent.width; height: 18; radius: 2.5; color: "#1A1A24"; border.color: "#405060"
                            Text { anchors.centerIn: parent; text: "HOLD OK (RESET TRIP)"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.resetCurrentTrip() }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 4: CHASSIS, BRAKING & TPMS (SYS-04)
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 4
                    width: modulesFlow.cardWidth; height: 215; radius: 5
                    color: "#0C1624"; border.color: "#1A2C40"; border.width: 1

                    Column {
                        anchors.fill: parent; anchors.margins: 7; spacing: 5

                        Row {
                            width: parent.width; spacing: 4
                            Rectangle { width: 3; height: 10; radius: 1.5; color: "#00E5FF"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "SYS-04: CHASSIS & TPMS"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                        }

                        // Parking Brake Toggle
                        Rectangle {
                            width: parent.width; height: 22; radius: 3
                            property bool isBrake: typeof controller !== "undefined" && controller && controller.parkBrakeActive
                            color: isBrake ? "#30FF1744" : "#121E2C"
                            border.color: isBrake ? "#FF1744" : "#223448"
                            Row {
                                anchors.centerIn: parent; spacing: 4
                                Rectangle { width: 5; height: 5; radius: 2.5; color: parent.parent.isBrake ? "#FF1744" : "#5A7288" }
                                Text { text: parent.parent.isBrake ? "PARK BRAKE: ENGAGED" : "PARK BRAKE: RELEASED"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setParkBrakeActive(!controller.parkBrakeActive) }
                        }

                        // Individual Tyre Pressure Readouts
                        Grid {
                            columns: 2; width: parent.width; spacing: 3
                            Repeater {
                                model: [
                                    { id: 0, name: "FL TYRE", p: (typeof controller !== "undefined" && controller ? Math.round(controller.flPsi) : 35) },
                                    { id: 1, name: "FR TYRE", p: (typeof controller !== "undefined" && controller ? Math.round(controller.frPsi) : 35) },
                                    { id: 2, name: "RL TYRE", p: (typeof controller !== "undefined" && controller ? Math.round(controller.rlPsi) : 35) },
                                    { id: 3, name: "RR TYRE", p: (typeof controller !== "undefined" && controller ? Math.round(controller.rrPsi) : 35) }
                                ]
                                Rectangle {
                                    width: (parent.width - 3) / 2; height: 24; radius: 2.5
                                    property bool isLow: modelData.p < 28
                                    color: isLow ? "#30FF1744" : "#101824"
                                    border.color: isLow ? "#FF1744" : "#203042"
                                    Row {
                                        anchors.centerIn: parent; spacing: 5
                                        Text { text: modelData.name; font.pixelSize: 7; font.bold: true; color: "#7E9AB8" }
                                        Text { text: modelData.p + " psi"; font.pixelSize: 8; font.bold: true; color: parent.parent.isLow ? "#FF5252" : "#00E676" }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (typeof controller !== "undefined" && controller) {
                                                if (modelData.id === 0) (modelData.p <= 24 ? controller.setAllTiresOK() : controller.deflateFL());
                                                else if (modelData.id === 1) (modelData.p <= 24 ? controller.setAllTiresOK() : controller.deflateFR());
                                                else if (modelData.id === 2) (modelData.p <= 24 ? controller.setAllTiresOK() : controller.deflateRL());
                                                else if (modelData.id === 3) (modelData.p <= 24 ? controller.setAllTiresOK() : controller.deflateRR());
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // TPMS Bulk Actions
                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 20; radius: 2.5; color: "#14241A"; border.color: "#00E676"
                                Text { anchors.centerIn: parent; text: "SET ALL 35 PSI (OK)"; font.pixelSize: 7; font.bold: true; color: "#00E676" }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTiresOK()
                                }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 20; radius: 2.5; color: "#24141A"; border.color: "#FF5252"
                                Text { anchors.centerIn: parent; text: "PUNCTURE FL (16)"; font.pixelSize: 7; font.bold: true; color: "#FF5252" }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: if (typeof controller !== "undefined" && controller) controller.punctureFL()
                                }
                            }
                        }

                        // Power Steering (EPS) Status
                        Rectangle {
                            width: parent.width; height: 20; radius: 2.5
                            property bool epsActive: typeof controller !== "undefined" && controller && controller.steeringActive
                            color: epsActive ? "#18261C" : "#30FF1744"
                            border.color: epsActive ? "#00E676" : "#FF1744"
                            Row {
                                anchors.centerIn: parent; spacing: 4
                                Rectangle { width: 4; height: 4; radius: 2; color: parent.parent.epsActive ? "#00E676" : "#FF1744" }
                                Text { text: "POWER STEERING (EPS): " + (parent.parent.epsActive ? "NORMAL" : "FAULT (MIL)"); font.pixelSize: 7; font.bold: true; color: parent.parent.epsActive ? "#CCD8E8" : "#FF8080" }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setSteeringActive(!controller.steeringActive) }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 5: ACCESS & BODY CLOSURES (SYS-05)
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 5
                    width: modulesFlow.cardWidth; height: 215; radius: 5
                    color: "#0C1624"; border.color: "#1A2C40"; border.width: 1

                    Column {
                        anchors.fill: parent; anchors.margins: 7; spacing: 5

                        Row {
                            width: parent.width; spacing: 4
                            Rectangle { width: 3; height: 10; radius: 1.5; color: "#00E5FF"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "SYS-05: ACCESS & CLOSURES"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                        }

                        // 4 Passenger Doors Matrix
                        Grid {
                            columns: 2; width: parent.width; spacing: 3
                            Repeater {
                                model: [
                                    { id: "FL", name: "FRONT LEFT", open: (typeof controller !== "undefined" && controller && controller.doorFLOpen) },
                                    { id: "FR", name: "FRONT RIGHT", open: (typeof controller !== "undefined" && controller && controller.doorFROpen) },
                                    { id: "RL", name: "REAR LEFT", open: (typeof controller !== "undefined" && controller && controller.doorRLOpen) },
                                    { id: "RR", name: "REAR RIGHT", open: (typeof controller !== "undefined" && controller && controller.doorRROpen) }
                                ]
                                Rectangle {
                                    width: (parent.width - 3) / 2; height: 24; radius: 3
                                    color: modelData.open ? "#35FF1744" : "#101824"
                                    border.color: modelData.open ? "#FF1744" : "#203042"
                                    border.width: modelData.open ? 1.5 : 1
                                    Row {
                                        anchors.centerIn: parent; spacing: 4
                                        Rectangle { width: 4; height: 4; radius: 2; color: modelData.open ? "#FF1744" : "#00E676" }
                                        Text { text: modelData.id + ": " + (modelData.open ? "AJAR" : "CLOSED"); font.pixelSize: 8; font.bold: true; color: modelData.open ? "#FF8080" : "#8AA2B8" }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (typeof controller !== "undefined" && controller) {
                                                if (modelData.id === "FL") controller.setDoorFLOpen(!controller.doorFLOpen);
                                                else if (modelData.id === "FR") controller.setDoorFROpen(!controller.doorFROpen);
                                                else if (modelData.id === "RL") controller.setDoorRLOpen(!controller.doorRLOpen);
                                                else if (modelData.id === "RR") controller.setDoorRROpen(!controller.doorRROpen);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Hood, Trunk & Sunroof
                        Grid {
                            columns: 3; width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 2.5
                                property bool open: typeof controller !== "undefined" && controller && controller.bonnetOpen
                                color: open ? "#35FF1744" : "#101824"; border.color: open ? "#FF1744" : "#203042"
                                Text { anchors.centerIn: parent; text: "HOOD: " + (parent.open ? "OPEN" : "SHUT"); font.pixelSize: 7; font.bold: true; color: parent.open ? "#FF8080" : "#8AA2B8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setBonnetOpen(!controller.bonnetOpen) }
                            }
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 2.5
                                property bool open: typeof controller !== "undefined" && controller && controller.trunkOpen
                                color: open ? "#35FF1744" : "#101824"; border.color: open ? "#FF1744" : "#203042"
                                Text { anchors.centerIn: parent; text: "TRUNK: " + (parent.open ? "OPEN" : "SHUT"); font.pixelSize: 7; font.bold: true; color: parent.open ? "#FF8080" : "#8AA2B8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setTrunkOpen(!controller.trunkOpen) }
                            }
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 2.5
                                property bool open: typeof controller !== "undefined" && controller && controller.sunroofAlertActive
                                color: open ? "#35FFA000" : "#101824"; border.color: open ? "#FFA000" : "#203042"
                                Text { anchors.centerIn: parent; text: "SUNROOF"; font.pixelSize: 7; font.bold: true; color: parent.open ? "#FFA000" : "#8AA2B8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setSunroofAlertActive(!controller.sunroofAlertActive) }
                            }
                        }

                        // Presets: Close All / Open All
                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 20; radius: 2.5; color: "#14241A"; border.color: "#00E676"
                                Text { anchors.centerIn: parent; text: "SECURE ALL DOORS"; font.pixelSize: 7; font.bold: true; color: "#00E676" }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (typeof controller !== "undefined" && controller) {
                                            controller.setDoorFLOpen(false); controller.setDoorFROpen(false);
                                            controller.setDoorRLOpen(false); controller.setDoorRROpen(false);
                                            controller.setBonnetOpen(false); controller.setTrunkOpen(false);
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 20; radius: 2.5; color: "#24141A"; border.color: "#FF5252"
                                Text { anchors.centerIn: parent; text: "AJAR 4 DOORS"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (typeof controller !== "undefined" && controller) {
                                            controller.setDoorFLOpen(true); controller.setDoorFROpen(true);
                                            controller.setDoorRLOpen(true); controller.setDoorRROpen(true);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 6: SAFETY RESTRAINTS & BELTS (SYS-06)
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 6
                    width: modulesFlow.cardWidth; height: 215; radius: 5
                    color: "#0C1624"; border.color: "#1A2C40"; border.width: 1

                    Column {
                        anchors.fill: parent; anchors.margins: 7; spacing: 5

                        Item {
                            width: parent.width; height: 14
                            Row {
                                anchors.left: parent.left; spacing: 4
                                Rectangle { width: 3; height: 10; radius: 1.5; color: "#00E5FF"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "SYS-06: OCCUPANT RESTRAINTS"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                            }
                            Text {
                                text: (typeof controller !== "undefined" && controller && controller.rearAlarmActive) ? "ALARM ACTIVE" : "SECURE"
                                font.pixelSize: 8; font.bold: true
                                color: (typeof controller !== "undefined" && controller && controller.rearAlarmActive) ? "#FF1744" : "#00E676"
                                anchors.right: parent.right
                            }
                        }

                        // Driver Front Belt
                        Rectangle {
                            width: parent.width; height: 22; radius: 3
                            property bool buckled: typeof controller !== "undefined" && controller && controller.seatbeltActive
                            color: buckled ? "#3000E676" : "#30FF1744"
                            border.color: buckled ? "#00E676" : "#FF1744"
                            Row {
                                anchors.centerIn: parent; spacing: 5
                                Rectangle { width: 5; height: 5; radius: 2.5; color: parent.parent.buckled ? "#00E676" : "#FF1744" }
                                Text { text: "DRIVER SEATBELT: " + (parent.parent.buckled ? "LATCHED" : "UNBUCKLED"); font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setSeatbeltActive(!controller.seatbeltActive) }
                        }

                        // 3-Seat Rear Matrix (RL, RC, RR)
                        Text { text: "REAR 3-POINT OCCUPANT SENSORS:"; font.pixelSize: 8; font.bold: true; color: "#7E9AB8" }
                        Grid {
                            columns: 3; width: parent.width; spacing: 3
                            Repeater {
                                model: [
                                    { id: "RL", name: "LEFT", b: (typeof controller !== "undefined" && controller && controller.rearLeftBuckled) },
                                    { id: "RC", name: "CENTER", b: (typeof controller !== "undefined" && controller && controller.rearCenterBuckled) },
                                    { id: "RR", name: "RIGHT", b: (typeof controller !== "undefined" && controller && controller.rearRightBuckled) }
                                ]
                                Rectangle {
                                    width: (parent.width - 6) / 3; height: 26; radius: 3
                                    color: modelData.b ? "#2000E676" : "#35FF1744"
                                    border.color: modelData.b ? "#00E676" : "#FF1744"
                                    border.width: modelData.b ? 1 : 1.5
                                    Column {
                                        anchors.centerIn: parent; spacing: 1
                                        Text { text: modelData.id + " " + modelData.name; font.pixelSize: 6; font.bold: true; color: "#7E9AB8"; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: modelData.b ? "LATCHED" : "UNLATCHED"; font.pixelSize: 7; font.bold: true; color: modelData.b ? "#00E676" : "#FF8080"; anchors.horizontalCenter: parent.horizontalCenter }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (typeof controller !== "undefined" && controller) {
                                                if (modelData.id === "RL") controller.setRearLeftBuckled(!controller.rearLeftBuckled);
                                                else if (modelData.id === "RC") controller.setRearCenterBuckled(!controller.rearCenterBuckled);
                                                else if (modelData.id === "RR") controller.setRearRightBuckled(!controller.rearRightBuckled);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Presets: Buckle All / Unbuckle All
                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 20; radius: 2.5; color: "#14241A"; border.color: "#00E676"
                                Text { anchors.centerIn: parent; text: "BUCKLE ALL (QUIET)"; font.pixelSize: 8; font.bold: true; color: "#00E676" }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (typeof controller !== "undefined" && controller) {
                                            controller.setSeatbeltActive(true);
                                            controller.setRearLeftBuckled(true);
                                            controller.setRearCenterBuckled(true);
                                            controller.setRearRightBuckled(true);
                                            controller.stopRearAlarm();
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 20; radius: 2.5; color: "#24141A"; border.color: "#FF5252"
                                Text { anchors.centerIn: parent; text: "UNLATCH ALL"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (typeof controller !== "undefined" && controller) {
                                            controller.setRearLeftBuckled(false);
                                            controller.setRearCenterBuckled(false);
                                            controller.setRearRightBuckled(false);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 7: INFOTAINMENT & CONNECTIVITY (SYS-07)
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 7
                    width: modulesFlow.cardWidth; height: 215; radius: 5
                    color: "#0C1624"; border.color: "#1A2C40"; border.width: 1

                    Column {
                        anchors.fill: parent; anchors.margins: 7; spacing: 5

                        Row {
                            width: parent.width; spacing: 4
                            Rectangle { width: 3; height: 10; radius: 1.5; color: "#00E5FF"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "SYS-07: INFOTAINMENT & MEDIA"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                        }

                        // Media Sources Switcher
                        Grid {
                            columns: 5; width: parent.width; spacing: 2
                            Repeater {
                                model: [
                                    { id: "Apple CarPlay", label: "CARPLAY" },
                                    { id: "Bluetooth", label: "BT AUDIO" },
                                    { id: "USB", label: "USB" },
                                    { id: "Android Auto", label: "ANDROID" },
                                    { id: "FM Radio", label: "FM" }
                                ]
                                Rectangle {
                                    width: (parent.width - 8) / 5; height: 22; radius: 2.5
                                    property bool isCur: typeof controller !== "undefined" && controller && controller.mediaSource === modelData.id
                                    color: isCur ? (modelData.id === "Apple CarPlay" ? "#300BD319" : "#3000E5FF") : "#101824"
                                    border.color: isCur ? (modelData.id === "Apple CarPlay" ? "#0BD319" : "#00E5FF") : "#203042"
                                    Text { anchors.centerIn: parent; text: modelData.label; font.pixelSize: 6; font.bold: true; color: parent.isCur ? "#FFFFFF" : "#7E9AB8" }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
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

                        // Media Playback Transport
                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 22; radius: 2.5; color: "#121E2C"; border.color: "#223448"
                                Text { anchors.centerIn: parent; text: "|< PREV"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.prevMediaTrack() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 22; radius: 2.5
                                property bool isPlay: typeof controller !== "undefined" && controller && controller.isMediaPlaying
                                color: isPlay ? "#2800E676" : "#24141A"
                                border.color: isPlay ? "#00E676" : "#FF5252"
                                Text { anchors.centerIn: parent; text: parent.isPlay ? "|| PAUSE" : "> PLAY"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleMediaPlayback() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 22; radius: 2.5; color: "#121E2C"; border.color: "#223448"
                                Text { anchors.centerIn: parent; text: "NEXT >|"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.nextMediaTrack() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 22; radius: 2.5
                                property bool showPop: typeof controller !== "undefined" && controller && controller.showMediaPopup
                                color: showPop ? "#30FFA000" : "#121E2C"; border.color: showPop ? "#FFA000" : "#223448"
                                Text { anchors.centerIn: parent; text: "BANNER"; font.pixelSize: 8; font.bold: true; color: parent.showPop ? "#FFA000" : "#7E9AB8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerMediaPopup() }
                            }
                        }

                        // Smart Key & Driver Attention
                        Text { text: "TELEMATICS & KEY FOB:"; font.pixelSize: 8; font.bold: true; color: "#7E9AB8" }
                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 2.5
                                property bool keyAlert: typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 1
                                color: keyAlert ? "#35FFA000" : "#101824"; border.color: keyAlert ? "#FFA000" : "#203042"
                                Text { anchors.centerIn: parent; text: parent.keyAlert ? "KEY NOT IN VEHICLE" : "KEY DETECTED"; font.pixelSize: 7; font.bold: true; color: parent.keyAlert ? "#FFA000" : "#00E676" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showSmartKeyAlert(controller.smartKeyPrompt === 1 ? 0 : 1) }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 2.5
                                property bool attAlert: typeof controller !== "undefined" && controller && controller.driverAttentionActive
                                color: attAlert ? "#35FFA000" : "#101824"; border.color: attAlert ? "#FFA000" : "#203042"
                                Text { anchors.centerIn: parent; text: parent.attAlert ? "DRIVER ATTENTION REST" : "DRIVER ALERT: OK"; font.pixelSize: 7; font.bold: true; color: parent.attAlert ? "#FFA000" : "#00E676" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setDriverAttentionActive(!controller.driverAttentionActive) }
                            }
                        }
                    }
                }
            }
        }
    }
}
