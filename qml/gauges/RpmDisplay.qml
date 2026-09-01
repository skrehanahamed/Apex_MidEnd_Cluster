/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           RpmDisplay.qml
 * Author:         SK Rehan Ahamed
 * Description:    Digital Tachometer & RPM Torque Curve Display
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: rpmRoot
    property real rpmValue: 0.0
    implicitWidth: 150
    implicitHeight: 120

    Column {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: rpmRoot.rpmValue.toFixed(1)
            font.pixelSize: 62
            font.bold: true
            font.family: "DSEG7 Classic"
            color: "#FFFFFF"
            style: Text.Normal
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "x1000rpm"
            font.pixelSize: 14
            font.bold: true
            font.family: "Rajdhani"
            color: "#FFFFFF"
            font.letterSpacing: 0.5
        }
    }
}


