/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           SevenSegmentDigit.qml
 * Author:         SK Rehan Ahamed
 * Description:    Custom 7-Segment Automotive Digital Digit Component
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: root
    property string digit: "0"
    property color activeColor: "#FFFFFF"
    property color ghostColor: "#0A1422"
    property real segmentThickness: 7.5

    implicitWidth: 44
    implicitHeight: 74

    readonly property var segMap: {
        "0": [true,  true,  true,  true,  true,  true,  false],
        "1": [false, true,  true,  false, false, false, false],
        "2": [true,  true,  false, true,  true,  false, true ],
        "3": [true,  true,  true,  true,  false, false, true ],
        "4": [false, true,  true,  false, false, true,  true ],
        "5": [true,  false, true,  true,  false, true,  true ],
        "6": [true,  false, true,  true,  true,  true,  true ],
        "7": [true,  true,  true,  false, false, false, false],
        "8": [true,  true,  true,  true,  true,  true,  true ],
        "9": [true,  true,  true,  true,  false, true,  true ],
        "-": [false, false, false, false, false, false, true ],
        " ": [false, false, false, false, false, false, false]
    }

    readonly property var activeSegs: segMap[root.digit] || [false, false, false, false, false, false, false]

    readonly property real w: width
    readonly property real h: height
    readonly property real t: segmentThickness
    readonly property real gap: 2.0

    // Segment A (Top Horizontal)
    Rectangle {
        x: t + gap
        y: 0
        width: w - 2 * (t + gap)
        height: t
        radius: 1.5
        color: root.activeSegs[0] ? root.activeColor : root.ghostColor
    }

    // Segment B (Top-Right Vertical)
    Rectangle {
        x: w - t
        y: t + gap
        width: t
        height: (h / 2) - t - 1.5 * gap
        radius: 1.5
        color: root.activeSegs[1] ? root.activeColor : root.ghostColor
    }

    // Segment C (Bottom-Right Vertical)
    Rectangle {
        x: w - t
        y: (h / 2) + 0.5 * gap
        width: t
        height: (h / 2) - t - 1.5 * gap
        radius: 1.5
        color: root.activeSegs[2] ? root.activeColor : root.ghostColor
    }

    // Segment D (Bottom Horizontal)
    Rectangle {
        x: t + gap
        y: h - t
        width: w - 2 * (t + gap)
        height: t
        radius: 1.5
        color: root.activeSegs[3] ? root.activeColor : root.ghostColor
    }

    // Segment E (Bottom-Left Vertical)
    Rectangle {
        x: 0
        y: (h / 2) + 0.5 * gap
        width: t
        height: (h / 2) - t - 1.5 * gap
        radius: 1.5
        color: root.activeSegs[4] ? root.activeColor : root.ghostColor
    }

    // Segment F (Top-Left Vertical)
    Rectangle {
        x: 0
        y: t + gap
        width: t
        height: (h / 2) - t - 1.5 * gap
        radius: 1.5
        color: root.activeSegs[5] ? root.activeColor : root.ghostColor
    }

    // Segment G (Middle Horizontal)
    Rectangle {
        x: t + gap
        y: (h / 2) - (t / 2)
        width: w - 2 * (t + gap)
        height: t
        radius: 1.5
        color: root.activeSegs[6] ? root.activeColor : root.ghostColor
    }
}
