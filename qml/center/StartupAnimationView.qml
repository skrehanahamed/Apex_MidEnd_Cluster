/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           StartupAnimationView.qml
 * Author:         SK Rehan Ahamed
 * Description:    Authentic OEM Hyundai HD Welcome Sequence - Frame-Accurate Blue Matrix Funnel & Laser Convergence
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: startupAnimRoot
    implicitWidth: 198
    implicitHeight: 366

    // Master 3.8-Second Welcome Animation Timeline (0.0 to 1.0)
    property real animProgress: 0.0

    NumberAnimation {
        id: startupTimeline
        target: startupAnimRoot
        property: "animProgress"
        from: 0.0
        to: 1.0
        duration: 3800
        easing.type: Easing.InOutQuad
        running: startupAnimRoot.visible
    }

    // Deep Midnight Pure Black Cluster Background
    Rectangle {
        anchors.fill: parent
        color: "#01040A"
    }

    // Canvas: OEM Blue Dot-Matrix Funnel & Laser Convergence (Frame-Accurate Recreation)
    Canvas {
        id: welcomeCanvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var p = startupAnimRoot.animProgress;
            var w = width;
            var h = height;
            var cy = h / 2 + 15.0; // Exactly matches side gauge baseline level

            // Master envelope
            var masterAlpha = 1.0;
            if (p < 0.06) {
                masterAlpha = p / 0.06;
            } else if (p > 0.88) {
                masterAlpha = Math.max(0.0, 1.0 - (p - 0.88) / 0.12);
            }

            if (masterAlpha <= 0.001) return;

            // =================================================================
            // 1. VOLUMETRIC AMBIENT AURA
            // =================================================================
            var auraAlpha = Math.sin(p * Math.PI) * 0.40 * masterAlpha;
            var auraGrad = ctx.createRadialGradient(w / 2, cy, 10, w / 2, cy, 140);
            auraGrad.addColorStop(0.0, "rgba(0, 160, 255, " + auraAlpha + ")");
            auraGrad.addColorStop(0.5, "rgba(0, 50, 180, " + (auraAlpha * 0.5) + ")");
            auraGrad.addColorStop(1.0, "rgba(0, 5, 30, 0.0)");
            ctx.fillStyle = auraGrad;
            ctx.fillRect(0, cy - 160, w, 320);

            // =================================================================
            // 2. STAGE 1: OEM BLUE DOT-MATRIX HYPERBOLIC FUNNEL (0.0 to 0.70)
            // =================================================================
            if (p < 0.72) {
                var s1Progress = p / 0.70;
                var s1Alpha = Math.sin(Math.min(1.0, s1Progress * 1.15) * Math.PI) * masterAlpha;

                // Convergence factor (1.0 = wide funnel, 0.0 = collapsed to line)
                var conv = Math.pow(Math.max(0.0, 1.0 - s1Progress), 1.6);
                var waveShift = s1Progress * 80.0; // Matrix travels across

                ctx.save();

                // 2.1 Render Glowing Dot-Matrix Grid inside the Funnel Envelope
                var dotSpacingX = 8.0;
                var dotSpacingY = 8.0;

                for (var gx = 0; gx <= w; gx += dotSpacingX) {
                    var nx = gx / w;
                    // Hyperbolic funnel upper and lower boundaries at column gx
                    var halfSpan = (20.0 + 90.0 * Math.pow(nx, 1.5)) * conv;
                    var yTopBound = cy - halfSpan;
                    var yBotBound = cy + halfSpan;

                    for (var gy = cy - 110; gy <= cy + 110; gy += dotSpacingY) {
                        // Check if dot falls inside the hyperbolic funnel
                        if (gy >= yTopBound && gy <= yBotBound) {
                            var distFromCenterY = Math.abs(gy - cy) / Math.max(1.0, halfSpan);
                            var dotAlpha = (1.0 - distFromCenterY * 0.6) * s1Alpha;
                            
                            // Dot size based on proximity to center and progress
                            var dotR = (1.4 + 1.2 * (1.0 - distFromCenterY)) * (0.6 + 0.4 * conv);

                            // Staggered honeycomb offset
                            var actualX = gx + ((Math.floor(gy / dotSpacingY) % 2 === 0) ? (dotSpacingX / 2) : 0);

                            // Authentic Hyundai Royal Blue to Cyan Dot Color
                            var r = Math.floor(0 + 100 * (1.0 - distFromCenterY));
                            var g = Math.floor(100 + 155 * (1.0 - distFromCenterY));
                            var b = 255;

                            ctx.fillStyle = "rgba(" + r + ", " + g + ", " + b + ", " + (dotAlpha * 0.85) + ")";
                            ctx.beginPath();
                            ctx.arc(actualX, gy, dotR, 0, Math.PI * 2);
                            ctx.fill();
                        }
                    }
                }

                // 2.2 Glowing Cyan Top & Bottom Funnel Contour Lines
                ctx.beginPath();
                for (var x = 0; x <= w; x += 4) {
                    var nxTop = x / w;
                    var yT = cy - (20.0 + 90.0 * Math.pow(nxTop, 1.5)) * conv;
                    if (x === 0) ctx.moveTo(x, yT);
                    else ctx.lineTo(x, yT);
                }
                ctx.strokeStyle = "rgba(0, 229, 255, " + (0.90 * s1Alpha) + ")";
                ctx.lineWidth = 2.4;
                ctx.stroke();

                ctx.beginPath();
                for (var x2 = 0; x2 <= w; x2 += 4) {
                    var nxBot = x2 / w;
                    var yB = cy + (20.0 + 90.0 * Math.pow(nxBot, 1.5)) * conv;
                    if (x2 === 0) ctx.moveTo(x2, yB);
                    else ctx.lineTo(x2, yB);
                }
                ctx.strokeStyle = "rgba(0, 200, 255, " + (0.90 * s1Alpha) + ")";
                ctx.lineWidth = 2.4;
                ctx.stroke();

                ctx.restore();
            }

            // =================================================================
            // 3. STAGE 2: CRISP HORIZONTAL LASER BEAM BRIDGE (0.45 to 0.95)
            // =================================================================
            if (p > 0.42) {
                var s2Progress = (p - 0.42) / 0.50;
                var s2Alpha = Math.sin(Math.min(1.0, s2Progress) * Math.PI) * masterAlpha;

                ctx.save();

                // Outer Soft Cyan Halo
                var haloGrad = ctx.createLinearGradient(0, cy, w, cy);
                haloGrad.addColorStop(0.0, "rgba(0, 160, 255, 0.0)");
                haloGrad.addColorStop(0.20, "rgba(0, 200, 255, " + (0.45 * s2Alpha) + ")");
                haloGrad.addColorStop(0.50, "rgba(180, 240, 255, " + (0.85 * s2Alpha) + ")");
                haloGrad.addColorStop(0.80, "rgba(0, 200, 255, " + (0.45 * s2Alpha) + ")");
                haloGrad.addColorStop(1.0, "rgba(0, 160, 255, 0.0)");

                ctx.strokeStyle = haloGrad;
                ctx.lineWidth = 6.0;
                ctx.beginPath();
                ctx.moveTo(0, cy);
                ctx.lineTo(w, cy);
                ctx.stroke();

                // Crisp Specular Laser Core
                var coreGrad = ctx.createLinearGradient(0, cy, w, cy);
                coreGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.0)");
                coreGrad.addColorStop(0.35, "rgba(255, 255, 255, " + (0.85 * s2Alpha) + ")");
                coreGrad.addColorStop(0.50, "rgba(255, 255, 255, " + (1.0 * s2Alpha) + ")");
                coreGrad.addColorStop(0.65, "rgba(255, 255, 255, " + (0.85 * s2Alpha) + ")");
                coreGrad.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");

                ctx.strokeStyle = coreGrad;
                ctx.lineWidth = 1.8;
                ctx.beginPath();
                ctx.moveTo(0, cy);
                ctx.lineTo(w, cy);
                ctx.stroke();

                // Radiant Center Glint Burst
                var glintGrad = ctx.createRadialGradient(w / 2, cy, 0, w / 2, cy, 14);
                glintGrad.addColorStop(0.0, "rgba(255, 255, 255, " + (1.0 * s2Alpha) + ")");
                glintGrad.addColorStop(0.40, "rgba(160, 240, 255, " + (0.75 * s2Alpha) + ")");
                glintGrad.addColorStop(1.0, "rgba(0, 140, 255, 0.0)");

                ctx.fillStyle = glintGrad;
                ctx.beginPath();
                ctx.arc(w / 2, cy, 14, 0, Math.PI * 2);
                ctx.fill();

                ctx.restore();
            }
        }

        Connections {
            target: startupAnimRoot
            function onAnimProgressChanged() { welcomeCanvas.requestPaint(); }
        }
    }
}
