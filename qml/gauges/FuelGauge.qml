/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           FuelGauge.qml
 * Author:         SK Rehan Ahamed
 * Description:    Automotive Digital Segmented Fuel Gauge (F -> E)
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: root
    implicitWidth: 560
    implicitHeight: 180

    // Fuel level (0.0 to 1.0)
    property real level: 1.0
    property real animatedLevel: level
    property bool isBootCheck: false
    property bool lowFuelAlert: !isBootCheck && (typeof controller !== "undefined" && controller ? (controller.fuelLevel <= 2) : (animatedLevel <= 0.18))

    // 4 quarter blocks with 3 slanted segments each (total 12 segments)
    property var groupSegmentCounts: [3, 3, 3, 3]
    readonly property int totalSegments: 12

    Behavior on animatedLevel {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    // Colors matching OEM Hyundai digital cluster
    property color litColor: lowFuelAlert ? "#ff9f1c" : "#ffffff"
    property color unlitColor: "#101826"
    property color unlitBorder: "#1c2a3f"
    property color railColor: lowFuelAlert ? "#ff9f1c" : "#ffffff"
    property color unlitRailColor: "#182438"
    property color glowColor: lowFuelAlert ? "#ffa938" : "#80d8ff"

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

            var startX = 60;
            var intraGroupGap = 4.0;
            var interGroupGap = 7.0;

            // Shift bars further along +X axis
            var barXShift = 12.0;

            // Height & Width: elongated along X axis
            var maxBarHeight = 22.0; // at F
            var minBarHeight = 13.0; // at E
            
            var maxBarWidth = 26.0;  // at F
            var minBarWidth = 19.0;  // at E

            var baseSlant = 38.0;

            // Base curve for the fuel meter
            function getFuelCurveY(t) {
                var y0 = 62.0;
                var y1 = 102.0;
                return y0 + (y1 - y0) * Math.sin(t * (Math.PI / 2.05));
            }

            function getBarHeight(t) {
                return maxBarHeight + (minBarHeight - maxBarHeight) * t;
            }

            function getBarWidth(t) {
                return maxBarWidth + (minBarWidth - maxBarWidth) * t;
            }

            // Calculate total width of all 4 groups
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

                // 1. Draw slanted segments for this block
                for (var s = 0; s < segCount; s++) {
                    var barIdx = globalIdx;
                    var isLit = (barIdx >= (totalBars - numLit));
                    if (numLit === totalBars) isLit = true;
                    if (numLit === 0) isLit = false;

                    var t = curX / fullSpan;
                    var bx = startX + curX + barXShift;
                    var by = getFuelCurveY(t);

                    var bWidth = getBarWidth(t);
                    var bHeight = getBarHeight(t);
                    var slant = baseSlant * (bHeight / maxBarHeight);

                    var tNext = (curX + bWidth) / fullSpan;
                    var byNext = getFuelCurveY(tNext);
                    var bHeightNext = getBarHeight(tNext);

                    // Parallelogram corners
                    var p1x = bx;
                    var p1y = by + bHeight;

                    var p2x = bx + bWidth;
                    var p2y = byNext + bHeightNext;

                    var p3x = bx + bWidth + slant;
                    var p3y = byNext;

                    var p4x = bx + slant;
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
                        if (root.lowFuelAlert) {
                            litGrad.addColorStop(0, root.litColor);
                            litGrad.addColorStop(1, Qt.darker(root.litColor, 1.25));
                        } else {
                            litGrad.addColorStop(0, "#ffffff");
                            litGrad.addColorStop(0.55, "#ffffff");
                            litGrad.addColorStop(1, "#d4efff");
                        }

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

                // 2. Draw the POINTY / SLANTED BOTTOM LINE for this block (ALWAYS ILLUMINATED)
                var railH = 3.5;
                var railGap = 4.0;

                var r_t0 = groupStartX / fullSpan;
                var r_t1 = groupEndX / fullSpan;

                var r_y0 = getFuelCurveY(r_t0) + getBarHeight(r_t0) + railGap;
                var r_y1 = getFuelCurveY(r_t1) + getBarHeight(r_t1) + railGap;

                var r_bx0 = startX + groupStartX;
                var r_bx1 = startX + groupEndX;

                var r_slant = baseSlant * (railH / maxBarHeight);

                var rp1x = r_bx0;
                var rp1y = r_y0 + railH;

                var rp2x = r_bx1;
                var rp2y = r_y1 + railH;

                var rp3x = r_bx1 + r_slant;
                var rp3y = r_y1;

                var rp4x = r_bx0 + r_slant;
                var rp4y = r_y0;

                ctx.save();
                ctx.beginPath();
                ctx.moveTo(rp1x, rp1y);
                ctx.lineTo(rp2x, rp2y);
                ctx.lineTo(rp3x, rp3y);
                ctx.lineTo(rp4x, rp4y);
                ctx.closePath();

                var railGrad = ctx.createLinearGradient(rp4x, rp4y, rp1x, rp1y);
                if (root.lowFuelAlert) {
                    railGrad.addColorStop(0, root.railColor);
                    railGrad.addColorStop(1, Qt.darker(root.railColor, 1.25));
                } else {
                    railGrad.addColorStop(0, "#ffffff");
                    railGrad.addColorStop(0.55, "#ffffff");
                    railGrad.addColorStop(1, "#c8ebff");
                }

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
    onLowFuelAlertChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()

    // "F" Label on top left
    Text {
        id: fullText
        text: "F"
        font.family: "Hyundai Sans Head"
        font.pixelSize: 40
        font.weight: Font.DemiBold
        color: root.lowFuelAlert && root.animatedLevel >= 0.9 ? root.litColor : "#ffffff"
        x: 48
        y: 34
        width: 32
        height: 39
        style: Text.Raised
        styleColor: "#152033"
    }

    // "E" Label on bottom right
    Text {
        id: emptyText
        text: "E"
        font.family: "Hyundai Sans Head"
        font.pixelSize: 40
        font.weight: Font.DemiBold
        color: root.lowFuelAlert ? root.litColor : "#ffffff"
        x: 430
        y: 82
        style: Text.Raised
        styleColor: "#152033"
    }

    // Fuel Pump Icon with Left Arrow below first block
    FuelIcon {
        id: fuelPumpIcon
        x: 84
        y: 127
        isLowFuel: root.lowFuelAlert
        scale: 1.2
    }
}
