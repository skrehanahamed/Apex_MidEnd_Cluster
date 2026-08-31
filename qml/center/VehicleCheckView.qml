import QtQuick
import QtQuick.Effects

Item {
    id: vehicleRoot
    implicitWidth: 198
    implicitHeight: 200

    // Master Timeline Progress Property (0.0 to 1.0 over 800ms smooth entry)
    property real checkProgress: 0.0

    NumberAnimation {
        id: checkTimelineAnim
        target: vehicleRoot
        property: "checkProgress"
        from: 0.0
        to: 1.0
        duration: 800
        easing.type: Easing.OutCubic
        running: vehicleRoot.visible
    }

    // ========================================================
    // 1. OEM STUDIO ILLUMINATED BLUE ASPHALT ROAD BACKGROUND
    // ========================================================
    Image {
        id: studioGroundBg
        anchors.fill: parent
        source: "qrc:/qt/qml/HyundaiExterCluster/assets/oem_studio_ground.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
    }

    // Base vertical positioning on the ground
    readonly property real baseCarY: 18.0

    // ========================================================
    // 2. PHOTOREALISTIC GROUND CONTACT SHADOW (Anchored to Floor)
    // ========================================================
    Image {
        id: groundShadowImg
        anchors.centerIn: parent
        anchors.verticalCenterOffset: vehicleRoot.baseCarY + 27
        width: 170
        height: 48
        z: 1
        source: "qrc:/qt/qml/HyundaiExterCluster/assets/car_ground_shadow.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true

        // Fades in smoothly and stays 100% visible till the end
        opacity: Math.min(1.0, vehicleRoot.checkProgress * 2.0)
    }

    // ========================================================
    // 3. HYUNDAI EXTER VEHICLE (Firmly grounded with continuous shine)
    // ========================================================
    Item {
        id: carContainer
        anchors.centerIn: parent
        width: 142
        height: 90
        z: 2

        // Planted firmly on the ground surface
        anchors.verticalCenterOffset: vehicleRoot.baseCarY

        // Opacity: Fades in smoothly on entry, stays 100% visible till the end
        opacity: Math.min(1.0, 0.05 + 0.95 * vehicleRoot.checkProgress)

        // Base High-Resolution Hyundai Exter Vehicle Render
        Image {
            id: exterCarImg
            anchors.fill: parent
            source: "qrc:/qt/qml/HyundaiExterCluster/assets/hyundai_exter_car.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        // ========================================================
        // Continuous Sweeping Metallic Specular Light Beam
        // ========================================================
        Item {
            id: sweepLightSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: sweepBeam
                width: 44
                height: parent.height * 2.6
                anchors.verticalCenter: parent.verticalCenter
                rotation: 22
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.30; color: "#2500E5FF" }
                    GradientStop { position: 0.45; color: "#90C8FFFF" }
                    GradientStop { position: 0.50; color: "#F0FFFFFF" }
                    GradientStop { position: 0.55; color: "#90C8FFFF" }
                    GradientStop { position: 0.70; color: "#2500E5FF" }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                // Continuous infinite left-to-right shine loop
                SequentialAnimation on x {
                    loops: Animation.Infinite
                    running: vehicleRoot.visible
                    NumberAnimation {
                        from: -sweepBeam.width - 20
                        to: carContainer.width + sweepBeam.width + 20
                        duration: 1400
                        easing.type: Easing.InOutQuad
                    }
                    PauseAnimation { duration: 400 }
                }
            }
        }

        // Strictly Masked Metallic Light Sweep across Car Paint Silhouette
        MultiEffect {
            anchors.fill: parent
            source: sweepLightSource
            maskEnabled: true
            maskSource: exterCarImg
            maskThresholdMin: 0.05
            maskSpreadAtMin: 0.05
            opacity: 0.90
        }

        // ========================================================
        // Headlights & Signature H-DRL Brief Illumination Flare
        // ========================================================
        Item {
            id: headlightFlareLayer
            anchors.fill: parent
            z: 10

            // Illuminates during the initial entry sweep
            opacity: {
                if (vehicleRoot.checkProgress >= 0.40 && vehicleRoot.checkProgress <= 0.90) {
                    var t = (vehicleRoot.checkProgress - 0.40) / 0.50;
                    return Math.sin(t * Math.PI) * 0.95;
                }
                return 0.0;
            }
            visible: opacity > 0.01

            // Signature Front Headlight Projector Flare
            Rectangle {
                x: parent.width * 0.28
                y: parent.height * 0.48
                width: 20
                height: 16
                radius: 8
                color: "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#FFFFFF" }
                    GradientStop { position: 0.5; color: "#8000F0FF" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Signature Upper H-LED DRL Glow
            Rectangle {
                x: parent.width * 0.24
                y: parent.height * 0.38
                width: 32
                height: 8
                radius: 4
                color: "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#FFFFFF" }
                    GradientStop { position: 0.6; color: "#6000E5FF" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    // ========================================================
    // 4. 3 OCCUPANT SEATBELT ALERT ICONS (Exact same position as trip screen)
    // ========================================================
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 1
        opacity: Math.min(1.0, vehicleRoot.checkProgress * 2.0)

        Repeater {
            model: 3
            Image {
                width: 20
                height: 22
                source: "qrc:/qt/qml/HyundaiExterCluster/resources/icons/seatbelt.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }
    }
}
