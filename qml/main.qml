import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    width: 800
    height: 600
    title: qsTr("ArcGIS Sign In App")

    SignInApp {
        anchors.fill: parent
    }
}
