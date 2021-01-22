import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import Esri.Runtime.Testing 1.0
import "../AppControls"
import "../Controls"

Page {
    id: page

    title: qsTr("Add Portal")

    readonly property alias portalType: portalTypeComboBox.currentText
    readonly property alias portalUrl: portalUrlTextInput.text

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

                        Frame {
                            Layout.fillWidth: true

                            background: Rectangle {
                                border.color: portalTypeComboBox.activeFocus
                                                ? "#408080"
                                                : "#c0c0c0"
                                color: "transparent"
                            }

                            RowLayout {
                                width: parent.width

                                SVGImage {
                                    Layout.preferredWidth: styles.smallIconSize
                                    Layout.preferredHeight: styles.smallIconSize

                                    source: "../Images/lock-32.svg"
                                }

                                ComboBox {
                                    id: portalTypeComboBox

                                    Layout.fillWidth: true

                                    model: [ "OAuth", "IWA", "PKI" ]
                                    font.pointSize: styles.textPointSize
                                }
                            }
                        }

                        AppTextInput {
                            id: portalUrlTextInput

                            imageSource: "../Images/web-32.svg"
                            placeholderText: qsTr("Portal URL")
                        }

                        AppSeparator {
                        }

                        AppButton {
                            Layout.alignment: Qt.AlignHCenter

                            text: qsTr("Add Portal")
                            font.pointSize: styles.textPointSize
                            enabled: portalUrlTextInput.text

                            onClicked: addPortal()
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

    function addPortal() {
        accepted();
    }
}
