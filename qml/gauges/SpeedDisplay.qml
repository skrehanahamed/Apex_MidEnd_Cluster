import QtQuick

Item {
    id: speedRoot
    property int speedValue: 0
    implicitWidth: 150
    implicitHeight: 120

    Column {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: speedRoot.speedValue.toString()
            font.pixelSize: 62
            font.bold: true
            font.family: "DSEG7 Classic"
            color: "#FFFFFF"
            style: Text.Normal
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "km/h"
            font.pixelSize: 16
            font.bold: true
            font.family: "Rajdhani"
            color: "#FFFFFF"
            font.letterSpacing: 0.5
        }
    }
}


