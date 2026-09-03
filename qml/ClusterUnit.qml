/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           ClusterUnit.qml
 * Author:         SK Rehan Ahamed
 * Description:    Main Cluster Gauge Bezel & Layout Frame
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

import QtQuick
import QtQuick.Layouts
import QtMultimedia
import "./frame"
import "./gauges"
import "./center"

Item {
    id: clusterUnit
    property int stateMode: controller ? controller.clusterState : 3 // 1: Startup, 2: BootCheck, 3: NormalTrip

    // --- Turn Signal Blink State & Audio Relay ---
    property bool turnBlinkState: true

    Timer {
        id: turnBlinkTimer
        interval: 350
        repeat: true
        running: (typeof controller !== "undefined" && controller && (controller.leftIndicator || controller.rightIndicator))
        onRunningChanged: {
            if (running) {
                turnBlinkState = true
                tickSound.play()
            } else {
                turnBlinkState = true
            }
        }
        onTriggered: {
            turnBlinkState = !turnBlinkState
            if (turnBlinkState) {
                tickSound.play()
            } else {
                tockSound.play()
            }
        }
    }

    SoundEffect {
        id: tickSound
        source: "qrc:/qt/qml/ApexCluster/resources/audio/tick.wav"
        volume: 0.8
    }

    SoundEffect {
        id: tockSound
        source: "qrc:/qt/qml/ApexCluster/resources/audio/tock.wav"
        volume: 0.7
    }

    SoundEffect {
        id: startupAnimationTone
        source: "qrc:/qt/qml/ApexCluster/resources/audio/startup_animation_tone.wav"
        volume: 0.95
    }

    SoundEffect {
        id: welcomeChime
        source: "qrc:/qt/qml/ApexCluster/resources/audio/welcome_chime.wav"
        volume: 0.9
    }

    SoundEffect {
        id: goodbyeChime
        source: "qrc:/qt/qml/ApexCluster/resources/audio/goodbye_chime.wav"
        volume: 0.9
    }

    SoundEffect {
        id: warningChime
        source: "qrc:/qt/qml/ApexCluster/resources/audio/warning_chime.wav"
        volume: 0.85
    }

    SoundEffect {
        id: seatbeltChime
        source: "qrc:/qt/qml/ApexCluster/resources/audio/seatbelt_chime.wav"
        volume: 0.8
    }

    SoundEffect {
        id: keyAlertChime
        source: "qrc:/qt/qml/ApexCluster/resources/audio/key_alert_chime.wav"
        volume: 0.85
    }

    SoundEffect {
        id: speedAlertChime
        source: "qrc:/qt/qml/ApexCluster/resources/audio/speed_alert_chime.wav"
        volume: 0.85
    }

    Timer {
        id: seatbeltChimeLoopTimer
        interval: 1200
        repeat: true
        running: controller && controller.rearAlarmActive
        onTriggered: seatbeltChime.play()
    }

    Connections {
        target: controller
        function onSignalStartupAnimationTone() { startupAnimationTone.play(); }
        function onSignalWelcomeChime() { welcomeChime.play(); }
        function onSignalGoodbyeChime() { goodbyeChime.play(); }
        function onSignalWarningChime() { warningChime.play(); }
        function onSignalSeatbeltChime() { seatbeltChime.play(); }
        function onSignalKeyAlertChime() { keyAlertChime.play(); }
        function onSignalSpeedAlertChime() { speedAlertChime.play(); }
        function onSignalPlayChime() { warningChime.play(); }
    }

    // --- Dynamic Startup Full Gauge Sweep (State 2: System Check) ---
    property real startupSpeedSweep: 0.0
    property real startupRpmSweep: 0.0

    SequentialAnimation {
        id: startupSweepAnim
        running: clusterUnit.stateMode === 2

        PauseAnimation { duration: 100 }

        // 1. Synchronized Gauge Sweep Up (0 -> 188 km/h, 0.0 -> 8.0 RPM)
        ParallelAnimation {
            NumberAnimation {
                target: clusterUnit
                property: "startupSpeedSweep"
                from: 0.0
                to: 188.0
                duration: 1200
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: clusterUnit
                property: "startupRpmSweep"
                from: 0.0
                to: 8.0
                duration: 1200
                easing.type: Easing.InOutQuad
            }
        }

        PauseAnimation { duration: 250 }

        // 2. Synchronized Gauge Sweep Down (188 -> 0 km/h, 8.0 -> 0.0 RPM)
        ParallelAnimation {
            NumberAnimation {
                target: clusterUnit
                property: "startupSpeedSweep"
                from: 188.0
                to: 0.0
                duration: 1100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: clusterUnit
                property: "startupRpmSweep"
                from: 8.0
                to: 0.0
                duration: 1100
                easing.type: Easing.InOutQuad
            }
        }
    }

    implicitWidth: 1280
    implicitHeight: 420

    // Master Cluster Housing (Dark Gloss Physical Dashboard Nacelle)
    Rectangle {
        id: clusterBezel
        anchors.fill: parent
        radius: 36
        color: "#020408"
        border.color: (clusterUnit.stateMode === 5 && (!controller || !controller.doorOpenAlert)) ? "#000000" : "#0F1824"
        border.width: 2.0
        opacity: (clusterUnit.stateMode === 5 && (!controller || !controller.doorOpenAlert)) ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        // Physical Matte/Gloss Dashboard Cavity Gradient
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#060A12" }
            GradientStop { position: 0.5; color: "#010307" }
            GradientStop { position: 1.0; color: "#04070E" }
        }

        // ========================================================
        // 1. LEFT & RIGHT PHYSICAL LIGHT-GUIDE NACELLES (NON-TFT)
        // ========================================================
        BlueFrame {
            id: blueSideFrame
            anchors.fill: parent
            tftWidth: centralTftScreen.width
            tftSpacing: 0.0
            speedValue: clusterUnit.stateMode === 2 ? clusterUnit.startupSpeedSweep : (controller ? controller.speed : 0)
            rpmValue: clusterUnit.stateMode === 2 ? clusterUnit.startupRpmSweep : (controller ? controller.rpm : 0.0)
            illumination: (clusterUnit.stateMode === 4 || clusterUnit.stateMode === 5) ? 0.0 : (clusterUnit.stateMode === 1 ? 0.95 : 1.0)
        }

        // --- LEFT NACELLE: Speedometer & Telltale Bank ---
        Item {
            id: leftSpeedSection
            anchors.left: parent.left
            anchors.right: centralTftScreen.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            opacity: (clusterUnit.stateMode === 1 || clusterUnit.stateMode === 4 || clusterUnit.stateMode === 5) ? 0.0 : 1.0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 300 } }

            SpeedDisplay {
                id: speedDisplay
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 135
                anchors.verticalCenterOffset: -4
                speedValue: clusterUnit.stateMode === 2 ? Math.round(clusterUnit.startupSpeedSweep) : (controller ? controller.speed : 0)
            }

            // --- Far-Left: Master Warning Light ---
            Image {
                id: masterWarningIcon
                anchors.left: parent.left
                anchors.leftMargin: 130
                anchors.verticalCenter: speedDisplay.verticalCenter
                anchors.verticalCenterOffset: -40
                width: 28
                height: 26
                source: "qrc:/qt/qml/ApexCluster/resources/icons/master_warning.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (clusterUnit.stateMode === 2 || (controller && controller.masterWarning)) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // --- Top-Left Telltales (Low Beam, High Beam, Left Turn Signal) ---
            Row {
                anchors.top: parent.top
                anchors.topMargin: 22
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 12

                // Low Beam Indicator
                Image {
                    id: lowBeamIcon
                    width: 28
                    height: 22
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/low_beam.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: (controller && controller.lowBeam) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                // High Beam Indicator
                Image {
                    id: highBeamIcon
                    width: 28
                    height: 22
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/high_beam.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: (controller && controller.highBeam) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                // Left Turn Signal (OFF during System Check, blinks only when turn stalk is engaged)
                Image {
                    id: leftTurnIcon
                    width: 26
                    height: 20
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/turn_left.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: (controller && controller.leftIndicator) ? (clusterUnit.turnBlinkState ? 1.0 : 0.0) : 0.0
                }
            }

            // 1. BRAKE Telltale (Top-Right of speed display)
            // 1. BRAKE Telltale (Top-Right of speed display)
            Image {
                id: brakeIcon
                anchors.left: speedDisplay.right
                anchors.leftMargin: 10
                anchors.top: speedDisplay.top
                anchors.topMargin: 2
                width: 32
                height: 26
                source: "qrc:/qt/qml/ApexCluster/resources/icons/brake.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.parkBrakeActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 2. ABS Telltale (Middle-Right of speed display)
            Image {
                id: absIcon
                anchors.left: speedDisplay.right
                anchors.leftMargin: 10
                anchors.top: speedDisplay.top
                anchors.topMargin: 36
                width: 32
                height: 26
                source: "qrc:/qt/qml/ApexCluster/resources/icons/abs.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.absActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 3. SEATBELT Telltale (Bottom-Right of speed display)
            Image {
                id: seatbeltIcon
                anchors.left: speedDisplay.right
                anchors.leftMargin: 12
                anchors.top: speedDisplay.top
                anchors.topMargin: 72
                width: 28
                height: 32
                source: "qrc:/qt/qml/ApexCluster/resources/icons/seatbelt.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.seatbeltActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 4. SMART KEY / IMMOBILIZER Telltale (Bottom-Center below km/h)
            Image {
                id: smartKeyIcon
                anchors.horizontalCenter: speedDisplay.horizontalCenter
                anchors.top: speedDisplay.bottom
                anchors.topMargin: 4
                width: 34
                height: 20
                source: "qrc:/qt/qml/ApexCluster/resources/icons/smart_key.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.smartKeyActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 5. TPMS Telltale (Bottom-Left of speed display)
            Image {
                id: tpmsIcon
                anchors.right: speedDisplay.left
                anchors.rightMargin: 10
                anchors.bottom: speedDisplay.bottom
                anchors.bottomMargin: 0
                width: 28
                height: 28
                source: "qrc:/qt/qml/ApexCluster/resources/icons/tpms.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.tpmsActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // --- Bottom-Left: Lamp Malfunction / Bulb Warning Light ---
            Image {
                id: lightWarningIcon
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 26
                anchors.right: parent.right
                anchors.rightMargin: 60
                width: 28
                height: 26
                source: "qrc:/qt/qml/ApexCluster/resources/icons/light_warning.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.lightWarning) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // --- Digital Fuel Level Gauge (F -> E) ---
            FuelGauge {
                id: fuelGauge
                anchors.left: parent.left
                anchors.leftMargin: 140
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                scale: 0.48
                transformOrigin: Item.BottomLeft
                isBootCheck: clusterUnit.stateMode === 2
                level: clusterUnit.stateMode === 2 ? 1.0 : (controller ? (controller.fuelLevel / 12.0) : 0.75)
            }
        }

        // --- RIGHT NACELLE: Tachometer & Telltale Bank ---
        Item {
            id: rightRpmSection
            anchors.left: centralTftScreen.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            opacity: (clusterUnit.stateMode === 1 || clusterUnit.stateMode === 4 || clusterUnit.stateMode === 5) ? 0.0 : 1.0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 300 } }

            RpmDisplay {
                id: rpmDisplay
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -135
                anchors.verticalCenterOffset: -4
                rpmValue: clusterUnit.stateMode === 2 ? clusterUnit.startupRpmSweep : (controller ? controller.rpm : 0.0)
            }

            // --- Top-Right Telltales (Right Turn Signal, Light ON / Position Lamp) ---
            Row {
                anchors.top: parent.top
                anchors.topMargin: 22
                anchors.left: parent.left
                anchors.leftMargin: 16
                spacing: 12

                // Right Turn Signal (OFF during System Check, blinks only when turn stalk is engaged)
                Image {
                    id: rightTurnIcon
                    width: 26
                    height: 20
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/turn_right.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: (controller && controller.rightIndicator) ? (clusterUnit.turnBlinkState ? 1.0 : 0.0) : 0.0
                }

                // Light ON / Position Lamp Indicator
                Image {
                    id: positionLampIcon
                    width: 30
                    height: 22
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/position_lamp.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: (controller && controller.positionLamp) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
            }

            // 1. STEERING Telltale (Top-Left of RPM display)
            Image {
                id: steeringIcon
                anchors.right: rpmDisplay.left
                anchors.rightMargin: 12
                anchors.top: rpmDisplay.top
                anchors.topMargin: 2
                width: 32
                height: 26
                source: "qrc:/qt/qml/ApexCluster/resources/icons/steering.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.steeringActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 2. BATTERY Telltale (Middle-Left of RPM display)
            Image {
                id: batteryIcon
                anchors.right: rpmDisplay.left
                anchors.rightMargin: 12
                anchors.top: rpmDisplay.top
                anchors.topMargin: 38
                width: 34
                height: 24
                source: "qrc:/qt/qml/ApexCluster/resources/icons/battery.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.batteryActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 3. AIRBAG Telltale (Bottom-Left of RPM display)
            Image {
                id: airbagIcon
                anchors.right: rpmDisplay.left
                anchors.rightMargin: 14
                anchors.top: rpmDisplay.top
                anchors.topMargin: 74
                width: 28
                height: 28
                source: "qrc:/qt/qml/ApexCluster/resources/icons/airbag.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.airbagActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 4. ENGINE OIL Telltale (Bottom-Center below x1000rpm)
            Image {
                id: oilIcon
                anchors.horizontalCenter: rpmDisplay.horizontalCenter
                anchors.top: rpmDisplay.bottom
                anchors.topMargin: 4
                width: 38
                height: 20
                source: "qrc:/qt/qml/ApexCluster/resources/icons/oil.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: (controller && controller.oilActive) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // --- Bottom-Right: ESC, ESC OFF, Check Engine / MIL ---
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 24
                anchors.left: parent.left
                anchors.leftMargin: 20
                spacing: 12

                // ESC Active
                Image {
                    id: escIcon
                    width: 26
                    height: 24
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/esc.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: (controller && controller.escActive) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                // ESC OFF
                Image {
                    id: escOffIcon
                    width: 28
                    height: 24
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/esc_off.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: (controller && controller.escOffActive) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                // Check Engine / MIL
                Image {
                    id: checkEngineIcon
                    width: 30
                    height: 22
                    source: "qrc:/qt/qml/ApexCluster/resources/icons/engine_mil.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: (controller && controller.checkEngineActive) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                // ISG / Auto Stop Indicator
                Item {
                    id: isgIcon
                    width: 34
                    height: 22
                    opacity: (controller && controller.isgActive) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32
                        height: 18
                        radius: 3
                        color: "#1500E676"
                        border.color: "#00E676"
                        border.width: 1.2

                        Text {
                            anchors.centerIn: parent
                            text: "AUTO\nSTOP"
                            font.pixelSize: 7
                            font.family: "Cluster Sans Head"
                            font.weight: Font.Bold
                            color: "#00E676"
                            horizontalAlignment: Text.AlignHCenter
                            lineHeight: 0.85
                        }
                    }
                }
            }

            // --- Digital Coolant Temperature Gauge (C -> H) ---
            TempGauge {
                id: tempGauge
                anchors.right: parent.right
                anchors.rightMargin: 100
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                scale: 0.48
                transformOrigin: Item.BottomRight
                level: clusterUnit.stateMode === 2 ? 1.0 : (controller ? (controller.tempLevel / 12.0) : 0.5)
            }
        }

        // ========================================================
        // 2. CENTRAL 4.2" COLOR TFT LCD SCREEN WITH SHADOW EFFECT
        // ========================================================
        // Outer Drop Shadow & Bezel Recess Cavity
        Rectangle {
            id: tftOuterShadow
            anchors.centerIn: centralTftScreen
            width: centralTftScreen.width + 20
            height: centralTftScreen.height + 20
            radius: 16
            color: "#66000000"
            border.color: "#33000000"
            border.width: 3
            opacity: (clusterUnit.stateMode === 5 && (!controller || !controller.isAnyDoorOpen)) ? 0.0 : 1.0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            // Soft Ambient Cavity Shadow
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 6
                height: parent.height - 6
                radius: 14
                color: "#CC010306"
                border.color: "#22000000"
                border.width: 2
            }
        }

        // Active TFT Glass Nacelle
        Rectangle {
            id: centralTftScreen
            anchors.centerIn: parent
            width: 198
            height: 366
            radius: 12
            // Active TFT LCD Backlit Surface
            color: "#03060C"
            border.color: "#182638"
            border.width: 1.5
            clip: true

            // TFT Screen Glass Inset Depth & Bezel Frame
            Rectangle {
                anchors.fill: parent
                radius: 12
                color: "transparent"
                border.color: "#0A121E"
                border.width: 2.0
            }

            // Subtle Glass Highlight Edge across Top
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1.2
                color: "#20FFFFFF"
            }

            // --- TFT STATE 1: Initial Startup Animation (Only Lines + Signature Animation, No ODO) ---
            Item {
                anchors.fill: parent
                visible: clusterUnit.stateMode === 1

                StartupAnimationView {
                    anchors.fill: parent
                }
            }

            // --- TFT STATE 2: Boot / Startup Vehicle View (Matches OEM Photo) ---
            Item {
                anchors.fill: parent
                visible: clusterUnit.stateMode === 2

                VehicleCheckView {
                    anchors.fill: parent
                }

                // Odometer at Bottom Right of Central TFT (OEM photo detail)
                Row {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    spacing: 1

                    Text {
                        id: s2OdoNum
                        text: (controller ? controller.odoKm : 29710)
                        font.pixelSize: 15
                        font.family: "Cluster Sans Head"
                        font.weight: Font.Medium
                        color: "#CCD8E8"
                    }

                    Text {
                        text: "km"
                        font.pixelSize: 11
                        font.family: "Cluster Sans Head"
                        color: "#CCD8E8"
                        anchors.bottom: s2OdoNum.bottom
                        anchors.bottomMargin: 1
                    }
                }
            }

            // --- TFT STATE 3 & STATE 5 (Door Wake): Normal Driving or Ignition-OFF Door Ajar View ---
            CenterTripDisplay {
                id: centerTrip
                anchors.fill: parent
                visible: (clusterUnit.stateMode === 3) || (clusterUnit.stateMode === 5 && controller && controller.doorOpenAlert)
            }

            // --- TFT STATE 4: Ignition OFF / Good-bye Screen ---
            Item {
                anchors.fill: parent
                visible: clusterUnit.stateMode === 4

                GoodbyeView {
                    anchors.fill: parent
                }
            }
        }
    }

    function navSettingsUp() { if (centerTrip) centerTrip.navSettingsUp(); }
    function navSettingsDown() { if (centerTrip) centerTrip.navSettingsDown(); }
    function selectSettings() { if (centerTrip) centerTrip.selectSettings(); }
    function backSettings() { if (centerTrip) centerTrip.backSettings(); }
    function triggerResetPrompt() { if (centerTrip) centerTrip.triggerResetPrompt(); }
}
