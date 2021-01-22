import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "../Controls"
import "../AppControls"

Page {
    id: page

    title: qsTr("Select Portal")

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

                    text: qsTr("Select Portal")
                    font.pointSize: styles.heading1PointSize
                    font.bold: styles.heading1Bold
                }

                Item { Layout.preferredHeight: 10 }

                ListView {
                    id: listView

                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight

                    model: appProperties.portals

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

                                source: "../Images/portal-32.svg"
                                color: listView.currentIndex === index
                                ? styles.listSelectedTextColor
                                : styles.listTextColor
                            }

                            AppText {
                                text: qsTr("%1 (%2)")
                                    .arg(modelData.url)
                                    .arg(modelData.type)
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

            onTriggered: addPortal()
        }

        MenuItem {
            text: qsTr("Delete ...")
            font.pointSize: styles.textPointSize
            enabled: listView.currentIndex >= 0 && !appProperties.portals[listView.currentIndex].protected

            onTriggered: deletePortal()
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

            onTriggered: resetPortals()
        }

    }

    Component {
        id: addPortalComponent

        AddPortalPage {
            onAccepted: {
                appProperties.portals.map( p => { p.selected = false; return p; } );
                appProperties.portals.push(
                            {
                                type: portalType,
                                url: portalUrl,
                                selected: true
                            } );
                appProperties.save();
                currentPortalChanged();
                stackView.pop();
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

        if (currentPortal === appProperties.portals[index]) {
            return;
        }

        signOut();

        console.log("currentPortal (before): ", JSON.stringify(currentPortal));

        for (let i=0; i < appProperties.portals.length; i++) {
            appProperties.portals[i].selected = ( i === index );
        }
        appProperties.portalsChanged();
        appProperties.save();

        currentPortalChanged();

        listView.model = appProperties.portals;

        refreshCurrentIndex();
    }

    function refreshCurrentIndex() {
        for (let i=0; i < appProperties.portals.length; i++) {
            if (appProperties.portals[i].selected) {
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

    function deletePortal() {
        let currentIndex = listView.currentIndex;
        appProperties.portals.splice(listView.currentIndex, 1);
        if (appProperties.portals.length > 0) {
            if (currentIndex < appProperties.portals.length) {
                appProperties.portals[currentIndex].selected = true;
            }
            else {
                appProperties.portals[0].selected = true;
            }
        }
        appProperties.save();
        currentPortalChanged();
        listView.model = appProperties.portals;
        refreshCurrentIndex();
    }

    function moveUp() {
        objectArrayMove(appProperties.portals, listView.currentIndex, listView.currentIndex-1);
        appProperties.save();
        currentPortalChanged();
        listView.model = appProperties.portals;
        refreshCurrentIndex();
    }

    function moveDown() {
        objectArrayMove(appProperties.portals, listView.currentIndex, listView.currentIndex+2);
        appProperties.save();
        currentPortalChanged();
        listView.model = appProperties.portals;
        refreshCurrentIndex();
    }

    function resetPortals() {
        appProperties.portals = appProperties.defaultPortals;
        appProperties.save();
        currentPortalChanged();
        listView.model = appProperties.portals;
        refreshCurrentIndex();
    }

    function addPortal() {
        stackView.push(addPortalComponent);
    }
}
