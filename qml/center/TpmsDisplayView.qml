/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           TpmsDisplayView.qml
 * Author:         SK Rehan Ahamed
 * Description:    3D 4-Wheel Tyre Pressure Monitoring System (TPMS)
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: tpmsRoot
    width: parent.width
    height: 204

    property double flPsi: controller ? controller.flPsi : 35.0
    property double frPsi: controller ? controller.frPsi : 35.0
    property double rlPsi: controller ? controller.rlPsi : 35.0
    property double rrPsi: controller ? controller.rrPsi : 31.0
    property bool calibrated: controller ? controller.tpmsCalibrated : false

    // Auto-calibration: drive for 5 seconds to calibrate TPMS
    Timer {
        id: driveCalibTimer
        interval: 5000
        running: controller && controller.speed > 0 && !tpmsRoot.calibrated
        repeat: false
        onTriggered: {
            if (controller) controller.setTpmsCalibrated(true);
        }
    }

    readonly property bool isHindi: controller && (controller.language === "हिन्दी" || controller.language === "Hindi")
    readonly property bool hasLowPressure: (flPsi < 32.0 || frPsi < 32.0 || rlPsi < 32.0 || rrPsi < 32.0)

    // 1. Title Header: "Tyre pressure" or "Low pressure" (Matches OEM Photo 1 & 2)
    Text {
        id: titleText
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: isHindi ? ((tpmsRoot.calibrated && tpmsRoot.hasLowPressure) ? "कम दबाव" : "टायर प्रेशर") : ((tpmsRoot.calibrated && tpmsRoot.hasLowPressure) ? "Low pressure" : "Tyre pressure")
        font.pixelSize: 19
        font.family: "Hyundai Sans Head Medium"
        font.weight: Font.DemiBold
        color: "#FFFFFF"
    }

    // 2. Center Top-Down Car Graphic
    Item {
        id: carContainer
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 10
        width: 68
        height: 120

        Image {
            id: carImage
            anchors.fill: parent
            source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/tpms_car_top.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            opacity: tpmsRoot.calibrated ? 1.0 : 0.75
        }

        // Helper Component for Glowing Tyre Pill
        component TyreGlow: Rectangle {
            property double psi: 35.0
            width: 8
            height: 22
            radius: 4
            visible: tpmsRoot.calibrated && psi < 32.0
            color: psi < 26.0 ? "#FF1744" : "#FFA000"
            border.color: psi < 26.0 ? "#FF8A80" : "#FFE082"
            border.width: 1.2
            z: 5

            // Outer Radiant Bloom
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 10
                height: parent.height + 10
                radius: 7
                color: parent.psi < 26.0 ? "#50FF1744" : "#50FFA000"
                z: -1
            }

            SequentialAnimation on opacity {
                running: parent.visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.7; to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.0; to: 0.7; duration: 600; easing.type: Easing.InOutQuad }
            }
        }

        // Front-Left Tyre Glow
        TyreGlow {
            id: flGlow
            x: 2
            y: 18
            psi: tpmsRoot.flPsi
        }

        // Front-Right Tyre Glow
        TyreGlow {
            id: frGlow
            x: parent.width - width - 2
            y: 18
            psi: tpmsRoot.frPsi
        }

        // Rear-Left Tyre Glow
        TyreGlow {
            id: rlGlow
            x: 2
            y: 78
            psi: tpmsRoot.rlPsi
        }

        // Rear-Right Tyre Glow (Illuminated in OEM Photo 2)
        TyreGlow {
            id: rrGlow
            x: parent.width - width - 2
            y: 78
            psi: tpmsRoot.rrPsi
        }
    }

    // 3. Four Corner PSI Pressure Value Digits
    Item {
        id: pressureValuesContainer
        anchors.fill: carContainer
        visible: tpmsRoot.calibrated
        opacity: tpmsRoot.calibrated ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        function getPsiColor(psi) {
            if (psi < 26.0) return "#FF5252";
            if (psi < 32.0) return "#FFD54F"; // OEM Amber/Yellow
            return "#FFFFFF";
        }

        function formatPressure(psi) {
            var unit = controller ? controller.tpmsUnit : "psi";
            if (unit === "bar") {
                return (psi * 0.0689476).toFixed(1);
            } else if (unit === "kPa") {
                return Math.round(psi * 6.89476).toString();
            }
            return Math.round(psi).toString();
        }

        // Front Left PSI Interactive Target
        Rectangle {
            x: -46
            y: 14
            width: 44
            height: 32
            radius: 4
            color: flArea.containsMouse ? "#3000E5FF" : "transparent"
            border.color: flArea.containsMouse ? "#8000E5FF" : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: pressureValuesContainer.formatPressure(tpmsRoot.flPsi)
                font.pixelSize: (controller && controller.tpmsUnit === "kPa") ? 18 : 22
                font.family: "Hyundai Sans Head Medium"
                font.weight: Font.DemiBold
                color: pressureValuesContainer.getPsiColor(tpmsRoot.flPsi)
            }

            MouseArea {
                id: flArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (controller) {
                        // Cycle through realistic presets: 35 -> 31 -> 24 -> 38 -> 35
                        var nextPsi = tpmsRoot.flPsi >= 35 ? 31 : (tpmsRoot.flPsi === 31 ? 24 : (tpmsRoot.flPsi === 24 ? 38 : 35));
                        controller.setFlPsi(nextPsi);
                    }
                }
                onWheel: function(wheel) {
                    if (controller) {
                        var delta = wheel.angleDelta.y > 0 ? 1 : -1;
                        controller.adjustPsi("FL", delta);
                    }
                }
            }
        }

        // Front Right PSI Interactive Target
        Rectangle {
            x: carContainer.width + 2
            y: 14
            width: 44
            height: 32
            radius: 4
            color: frArea.containsMouse ? "#3000E5FF" : "transparent"
            border.color: frArea.containsMouse ? "#8000E5FF" : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: pressureValuesContainer.formatPressure(tpmsRoot.frPsi)
                font.pixelSize: (controller && controller.tpmsUnit === "kPa") ? 18 : 22
                font.family: "Hyundai Sans Head Medium"
                font.weight: Font.DemiBold
                color: pressureValuesContainer.getPsiColor(tpmsRoot.frPsi)
            }

            MouseArea {
                id: frArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (controller) {
                        var nextPsi = tpmsRoot.frPsi >= 35 ? 31 : (tpmsRoot.frPsi === 31 ? 24 : (tpmsRoot.frPsi === 24 ? 38 : 35));
                        controller.setFrPsi(nextPsi);
                    }
                }
                onWheel: function(wheel) {
                    if (controller) {
                        var delta = wheel.angleDelta.y > 0 ? 1 : -1;
                        controller.adjustPsi("FR", delta);
                    }
                }
            }
        }

        // Rear Left PSI Interactive Target
        Rectangle {
            x: -46
            y: 74
            width: 44
            height: 32
            radius: 4
            color: rlArea.containsMouse ? "#3000E5FF" : "transparent"
            border.color: rlArea.containsMouse ? "#8000E5FF" : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: pressureValuesContainer.formatPressure(tpmsRoot.rlPsi)
                font.pixelSize: (controller && controller.tpmsUnit === "kPa") ? 18 : 22
                font.family: "Hyundai Sans Head Medium"
                font.weight: Font.DemiBold
                color: pressureValuesContainer.getPsiColor(tpmsRoot.rlPsi)
            }

            MouseArea {
                id: rlArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (controller) {
                        var nextPsi = tpmsRoot.rlPsi >= 35 ? 31 : (tpmsRoot.rlPsi === 31 ? 24 : (tpmsRoot.rlPsi === 24 ? 38 : 35));
                        controller.setRlPsi(nextPsi);
                    }
                }
                onWheel: function(wheel) {
                    if (controller) {
                        var delta = wheel.angleDelta.y > 0 ? 1 : -1;
                        controller.adjustPsi("RL", delta);
                    }
                }
            }
        }

        // Rear Right PSI Interactive Target
        Rectangle {
            x: carContainer.width + 2
            y: 74
            width: 44
            height: 32
            radius: 4
            color: rrArea.containsMouse ? "#3000E5FF" : "transparent"
            border.color: rrArea.containsMouse ? "#8000E5FF" : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: pressureValuesContainer.formatPressure(tpmsRoot.rrPsi)
                font.pixelSize: (controller && controller.tpmsUnit === "kPa") ? 18 : 22
                font.family: "Hyundai Sans Head Medium"
                font.weight: Font.DemiBold
                color: pressureValuesContainer.getPsiColor(tpmsRoot.rrPsi)
            }

            MouseArea {
                id: rrArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (controller) {
                        var nextPsi = tpmsRoot.rrPsi >= 35 ? 31 : (tpmsRoot.rrPsi === 31 ? 24 : (tpmsRoot.rrPsi === 24 ? 38 : 35));
                        controller.setRrPsi(nextPsi);
                    }
                }
                onWheel: function(wheel) {
                    if (controller) {
                        var delta = wheel.angleDelta.y > 0 ? 1 : -1;
                        controller.adjustPsi("RR", delta);
                    }
                }
            }
        }

        // Unit Label "psi" / "kPa" / "bar"
        Text {
            anchors.top: parent.bottom
            anchors.topMargin: 3
            anchors.horizontalCenter: parent.horizontalCenter
            text: controller ? controller.tpmsUnit : "psi"
            font.pixelSize: 15
            font.family: "Hyundai Sans Head Medium"
            font.weight: Font.DemiBold
            color: "#FFFFFF"
        }
    }

    // 4. "Drive to display" Overlay Card (Photo 3)
    Rectangle {
        id: driveToDisplayCard
        anchors.centerIn: carContainer
        width: 156
        height: 52
        radius: 4
        visible: !tpmsRoot.calibrated
        opacity: !tpmsRoot.calibrated ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        color: "#B0081420"
        border.color: "#5000E5FF"
        border.width: 1.2

        Text {
            anchors.centerIn: parent
            text: tpmsRoot.isHindi ? "प्रदर्शित करने के लिए ड्राइव करें" : "Drive to display"
            font.pixelSize: tpmsRoot.isHindi ? 12 : 16
            font.family: "Hyundai Sans Head Medium"
            font.weight: Font.DemiBold
            color: "#FFFFFF"
        }
    }
}
