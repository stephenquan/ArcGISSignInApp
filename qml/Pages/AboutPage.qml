import QtQuick 2.12
import QtQuick.Controls 2.12
import QtPositioning 5.12
import QtQuick.Layouts 1.12
import Esri.Runtime.Testing 1.0
import "../Controls"
import "../AppControls"

Page {
    property bool initializing: true

    title: qsTr("About")

    background: Rectangle {
        color: styles.windowColor
    }

    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.margins: 10

        contentWidth: frame.width
        contentHeight: frame.height
        clip: true

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
                width: parent.width

                AppText {
                    text: qsTr("Secure Map App")

                    horizontalAlignment: Qt.AlignHCenter
                }

                AppText {
                    text: qsTr("This is an application for testing secured WebMaps with the ArcGIS Runtime. Authentication types supported are: OAuth, PKI and IWA.  Use the User icon to login to either ArcGIS Online or on your enterprise ArcGIS for Portal.")
                }

                AppSeparator {
                }

                AppText {
                    text: [
                        qsTr("Qt Version: %1").arg(QtAppFramework.qtVersion),
                        qsTr("ArcGIS Runtime Version: %1").arg(ArcGISRuntimeEnvironment.version),
                        qsTr("User Home Path: %1").arg(QtAppFramework.userHomeFolder.path)
                    ].join("\n")
                }
            }
        }
    }
}
