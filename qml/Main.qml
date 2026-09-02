/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           Main.qml
 * Author:         SK Rehan Ahamed
 * Description:    Root Window & Global Event Routing Container
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick
import QtQuick.Controls
import "simulator"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1320
    height: 480
    minimumWidth: 1000
    minimumHeight: 380
    title: "Hyundai Exter AMT — Digital Instrument Cluster"
    color: "#000000"

    property bool developerMode: false

    // Automotive Digital Fonts
    FontLoader { id: orbitronFont; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/Orbitron-Bold.ttf" }
    FontLoader { id: rajdhaniFont; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/Rajdhani-Bold.ttf" }
    FontLoader { id: dseg7Font; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/DSEG7Classic-Bold.ttf" }
    FontLoader { id: dseg7RegularFont; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/DSEG7Classic-Regular.ttf" }

    Item {
        id: clusterContainer
        anchors.fill: parent
        focus: true

        // 1. Production Digital Instrument Cluster
        ClusterUnit {
            id: liveCluster
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.98, 1280)
            height: Math.min(parent.height * 0.96, 420)
            stateMode: controller ? controller.clusterState : 3
        }

        // 2. Keyboard & Controller Bindings
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Space) {
                if (controller) controller.triggerStartupSequence();
            } else if (event.key === Qt.Key_G || event.key === Qt.Key_M) {
                if (controller) controller.cycleGear();
            } else if (event.key === Qt.Key_D) {
                if (controller) controller.setGear("D");
            } else if (event.key === Qt.Key_N) {
                if (controller) controller.setGear("N");
            } else if (event.key === Qt.Key_R) {
                if (controller) controller.setGear("R");
            } else if (event.key === Qt.Key_P) {
                if (controller) controller.setGear("P");
            } else if (event.key === Qt.Key_1) {
                if (controller) controller.setGear("M1");
            } else if (event.key === Qt.Key_2) {
                if (controller) controller.setGear("M2");
            } else if (event.key === Qt.Key_3) {
                if (controller) controller.setGear("M3");
            } else if (event.key === Qt.Key_4) {
                if (controller) controller.setGear("M4");
            } else if (event.key === Qt.Key_5) {
                if (controller) controller.setGear("M5");
            } else if (event.key === Qt.Key_A) {
                if (controller) controller.driveDemo();
            } else if (event.key === Qt.Key_B) {
                if (controller) controller.setParkBrakeActive(!controller.parkBrakeActive);
            } else if (event.key === Qt.Key_Down) {
                if (controller && controller.menuTab === 1) {
                    liveCluster.navSettingsDown();
                } else if (controller) {
                    controller.nextTripPage();
                }
            } else if (event.key === Qt.Key_Up) {
                if (controller && controller.menuTab === 1) {
                    liveCluster.navSettingsUp();
                } else if (controller) {
                    controller.prevTripPage();
                }
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (controller && controller.menuTab === 1) {
                    liveCluster.selectSettings();
                }
            } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace) {
                if (controller && controller.menuTab === 1) {
                    liveCluster.backSettings();
                }
            } else if (event.key === Qt.Key_Right) {
                if (controller) {
                    controller.setSpeed(Math.min(180, controller.speed + 2));
                    controller.setRpm(Math.min(6.5, controller.rpm + 0.12));
                }
            } else if (event.key === Qt.Key_Left) {
                if (controller) {
                    controller.setSpeed(Math.max(0, controller.speed - 2));
                    controller.setRpm(Math.max(0.8, controller.rpm - 0.12));
                }
            } else if (event.key === Qt.Key_I) {
                if (controller) controller.triggerInfoMenu();
            } else if (event.key === Qt.Key_L) {
                if (controller) controller.cycleLightMode();
            } else if (event.key === Qt.Key_C) {
                if (controller) controller.toggleCruise();
            } else if (event.key === Qt.Key_F12 || event.key === Qt.Key_Tab) {
                ecuSimulatorWindow.visible = !ecuSimulatorWindow.visible;
                if (ecuSimulatorWindow.visible) ecuSimulatorWindow.raise();
            }
        }

        // Floating Quick Button to Toggle / Focus ECU Simulator Window
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 12
            width: 130
            height: 28
            radius: 5
            color: ecuSimulatorWindow.visible ? "#2500E5FF" : "#1A2230"
            border.color: ecuSimulatorWindow.visible ? "#00E5FF" : "#304050"
            border.width: 1.2
            z: 9999

            Row {
                anchors.centerIn: parent
                spacing: 5
                Text { text: "🎛️"; font.pixelSize: 11 }
                Text {
                    text: ecuSimulatorWindow.visible ? "ECU Bench (ON)" : "ECU Bench (OFF)"
                    font.pixelSize: 10
                    font.bold: true
                    color: ecuSimulatorWindow.visible ? "#00E5FF" : "#80A0C0"
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    ecuSimulatorWindow.visible = !ecuSimulatorWindow.visible;
                    if (ecuSimulatorWindow.visible) ecuSimulatorWindow.raise();
                }
            }
        }
    }

    // =================================================================
    // 2. SEPARATE MOVABLE ECU EMULATOR WINDOW
    // =================================================================
    Window {
        id: ecuSimulatorWindow
        title: "⚙️ Hyundai Exter — ECU Simulator Bench"
        visible: true
        width: 380
        height: 680
        minimumWidth: 340
        minimumHeight: 400
        x: appWindow.x + appWindow.width + 16
        y: appWindow.y
        color: "#080F18"

        EcuSimulatorPanel {
            id: ecuSimulator
            anchors.fill: parent

            onBtnUpPressed: {
                if (controller && controller.menuTab === 1) {
                    liveCluster.navSettingsUp();
                } else if (controller) {
                    controller.prevTripPage();
                }
            }

            onBtnDownPressed: {
                if (controller && controller.menuTab === 1) {
                    liveCluster.navSettingsDown();
                } else if (controller) {
                    controller.nextTripPage();
                }
            }

            onBtnOkPressed: {
                if (controller && controller.menuTab === 1) {
                    liveCluster.selectSettings();
                }
            }

            onBtnBackPressed: {
                if (controller && controller.menuTab === 1) {
                    liveCluster.backSettings();
                }
            }

            onBtnInfoPressed: {
                if (controller) {
                    controller.triggerInfoMenu();
                }
            }
        }
    }


    Component.onCompleted: {
        clusterContainer.forceActiveFocus();
        if (controller) {
            controller.triggerStartupSequence();
        }
    }
}
