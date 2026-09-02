/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           InstantEcoGauge.qml
 * Author:         SK Rehan Ahamed
 * Description:    3D Volumetric Extruded Instant Fuel Economy Gauge
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: ecoRoot
    property real value: 0.0 // 0.0 to 30.0 km/L
    property string themeColor: "blue"

    width: 176
    height: 32

    // Soft, Eye-Comfortable Automotive Illumination Palettes (Balanced & Glare-Free)
    readonly property color topFillBack: themeColor === "green" ? "#54BE82" : (themeColor === "red" ? "#D85860" : "#4A9ED8")
    readonly property color topFillFront: themeColor === "green" ? "#1E9854" : (themeColor === "red" ? "#B82838" : "#1870BC")
    readonly property color frontFillTop: themeColor === "green" ? "#188046" : (themeColor === "red" ? "#981E2C" : "#125C9E")
    readonly property color frontFillBottom: themeColor === "green" ? "#0E502B" : (themeColor === "red" ? "#64121C" : "#0A3C68")
    readonly property color neonBeamColor: themeColor === "green" ? "rgba(190, 245, 210, 0.70)" : (themeColor === "red" ? "rgba(255, 195, 200, 0.70)" : "rgba(175, 220, 255, 0.70)")
    readonly property color neonGlowColor: themeColor === "green" ? "rgba(20, 160, 80, 0.45)" : (themeColor === "red" ? "rgba(200, 35, 50, 0.45)" : "rgba(0, 120, 210, 0.45)")

    // Smooth value interpolation
    property real animatedValue: 0.0
    Behavior on animatedValue {
        NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
    }

    onValueChanged: animatedValue = Math.max(0.0, Math.min(30.0, value))

    // =================================================================
    // 1. 100% PROGRAMMATIC 3D METALLIC & GLOSSY GLASS ECO GAUGE CANVAS
    // =================================================================
    Canvas {
        id: ecoCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var w = width;
            var depthX = 7.0;
            var hTop = 9.0;
            var hFront = 6.5;
            var yFrontBottom = hTop + hFront; // 15.5
            var yBaseline = 19.5;

            var innerW = w - 2 * depthX;
            var fraction = Math.max(0.0, Math.min(1.0, ecoRoot.animatedValue / 30.0));

            var xDiv1 = depthX + innerW * (1.0 / 3.0); // 10 km/L
            var xDiv2 = depthX + innerW * (2.0 / 3.0); // 20 km/L

            // ---------------------------------------------------------
            // A. DARK METALLIC SLATE-BLUE GLASS BASE TRACK (Unfilled)
            // ---------------------------------------------------------
            // 1. Top Face (Isometric Trapezoid)
            ctx.beginPath();
            ctx.moveTo(depthX, 1.0);
            ctx.lineTo(w - depthX, 1.0);
            ctx.lineTo(w, hTop);
            ctx.lineTo(0, hTop);
            ctx.closePath();
            var bgTopGrad = ctx.createLinearGradient(0, 1.0, 0, hTop);
            bgTopGrad.addColorStop(0.0, "#1A2E46");
            bgTopGrad.addColorStop(0.5, "#102034");
            bgTopGrad.addColorStop(1.0, "#09121E");
            ctx.fillStyle = bgTopGrad;
            ctx.fill();
            ctx.strokeStyle = "#16283C";
            ctx.lineWidth = 0.8;
            ctx.stroke();

            // Top Rail Highlight Line
            ctx.beginPath();
            ctx.moveTo(depthX, 1.5);
            ctx.lineTo(w - depthX, 1.5);
            ctx.strokeStyle = "rgba(100, 160, 220, 0.45)";
            ctx.lineWidth = 0.8;
            ctx.stroke();

            // 2. Front Face (Glossy Rectangle)
            ctx.beginPath();
            ctx.moveTo(0, hTop);
            ctx.lineTo(w, hTop);
            ctx.lineTo(w, yFrontBottom);
            ctx.lineTo(0, yFrontBottom);
            ctx.closePath();
            var bgFrontGrad = ctx.createLinearGradient(0, hTop, 0, yFrontBottom);
            bgFrontGrad.addColorStop(0.0, "#0E1C2C");
            bgFrontGrad.addColorStop(0.5, "#08121E");
            bgFrontGrad.addColorStop(1.0, "#04080F");
            ctx.fillStyle = bgFrontGrad;
            ctx.fill();
            ctx.strokeStyle = "#08121C";
            ctx.lineWidth = 0.8;
            ctx.stroke();

            // 3. Diagonal Glass Specular Gloss Sheen Reflection (Top-Right)
            ctx.beginPath();
            ctx.moveTo(xDiv2 + 10, 1.0);
            ctx.lineTo(w - depthX - 6, 1.0);
            ctx.lineTo(w - 18, hTop);
            ctx.lineTo(xDiv2 + 2, hTop);
            ctx.closePath();
            var glossGrad = ctx.createLinearGradient(xDiv2 + 10, 1.0, w - 18, hTop);
            glossGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.32)");
            glossGrad.addColorStop(0.5, "rgba(255, 255, 255, 0.12)");
            glossGrad.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");
            ctx.fillStyle = glossGrad;
            ctx.fill();

            // ---------------------------------------------------------
            // B. DYNAMIC 3D VIBRANT ILLUMINATED LEVEL FILL (When fraction > 0)
            // ---------------------------------------------------------
            if (fraction > 0.005) {
                var fillWFront = w * fraction;
                var fillWTop = depthX + (w - 2 * depthX) * fraction;

                // 1. Fill Top Face (Luminous Glass Gradient)
                ctx.beginPath();
                ctx.moveTo(depthX, 1.0);
                ctx.lineTo(fillWTop, 1.0);
                ctx.lineTo(fillWFront, hTop);
                ctx.lineTo(0, hTop);
                ctx.closePath();

                var fillTopGrad = ctx.createLinearGradient(0, 1.0, 0, hTop);
                fillTopGrad.addColorStop(0.0, ecoRoot.topFillBack);
                fillTopGrad.addColorStop(0.6, ecoRoot.topFillFront);
                fillTopGrad.addColorStop(1.0, ecoRoot.topFillBack);
                ctx.fillStyle = fillTopGrad;
                ctx.fill();

                // Top Specular Highlight Line
                ctx.beginPath();
                ctx.moveTo(depthX, 1.5);
                ctx.lineTo(fillWTop, 1.5);
                ctx.strokeStyle = "rgba(255, 255, 255, 0.90)";
                ctx.lineWidth = 1.0;
                ctx.stroke();

                // 2. Fill Front Face (Deep 3D Volume Gradient)
                ctx.beginPath();
                ctx.moveTo(0, hTop);
                ctx.lineTo(fillWFront, hTop);
                ctx.lineTo(fillWFront, yFrontBottom);
                ctx.lineTo(0, yFrontBottom);
                ctx.closePath();

                var fillFrontGrad = ctx.createLinearGradient(0, hTop, 0, yFrontBottom);
                fillFrontGrad.addColorStop(0.0, ecoRoot.frontFillTop);
                fillFrontGrad.addColorStop(1.0, ecoRoot.frontFillBottom);
                ctx.fillStyle = fillFrontGrad;
                ctx.fill();

                // 3. Gentle Ambient Horizontal Core Beam
                ctx.beginPath();
                ctx.moveTo(4, hTop + hFront * 0.55);
                ctx.lineTo(fillWFront, hTop + hFront * 0.55);
                ctx.strokeStyle = ecoRoot.neonGlowColor;
                ctx.lineWidth = 2.2;
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(4, hTop + hFront * 0.55);
                ctx.lineTo(fillWFront, hTop + hFront * 0.55);
                ctx.strokeStyle = ecoRoot.neonBeamColor;
                ctx.lineWidth = 1.0;
                ctx.stroke();

                // 4. Leading Edge Tip Divider Line
                ctx.beginPath();
                ctx.moveTo(fillWTop, 1.0);
                ctx.lineTo(fillWFront, hTop);
                ctx.lineTo(fillWFront, yFrontBottom);
                ctx.strokeStyle = "#FFFFFF";
                ctx.lineWidth = 1.6;
                ctx.stroke();
            }

            // ---------------------------------------------------------
            // C. SHARP HORIZONTAL SPECULAR RIDGE CREASE LINE
            // ---------------------------------------------------------
            // Ridge over fill
            if (fraction > 0.005) {
                ctx.beginPath();
                ctx.moveTo(0, hTop);
                ctx.lineTo(w * fraction, hTop);
                ctx.strokeStyle = "rgba(255, 255, 255, 0.95)";
                ctx.lineWidth = 1.2;
                ctx.stroke();
            }

            // Ridge over unfilled glass track
            ctx.beginPath();
            ctx.moveTo(w * fraction, hTop);
            ctx.lineTo(w, hTop);
            ctx.strokeStyle = "rgba(140, 185, 230, 0.70)";
            ctx.lineWidth = 1.0;
            ctx.stroke();

            // Bottom base rail line
            ctx.beginPath();
            ctx.moveTo(0, yFrontBottom);
            ctx.lineTo(w, yFrontBottom);
            ctx.strokeStyle = "rgba(70, 120, 170, 0.55)";
            ctx.lineWidth = 0.8;
            ctx.stroke();

            // ---------------------------------------------------------
            // D. 3D DIVIDER GRID LINES & METALLIC KNOBS AT 10 & 20
            // ---------------------------------------------------------
            // 1. Divider at 10 km/L
            var div1XTop = depthX + (w - 2 * depthX) * (1.0 / 3.0);
            var div1XFront = w * (1.0 / 3.0);
            ctx.beginPath();
            ctx.moveTo(div1XTop, 1.0);
            ctx.lineTo(div1XFront, hTop);
            ctx.lineTo(div1XFront, yFrontBottom);
            ctx.strokeStyle = "rgba(255, 255, 255, 0.85)";
            ctx.lineWidth = 1.2;
            ctx.stroke();

            // Protruding 3D Knob / Notch Tab at 10 (Connecting down to baseline)
            ctx.beginPath();
            ctx.moveTo(div1XFront, yFrontBottom);
            ctx.lineTo(div1XFront, yBaseline);
            ctx.strokeStyle = "#D0E2F4";
            ctx.lineWidth = 1.8;
            ctx.stroke();

            // 2. Divider at 20 km/L
            var div2XTop = depthX + (w - 2 * depthX) * (2.0 / 3.0);
            var div2XFront = w * (2.0 / 3.0);
            ctx.beginPath();
            ctx.moveTo(div2XTop, 1.0);
            ctx.lineTo(div2XFront, hTop);
            ctx.lineTo(div2XFront, yFrontBottom);
            ctx.strokeStyle = "rgba(255, 255, 255, 0.85)";
            ctx.lineWidth = 1.2;
            ctx.stroke();

            // Protruding 3D Knob / Notch Tab at 20 (Connecting down to baseline)
            ctx.beginPath();
            ctx.moveTo(div2XFront, yFrontBottom);
            ctx.lineTo(div2XFront, yBaseline);
            ctx.strokeStyle = "#D0E2F4";
            ctx.lineWidth = 1.8;
            ctx.stroke();

            // ---------------------------------------------------------
            // E. SOLID 3D CHROME / METALLIC BRUSHED END CAPS ([ and ])
            // ---------------------------------------------------------
            // 1. Left Chrome Cap Pillar [
            ctx.beginPath();
            ctx.moveTo(depthX + 2.5, 0.5);
            ctx.lineTo(depthX - 0.5, 0.5);
            ctx.lineTo(-0.5, hTop);
            ctx.lineTo(-0.5, yFrontBottom + 0.5);
            ctx.lineTo(3.5, yFrontBottom + 0.5);
            ctx.strokeStyle = "#FFFFFF";
            ctx.lineWidth = 2.4;
            ctx.stroke();

            // Left Bottom Tab down to baseline
            ctx.beginPath();
            ctx.moveTo(4.0, yFrontBottom);
            ctx.lineTo(4.0, yBaseline);
            ctx.strokeStyle = "#D0E2F4";
            ctx.lineWidth = 1.8;
            ctx.stroke();

            // 2. Right Chrome Cap Pillar ]
            ctx.beginPath();
            ctx.moveTo(w - depthX - 2.5, 0.5);
            ctx.lineTo(w - depthX + 0.5, 0.5);
            ctx.lineTo(w + 0.5, hTop);
            ctx.lineTo(w + 0.5, yFrontBottom + 0.5);
            ctx.lineTo(w - 3.5, yFrontBottom + 0.5);
            ctx.strokeStyle = "#FFFFFF";
            ctx.lineWidth = 2.4;
            ctx.stroke();

            // Right Bottom Tab down to baseline
            ctx.beginPath();
            ctx.moveTo(w - 4.0, yFrontBottom);
            ctx.lineTo(w - 4.0, yBaseline);
            ctx.strokeStyle = "#D0E2F4";
            ctx.lineWidth = 1.8;
            ctx.stroke();

            // ---------------------------------------------------------
            // F. CONTINUOUS THIN METALLIC SCALE BASELINE (0 to 30)
            // ---------------------------------------------------------
            ctx.beginPath();
            ctx.moveTo(4.0, yBaseline);
            ctx.lineTo(w - 4.0, yBaseline);
            ctx.strokeStyle = "rgba(160, 195, 230, 0.70)";
            ctx.lineWidth = 1.0;
            ctx.stroke();
        }

        Connections {
            target: ecoRoot
            function onAnimatedValueChanged() { ecoCanvas.requestPaint(); }
            function onThemeColorChanged() { ecoCanvas.requestPaint(); }
        }
    }

    // =================================================================
    // 2. SCALE NUMBERS: 0, 10, 20, 30 (Alignd Underneath Baseline)
    // =================================================================
    Item {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        height: 12

        // 0
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 1
            anchors.verticalCenter: parent.verticalCenter
            text: "0"
            font.pixelSize: 11
            font.family: "Hyundai Sans Head"
            font.weight: Font.DemiBold
            color: "#FFFFFF"
        }

        // 10
        Text {
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: parent.width * (1.0 / 3.0)
            anchors.verticalCenter: parent.verticalCenter
            text: "10"
            font.pixelSize: 11
            font.family: "Hyundai Sans Head"
            font.weight: Font.DemiBold
            color: "#FFFFFF"
        }

        // 20
        Text {
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: parent.width * (2.0 / 3.0)
            anchors.verticalCenter: parent.verticalCenter
            text: "20"
            font.pixelSize: 11
            font.family: "Hyundai Sans Head"
            font.weight: Font.DemiBold
            color: "#FFFFFF"
        }

        // 30
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 1
            anchors.verticalCenter: parent.verticalCenter
            text: "30"
            font.pixelSize: 11
            font.family: "Hyundai Sans Head"
            font.weight: Font.DemiBold
            color: "#FFFFFF"
        }
    }
}
