/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           VehicleCheckView.qml
 * Author:         SK Rehan Ahamed
 * Description:    Authentic OEM Hyundai System Check - Photorealistic Texture Sequence
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick
import QtQuick.Effects

Item {
    id: vehicleRoot
    implicitWidth: 198
    implicitHeight: 366

    // Master Timeline Progress Property (0.0 to 1.0 over 2000ms reveal)
    property real checkProgress: 0.0
    readonly property bool isHindi: controller && (controller.language === "हिन्दी" || controller.language === "Hindi")
    FontLoader { id: hyundaiMedium; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Medium.ttf" }
    FontLoader { id: notoDevanagari; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/NotoSansDevanagari-Regular.ttf" }
    readonly property string fontHeadMedium: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (hyundaiMedium.status === FontLoader.Ready ? hyundaiMedium.name : "Hyundai Sans Head Medium")

    NumberAnimation {
        id: checkTimelineAnim
        target: vehicleRoot
        property: "checkProgress"
        from: 0.0
        to: 1.0
        duration: 2000
        easing.type: Easing.InOutQuad
        running: vehicleRoot.visible
    }

    // Deep Midnight Base Background
    Rectangle {
        anchors.fill: parent
        color: "#01040A"
    }

    // ========================================================
    // 0. SYSTEM CHECK TITLE HEADER
    // ========================================================
    Text {
        id: systemCheckTitle
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        text: (controller && (controller.language === "हिन्दी" || controller.language === "Hindi")) ? "सिस्टम जाँच" : "System check"
        font.pixelSize: 18
        font.family: vehicleRoot.fontHeadMedium
        font.weight: Font.DemiBold
        color: "#FFFFFF"
        font.letterSpacing: 0.3
        z: 20
        opacity: Math.min(1.0, Math.max(0.0, (vehicleRoot.checkProgress - 0.10) / 0.30))
    }

    // Base vertical positioning on the ground
    readonly property real baseCarY: 18.0

    // ========================================================
    // 1. OEM STUDIO ILLUMINATED BLUE ASPHALT ROAD BACKGROUND
    // ========================================================
    Image {
        id: studioGroundBg
        anchors.fill: parent
        source: "qrc:/qt/qml/HyundaiExterCluster/assets/oem_studio_ground.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        z: 1
        opacity: Math.min(1.0, Math.max(0.0, (vehicleRoot.checkProgress - 0.15) / 0.55))
    }

    // ========================================================
    // 2. PHOTOREALISTIC GROUND CONTACT SHADOW
    // ========================================================
    Image {
        id: groundShadowImg
        anchors.centerIn: parent
        anchors.verticalCenterOffset: vehicleRoot.baseCarY + 27
        width: 170
        height: 48
        z: 2
        source: "qrc:/qt/qml/HyundaiExterCluster/assets/car_ground_shadow.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        opacity: Math.min(1.0, Math.max(0.0, (vehicleRoot.checkProgress - 0.25) / 0.50))
    }

    // ========================================================
    // 3. HYUNDAI EXTER 3D VEHICLE REVEAL
    // ========================================================
    Item {
        id: carContainer
        anchors.centerIn: parent
        width: 142
        height: 90
        z: 5
        anchors.verticalCenterOffset: vehicleRoot.baseCarY

        // 3.1 Base 3D Vehicle Render (Fades in out of the horizontal beam)
        Image {
            id: exterCarImg
            anchors.fill: parent
            source: "qrc:/qt/qml/HyundaiExterCluster/assets/hyundai_exter_car.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            opacity: {
                if (vehicleRoot.checkProgress < 0.15) {
                    return (vehicleRoot.checkProgress / 0.15) * 0.25;
                } else if (vehicleRoot.checkProgress < 0.70) {
                    return 0.25 + ((vehicleRoot.checkProgress - 0.15) / 0.55) * 0.75;
                }
                return 1.0;
            }
        }

        // 3.2 Photorealistic Specular Edge Highlight (Roofline/Windshield)
        Rectangle {
            id: carSilhouetteGlow
            anchors.fill: parent
            color: "transparent"
            border.color: "#8000E5FF"
            border.width: 1
            radius: 4
            z: 8
            opacity: {
                if (vehicleRoot.checkProgress < 0.10) {
                    return vehicleRoot.checkProgress / 0.10;
                } else if (vehicleRoot.checkProgress < 0.45) {
                    return 0.50;
                } else if (vehicleRoot.checkProgress < 0.80) {
                    return Math.max(0.0, 0.50 * (1.0 - (vehicleRoot.checkProgress - 0.45) / 0.35));
                }
                return 0.0;
            }
            visible: opacity > 0.001
        }

        // 3.3 Continuous Metallic Specular Light Sweep
        Item {
            id: sweepLightSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: sweepBeam
                width: 44
                height: parent.height * 2.6
                anchors.verticalCenter: parent.verticalCenter
                rotation: 22
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.30; color: "#2500E5FF" }
                    GradientStop { position: 0.45; color: "#90C8FFFF" }
                    GradientStop { position: 0.50; color: "#F0FFFFFF" }
                    GradientStop { position: 0.55; color: "#90C8FFFF" }
                    GradientStop { position: 0.70; color: "#2500E5FF" }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                // Continuous infinite left-to-right shine loop
                SequentialAnimation on x {
                    loops: Animation.Infinite
                    running: vehicleRoot.visible && vehicleRoot.checkProgress > 0.40
                    NumberAnimation {
                        from: -sweepBeam.width - 20
                        to: carContainer.width + sweepBeam.width + 20
                        duration: 1400
                        easing.type: Easing.InOutQuad
                    }
                    PauseAnimation { duration: 400 }
                }
            }
        }

        // Strictly Masked Metallic Light Sweep across Car Paint Silhouette
        MultiEffect {
            anchors.fill: parent
            source: sweepLightSource
            maskEnabled: true
            maskSource: exterCarImg
            maskThresholdMin: 0.05
            maskSpreadAtMin: 0.05
            opacity: Math.min(0.90, Math.max(0.0, (vehicleRoot.checkProgress - 0.30) / 0.30 * 0.90))
            z: 9
        }
    }

    // ========================================================
    // 4. AUTHENTIC OEM LASER BEAM (Passes across Headlights/Waistline)
    // ========================================================
    Item {
        id: laserBeamContainer
        anchors.centerIn: parent
        anchors.verticalCenterOffset: vehicleRoot.baseCarY - 3
        width: parent.width * 1.15
        height: 14
        z: 12
        opacity: {
            if (vehicleRoot.checkProgress < 0.08) {
                return vehicleRoot.checkProgress / 0.08;
            } else if (vehicleRoot.checkProgress < 0.38) {
                return 1.0;
            } else if (vehicleRoot.checkProgress < 0.75) {
                return Math.max(0.0, 1.0 - (vehicleRoot.checkProgress - 0.38) / 0.37);
            }
            return 0.0;
        }
        visible: opacity > 0.001

        // Center intense cyan core line
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.2; color: "#00E5FF" }
                GradientStop { position: 0.5; color: "#FFFFFF" }
                GradientStop { position: 0.8; color: "#00E5FF" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Soft halo glow
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: 8
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.25; color: "#3000E5FF" }
                GradientStop { position: 0.50; color: "#8000E5FF" }
                GradientStop { position: 0.75; color: "#3000E5FF" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // ========================================================
    // 5. 3 OCCUPANT SEATBELT ALERT ICONS (Startup bulb check: All 3 solid red)
    // ========================================================
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 3
        opacity: Math.min(1.0, Math.max(0.0, (vehicleRoot.checkProgress - 0.15) / 0.35))
        z: 20

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
}
