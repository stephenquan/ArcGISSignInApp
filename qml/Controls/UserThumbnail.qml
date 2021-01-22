import QtQuick 2.12

Item {
    property alias signedOutColor: signedOutImage.color

    Image {
        id: thumbnailImage

        anchors.fill: parent

        source: appProperties.userThumbnailUri
        visible: appProperties.username && appProperties.userThumbnailUri
        fillMode: Image.PreserveAspectFit
    }

    Rectangle {
        anchors.fill: parent

        color: styles.userThumbnailBackgroundColor
        visible: appProperties.username && !appProperties.userThumbnailUri

        Text {
            anchors.centerIn: parent
            text: appProperties.userFullName
                  ? appProperties.userFullName
                             .split(/\s/)
                             .map(w => w.charAt(0))
                             .join("")
                  : ""
            font.pointSize: Math.max(parent.height / 3, styles.textPointSize)
            color: styles.userThumbnailTextColor
        }
    }

    SVGImageButton {
        id: signedOutImage

        anchors.fill: parent

        visible: !appProperties.username
        source: "../Images/user-32.svg"
    }
}
