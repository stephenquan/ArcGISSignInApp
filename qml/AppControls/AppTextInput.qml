import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "../Controls"

Frame {
    id: appTextInput

    property alias text: textInput.text
    //property alias echoMode: textInput.echoMode // @@ISSUE101: Initial incorrect vertical alignment
    property int echoMode // @@WORKAROUND101
    property alias readOnly: textInput.readOnly
    property alias placeholderText: _placeholderText.text
    property alias imageSource: image.source
    property alias button1: _button1

    activeFocusOnTab: true
    onActiveFocusChanged: if (activeFocus) textInput.focus = true

    signal accepted()

    Layout.fillWidth: true

    background: Rectangle {
        border.color: textInput.activeFocus
                        ? "#408080"
                        : "#c0c0c0"
        color: "transparent"
    }

    RowLayout {
        width: parent.width

        SVGImage {
            id: image

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: styles.smallIconSize
            Layout.preferredHeight: styles.smallIconSize

            visible: source
        }

        TextInput {
            id: textInput

            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            font.pointSize: styles.textPointSize
            selectByMouse: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            onAccepted: appTextInput.accepted()

            Text {
                id: _placeholderText

                anchors.fill: parent

                font.pointSize: parent.font.pointSize
                color: styles.placeholderTextColor
                visible: !parent.text
            }

            Component.onCompleted: {
                echoMode = Qt.binding( () => appTextInput.echoMode ); /// @@WORKAROUND101
            }
        }

        SVGImageButton {
            id: _button1

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: styles.smallIconSize
            Layout.preferredHeight: styles.smallIconSize
        }
    }
}
