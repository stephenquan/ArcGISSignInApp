import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Item {
    id: svgImageButton

    property alias source: svgImage.source
    property alias color: svgImage.color
    property alias pressed: mouseArea.pressed

    signal clicked()

    SVGImage {
        id: svgImage

        anchors.fill: parent
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onClicked: svgImageButton.clicked()
    }
}
