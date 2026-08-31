import QtQuick
import QtQuick.Layouts
import "./frame"
import "./gauges"
import "./center"

Item {
    id: clusterUnit
    property int stateMode: controller ? controller.clusterState : 3 // 1: Startup, 2: BootCheck, 3: NormalTrip

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
        border.color: "#0F1824"
        border.width: 2.0

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
            illumination: clusterUnit.stateMode === 1 ? 0.95 : 1.0
        }

        // --- LEFT NACELLE: Speedometer & Telltale Bank ---
        Item {
            id: leftSpeedSection
            anchors.left: parent.left
            anchors.right: centralTftScreen.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            opacity: clusterUnit.stateMode === 1 ? 0.0 : 1.0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 300 } }

            SpeedDisplay {
                id: speedDisplay
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 135
                anchors.verticalCenterOffset: -4
                speedValue: clusterUnit.stateMode === 2 ? Math.round(clusterUnit.startupSpeedSweep) : (controller ? controller.speed : 0)
            }

            // 1. BRAKE Telltale (Top-Right)
            Image {
                id: brakeIcon
                anchors.left: speedDisplay.right
                anchors.leftMargin: 10
                anchors.top: speedDisplay.top
                anchors.topMargin: 2
                width: 32
                height: 26
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/brake.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            // 2. ABS Telltale (Middle-Right)
            Image {
                id: absIcon
                anchors.left: speedDisplay.right
                anchors.leftMargin: 10
                anchors.top: speedDisplay.top
                anchors.topMargin: 36
                width: 32
                height: 26
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/abs.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            // 3. SEATBELT Telltale (Bottom-Right)
            Image {
                id: seatbeltIcon
                anchors.left: speedDisplay.right
                anchors.leftMargin: 12
                anchors.top: speedDisplay.top
                anchors.topMargin: 72
                width: 28
                height: 32
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/seatbelt.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            // 4. SMART KEY / IMMOBILIZER Telltale (Bottom-Center below km/h)
            Image {
                id: smartKeyIcon
                anchors.horizontalCenter: speedDisplay.horizontalCenter
                anchors.top: speedDisplay.bottom
                anchors.topMargin: 4
                width: 34
                height: 20
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/smart_key.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            // 5. TPMS Telltale (Bottom-Left)
            Image {
                id: tpmsIcon
                anchors.right: speedDisplay.left
                anchors.rightMargin: 10
                anchors.bottom: speedDisplay.bottom
                anchors.bottomMargin: 0
                width: 28
                height: 28
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/tpms.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        // --- RIGHT NACELLE: Tachometer & Telltale Bank ---
        Item {
            id: rightRpmSection
            anchors.left: centralTftScreen.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            opacity: clusterUnit.stateMode === 1 ? 0.0 : 1.0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 300 } }

            RpmDisplay {
                id: rpmDisplay
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -135
                anchors.verticalCenterOffset: -4
                rpmValue: clusterUnit.stateMode === 2 ? clusterUnit.startupRpmSweep : (controller ? controller.rpm : 0.0)
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
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/steering.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
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
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/battery.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
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
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/airbag.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            // 4. ENGINE OIL Telltale (Bottom-Center below x1000rpm)
            Image {
                id: oilIcon
                anchors.horizontalCenter: rpmDisplay.horizontalCenter
                anchors.top: rpmDisplay.bottom
                anchors.topMargin: 4
                width: 38
                height: 20
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/oil.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
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

            // --- TFT STATE 1: Initial Startup (Clean Dark Screen + ODO) ---
            Item {
                anchors.fill: parent
                visible: clusterUnit.stateMode === 1

                // Odometer (Bottom Right: number large, unit small)
                Row {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    spacing: 1

                    Text {
                        id: s1OdoNum
                        text: (controller ? controller.odoKm : 29710)
                        font.pixelSize: 15
                        font.family: "Hyundai Sans Head"
                        font.weight: Font.Medium
                        color: "#CCD8E8"
                    }

                    Text {
                        text: "km"
                        font.pixelSize: 11
                        font.family: "Hyundai Sans Head"
                        color: "#CCD8E8"
                        anchors.bottom: s1OdoNum.bottom
                        anchors.bottomMargin: 1
                    }
                }
            }

            // --- TFT STATE 2: Boot / System Check (Matches OEM Photo) ---
            Item {
                anchors.fill: parent
                visible: clusterUnit.stateMode === 2

                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 24
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "System check"
                    font.pixelSize: 18
                    font.family: "Hyundai Sans Head"
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                    font.letterSpacing: 0.3
                }

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
                        font.family: "Hyundai Sans Head"
                        font.weight: Font.Medium
                        color: "#CCD8E8"
                    }

                    Text {
                        text: "km"
                        font.pixelSize: 11
                        font.family: "Hyundai Sans Head"
                        color: "#CCD8E8"
                        anchors.bottom: s2OdoNum.bottom
                        anchors.bottomMargin: 1
                    }
                }
            }

            // --- TFT STATE 3: Normal Driving (Gear, DTE, Trip, ODO, Temp) ---
            CenterTripDisplay {
                id: centerTrip
                anchors.fill: parent
                visible: clusterUnit.stateMode === 3
            }
        }
    }

    function navSettingsUp() { if (centerTrip) centerTrip.navSettingsUp(); }
    function navSettingsDown() { if (centerTrip) centerTrip.navSettingsDown(); }
    function selectSettings() { if (centerTrip) centerTrip.selectSettings(); }
    function backSettings() { if (centerTrip) centerTrip.backSettings(); }
}
