import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Esri.Runtime.Testing 1.0

Page {
    id: page

    title: qsTr("Select an account")

    readonly property int kSelectionNone: -1
    readonly property int kSelectionAdd: -2
    property int selectionIndex: kSelectionNone

    onSelectionIndexChanged: doPingPortal()

    background: Rectangle {
        color: styles.windowColor
    }

    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.margins: 10

        contentWidth: columnLayout.width
        contentHeight: columnLayout.height
        clip: true

        ColumnLayout {
            id: columnLayout

            width: flickable.width

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 0

                Repeater {
                    model: appProperties.portals

                    delegate: AccountDelegate {
                        icon: "../Images/portal-32.svg"
                        url: modelData.url
                        type: modelData.type
                        itemIndex: index
                        properties: modelData
                    }
                }

                AccountDelegate {
                    icon: "../Images/plus-32.svg"
                    itemIndex: kSelectionAdd
                    displayText: qsTr("Add another portal")
                }
            }

            Button {
                Layout.alignment: Qt.AlignRight

                text: qsTr("Sign In")
                font.pointSize: styles.textPointSize
                enabled: selectionIndex !== kSelectionNone
                && !pollPortal.busy
                && pollPortal.error === QtNetworkError.NoError

                onClicked: doSignIn()
            }
        }
    }

    footer: Frame {
        ColumnLayout {
            width: parent.width

            Text {
                text: pollPortal.url
                font.pointSize: styles.textPointSize
                visible: pollPortal.busy
            }

            Text {
                text: qsTr("%1 (%2)")
                .arg(QtNetworkError.stringify(pollPortal.error))
                .arg(pollPortal.error)
                font.pointSize: styles.textPointSize
                color: "red"
                visible: pollPortal.error !== QtNetworkError.NoError
            }

            Text {
                text: pollPortal.errorText
                font.pointSize: styles.textPointSize
                color: "red"
                visible: pollPortal.error !== QtNetworkError.NoError
            }
        }
    }

    QtNetworkRequest {
        id: pollPortal

        property url portalUrl: "https://www.arcgis.com"
        url: portalUrl + "/sharing/rest"
        readonly property bool busy: readyState !== QtReadyState.UNSENT
                            && readyState !== QtReadyState.DONE

        function submit() {
            send( { "f" : "pjson" } );
        }

        onReadyStateChanged: {
            console.log(qsTr("pollPortal: url=%1, readyState: %2 (%3)")
                        .arg(url)
                        .arg(QtReadyState.stringify(readyState))
                        .arg(readyState)
                        )
            if (readyState !== QtReadyState.DONE)
            {
                return;
            }

            if (error !== QtNetworkError.NoError)
            {
                console.log(qsTr("pollPortal: error: %1: %2 (%3)")
                            .arg(errorText)
                            .arg(QtNetworkError.stringify(error))
                            .arg(error)
                            );
                return;
            }

            console.log(qsTr("pollPortal: responseText:"));
            console.log(responseText);
        }

    }

    function doPingPortal() {
        if (selectionIndex < 0) {
            return;
        }

        pollPortal.portalUrl = appProperties.portals[selectionIndex].url;
        pollPortal.submit();
    }

    function doSignIn() {

    }
}

