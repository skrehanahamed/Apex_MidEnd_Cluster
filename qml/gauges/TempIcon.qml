/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           TempIcon.qml
 * Author:         SK Rehan Ahamed
 * Description:    Digital Coolant Temperature Thermometer Icon
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: root
    implicitWidth: 48
    implicitHeight: 34

    property color iconColor: "#ffffff"

    Image {
        id: iconImg
        anchors.fill: parent
        source: "qrc:/qt/qml/ApexCluster/resources/icons/temp_meter_icon.png"
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true
        asynchronous: false
    }
}
