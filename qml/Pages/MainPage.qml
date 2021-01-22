import QtQuick 2.12
import QtQuick.Controls 2.12
import QtPositioning 5.12
import QtQuick.Layouts 1.12

Page {
    property bool initializing: true
    property int authenticationChallengeCount: 0

    title: currentMap.name

    property Button refreshButton: Button {
        onClicked: refresh()
    }

    property Button userButton: Button {
        onClicked: userClicked()
    }

    Menu {
        id: menu

        x: parent.width - menu.width
        y: 0

        MenuItem {
            text: qsTr("Select Map...")
            font.pointSize: styles.textPointSize

            onTriggered: selectMap()
        }

        MenuItem {
            text: qsTr("About")
            font.pointSize: styles.textPointSize

            onTriggered: about()
        }
    }

    Component.onCompleted: Qt.callLater(init)

    Component {
        id: selectMapComponent

        SelectMapPage {
        }
    }

    function init() {
        initializing = true;
        refresh();
        initializing = false;
    }

    function refresh() {
    }

    function userClicked() {
        stackView.push(userComponent);
    }

    function about() {
        stackView.push(aboutComponent);
    }

    function menuClicked() {
        menu.open();
    }

    function selectMap() {
        stackView.push(selectMapComponent);
    }

}

