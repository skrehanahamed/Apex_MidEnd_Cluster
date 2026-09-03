/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           FuelIcon.qml
 * Author:         SK Rehan Ahamed
 * Description:    Digital Fuel Pump & Left-Arrow Indicator Icon
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick
import QtQuick.Effects

Item {
    id: root
    implicitWidth: 48
    implicitHeight: 34

    property color iconColor: "#ffffff"
    property bool isLowFuel: false
    property color activeColor: isLowFuel ? "#ff9f1c" : iconColor

    Behavior on activeColor {
        ColorAnimation { duration: 300 }
    }

    Image {
        id: iconImg
        anchors.fill: parent
        source: "qrc:/qt/qml/ApexCluster/resources/icons/fuel_meter_icon.png"
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true
        asynchronous: false
        layer.enabled: root.isLowFuel
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: root.activeColor
        }
    }
}
