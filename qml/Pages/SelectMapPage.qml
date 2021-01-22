import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "../Controls"
import "../AppControls"

Page {
    id: page

    title: qsTr("Select Map")

    property Button menuButton: Button {
        onClicked: menuClicked()
    }

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
                id: columnLayout

                width: parent.width

                Text {
                    Layout.fillWidth: true

                    text: qsTr("Select Map")
                    font.pointSize: styles.heading1PointSize
                    font.bold: styles.heading1Bold
                }

                Item { Layout.preferredHeight: 10 }

                ListView {
                    id: listView

                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight

                    model: appProperties.maps

                    delegate: Frame {
                        width: listView.width

                        background: Rectangle {
                            color: listView.currentIndex === index
                                   ? styles.listSelectedBackgroundColor
                                   : (index & 1)
                                     ? styles.listOddBackgroundColor
                                     : styles.listEvenBackgroundColor

                            MouseArea {
                                anchors.fill: parent

                                onClicked: select(index)
                            }
                        }

                        RowLayout {
                            width: parent.width

                            SVGImage {
                                Layout.preferredWidth: styles.smallIconSize
                                Layout.preferredHeight: styles.smallIconSize

                                source: "../Images/map-32.svg"
                                color: listView.currentIndex === index
                                ? styles.listSelectedTextColor
                                : styles.listTextColor
                            }

                            AppText {
                                text: modelData.name
                                color: listView.currentIndex === index
                                ? styles.listSelectedTextColor
                                : styles.listTextColor
                            }

                            SVGImage {
                                Layout.preferredWidth: styles.smallIconSize
                                Layout.preferredHeight: styles.smallIconSize

                                visible: listView.currentIndex === index
                                source: listView.currentIndex === index
                                ? "../Images/check-32.svg"
                                : ""
                                color: listView.currentIndex === index
                                ? styles.listSelectedTextColor
                                : styles.listTextColor
                            }

                        }
                    }
                }

            }
        }
    }

    QtObject {
        id: internal

        property bool initialzing: true
    }

    Rectangle {
        anchors.fill: parent

        color: "black"
        opacity: 0.5
        visible: menu.visible
    }

    Menu {
        id: menu

        x: parent.width - menu.width
        y: 0

        MenuItem {
            text: qsTr("Add ...")
            font.pointSize: styles.textPointSize

            onTriggered: addMap()
        }

        MenuItem {
            text: qsTr("Delete ...")
            font.pointSize: styles.textPointSize
            enabled: listView.currentIndex >= 0 && !appProperties.maps[listView.currentIndex].protected

            onTriggered: deleteMap()
        }

        MenuItem {
            text: qsTr("Move Up")
            font.pointSize: styles.textPointSize
            enabled: listView.currentIndex > 0

            onTriggered: moveUp()
        }

        MenuItem {
            text: qsTr("Move Down")
            font.pointSize: styles.textPointSize
            enabled: listView.currentIndex >= 0 && listView.currentIndex < listView.count - 1

            onTriggered: moveDown()
        }

        MenuItem {
            text: qsTr("Reset")
            font.pointSize: styles.textPointSize

            onTriggered: resetMaps()
        }

    }

    Component {
        id: addMapComponent

        AddMapPage {
            onAccepted: {
                appProperties.maps.map( p => { p.selected = false; return p; } );
                appProperties.maps.push(
                            {
                                name: mapName,
                                type: mapType,
                                url: mapUrl,
                                selected: true
                            } );
                appProperties.save();
                currentMapChanged();
                stackView.pop();
                listView.model = appProperties.maps;
                refreshCurrentIndex();
            }
        }
    }

    Component.onCompleted: Qt.callLater(init)

    function init() {
        internal.initialzing = true;
        refreshCurrentIndex();
        internal.initialzing = false;
    }

    function select(index) {
        if (internal.initializing) {
            return;
        }

        if (currentMap === appProperties.maps[index]) {
            return;
        }

        console.log("currentMap (before): ", JSON.stringify(currentMap));

        for (let i=0; i < appProperties.maps.length; i++) {
            appProperties.maps[i].selected = ( i === index );
        }
        appProperties.mapsChanged();
        appProperties.save();

        currentMapChanged();

        listView.model = appProperties.maps;

        refreshCurrentIndex();
    }

    function refreshCurrentIndex() {
        for (let i=0; i < appProperties.maps.length; i++) {
            if (appProperties.maps[i].selected) {
                listView.currentIndex = i;
                return;
            }
        }

        listView.currentIndex = -1;
    }

    function menuClicked() {
        menu.open();
    }

    function objectArrayMove(arr, from, to) {
        let rank = Symbol("rank");
        arr.forEach( (item, i) => item[rank] = i );
        arr[from][rank] = to - 0.5;
        arr.sort( (i, j) => i[rank] - j[rank]);
    }

    function deleteMap() {
        let currentIndex = listView.currentIndex;
        appProperties.maps.splice(listView.currentIndex, 1);
        if (appProperties.maps.length > 0)
        {
            if (currentIndex < appProperties.maps.length)
            {
                appProperties.maps[currentIndex].selected = true;
            }
            else
            {
                appProperties.maps[0].selected = true;
            }
        }
        appProperties.save();
        currentMapChanged();
        listView.model = appProperties.maps;
        refreshCurrentIndex();
    }

    function moveUp() {
        objectArrayMove(appProperties.maps, listView.currentIndex, listView.currentIndex-1);
        appProperties.save();
        currentMapChanged();
        listView.model = appProperties.maps;
        refreshCurrentIndex();
    }

    function moveDown() {
        objectArrayMove(appProperties.maps, listView.currentIndex, listView.currentIndex+2);
        appProperties.save();
        currentMapChanged();
        listView.model = appProperties.maps;
        refreshCurrentIndex();
    }

    function resetMaps() {
        appProperties.maps = appProperties.defaultMaps;
        appProperties.save();
        currentMapChanged();
        listView.model = appProperties.maps;
        refreshCurrentIndex();
    }

    function addMap() {
        stackView.push(addMapComponent);
    }
}
