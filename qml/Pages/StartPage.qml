import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {
    id: page

    background: Rectangle {
        color: styles.windowColor
    }

    Button {
        anchors.centerIn: parent

        text: qsTr("Start")
        font.pointSize: styles.textPointSize

        onClicked: doStart()
    }

    Component {
        id: selectAccountPage

        SelectAccountPage {
        }
    }

    function doStart() {
        stackView.push(selectAccountPage);
    }
}

