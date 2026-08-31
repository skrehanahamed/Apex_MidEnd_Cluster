import QtQuick
import QtQuick.Effects

Item {
    id: root
    property real speedValue: 0.0
    property real rpmValue: 0.0
    property real illumination: 1.0

    // Theme Line Color: "blue" (#00E5FF), "green" (#00E676), "red" (#FF5252)
    property string themeColor: controller ? controller.themeColor : "blue"
    readonly property color themeLineColor: themeColor === "green" ? "#00E676" : (themeColor === "red" ? "#FF5252" : "#00E5FF")

    // Closer TFT screen gap configuration
    property real tftWidth: 200.0
    property real tftSpacing: 0.0

    // Progressive speed/RPM thresholds (5 OEM concentric lines)
    readonly property real speedThreshold2: 30.0
    readonly property real speedThreshold3: 60.0
    readonly property real speedThreshold4: 90.0
    readonly property real speedThreshold5: 120.0

    readonly property real rpmThreshold2: 2.0
    readonly property real rpmThreshold3: 3.5
    readonly property real rpmThreshold4: 5.0
    readonly property real rpmThreshold5: 6.5

    // ========================================================
    // 🎛️ PROGRESSIVE STEPPED OPACITY (Fades inward little by little)
    // ========================================================
    readonly property real line1Alpha: 1.00  // Outermost - Full brightness
    readonly property real line2Alpha: 0.85  // Line 2 - Slightly lower
    readonly property real line3Alpha: 0.70  // Line 3 - Medium intensity
    readonly property real line4Alpha: 0.55  // Line 4 - Softer glow
    readonly property real line5Alpha: 0.40  // Innermost - Subtle accent glow

    // ========================================================
    // 🎛️ POSITION OFFSET CONTROLS
    // ========================================================
    property real line1Offset: 0.0
    property real line2Offset: 0.0
    property real line3Offset: 0.0
    property real line4Offset: 0.0
    property real line5Offset: 0.0

    implicitWidth: 1280
    implicitHeight: 420

    Item {
        id: container
        anchors.fill: parent
        opacity: root.illumination
        layer.enabled: root.themeColor !== "blue"
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: root.themeLineColor
        }

        // =================================================================
        // LEFT CLUSTER: SPEEDOMETER 5 PROGRESSIVE LINES
        // =================================================================
        Item {
            id: leftClusterContainer
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: (root.tftWidth / 2) + root.tftSpacing
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            scale: 0.78
            transformOrigin: Item.Right

            // Speed Line 1 (Outermost - 100% opacity)
            Image {
                id: speedLine1Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: root.line1Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/speed_line1.svg"
                sourceSize.width: 570
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line1Alpha
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }

            // Speed Line 2 (85% opacity)
            Image {
                id: speedLine2Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: root.line2Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/speed_line2.svg"
                sourceSize.width: 570
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line2Alpha * (root.speedValue >= root.speedThreshold2 ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }

            // Speed Line 3 (70% opacity)
            Image {
                id: speedLine3Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: root.line3Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/speed_line3.svg"
                sourceSize.width: 570
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line3Alpha * (root.speedValue >= root.speedThreshold3 ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }

            // Speed Line 4 (55% opacity)
            Image {
                id: speedLine4Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: root.line4Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/speed_line4.svg"
                sourceSize.width: 570
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line4Alpha * (root.speedValue >= root.speedThreshold4 ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }

            // Speed Line 5 (Innermost - 40% opacity)
            Image {
                id: speedLine5Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: root.line5Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/speed_line5.svg"
                sourceSize.width: 570
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line5Alpha * (root.speedValue >= root.speedThreshold5 ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }
        }

        // =================================================================
        // RIGHT CLUSTER: TACHOMETER 5 PROGRESSIVE LINES
        // =================================================================
        Item {
            id: rightClusterContainer
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: (root.tftWidth / 2) + root.tftSpacing
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            scale: 0.78
            transformOrigin: Item.Left

            // RPM Line 1 (Outermost - 100% opacity)
            Image {
                id: rpmLine1Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -root.line1Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/rpm_line1.svg"
                sourceSize.width: 568
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line1Alpha
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }

            // RPM Line 2 (85% opacity)
            Image {
                id: rpmLine2Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -root.line2Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/rpm_line2.svg"
                sourceSize.width: 568
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line2Alpha * ((root.rpmValue >= root.rpmThreshold2 || root.speedValue >= root.speedThreshold2) ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }

            // RPM Line 3 (70% opacity)
            Image {
                id: rpmLine3Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -root.line3Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/rpm_line3.svg"
                sourceSize.width: 568
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line3Alpha * ((root.rpmValue >= root.rpmThreshold3 || root.speedValue >= root.speedThreshold3) ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }

            // RPM Line 4 (55% opacity)
            Image {
                id: rpmLine4Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -root.line4Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/rpm_line4.svg"
                sourceSize.width: 568
                sourceSize.height: 471
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                opacity: root.illumination * root.line4Alpha * ((root.rpmValue >= root.rpmThreshold4 || root.speedValue >= root.speedThreshold4) ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }

            // RPM Line 5 (Innermost - 40% opacity)
            Image {
                id: rpmLine5Img
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -root.line5Offset
                width: parent.width
                height: parent.height
                source: "qrc:/qt/qml/HyundaiExterCluster/assets/rpm_line5.svg"
                sourceSize.width: 568
                opacity: root.illumination * root.line5Alpha * ((root.rpmValue >= root.rpmThreshold5 || root.speedValue >= root.speedThreshold5) ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
            }
        }
    }
}
