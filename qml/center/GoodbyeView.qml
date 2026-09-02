/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           GoodbyeView.qml
 * Author:         SK Rehan Ahamed
 * Description:    Cluster Power-Off Summary & Shutdown Sequence
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick

Item {
    id: goodbyeRoot
    implicitWidth: 198
    implicitHeight: 366

        FontLoader { id: hyundaiRegular; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Regular.ttf" }
    FontLoader { id: hyundaiMedium; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Medium.ttf" }
    FontLoader { id: hyundaiBold; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Bold.ttf" }
    FontLoader { id: notoDevanagari; source: "qrc:/qt/qml/HyundaiExterCluster/resources/fonts/NotoSansDevanagari-Regular.ttf" }

    readonly property string fontHeadRegular: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (hyundaiRegular.status === FontLoader.Ready ? hyundaiRegular.name : "Hyundai Sans Head Regular")
    readonly property string fontHeadMedium: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (hyundaiMedium.status === FontLoader.Ready ? hyundaiMedium.name : "Hyundai Sans Head Medium")
    readonly property string fontHeadBold: isHindi ? (notoDevanagari.status === FontLoader.Ready ? notoDevanagari.name : "Noto Sans Devanagari") : (hyundaiBold.status === FontLoader.Ready ? hyundaiBold.name : "Hyundai Sans Head Bold")

    property bool isHindi: controller && (controller.language === "हिन्दी" || controller.language === "Hindi")
    property string themeColor: controller ? controller.themeColor : "blue"

    readonly property color themeCoreColor: themeColor === "green" ? "#D0FFE0" : (themeColor === "red" ? "#FFD0D0" : "#D0E0FF")
    readonly property color themePrimaryColor: themeColor === "green" ? "#00E676" : (themeColor === "red" ? "#FF5252" : "#00E5FF")
    readonly property color themeGlowGradient: themeColor === "green" ? "#5000C853" : (themeColor === "red" ? "#50FF1744" : "#5000C8FF")
    readonly property color themeUnderGlow: themeColor === "green" ? "#2500E676" : (themeColor === "red" ? "#25FF5252" : "#2500E5FF")

    // Deep Black Background
    Rectangle {
        anchors.fill: parent
        color: "#03060C"
    }

    // =================================================================
    // 0. UPPER HEADER SECTION: FUEL ICON & DTE RANGE
    // =================================================================
    Item {
        id: topHeaderSection
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.right: parent.right
        anchors.rightMargin: 18
        height: 32

        // Fuel Pump Icon & Range (DTE)
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Image {
                width: 28
                height: 28
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/fuel_pump.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: (controller && (controller.fuelLevel === 0 || controller.dteKm <= 0)) ? "---" : (controller ? controller.dteKm : 52)
                font.pixelSize: 22
                font.family: goodbyeRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2
                text: "km"
                font.pixelSize: 14
                font.family: goodbyeRoot.fontHeadRegular
                color: "#FFFFFF"
            }
        }
    }

    // =================================================================
    // 1. TOP SECTION: UPPER ACCENT LINE
    // =================================================================
    Item {
        id: topSection
        anchors.top: parent.top
        anchors.topMargin: 46
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 10

        // Soft Ambient Light under top line
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.96
            height: 5
            opacity: 0.35
            color: "transparent"
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#40FFFFFF" }
                GradientStop { position: 0.4; color: goodbyeRoot.themeUnderGlow }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Crisp Core Top Line
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 1.5
            radius: 0.75
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.2; color: goodbyeRoot.themeGlowGradient }
                GradientStop { position: 0.5; color: goodbyeRoot.themeCoreColor }
                GradientStop { position: 0.8; color: goodbyeRoot.themeGlowGradient }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // =================================================================
    // 2. MIDDLE CONTENT: DRIVE SUMMARY STATS
    // =================================================================
    Item {
        id: middleContent
        anchors.top: topSection.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.92
        height: 204

        Column {
            anchors.fill: parent
            spacing: 16

            // Header Title: "Drive info" (or "ड्राइव जानकारी" in Hindi)
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: goodbyeRoot.isHindi ? "ड्राइव जानकारी" : "Drive info"
                font.pixelSize: 19
                font.family: goodbyeRoot.fontHeadMedium
                font.weight: Font.DemiBold
                color: "#FFFFFF"
            }

            // 3 Data Rows (Distance, Time, Economy)
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: 14

                // Row 1: Distance (🚗 15.4 km)
                Item {
                    width: parent.width
                    height: 34

                    Image {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 34
                        source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/trip_car.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        id: r1Val
                        anchors.right: parent.right
                        anchors.rightMargin: 46
                        anchors.verticalCenter: parent.verticalCenter
                        text: (controller ? controller.tripKm.toFixed(1) : "15.4")
                        font.pixelSize: 24
                        font.family: goodbyeRoot.fontHeadMedium
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }

                    Text {
                        anchors.left: r1Val.right
                        anchors.leftMargin: 3
                        anchors.bottom: r1Val.bottom
                        anchors.bottomMargin: 2
                        text: "km"
                        font.pixelSize: 14
                        font.family: goodbyeRoot.fontHeadRegular
                        color: "#FFFFFF"
                    }
                }

                // Row 2: Elapsed Time (🕒 0:42 h:m)
                Item {
                    width: parent.width
                    height: 34

                    Image {
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36
                        height: 34
                        source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/trip_clock.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        id: r2Val
                        anchors.right: parent.right
                        anchors.rightMargin: 46
                        anchors.verticalCenter: parent.verticalCenter
                        text: (controller ? controller.tripTime : "0:42")
                        font.pixelSize: 24
                        font.family: goodbyeRoot.fontHeadMedium
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }

                    Text {
                        anchors.left: r2Val.right
                        anchors.leftMargin: 3
                        anchors.bottom: r2Val.bottom
                        anchors.bottomMargin: 2
                        text: "h:m"
                        font.pixelSize: 14
                        font.family: goodbyeRoot.fontHeadRegular
                        color: "#FFFFFF"
                    }
                }

                // Row 3: Fuel Economy (⛽ 18.2 km/L)
                Item {
                    width: parent.width
                    height: 34

                    Image {
                        anchors.left: parent.left
                        anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36
                        height: 34
                        source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/trip_fuel.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        id: r3Val
                        anchors.right: parent.right
                        anchors.rightMargin: 46
                        anchors.verticalCenter: parent.verticalCenter
                        text: (controller && controller.fuelUnit === "L/100km") ?
                              (controller.tripEconomy > 0.1 ? (100.0 / controller.tripEconomy).toFixed(1) : "0.0") :
                              (controller ? controller.tripEconomy.toFixed(1) : "14.2")
                        font.pixelSize: 24
                        font.family: goodbyeRoot.fontHeadMedium
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }

                    Text {
                        anchors.left: r3Val.right
                        anchors.leftMargin: 3
                        anchors.bottom: r3Val.bottom
                        anchors.bottomMargin: 2
                        text: (controller && controller.fuelUnit === "L/100km") ? "L/100km" : "km/L"
                        font.pixelSize: (controller && controller.fuelUnit === "L/100km") ? 11 : 14
                        font.family: goodbyeRoot.fontHeadRegular
                        color: "#FFFFFF"
                    }
                }
            }
        }
    }

    // =================================================================
    // 3. BOTTOM SECTION: LOWER ACCENT LINE + ODOMETER & AMBIENT TEMP
    // =================================================================
    Item {
        id: bottomSection
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 52

        // Lower Accent Line
        Item {
            id: bottomDividerLine
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.92
            height: 8

            Rectangle {
                anchors.top: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.96
                height: 7
                opacity: 0.40
                color: "transparent"
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#55FFFFFF" }
                    GradientStop { position: 0.4; color: goodbyeRoot.themeUnderGlow }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 1.5
                radius: 0.75
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: goodbyeRoot.themeGlowGradient }
                    GradientStop { position: 0.5; color: goodbyeRoot.themeCoreColor }
                    GradientStop { position: 0.8; color: goodbyeRoot.themeGlowGradient }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // Bottom Right: Ambient Temp & Odometer (Matches OEM Photo 1:1)
        Column {
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            spacing: 0

            // 1. Ambient Temperature (e.g. 29 °C)
            Row {
                anchors.right: parent.right
                spacing: 1

                Text {
                    text: (controller ? controller.ambientTemp : 29)
                    font.pixelSize: 14
                    font.family: goodbyeRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                Text {
                    text: (controller ? controller.tempUnit : "°C")
                    font.pixelSize: 11
                    font.family: goodbyeRoot.fontHeadRegular
                    color: "#FFFFFF"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                }
            }

            // 2. Odometer Total Distance (e.g. 10230 km)
            Row {
                anchors.right: parent.right
                spacing: 1

                Text {
                    id: odoValText
                    text: (controller ? controller.odoKm : 10230)
                    font.pixelSize: 15
                    font.family: goodbyeRoot.fontHeadMedium
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                Text {
                    text: "km"
                    font.pixelSize: 11
                    font.family: goodbyeRoot.fontHeadRegular
                    color: "#FFFFFF"
                    anchors.bottom: odoValText.bottom
                    anchors.bottomMargin: 1
                }
            }
        }
    }
}
