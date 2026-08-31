import QtQuick

Item {
    id: tripRoot
    implicitWidth: 220
    implicitHeight: 140

    property string tripDistance: (controller ? controller.tripKm.toFixed(1) : "0.0") + " km"
    property string tripDuration: controller ? controller.tripTime : "0:00 h:m"
    property string tripEconomy: (controller ? controller.tripEconomy.toFixed(1) : "0.0") + " km/L"

    Column {
        anchors.fill: parent
        spacing: 7

        // Header Title
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Current trip"
            font.pixelSize: 15
            font.bold: true
            font.family: "Helvetica Neue"
            color: "#B4C8DC"
        }

        // Thin Horizontal Divider
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.92
            height: 1
            color: "#223146"
        }

        // Row 1: Trip Distance
        Item {
            width: parent.width
            height: 18

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "🚘"
                font.pixelSize: 13
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: tripRoot.tripDistance
                font.pixelSize: 15
                font.bold: true
                font.family: "Helvetica Neue"
                color: "#FFFFFF"
            }
        }

        // Row 2: Trip Duration
        Item {
            width: parent.width
            height: 18

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "⏱️"
                font.pixelSize: 13
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: tripRoot.tripDuration
                font.pixelSize: 15
                font.bold: true
                font.family: "Helvetica Neue"
                color: "#FFFFFF"
            }
        }

        // Row 3: Fuel Economy
        Item {
            width: parent.width
            height: 18

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "⛽"
                font.pixelSize: 13
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: tripRoot.tripEconomy
                font.pixelSize: 15
                font.bold: true
                font.family: "Aptos, DIN 1451, Arial"
                color: "#FFFFFF"
            }
        }

        // Footer Reset Prompt
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Hold [ OK ] : Reset"
            font.pixelSize: 11
            font.family: "Aptos, DIN 1451, Arial"
            color: "#6E859E"
        }
    }
}
