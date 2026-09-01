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
        easing.type: Easing.InOutSine
        running: startupAnimRoot.visible
    }

    // Deep Pure Black Cluster Background
    Rectangle {
        anchors.fill: parent
        color: "#02060E"
    }

    // Photorealistic 3-Section Fluid "Wave of Light" Canvas (3.8s Welcome Sequence)
    Canvas {
        id: waveCanvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var p = startupAnimRoot.animProgress;
            var cy = height / 2;
            var w = width;

            // Master Entry & Exit Envelope
            var masterAlpha = 1.0;
            if (p < 0.12) {
                masterAlpha = p / 0.12; // Smooth 0.4s fade-in
            } else if (p > 0.88) {
                masterAlpha = Math.max(0.0, 1.0 - (p - 0.88) / 0.12); // Smooth dissolve out
            }

            if (masterAlpha <= 0.001) return;

            // =================================================================
            // SECTION 1: EXPANDING AMBIENT RADIAL LIGHT AURA & HORIZON GLOW
            // =================================================================
            var auraPulse = Math.sin(p * Math.PI);
            var glowX = w * (0.15 + 0.7 * p);
            var mistGrad = ctx.createRadialGradient(glowX, cy, 10, glowX, cy, 110);
            mistGrad.addColorStop(0.0, "rgba(0, 229, 255, " + (0.32 * masterAlpha * auraPulse) + ")");
            mistGrad.addColorStop(0.4, "rgba(0, 110, 240, " + (0.16 * masterAlpha * auraPulse) + ")");
            mistGrad.addColorStop(1.0, "rgba(0, 20, 90, 0.0)");

            ctx.fillStyle = mistGrad;
            ctx.fillRect(0, cy - 120, w, 240);

            // =================================================================
            // SECTION 2: MULTI-LAYERED UNDULATING WAVE OF LIGHT (Flowing 3D Ribbons)
            // =================================================================
            var cycleSpeed = p * Math.PI * 7.5;

            // Envelope: Starts flat, undulates high during middle 2.5s, settles into horizon
            var waveAmpMaster = Math.sin(p * Math.PI);

            // --- Wave Layer 1: Deep Blue-Cyan Ambient Ribbon ---
            ctx.save();
            ctx.beginPath();
            var amp1 = 32.0 * waveAmpMaster;
            ctx.moveTo(0, cy);
            for (var x = 0; x <= w; x += 3) {
                var normX = x / w;
                var envelope = Math.sin(normX * Math.PI);
                var y1 = cy + Math.sin(normX * 5.2 - cycleSpeed) * amp1 * envelope;
                ctx.lineTo(x, y1);
            }
            ctx.strokeStyle = "rgba(0, 130, 255, " + (0.40 * masterAlpha) + ")";
            ctx.lineWidth = 7.0;
            ctx.lineCap = "round";
            ctx.stroke();
            ctx.restore();

            // --- Wave Layer 2: Secondary Harmonic Neon Ribbon ---
            ctx.save();
            ctx.beginPath();
            var amp2 = 24.0 * waveAmpMaster;
            ctx.moveTo(0, cy);
            for (var x2 = 0; x2 <= w; x2 += 3) {
                var normX2 = x2 / w;
                var envelope2 = Math.sin(normX2 * Math.PI);
                var y2 = cy + Math.sin(normX2 * 7.4 - cycleSpeed * 1.2 + 1.4) * amp2 * envelope2;
                ctx.lineTo(x2, y2);
            }
            ctx.strokeStyle = "rgba(0, 229, 255, " + (0.80 * masterAlpha) + ")";
            ctx.lineWidth = 3.2;
            ctx.lineCap = "round";
            ctx.stroke();
            ctx.restore();

            // --- Wave Layer 3: Specular White Core Energy Beam ---
            ctx.save();
            ctx.beginPath();
            var amp3 = 18.0 * waveAmpMaster;
            ctx.moveTo(0, cy);
            for (var x3 = 0; x3 <= w; x3 += 2) {
                var normX3 = x3 / w;
                var envelope3 = Math.sin(normX3 * Math.PI);
                var y3 = cy + Math.sin(normX3 * 6.1 - cycleSpeed * 1.1 + 0.7) * amp3 * envelope3;
                ctx.lineTo(x3, y3);
            }
            ctx.strokeStyle = "rgba(255, 255, 255, " + (0.95 * masterAlpha) + ")";
            ctx.lineWidth = 1.8;
            ctx.lineCap = "round";
            ctx.stroke();
            ctx.restore();

            // =================================================================
            // SECTION 3: TRAVELING CREST PULSE FLARE & STREAM OF LIGHT PARTICLES
            // =================================================================
            var crestP = (p * 1.4) % 1.0;
            var crestX = w * crestP;
            var crestY = cy + Math.sin(crestP * 6.1 - cycleSpeed * 1.1 + 0.7) * amp3 * Math.sin(crestP * Math.PI);

            if (crestP > 0.08 && crestP < 0.92) {
                var flareR = 15.0 * Math.sin(crestP * Math.PI) * masterAlpha;
                var flareGrad = ctx.createRadialGradient(crestX, crestY, 0, crestX, crestY, flareR * 2.2);
                flareGrad.addColorStop(0.0, "rgba(255, 255, 255, " + (1.0 * masterAlpha) + ")");
                flareGrad.addColorStop(0.35, "rgba(0, 229, 255, " + (0.85 * masterAlpha) + ")");
                flareGrad.addColorStop(1.0, "rgba(0, 229, 255, 0.0)");

                ctx.fillStyle = flareGrad;
                ctx.beginPath();
                ctx.arc(crestX, crestY, flareR * 2.2, 0, Math.PI * 2);
                ctx.fill();

                // Specular Light Crosshair Glint
                ctx.strokeStyle = "rgba(255, 255, 255, " + (0.95 * masterAlpha) + ")";
                ctx.lineWidth = 1.4;
                ctx.beginPath();
                ctx.moveTo(crestX - 18, crestY);
                ctx.lineTo(crestX + 18, crestY);
                ctx.moveTo(crestX, crestY - 10);
                ctx.lineTo(crestX, crestY + 10);
                ctx.stroke();
            }

            // Trailing Luminous Energy Particles
            var particles = [
                { dx: -28, dy: -9, r: 1.8, a: 0.8 },
                { dx: -16, dy: 11, r: 1.4, a: 0.75 },
                { dx: -42, dy: 5, r: 2.1, a: 0.65 },
                { dx: 20, dy: -14, r: 1.6, a: 0.7 },
                { dx: 36, dy: 7, r: 1.3, a: 0.5 },
                { dx: -60, dy: -6, r: 1.5, a: 0.45 },
                { dx: -75, dy: 8, r: 1.2, a: 0.35 }
            ];

            for (var i = 0; i < particles.length; i++) {
                var pt = particles[i];
                var px = crestX + pt.dx;
                var py = crestY + pt.dy;
                if (px > 2 && px < w - 2) {
                    ctx.fillStyle = "rgba(180, 245, 255, " + (pt.a * masterAlpha) + ")";
                    ctx.beginPath();
                    ctx.arc(px, py, pt.r, 0, Math.PI * 2);
                    ctx.fill();
                }
            }

            // =================================================================
            // SECTION 4: HORIZONTAL SETTLE & DISSOLVE HORIZON (During final 1.0s)
            // =================================================================
            if (p > 0.65) {
                var settleP = (p - 0.65) / 0.35;
                var horizonAlpha = Math.sin(settleP * Math.PI) * 0.7 * masterAlpha;

                var hGrad = ctx.createLinearGradient(0, cy, w, cy);
                hGrad.addColorStop(0.0, "rgba(0, 229, 255, 0.0)");
                hGrad.addColorStop(0.2, "rgba(0, 229, 255, " + (0.5 * horizonAlpha) + ")");
                hGrad.addColorStop(0.5, "rgba(255, 255, 255, " + horizonAlpha + ")");
                hGrad.addColorStop(0.8, "rgba(0, 229, 255, " + (0.5 * horizonAlpha) + ")");
                hGrad.addColorStop(1.0, "rgba(0, 229, 255, 0.0)");

                ctx.strokeStyle = hGrad;
                ctx.lineWidth = 1.8;
                ctx.beginPath();
                ctx.moveTo(0, cy + 20 * (1.0 - settleP));
                ctx.lineTo(w, cy + 20 * (1.0 - settleP));
                ctx.stroke();
            }
        }

        Connections {
            target: startupAnimRoot
            function onAnimProgressChanged() { waveCanvas.requestPaint(); }
        }
    }
}
