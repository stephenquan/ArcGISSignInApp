import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "Controls"

Frame {
    background: Rectangle {
        color: styles.headerBackgroundColor
    }

    RowLayout {
        width: parent.width

        Item {
            Layout.preferredWidth: styles.iconSize
            Layout.preferredHeight: styles.iconSize

            SVGImageButton {
                anchors.fill: parent

                source: "Images/chevron-left-32.svg"
                color: styles.headerTextColor
                visible: stackView.depth > 1

                onClicked: stackView.pop()
            }
        }

        Item {
            Layout.preferredWidth: styles.iconSize
            Layout.preferredHeight: styles.iconSize

            SVGImageButton {
                anchors.fill: parent

                readonly property var refreshButton: currentPage ? currentPage["refreshButton"] : null;

                source: "Images/refresh-32.svg"
                color: styles.headerTextColor
                visible: !!refreshButton && refreshButton.visible
                enabled: !!refreshButton && refreshButton.enabled

                onClicked: refreshButton.clicked()
            }
        }

        Text {
            Layout.fillWidth: true

            text: currentPage.title || signInApp.title
            font.pointSize: styles.headerTextPointSize
            color: styles.headerTextColor
            horizontalAlignment: Qt.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        UserThumbnail {
            Layout.preferredWidth: styles.iconSize
            Layout.preferredHeight: styles.iconSize

            signedOutColor: "white"

            MouseArea {
                anchors.fill: parent

                readonly property var userButton: currentPage ? currentPage["userButton"] : null;

                enabled: !!userButton && userButton.enabled

                onClicked: {
                    console.log("Hi");
                    !!userButton.clicked()
                }
            }
        }

        Item {
            Layout.preferredWidth: styles.iconSize
            Layout.preferredHeight: styles.iconSize

            SVGImageButton {
                anchors.fill: parent

                readonly property var menuButton: currentPage ? currentPage["menuButton"] : null;

                source: "Images/ellipsis-32.svg"
                color: styles.headerTextColor
                visible: !!menuButton && menuButton.visible
                enabled: !!menuButton && menuButton.enabled

                onClicked: menuButton.clicked()
            }
        }
    }
}

