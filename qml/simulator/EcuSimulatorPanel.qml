/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           EcuSimulatorPanel.qml
 * Author:         SK Rehan Ahamed
 * Description:    Dynamic Landscape ECU Telemetry Test Bench & Diagnostics
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick
import QtQuick.Controls

Item {
    id: ecuRoot
    property bool isOpen: true
    property int activeTab: 0 // 0 = Grid Overview, 1 = Powertrain, 2 = Steering & Trip, 3 = TPMS & Body, 4 = Lights & Telltales, 5 = Media & Alerts

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
    function toggleDemo() {
        if (typeof controller !== "undefined" && controller) controller.driveDemo();
    }

    // Main Card Background
    Rectangle {
        id: bgCard
        anchors.fill: parent
        radius: 8
        color: "#080F18"
        border.color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#3000E676" : ((typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#30FF5252" : "#3000E5FF")
        border.width: 1.2
        clip: true

        // Top Accent Strip
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2.5
            color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#00E676" : ((typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#FF5252" : "#00E5FF")
        }

        // =============================================================
        // 1. TOP MASTER TOOLBAR (Theme, Ignition, Master Shortcuts)
        // =============================================================
        Item {
            id: masterHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Status Dot
                Rectangle {
                    width: 8; height: 8; radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: (typeof controller !== "undefined" && controller && controller.themeColor === "green") ? "#00E676" : ((typeof controller !== "undefined" && controller && controller.themeColor === "red") ? "#FF5252" : "#00E5FF")
                }

                Text {
                    text: "ECU BENCH:"
                    font.pixelSize: 10
                    font.bold: true
                    color: "#80A0C0"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Theme Switcher Buttons
                Repeater {
                    model: [
                        { name: "Blue", col: "blue", dot: "#00E5FF", border: "#00E5FF" },
                        { name: "Green", col: "green", dot: "#00E676", border: "#00E676" },
                        { name: "Red", col: "red", dot: "#FF5252", border: "#FF5252" }
                    ]
                    Rectangle {
                        width: 52; height: 22; radius: 3
                        anchors.verticalCenter: parent.verticalCenter
                        color: (typeof controller !== "undefined" && controller && controller.themeColor === modelData.col) ? "#35" + modelData.dot.substring(1) : "#142030"
                        border.color: (typeof controller !== "undefined" && controller && controller.themeColor === modelData.col) ? modelData.border : "#283848"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 3
                            Rectangle { width: 5; height: 5; radius: 2.5; color: modelData.dot }
                            Text { text: modelData.name; font.pixelSize: 9; font.bold: true; color: "#FFFFFF" }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.changeTheme(modelData.col) }
                    }
                }

                // Quick Ignition Toggle
                Rectangle {
                    width: 82; height: 22; radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    property bool isIgnOn: (typeof controller !== "undefined" && controller && controller.clusterState !== 5 && controller.clusterState !== 4)
                    color: isIgnOn ? "#3000E676" : "#40FF1744"
                    border.color: isIgnOn ? "#00E676" : "#FF1744"

                    Text {
                        anchors.centerIn: parent
                        text: parent.isIgnOn ? "🟢 IGN: ON" : "🔴 IGN: OFF"
                        font.pixelSize: 9; font.bold: true; color: "#FFFFFF"
                    }
                    MouseArea {
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

            // Right side: Quick Master Fault Controls
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Rectangle {
                    width: 58; height: 22; radius: 3
                    color: "#183024"; border.color: "#00E676"
                    Text { anchors.centerIn: parent; text: "ALL ON"; font.pixelSize: 8; font.bold: true; color: "#00E676" }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTelltales(true) }
                }

                Rectangle {
                    width: 58; height: 22; radius: 3
                    color: "#281820"; border.color: "#FF5252"
                    Text { anchors.centerIn: parent; text: "ALL OFF"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTelltales(false) }
                }

                Rectangle {
                    width: 68; height: 22; radius: 3
                    color: "#182838"; border.color: "#00E5FF"
                    Text { anchors.centerIn: parent; text: "RESTART"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerStartupSequence() }
                }
            }
        }

        // =============================================================
        // 2. DYNAMIC LANDSCAPE MODULE CATEGORY TABS
        // =============================================================
        Rectangle {
            id: tabBar
            anchors.top: masterHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 32
            color: "#0B1522"
            border.color: "#18283A"
            border.width: 1

            ListView {
                id: tabListView
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                orientation: ListView.Horizontal
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds

                model: [
                    { id: 0, label: "🔲 Overview Grid" },
                    { id: 1, label: "🚗 Powertrain & AMT" },
                    { id: 2, label: "🎛️ Steering & Trip" },
                    { id: 3, label: "🛞 TPMS & Body" },
                    { id: 4, label: "🚨 Lights & Warnings" },
                    { id: 5, label: "🎵 Media & Alerts" }
                ]

                delegate: Rectangle {
                    height: 24
                    width: tabText.implicitWidth + 20
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 4
                    color: ecuRoot.activeTab === modelData.id ? "#3000E5FF" : "#121E2C"
                    border.color: ecuRoot.activeTab === modelData.id ? "#00E5FF" : "#243448"
                    border.width: ecuRoot.activeTab === modelData.id ? 1.2 : 1

                    Text {
                        id: tabText
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: 9
                        font.bold: true
                        color: ecuRoot.activeTab === modelData.id ? "#00E5FF" : "#8FA8C0"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ecuRoot.activeTab = modelData.id
                    }
                }
            }
        }

        // =============================================================
        // 3. DYNAMIC LANDSCAPE SCROLL CONTENT AREA
        // =============================================================
        ScrollView {
            id: mainScroll
            anchors.top: tabBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 8
            clip: true

            // Grid or Single Module Container
            Flow {
                id: modulesFlow
                width: mainScroll.width - 12
                spacing: 8

                // Dynamic Column Width Calculation for Landscape Responsive Grid
                readonly property int gridCols: width > 1020 ? 3 : (width > 680 ? 2 : 1)
                readonly property real cardWidth: ecuRoot.activeTab === 0 ? ((width - (gridCols - 1) * spacing) / gridCols) : width

                // -----------------------------------------------------
                // CARD 1: POWERTRAIN & VEHICLE DYNAMICS
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 1
                    width: modulesFlow.cardWidth
                    implicitHeight: card1Col.implicitHeight + 16
                    radius: 6
                    color: "#101B28"
                    border.color: "#203448"
                    border.width: 1

                    Column {
                        id: card1Col
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // Section Title
                        Row {
                            spacing: 5
                            Text { text: "🚗"; font.pixelSize: 11 }
                            Text { text: "POWERTRAIN & AMT DYNAMICS"; font.pixelSize: 10; font.bold: true; color: "#00E5FF" }
                        }

                        // Cluster State Selector
                        Row {
                            width: parent.width
                            spacing: 3
                            Repeater {
                                model: [
                                    { name: "1: Startup", state: 1 },
                                    { name: "2: Check", state: 2 },
                                    { name: "3: Drive", state: 3 },
                                    { name: "4: Off", state: 5 }
                                ]
                                Rectangle {
                                    width: (parent.width - 9) / 4
                                    height: 24
                                    radius: 3
                                    color: (typeof controller !== "undefined" && controller && controller.clusterState === modelData.state) ? "#4000C8FF" : "#142232"
                                    border.color: (typeof controller !== "undefined" && controller && controller.clusterState === modelData.state) ? "#00E5FF" : "#283C50"

                                    Text { anchors.centerIn: parent; text: modelData.name; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.state === 5) {
                                                if (typeof controller !== "undefined" && controller) controller.triggerShutdown();
                                            } else {
                                                ecuRoot.changeState(modelData.state);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Auto Simulation Control Card
                        Rectangle {
                            id: demoCard
                            width: parent.width
                            height: demoActive ? 76 : 38
                            radius: 6
                            clip: true
                            property bool demoActive: typeof controller !== "undefined" && controller && controller.isDemoDriving

                            Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                            gradient: Gradient {
                                GradientStop { position: 0.0; color: demoCard.demoActive ? "#2800E676" : "#201a2a40" }
                                GradientStop { position: 1.0; color: demoCard.demoActive ? "#1200b050" : "#10101828" }
                            }
                            border.color: demoCard.demoActive ? "#00E676" : "#3000E5FF"

                            Item {
                                id: topRowDemo
                                width: parent.width; height: 38
                                anchors.top: parent.top

                                Rectangle {
                                    id: statusLedDemo
                                    anchors.left: parent.left; anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 7; height: 7; radius: 3.5
                                    color: demoCard.demoActive ? "#00E676" : "#445060"
                                }

                                Text {
                                    anchors.left: statusLedDemo.right; anchors.leftMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: demoCard.demoActive ? "AUTO-DRIVE RUNNING" : "AUTO SIMULATION"
                                    font.pixelSize: 9; font.bold: true
                                    color: demoCard.demoActive ? "#00E676" : "#80A0C0"
                                }

                                Rectangle {
                                    anchors.right: parent.right; anchors.rightMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 58; height: 22; radius: 4
                                    color: demoCard.demoActive ? "#40FF3B3B" : "#3000E5FF"
                                    border.color: demoCard.demoActive ? "#FF5252" : "#00E5FF"

                                    Text { anchors.centerIn: parent; text: demoCard.demoActive ? "⏹ STOP" : "▶ START"; font.pixelSize: 9; font.bold: true; color: demoCard.demoActive ? "#FF5252" : "#00E5FF" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.toggleDemo() }
                                }
                            }

                            Column {
                                visible: demoCard.demoActive
                                anchors.left: parent.left; anchors.right: parent.right
                                anchors.leftMargin: 8; anchors.rightMargin: 8
                                anchors.top: topRowDemo.bottom
                                spacing: 3

                                Text {
                                    width: parent.width
                                    text: (typeof controller !== "undefined" && controller && controller.demoScenario) ? controller.demoScenario : "—"
                                    font.pixelSize: 8; color: "#C0E8FF"; elide: Text.ElideRight
                                }

                                Item {
                                    width: parent.width; height: 8
                                    Rectangle { anchors.fill: parent; radius: 2; color: "#18303C" }
                                    Rectangle {
                                        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; radius: 2
                                        property real phase: typeof controller !== "undefined" && controller ? (controller.speed <= 5 ? 0 : controller.speed <= 60 ? 1 : 2) : 0
                                        color: phase === 0 ? "#FF8A00" : phase === 1 ? "#00B0FF" : "#00E676"
                                        width: parent.width * Math.min(1.0, (typeof controller !== "undefined" && controller ? controller.speed : 0) / 120.0)
                                    }
                                }
                            }
                        }

                        // Speed Readout & Slider
                        Item {
                            width: parent.width; height: 16
                            Text {
                                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                text: "SPEED: " + (typeof controller !== "undefined" && controller ? controller.speed : 0) + " km/h"
                                font.pixelSize: 9; font.bold: true; color: "#00E5FF"
                            }
                            Text {
                                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                text: "AMT RPM: " + (typeof controller !== "undefined" && controller ? controller.rpm.toFixed(1) : "0.0") + "k (" + (typeof controller !== "undefined" && controller ? controller.gear : "N") + ")"
                                font.pixelSize: 8; font.bold: true; color: "#00E676"
                            }
                        }

                        Slider {
                            width: parent.width; height: 24
                            from: 0; to: 180; stepSize: 1
                            value: typeof controller !== "undefined" && controller ? controller.speed : 0
                            onMoved: if (typeof controller !== "undefined" && controller) controller.setSpeed(Math.round(value))
                        }

                        // Gear Selector
                        Text { text: "AMT GEAR SELECTOR"; font.pixelSize: 8; font.bold: true; color: "#80A0C0" }
                        Grid {
                            columns: 5; width: parent.width; spacing: 3
                            Repeater {
                                model: ["P", "R", "N", "D", "1", "2", "3", "4", "5", "M1", "M2", "M3", "M4", "M5"]
                                Rectangle {
                                    width: (parent.width - 12) / 5; height: 22; radius: 3
                                    color: (typeof controller !== "undefined" && controller && controller.gear === modelData) ? "#5000C8FF" : "#142232"
                                    border.color: (typeof controller !== "undefined" && controller && controller.gear === modelData) ? "#00E5FF" : "#283C50"
                                    Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.changeGear(modelData) }
                                }
                            }
                        }

                        // Fuel & Coolant Temp Sliders
                        Item {
                            width: parent.width; height: 14
                            Text { text: "FUEL LEVEL: " + (typeof controller !== "undefined" && controller ? controller.fuelLevel : 9) + "/12 bars"; font.pixelSize: 8; font.bold: true; color: "#00E5FF"; anchors.left: parent.left }
                            Text { text: "RANGE: " + (typeof controller !== "undefined" && controller ? (controller.fuelLevel <= 0 ? "---" : controller.dteKm + " km") : "---"); font.pixelSize: 8; font.bold: true; color: "#CCD8E8"; anchors.right: parent.right }
                        }
                        Slider {
                            width: parent.width; height: 22
                            from: 0; to: 12; stepSize: 1
                            value: typeof controller !== "undefined" && controller ? controller.fuelLevel : 9
                            onMoved: if (typeof controller !== "undefined" && controller) controller.setFuelLevel(Math.round(value))
                        }

                        Item {
                            width: parent.width; height: 14
                            Text { text: "COOLANT TEMP: " + (typeof controller !== "undefined" && controller ? controller.tempLevel : 6) + "/12 bars"; font.pixelSize: 8; font.bold: true; color: "#00E5FF"; anchors.left: parent.left }
                        }
                        Slider {
                            width: parent.width; height: 22
                            from: 0; to: 12; stepSize: 1
                            value: typeof controller !== "undefined" && controller ? controller.tempLevel : 6
                            onMoved: if (typeof controller !== "undefined" && controller) controller.setTempLevel(Math.round(value))
                        }

                        // Cruise Control Controls
                        Text { text: "CRUISE CONTROL (STEERING)"; font.pixelSize: 8; font.bold: true; color: "#80A0C0" }
                        Row {
                            width: parent.width; spacing: 4
                            Rectangle {
                                width: (parent.width - 12) / 4; height: 24; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.cruiseEnabled) ? "#3000E676" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.cruiseEnabled) ? "#00E676" : "#283848"
                                Text { anchors.centerIn: parent; text: "CRUISE [C]"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleCruise() }
                            }
                            Rectangle {
                                width: (parent.width - 12) / 4; height: 24; radius: 3
                                color: "#142030"; border.color: "#283848"
                                Text { anchors.centerIn: parent; text: "SET / −"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseSet() }
                            }
                            Rectangle {
                                width: (parent.width - 12) / 4; height: 24; radius: 3
                                color: "#142030"; border.color: "#283848"
                                Text { anchors.centerIn: parent; text: "RES / +"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseResPlus() }
                            }
                            Rectangle {
                                width: (parent.width - 12) / 4; height: 24; radius: 3
                                color: "#142030"; border.color: "#283848"
                                Text { anchors.centerIn: parent; text: "CANCEL"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.cruiseCancel() }
                            }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 2: STEERING SWITCHES & TRIP COMPUTER
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 2
                    width: modulesFlow.cardWidth
                    implicitHeight: card2Col.implicitHeight + 16
                    radius: 6
                    color: "#101B28"
                    border.color: "#203448"
                    border.width: 1

                    Column {
                        id: card2Col
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // Section Title
                        Row {
                            spacing: 5
                            Text { text: "🎛️"; font.pixelSize: 11 }
                            Text { text: "STEERING D-PAD & TRIP PAGES"; font.pixelSize: 10; font.bold: true; color: "#00E5FF" }
                        }

                        // D-Pad Grid
                        Grid {
                            columns: 3; width: parent.width; spacing: 4
                            Rectangle {
                                width: (parent.width - 8) / 3; height: 28; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.showMenuTabs) ? "#4000E5FF" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.showMenuTabs) ? "#00E5FF" : "#283848"
                                Text { anchors.centerIn: parent; text: "📄 INFO [I]"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnInfoPressed() }
                            }
                            Rectangle {
                                width: (parent.width - 8) / 3; height: 28; radius: 3
                                color: "#182838"; border.color: "#305070"
                                Text { anchors.centerIn: parent; text: "▲ UP [↑]"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnUpPressed() }
                            }
                            Rectangle {
                                width: (parent.width - 8) / 3; height: 28; radius: 3
                                color: "#182838"; border.color: "#305070"
                                Text { anchors.centerIn: parent; text: "↩ BACK [Esc]"; font.pixelSize: 8; font.bold: true; color: "#FFA726" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnBackPressed() }
                            }
                            Item { width: (parent.width - 8) / 3; height: 28 }
                            Rectangle {
                                width: (parent.width - 8) / 3; height: 28; radius: 3
                                color: "#182838"; border.color: "#305070"
                                Text { anchors.centerIn: parent; text: "▼ DOWN [↓]"; font.pixelSize: 8; font.bold: true; color: "#00E5FF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: ecuRoot.btnDownPressed() }
                            }
                            Rectangle {
                                width: (parent.width - 8) / 3; height: 28; radius: 3
                                color: "#0A3858"; border.color: "#00E5FF"
                                Text { anchors.centerIn: parent; text: "OK [Hold: Reset]"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: ecuRoot.btnOkPressed()
                                }
                            }
                        }

                        // Trip Computer Page Selector
                        Text { text: "ACTIVE TRIP PAGE"; font.pixelSize: 8; font.bold: true; color: "#80A0C0" }
                        Row {
                            width: parent.width; spacing: 4
                            Repeater {
                                model: [
                                    { name: "Drive info", page: 0 },
                                    { name: "Since refuel", page: 1 },
                                    { name: "Accumulated", page: 2 }
                                ]
                                Rectangle {
                                    width: (parent.width - 8) / 3; height: 26; radius: 3
                                    color: (typeof controller !== "undefined" && controller && controller.tripPage === modelData.page) ? "#4000E5FF" : "#142030"
                                    border.color: (typeof controller !== "undefined" && controller && controller.tripPage === modelData.page) ? "#00E5FF" : "#283848"
                                    Text { anchors.centerIn: parent; text: modelData.name; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setTripPage(modelData.page) }
                                }
                            }
                        }

                        // Reset Active Trip Button
                        Rectangle {
                            width: parent.width; height: 26; radius: 3
                            color: (typeof controller !== "undefined" && controller && controller.tripPage === 0) ? "#101824" : "#2000E5FF"
                            border.color: (typeof controller !== "undefined" && controller && controller.tripPage === 0) ? "#304050" : "#00E5FF"
                            opacity: (typeof controller !== "undefined" && controller && controller.tripPage === 0) ? 0.45 : 1.0

                            Text {
                                anchors.centerIn: parent
                                text: (typeof controller !== "undefined" && controller && controller.tripPage === 0) ?
                                      "🔒 Drive info resets automatically" :
                                      ((typeof controller !== "undefined" && controller && controller.tripPage === 1) ?
                                       "🔄 RESET: Since refuelling (Hold OK)" : "🔄 RESET: Accumulated info (Hold OK)")
                                font.pixelSize: 8; font.bold: true
                                color: (typeof controller !== "undefined" && controller && controller.tripPage === 0) ? "#80A0B0" : "#00E5FF"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: (typeof controller !== "undefined" && controller && controller.tripPage !== 0) ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: if (typeof controller !== "undefined" && controller && controller.tripPage !== 0) controller.resetActiveTripPage()
                            }
                        }

                        // Live Telemetry Readout Box
                        Rectangle {
                            width: parent.width; height: 60; radius: 4
                            color: "#0D1824"; border.color: "#1E3042"
                            Column {
                                anchors.fill: parent; anchors.margins: 6; spacing: 3
                                Row {
                                    width: parent.width
                                    Text { text: "Distance:"; font.pixelSize: 8; color: "#80A0C0" }
                                    Text { text: (typeof controller !== "undefined" && controller ? (controller.tripPage === 1 ? controller.refuelKm.toFixed(1) : (controller.tripPage === 2 ? controller.accumKm.toFixed(1) : controller.tripKm.toFixed(1))) : "0.0") + " km"; font.pixelSize: 8; font.bold: true; color: "#00E5FF"; anchors.right: parent.right }
                                }
                                Row {
                                    width: parent.width
                                    Text { text: "Elapsed Time:"; font.pixelSize: 8; color: "#80A0C0" }
                                    Text { text: (typeof controller !== "undefined" && controller ? (controller.tripPage === 1 ? controller.refuelTime : (controller.tripPage === 2 ? controller.accumTime : controller.tripTime)) : "0:00") + " h:m"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF"; anchors.right: parent.right }
                                }
                                Row {
                                    width: parent.width
                                    Text { text: "Fuel Economy:"; font.pixelSize: 8; color: "#80A0C0" }
                                    Text { text: (typeof controller !== "undefined" && controller ? (controller.tripPage === 1 ? controller.refuelEconomy.toFixed(1) : (controller.tripPage === 2 ? controller.accumEconomy.toFixed(1) : controller.tripEconomy.toFixed(1))) : "0.0") + " km/L"; font.pixelSize: 8; font.bold: true; color: "#00E676"; anchors.right: parent.right }
                                }
                            }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 3: TPMS 4-WHEEL & DOORS / BODY CONTROLS
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 3
                    width: modulesFlow.cardWidth
                    implicitHeight: card3Col.implicitHeight + 16
                    radius: 6
                    color: "#101B28"
                    border.color: "#203448"
                    border.width: 1

                    Column {
                        id: card3Col
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // Section Title
                        Row {
                            spacing: 5
                            Text { text: "🛞"; font.pixelSize: 11 }
                            Text { text: "TPMS & BODY / DOORS STATION"; font.pixelSize: 10; font.bold: true; color: "#00E5FF" }
                        }

                        // Presets & Calibration
                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 6) * 0.38; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "#3000E5FF" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "#00E5FF" : "#283848"
                                Text { anchors.centerIn: parent; text: (typeof controller !== "undefined" && controller && controller.tpmsCalibrated) ? "🟢 CALIBRATED" : "⚪ DRIVE DISPLAY"; font.pixelSize: 7; font.bold: true; color: "#FFFFFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setTpmsCalibrated(!controller.tpmsCalibrated) }
                            }
                            Rectangle {
                                width: (parent.width - 6) * 0.31; height: 22; radius: 3
                                color: "#18281E"; border.color: "#00E676"
                                Text { anchors.centerIn: parent; text: "✅ 35 PSI OK"; font.pixelSize: 7; font.bold: true; color: "#00E676" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTiresOK() }
                            }
                            Rectangle {
                                width: (parent.width - 6) * 0.31; height: 22; radius: 3
                                color: "#281E18"; border.color: "#FF9100"
                                Text { anchors.centerIn: parent; text: "⚠️ 24 PSI LOW"; font.pixelSize: 7; font.bold: true; color: "#FF9100" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setAllTiresLow() }
                            }
                        }

                        // 2x2 Wheel Grid
                        Grid {
                            columns: 2; width: parent.width; spacing: 4
                            Repeater {
                                model: [
                                    { id: "FL", label: "FL", getVal: function() { return controller ? controller.flPsi : 35 }, setVal: function(v) { if (controller) { controller.setFlPsi(v); controller.setTpmsCalibrated(true); } } },
                                    { id: "FR", label: "FR", getVal: function() { return controller ? controller.frPsi : 35 }, setVal: function(v) { if (controller) { controller.setFrPsi(v); controller.setTpmsCalibrated(true); } } },
                                    { id: "RL", label: "RL", getVal: function() { return controller ? controller.rlPsi : 35 }, setVal: function(v) { if (controller) { controller.setRlPsi(v); controller.setTpmsCalibrated(true); } } },
                                    { id: "RR", label: "RR", getVal: function() { return controller ? controller.rrPsi : 31 }, setVal: function(v) { if (controller) { controller.setRrPsi(v); controller.setTpmsCalibrated(true); } } }
                                ]
                                Rectangle {
                                    width: (parent.width - 4) / 2; height: 38; radius: 4
                                    property real val: modelData.getVal()
                                    property color stCol: val < 26.0 ? "#FF5252" : (val < 32.0 ? "#FFD54F" : "#00E676")
                                    color: "#142030"; border.color: stCol; border.width: 1

                                    Row {
                                        anchors.fill: parent; anchors.margins: 3; spacing: 3
                                        Text { text: modelData.label; font.pixelSize: 8; font.bold: true; color: "#CCD8E8"; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: Math.round(parent.parent.val) + " psi"; font.pixelSize: 8; font.bold: true; color: parent.parent.stCol; anchors.verticalCenter: parent.verticalCenter }
                                        Item { width: 4 }
                                        Rectangle {
                                            width: 18; height: 18; radius: 2; color: "#223348"; anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 10; color: "#FFF" }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.setVal(Math.max(15, parent.parent.parent.val - 1)) }
                                        }
                                        Rectangle {
                                            width: 18; height: 18; radius: 2; color: "#223348"; anchors.verticalCenter: parent.verticalCenter
                                            Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 10; color: "#FFF" }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.setVal(Math.min(50, parent.parent.parent.val + 1)) }
                                        }
                                    }
                                }
                            }
                        }

                        // Doors & Openings Controls
                        Text { text: "DOORS & BODY OPENINGS"; font.pixelSize: 8; font.bold: true; color: "#80A0C0" }
                        Grid {
                            columns: 2; width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.doorFrontRight) ? "#40FF5252" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.doorFrontRight) ? "#FF5252" : "#283848"
                                Text { anchors.centerIn: parent; text: "🚪 DRIVER (FR)"; font.pixelSize: 7; font.bold: true; color: "#FFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleDoorFR() }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.doorFrontLeft) ? "#40FF5252" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.doorFrontLeft) ? "#FF5252" : "#283848"
                                Text { anchors.centerIn: parent; text: "🚪 PASSENGER (FL)"; font.pixelSize: 7; font.bold: true; color: "#FFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleDoorFL() }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.doorRearRight) ? "#40FF5252" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.doorRearRight) ? "#FF5252" : "#283848"
                                Text { anchors.centerIn: parent; text: "🚪 REAR RIGHT (RR)"; font.pixelSize: 7; font.bold: true; color: "#FFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleDoorRR() }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.doorRearLeft) ? "#40FF5252" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.doorRearLeft) ? "#FF5252" : "#283848"
                                Text { anchors.centerIn: parent; text: "🚪 REAR LEFT (RL)"; font.pixelSize: 7; font.bold: true; color: "#FFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleDoorRL() }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.bonnetOpen) ? "#40FF2020" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.bonnetOpen) ? "#FF2020" : "#283848"
                                Text { anchors.centerIn: parent; text: "🚘 BONNET (HOOD)"; font.pixelSize: 7; font.bold: true; color: "#FF5252" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleBonnet() }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.trunkOpen) ? "#40FF2020" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.trunkOpen) ? "#FF2020" : "#283848"
                                Text { anchors.centerIn: parent; text: "🧳 TRUNK (BOOT)"; font.pixelSize: 7; font.bold: true; color: "#FF5252" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleTrunk() }
                            }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 4: LIGHTS & WARNING TELLTALES
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 4
                    width: modulesFlow.cardWidth
                    implicitHeight: card4Col.implicitHeight + 16
                    radius: 6
                    color: "#101B28"
                    border.color: "#203448"
                    border.width: 1

                    Column {
                        id: card4Col
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // Section Title
                        Row {
                            spacing: 5
                            Text { text: "🚨"; font.pixelSize: 11 }
                            Text { text: "LIGHT STALK & TELLTALES"; font.pixelSize: 10; font.bold: true; color: "#00E5FF" }
                        }

                        // Light Stalk Mode
                        Text { text: "OEM LIGHT STALK (POPUP BANNER)"; font.pixelSize: 8; font.bold: true; color: "#80A0C0" }
                        Row {
                            width: parent.width; spacing: 3
                            Repeater {
                                model: [
                                    { name: "OFF", mode: 0 },
                                    { name: "AUTO", mode: 1 },
                                    { name: "POSITION", mode: 2 },
                                    { name: "HEADLIGHT", mode: 3 }
                                ]
                                Rectangle {
                                    width: (parent.width - 9) / 4; height: 22; radius: 3
                                    color: (typeof controller !== "undefined" && controller && controller.lightMode === modelData.mode) ? "#4000E5FF" : "#142030"
                                    border.color: (typeof controller !== "undefined" && controller && controller.lightMode === modelData.mode) ? "#00E5FF" : "#283848"
                                    Text { anchors.centerIn: parent; text: modelData.name; font.pixelSize: 7; font.bold: true; color: "#FFFFFF" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLightMode(modelData.mode) }
                                }
                            }
                        }

                        // Direct Lights Overrides
                        Grid {
                            columns: 3; width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.leftIndicator) ? "#4000E676" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.leftIndicator) ? "#00E676" : "#283848"
                                Text { anchors.centerIn: parent; text: "⬅ Turn Left"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setLeftIndicator(!controller.leftIndicator) }
                            }
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.rightIndicator) ? "#4000E676" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.rightIndicator) ? "#00E676" : "#283848"
                                Text { anchors.centerIn: parent; text: "Turn Right ➡"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setRightIndicator(!controller.rightIndicator) }
                            }
                            Rectangle {
                                width: (parent.width - 6) / 3; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.highBeam) ? "#4000B0FF" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.highBeam) ? "#00B0FF" : "#283848"
                                Text { anchors.centerIn: parent; text: "High Beam"; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.setHighBeam(!controller.highBeam) }
                            }
                        }

                        // Warning Telltales Grid
                        Text { text: "FAULT TELLTALE INJECTORS"; font.pixelSize: 8; font.bold: true; color: "#FF5252" }
                        Grid {
                            columns: 3; width: parent.width; spacing: 3
                            Repeater {
                                model: [
                                    { name: "Brake", get: function() { return controller ? controller.parkBrakeActive : false }, toggle: function() { if (controller) controller.setParkBrakeActive(!controller.parkBrakeActive) } },
                                    { name: "ABS", get: function() { return controller ? controller.absActive : false }, toggle: function() { if (controller) controller.setAbsActive(!controller.absActive) } },
                                    { name: "Seatbelt", get: function() { return controller ? controller.seatbeltActive : false }, toggle: function() { if (controller) controller.setSeatbeltActive(!controller.seatbeltActive) } },
                                    { name: "Battery", get: function() { return controller ? controller.batteryActive : false }, toggle: function() { if (controller) controller.setBatteryActive(!controller.batteryActive) } },
                                    { name: "Airbag", get: function() { return controller ? controller.airbagActive : false }, toggle: function() { if (controller) controller.setAirbagActive(!controller.airbagActive) } },
                                    { name: "Oil", get: function() { return controller ? controller.oilActive : false }, toggle: function() { if (controller) controller.setOilActive(!controller.oilActive) } },
                                    { name: "Steering", get: function() { return controller ? controller.steeringActive : false }, toggle: function() { if (controller) controller.setSteeringActive(!controller.steeringActive) } },
                                    { name: "Check Engine", get: function() { return controller ? controller.checkEngineActive : false }, toggle: function() { if (controller) controller.setCheckEngineActive(!controller.checkEngineActive) } },
                                    { name: "ESC", get: function() { return controller ? controller.escActive : false }, toggle: function() { if (controller) controller.setEscActive(!controller.escActive) } }
                                ]
                                Rectangle {
                                    width: (parent.width - 6) / 3; height: 22; radius: 3
                                    property bool active: modelData.get()
                                    color: active ? "#40FF3D57" : "#142030"
                                    border.color: active ? "#FF3D57" : "#283848"
                                    Text { anchors.centerIn: parent; text: modelData.name; font.pixelSize: 8; font.bold: true; color: "#FFFFFF" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.toggle() }
                                }
                            }
                        }
                    }
                }

                // -----------------------------------------------------
                // CARD 5: INFOTAINMENT & SMART ALERTS
                // -----------------------------------------------------
                Rectangle {
                    visible: ecuRoot.activeTab === 0 || ecuRoot.activeTab === 5
                    width: modulesFlow.cardWidth
                    implicitHeight: card5Col.implicitHeight + 16
                    radius: 6
                    color: "#101B28"
                    border.color: "#203448"
                    border.width: 1

                    Column {
                        id: card5Col
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // Section Title
                        Row {
                            spacing: 5
                            Text { text: "🎵"; font.pixelSize: 11 }
                            Text { text: "INFOTAINMENT & SMART ALERTS"; font.pixelSize: 10; font.bold: true; color: "#00E5FF" }
                        }

                        // Media Sources
                        Row {
                            width: parent.width; spacing: 3
                            Repeater {
                                model: [
                                    { id: "USB", label: "💾 USB" },
                                    { id: "Bluetooth", label: "ᛒ BT" },
                                    { id: "Apple CarPlay", label: "📱 CarPlay" },
                                    { id: "Android Auto", label: "🤖 Android" },
                                    { id: "FM Radio", label: "📻 FM" }
                                ]
                                Rectangle {
                                    width: (parent.width - 12) / 5; height: 22; radius: 3
                                    color: (typeof controller !== "undefined" && controller && controller.mediaSource === modelData.id) ? "#4000E5FF" : "#142030"
                                    border.color: (typeof controller !== "undefined" && controller && controller.mediaSource === modelData.id) ? "#00E5FF" : "#283848"
                                    Text { anchors.centerIn: parent; text: modelData.label; font.pixelSize: 7; font.bold: true; color: "#FFFFFF" }
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

                        // Transport Playback Controls
                        Row {
                            width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 22; radius: 3; color: "#182638"; border.color: "#304860"
                                Text { anchors.centerIn: parent; text: "⏮ Prev"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.prevMediaTrack() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.isMediaPlaying) ? "#3000E676" : "#281820"
                                border.color: (typeof controller !== "undefined" && controller && controller.isMediaPlaying) ? "#00E676" : "#FF5252"
                                Text { anchors.centerIn: parent; text: (typeof controller !== "undefined" && controller && controller.isMediaPlaying) ? "⏸ Pause" : "▶ Play"; font.pixelSize: 8; font.bold: true; color: "#FFF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.toggleMediaPlayback() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 22; radius: 3; color: "#182638"; border.color: "#304860"
                                Text { anchors.centerIn: parent; text: "⏭ Next"; font.pixelSize: 8; font.bold: true; color: "#CCD8E8" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.nextMediaTrack() }
                            }
                            Rectangle {
                                width: (parent.width - 9) / 4; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.showMediaPopup) ? "#40FF9100" : "#223042"
                                border.color: (typeof controller !== "undefined" && controller && controller.showMediaPopup) ? "#FF9100" : "#406080"
                                Text { anchors.centerIn: parent; text: "🔔 Popup"; font.pixelSize: 8; font.bold: true; color: "#FFD54F" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerMediaPopup() }
                            }
                        }

                        // Smart Key & Pedal Prompts
                        Text { text: "SMART KEY & PEDAL ALERTS"; font.pixelSize: 8; font.bold: true; color: "#80A0C0" }
                        Grid {
                            columns: 2; width: parent.width; spacing: 3
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 1) ? "#40FFA000" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.smartKeyPrompt === 1) ? "#FFA000" : "#283848"
                                Text { anchors.centerIn: parent; text: "🔑 Key Not In Car"; font.pixelSize: 7; font.bold: true; color: "#FFD54F" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showSmartKeyAlert(controller.smartKeyPrompt === 1 ? 0 : 1) }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.startPedalPrompt === 3) ? "#4000E5FF" : "#142030"
                                border.color: (typeof controller !== "undefined" && controller && controller.startPedalPrompt === 3) ? "#00E5FF" : "#283848"
                                Text { anchors.centerIn: parent; text: "🛑 Press Brake"; font.pixelSize: 7; font.bold: true; color: "#00E5FF" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.showStartPedalAlert(controller.startPedalPrompt === 3 ? 0 : 3) }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: (typeof controller !== "undefined" && controller && controller.reduceSpeedAlert) ? "#40FF9E1B" : "#142030"
                                border.color: "#FF9E1B"
                                Text { anchors.centerIn: parent; text: "⚠️ Speed Alert"; font.pixelSize: 7; font.bold: true; color: "#FF9E1B" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (typeof controller !== "undefined" && controller) controller.triggerReduceSpeedAlert() }
                            }
                            Rectangle {
                                width: (parent.width - 3) / 2; height: 22; radius: 3
                                color: "#281820"; border.color: "#FF5252"
                                Text { anchors.centerIn: parent; text: "❌ Clear Alerts"; font.pixelSize: 7; font.bold: true; color: "#FF5252" }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (typeof controller !== "undefined" && controller) {
                                            controller.showSmartKeyAlert(0);
                                            controller.showStartPedalAlert(0);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
    }
}
