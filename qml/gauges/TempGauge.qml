/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           TempGauge.qml
 * Author:         SK Rehan Ahamed
 * Description:    Automotive Digital Coolant Temperature Gauge (C -> H)
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: root
    implicitWidth: 560
    implicitHeight: 180

    // Temperature level (0.0 = Cold/C to 1.0 = Hot/H)
    property real level: 1.0
    property real animatedLevel: level

    // 4 quarter blocks with 3 slanted segments each (total 12 segments)
    property var groupSegmentCounts: [3, 3, 3, 3]
    readonly property int totalSegments: 12

    Behavior on animatedLevel {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    // Pure white illumination matching the OEM digital cluster reference
    property color litColor: "#ffffff"
    property color unlitColor: "#101826"
    property color unlitBorder: "#1c2a3f"
    property color railColor: "#ffffff"
    property color unlitRailColor: "#182438"
    property color glowColor: "#80d8ff"

    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        antialiasing: true
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            var totalBars = root.totalSegments;
            var numLit = Math.round(root.animatedLevel * totalBars);

            var startX = 90;
            var intraGroupGap = 4.0;
            var interGroupGap = 7.0;

            // Shift bars towards -X left axis while keeping lines in place
            var barXShift = -12.0;

            // Height & Width tapering: smaller at C (left), bigger at H (right)
            var minBarHeight = 13.0; // at C
            var maxBarHeight = 22.0; // at H
            
            var minBarWidth = 19.0;  // at C
            var maxBarWidth = 26.0;  // at H

            var baseSlant = 38.0;

            // Reverse automotive dial arc: starts flat at C (left) and sweeps upwards into H (right)
            function getTempCurveY(t) {
                var yC = 102.0; // Bottom/flat at C
                var yH = 58.0;  // Sweeps up at H
                return yC - (yC - yH) * (1.0 - Math.cos(t * (Math.PI / 2.05)));
            }

            function getBarHeight(t) {
                return minBarHeight + (maxBarHeight - minBarHeight) * t;
            }

            function getBarWidth(t) {
                return minBarWidth + (maxBarWidth - minBarWidth) * t;
            }

            // Calculate total width of all 4 groups accounting for tapering
            var numGroups = root.groupSegmentCounts.length;
            var fullSpan = 0;
            for (var g = 0; g < numGroups; g++) {
                var c = root.groupSegmentCounts[g];
                for (var cs = 0; cs < c; cs++) {
                    var estT = (g * 3 + cs) / (totalBars - 1);
                    fullSpan += getBarWidth(estT) + intraGroupGap;
                }
                fullSpan -= intraGroupGap;
                if (g < numGroups - 1) fullSpan += interGroupGap;
            }

            var globalIdx = 0;
            var curX = 0;

            for (var grp = 0; grp < numGroups; grp++) {
                var segCount = root.groupSegmentCounts[grp];
                var groupStartX = curX;

                // 1. Draw slanted segments (pure crisp white)
                for (var s = 0; s < segCount; s++) {
                    var barIdx = globalIdx;
                    var isLit = barIdx < numLit;
                    if (numLit === totalBars) isLit = true;
                    if (numLit === 0) isLit = false;

                    var t = curX / fullSpan;
                    var bx = startX + curX + barXShift;
                    var by = getTempCurveY(t);

                    var bWidth = getBarWidth(t);
                    var bHeight = getBarHeight(t);
                    var slant = baseSlant * (bHeight / maxBarHeight);

                    var tNext = (curX + bWidth) / fullSpan;
                    var byNext = getTempCurveY(tNext);
                    var bHeightNext = getBarHeight(tNext);

                    // Parallelogram corners tilted towards left axis
                    var p1x = bx;
                    var p1y = by + bHeight;

                    var p2x = bx + bWidth;
                    var p2y = byNext + bHeightNext;

                    var p3x = bx + bWidth - slant;
                    var p3y = byNext;

                    var p4x = bx - slant;
                    var p4y = by;

                    ctx.save();
                    ctx.beginPath();
                    ctx.moveTo(p1x, p1y);
                    ctx.lineTo(p2x, p2y);
                    ctx.lineTo(p3x, p3y);
                    ctx.lineTo(p4x, p4y);
                    ctx.closePath();

                    if (isLit) {
                        var litGrad = ctx.createLinearGradient(p4x, p4y, p1x, p1y);
                        litGrad.addColorStop(0, "#ffffff");
                        litGrad.addColorStop(0.55, "#ffffff");
                        litGrad.addColorStop(1, "#d4efff");

                        ctx.fillStyle = litGrad;
                        ctx.shadowColor = root.glowColor;
                        ctx.shadowBlur = 10;
                        ctx.fill();

                        // Inner crisp edge highlight
                        ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.9);
                        ctx.lineWidth = 0.7;
                        ctx.stroke();
                    } else {
                        ctx.fillStyle = root.unlitColor;
                        ctx.fill();

                        ctx.strokeStyle = root.unlitBorder;
                        ctx.lineWidth = 1.0;
                        ctx.stroke();
                    }
                    ctx.restore();

                    curX += bWidth + intraGroupGap;
                    globalIdx++;
                }

                var groupEndX = curX - intraGroupGap;

                // 2. Draw the POINTY / SLANTED BOTTOM LINE for this block (ALWAYS ILLUMINATED PURE WHITE)
                var railH = 3.5;
                var railGap = 4.0;

                var r_t0 = groupStartX / fullSpan;
                var r_t1 = groupEndX / fullSpan;

                var r_y0 = getTempCurveY(r_t0) + getBarHeight(r_t0) + railGap;
                var r_y1 = getTempCurveY(r_t1) + getBarHeight(r_t1) + railGap;

                var r_bx0 = startX + groupStartX;
                var r_bx1 = startX + groupEndX;

                var r_slant = baseSlant * (railH / maxBarHeight);

                var rp1x = r_bx0;
                var rp1y = r_y0 + railH;

                var rp2x = r_bx1;
                var rp2y = r_y1 + railH;

                var rp3x = r_bx1 - r_slant;
                var rp3y = r_y1;

                var rp4x = r_bx0 - r_slant;
                var rp4y = r_y0;

                ctx.save();
                ctx.beginPath();
                ctx.moveTo(rp1x, rp1y);
                ctx.lineTo(rp2x, rp2y);
                ctx.lineTo(rp3x, rp3y);
                ctx.lineTo(rp4x, rp4y);
                ctx.closePath();

                var railGrad = ctx.createLinearGradient(rp4x, rp4y, rp1x, rp1y);
                railGrad.addColorStop(0, "#ffffff");
                railGrad.addColorStop(0.55, "#ffffff");
                railGrad.addColorStop(1, "#c8ebff");

                ctx.fillStyle = railGrad;
                ctx.shadowColor = root.glowColor;
                ctx.shadowBlur = 9;
                ctx.fill();

                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.85);
                ctx.lineWidth = 0.5;
                ctx.stroke();
                ctx.restore();

                curX = groupEndX + interGroupGap;
            }
        }
    }

    onAnimatedLevelChanged: canvas.requestPaint()
    onLitColorChanged: canvas.requestPaint()
    onRailColorChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()

    // "C" (Cold) Label on bottom left
    Text {
        id: coldText
        text: "C"
        font.family: "Hyundai Sans Head"
        font.pixelSize: 40
        font.weight: Font.DemiBold
        color: "#ffffff"
        x: 17
        y: 82
        width: 32
        height: 39
        style: Text.Raised
        styleColor: "#152033"
    }

    // "H" (Hot) Label on top right
    Text {
        id: hotText
        text: "H"
        font.family: "Hyundai Sans Head"
        font.pixelSize: 40
        font.weight: Font.DemiBold
        color: "#ffffff"
        x: 384
        y: 21
        style: Text.Raised
        styleColor: "#152033"
    }

    // Coolant Temperature Thermometer Icon below the 4th block on the right
    TempIcon {
        id: tempIcon
        x: 348
        y: 122
        scale: 1.2
    }
}
