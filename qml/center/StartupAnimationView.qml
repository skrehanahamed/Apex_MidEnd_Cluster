/**
 * ============================================================================
 * Project:        APEX Horizon Digital Instrument Cluster HMI
 * File:           StartupAnimationView.qml
 * Description:    Pure APEX Logo -> WELCOME -> Ready to Drive Animation (Line-Free)
 * ============================================================================
 */

import QtQuick
import QtQuick.Effects

Item {
    id: startupAnimRoot
    implicitWidth: 198
    implicitHeight: 366

    // Master 3.6-Second Welcome Animation Timeline (0.0 to 1.0)
    property real animProgress: 0.0

    NumberAnimation {
        id: startupTimeline
        target: startupAnimRoot
        property: "animProgress"
        from: 0.0
        to: 1.0
        duration: 3600
        easing.type: Easing.InOutCubic
        running: startupAnimRoot.visible
    }

    // Pure Deep Midnight Black - Zero background shapes or glows
    Rectangle {
        anchors.fill: parent
        color: "#01040A"
    }

    // Master Fade Envelope
    readonly property real masterOpacity: {
        if (animProgress < 0.08) return animProgress / 0.08;
        if (animProgress > 0.88) return Math.max(0.0, 1.0 - (animProgress - 0.88) / 0.12);
        return 1.0;
    }

    // Center Branding Container (Strictly Line-Free)
    Item {
        id: brandContainer
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -12
        width: parent.width
        height: 150
        opacity: masterOpacity

        // ========================================================
        // 1. APEX LOGO ONLY
        // ========================================================
        Image {
            id: apexLogoImg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            width: 158
            height: 35
            source: "qrc:/qt/qml/ApexCluster/assets/apex_logo.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            scale: 0.88 + 0.12 * Math.min(1.0, animProgress / 0.35)
            opacity: Math.min(1.0, animProgress / 0.16)
        }

        // Metallic Specular Shimmer Sweep across the APEX Logo
        Item {
            id: shimmerSource
            anchors.fill: apexLogoImg
            visible: false

            Rectangle {
                id: shimmerBar
                width: 32
                height: parent.height * 2.4
                anchors.verticalCenter: parent.verticalCenter
                rotation: 25
                x: {
                    var p = Math.max(0.0, Math.min(1.0, (animProgress - 0.18) / 0.45));
                    return -width - 25 + p * (apexLogoImg.width + width + 50);
                }
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#E0FFFFFF" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        MultiEffect {
            anchors.fill: apexLogoImg
            source: shimmerSource
            maskEnabled: true
            maskSource: apexLogoImg
            maskThresholdMin: 0.10
            maskSpreadAtMin: 0.05
            opacity: (animProgress >= 0.18 && animProgress <= 0.68) ? 0.95 : 0.0
            z: 5
        }

        // ========================================================
        // 2. "WELCOME" SECTION (NO LINES)
        // ========================================================
        Text {
            id: welcomeText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: apexLogoImg.bottom
            anchors.topMargin: 20
            text: "WELCOME"
            font.family: "Rajdhani"
            font.pixelSize: 18
            font.weight: Font.Bold
            // Dynamic expanding letter tracking for futuristic reveal
            font.letterSpacing: {
                var p = Math.max(0.0, Math.min(1.0, (animProgress - 0.26) / 0.35));
                return 3.0 + p * 3.5;
            }
            color: "#FFFFFF"
            opacity: {
                var p = Math.max(0.0, Math.min(1.0, (animProgress - 0.26) / 0.25));
                return p;
            }
            scale: {
                var p = Math.max(0.0, Math.min(1.0, (animProgress - 0.26) / 0.35));
                return 0.88 + 0.12 * p;
            }
        }

        // Soft Cyan Atmospheric Accent Glow on WELCOME
        Text {
            anchors.centerIn: welcomeText
            text: welcomeText.text
            font.family: welcomeText.font.family
            font.pixelSize: welcomeText.font.pixelSize
            font.weight: welcomeText.font.weight
            font.letterSpacing: welcomeText.font.letterSpacing
            color: "#00E5FF"
            opacity: welcomeText.opacity * 0.35
            scale: welcomeText.scale * 1.04
            z: -1
        }

        // ========================================================
        // 3. "Ready to Drive" SECTION (NO LINES)
        // ========================================================
        Text {
            id: readyText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: welcomeText.bottom
            anchors.topMargin: 9
            text: "Ready to Drive"
            font.family: "Cluster Sans Head"
            font.pixelSize: 12
            font.weight: Font.Medium
            font.letterSpacing: 1.2
            color: "#80C8FF"
            opacity: {
                var p = Math.max(0.0, Math.min(1.0, (animProgress - 0.42) / 0.25));
                return p * 0.95;
            }
            scale: {
                var p = Math.max(0.0, Math.min(1.0, (animProgress - 0.42) / 0.25));
                return 0.92 + 0.08 * p;
            }
        }
    }
}
