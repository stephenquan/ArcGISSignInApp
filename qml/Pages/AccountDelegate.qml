import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Frame {
    id: delegate

    Layout.fillWidth: true

    property int itemIndex: kSelectionNone
    property url icon
    property url url
    property string type
    property string displayText
    property var properties
    property bool selected: itemIndex === selectionIndex
    property color backgroundColor: selected
                                    ? styles.listSelectedBackgroundColor
                                    : styles.listBackgroundColor
    property color textColor: selected
                              ? styles.listSelectedTextColor
                              : styles.listTextColor

    background: Rectangle {
        color: backgroundColor

        MouseArea {
            anchors.fill: parent

            onClicked: {
                selectionIndex = itemIndex;
            }
        }
    }

    RowLayout {
        width: parent.width

        Rectangle {
            Layout.preferredWidth: styles.iconSize * 1.4
            Layout.preferredHeight: styles.iconSize * 1.4

            radius: width / 2
            color: styles.iconColor

            Item {
                anchors.centerIn: parent
                width: styles.iconSize
                height: styles.iconSize

                Image {
                    anchors.fill: parent

                    source: icon
                    sourceSize: Qt.size(width, height)
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true

                text: url
                font.pointSize: styles.textPointSize
                visible: text
                color: textColor
            }

            Text {
                Layout.fillWidth: true

                text: type
                font.pointSize: styles.textPointSize
                visible: text
                color: textColor
            }

            Text {
                Layout.fillWidth: true

                text: displayText
                font.pointSize: styles.textPointSize
                visible: text
                color: textColor
            }

        }

    }

}
