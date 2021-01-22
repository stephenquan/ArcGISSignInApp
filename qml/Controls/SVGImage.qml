import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Item {
    property alias source: image.source
    property alias color: colorOverlay.color

    Image {
        id: image

        anchors.fill: parent

        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        id: colorOverlay

        anchors.fill: image
        visible: color !== "black"

        source: image
        color: "black"
    }
}
