import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "../Controls"

RowLayout {
    id: appTextLayout

    Layout.fillWidth: true
    Layout.preferredHeight: flickable.height

    property alias imageSource: image.source
    property alias text: appText.text

    SVGImage {
        id: leftEllipsis

        Layout.preferredWidth: styles.smallIconSize
        Layout.preferredHeight: styles.smallIconSize

        source: "../Images/ellipsis-32.svg"
        visible: flickable.contentX > 0
    }

    Flickable {
        id: flickable

        Layout.fillWidth: true
        Layout.preferredHeight: rowLayout.height
        contentWidth: rowLayout.width
        contentHeight: rowLayout.height
        clip: true
        leftMargin: Math.max((width - contentWidth) / 2, 0)

        RowLayout {
            id: rowLayout

            SVGImage {
                id: image

                Layout.preferredWidth: styles.smallIconSize
                Layout.preferredHeight: styles.smallIconSize

                visible: source
            }

            Text {
                id: appText

                text: "ABC"
                font.pointSize: styles.textPointSize
            }
        }
    }

    SVGImage {
        id: ellipsis

        Layout.preferredWidth: styles.smallIconSize
        Layout.preferredHeight: styles.smallIconSize

        source: "../Images/ellipsis-32.svg"
        visible: flickable.contentX + flickable.width < rowLayout.width
    }

}
