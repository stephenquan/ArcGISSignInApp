import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import Esri.Runtime.Testing 1.0
import "../AppControls"
import "../Controls"

Page {
    id: page

    title: qsTr("Add Map")

    readonly property alias mapName: mapNameTextInput.text
    readonly property alias mapType: mapTypeComboBox.currentText
    readonly property alias mapUrl: mapUrlTextInput.text

    signal accepted()
    signal rejected()

    background: Rectangle {
        color: styles.windowColor
    }

    Flickable {
        id: flickable

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: (parent.width - 20) * 80 / 100

        contentWidth: frame.width
        contentHeight: frame.height
        clip: true
        topMargin: Math.max((parent.height - frame.height) / 2, 0)

        Frame {
            id: frame

            width: flickable.width

            background: Rectangle {
                border.color: styles.frameBorderColor
                border.width: styles.frameBorderWidth
                color: styles.frameColor
                radius: styles.frameRadius
            }

            ColumnLayout {
                id: columnLayout

                width: parent.width

                spacing: 10

                AppSeparator {
                }

                Frame {
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "white"
                    }

                    ColumnLayout {
                        width: parent.width

                        AppSeparator {
                        }

                        AppTextInput {
                            id: mapNameTextInput

                            imageSource: "../Images/description-32.svg"
                            placeholderText: qsTr("Map Name")
                        }

                        Frame {
                            Layout.fillWidth: true

                            background: Rectangle {
                                border.color: mapTypeComboBox.activeFocus
                                                ? "#408080"
                                                : "#c0c0c0"
                                color: "transparent"
                            }

                            RowLayout {
                                width: parent.width

                                SVGImage {
                                    Layout.preferredWidth: styles.smallIconSize
                                    Layout.preferredHeight: styles.smallIconSize

                                    source: "../Images/map-32.svg"
                                }

                                ComboBox {
                                    id: mapTypeComboBox

                                    Layout.fillWidth: true

                                    model: [ "WebMap", "VectorTileLayer" ]
                                    font.pointSize: styles.textPointSize
                                }
                            }
                        }

                        AppTextInput {
                            id: mapUrlTextInput

                            imageSource: "../Images/web-32.svg"
                            placeholderText: qsTr("Map URL")
                        }

                        AppSeparator {
                        }

                        AppButton {
                            Layout.alignment: Qt.AlignHCenter

                            text: qsTr("Add Map")
                            font.pointSize: styles.textPointSize
                            enabled: mapNameTextInput.text && mapUrlTextInput.text

                            onClicked: addMap()
                        }

                        AppSeparator {
                        }

                    }
                }
            }
        }
    }

    QtObject {
        id: internal

        property string errorString: ""
    }

    function addMap() {
        accepted();
    }
}
