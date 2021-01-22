import QtQuick 2.12

QtObject {
    id: styles

    // App Global
    property int iconSize: 32
    property int smallIconSize: 24
    property double textPointSize: 12
    property double heading1PointSize: 12
    property bool heading1Bold: true
    property color userThumbnailBackgroundColor: "#804080"
    property color userThumbnailTextColor: "white"
    property color placeholderTextColor: "#c0c0c0"

    // App Header
    property color headerBackgroundColor: "#6060a0"
    property color headerTextColor: "white"
    property double headerTextPointSize: 16

    // App Footer
    property color footerBackgroundColor: "#808080"

    // App Window
    //property color windowColor: "#f0fff0"
    property color windowColor: "#e0ffe0"
    //property color frameColor: "#e0e0e0"
    property color frameColor: "white"
    property color frameBorderColor: "#c0c0c0"
    property int frameBorderWidth: 1
    property double frameRadius: 5

    // Lists
    property color listOddBackgroundColor: "#e0e0e0"
    property color listEvenBackgroundColor: "#c0c0c0"
    property color listSelectedBackgroundColor: "#60a0a0"
    property color listSelectedTextColor: "white"
    property color listTextColor: "black"

}
