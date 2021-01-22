import QtQuick 2.12
import QtQuick.Controls 2.12
import QtPositioning 5.12
import QtQuick.Layouts 1.12
import Esri.ArcGISRuntime 100.5
import Esri.Runtime.Testing 1.0

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

    property Button menuButton: Button {
        onClicked: menuClicked()
    }

    MapView {
        id: mapView

        anchors.fill: parent
    }

    Connections {
        target: webMapApp

        onCurrentMapChanged: {
            if (initializing) {
                return;
            }

            Qt.callLater(refresh);
        }
    }

    OAuthClientInfo {
        id: clientInfo

        oAuthMode: Enums.OAuthModeUser
        clientId: appProperties.oauthClientId
    }

    Connections {
        target: AuthenticationManager

        onAuthenticationChallenge: {
            authenticationChallengeCount++;
            appInfo(qsTr("MapPage: AuthenticationChallenge: Start challengeCount=%1")
                    .arg(authenticationChallengeCount)
                    );

            let params = {
                //oAuthClientInfo: clientInfo,
                //oAuthRefreshToken: appProperties.refreshToken,
                //referer: "https://www.arcgis.com",
                referer: currentPortal ? currentPortal.url : "",
                token: appProperties.token,
                tokenExpiry: appProperties.tokenExpires,
                //tokenServiceUrl: "https://www.arcgis.com/sharing/rest/oauth2/token"
                tokenServicesUrl: currentPortal ? "%1/sharing/rest/generateToken".arg(currentPortal.url) : null,
                //username: QtNetworking.user,
                username: appProperties.username,
                password: QtNetworking.password
            };
            let sanitizedParams = {
                referer: params.referer,
                token: params.token,
                tokenExpiry: params.tokenExpiry,
                tokenServicesUrl: params.tokenServicesUrl,
                username: params.username,
                password: params.password ? qsTr("PASSWORD SUPPLIED") : qsTr("PASSWORD_EMPTY")
            };
            appInfo(qsTr("MapPage: AuthenticationChallenge: Credential challengeCount=%1, params=%2")
                    .arg(authenticationChallengeCount)
                    .arg(JSON.stringify(sanitizedParams)));
            let credential = ArcGISRuntimeEnvironment.createObject("Credential", params);
            challenge.continueWithCredential(credential);

            appInfo(qsTr("MapPage: AuthenticationChallenge: Finished challengeCount=%1")
                    .arg(authenticationChallengeCount));
        }
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
        AuthenticationManager.credentialCacheEnabled = false;
        initializing = false;
    }

    function refresh() {
        if (!currentMap) {
            appWarn(qsTr("MapPage.Refresh: No valid map"));
            return;
        }

        if (currentMap.type === "WebMap") {
            appInfo(qsTr("MapPage: Refresh: WebMap: name=%1, url=%2")
                    .arg(JSON.stringify(currentMap.name))
                    .arg(JSON.stringify(currentMap.url)));
            mapView.map = ArcGISRuntimeEnvironment.createObject("Map", { initUrl: currentMap.url } );
            return;
        }

        if (currentMap.type === "VectorTiledLayer") {
            appInfo(qsTr("MapPage: Refresh: VectorTiledLayer: name=%1, url=%2")
                    .arg(JSON.stringify(currentMap.name))
                    .arg(JSON.stringify(currentMap.url)));

            let layer = ArcGISRuntimeEnvironment.createObject("ArcGISVectorTiledLayer", {url:currentMap.url});
            let newBasemap = ArcGISRuntimeEnvironment.createObject("Basemap");
            newBasemap.baseLayers.append(layer);
            mapView.map = ArcGISRuntimeEnvironment.createObject("Map", { basemap: newBasemap });
            return;
        }

        appWarn(qsTr("MapPage: Refresh: Map unsupported: name=%1, type=%1")
                .arg(JSON.stringify(currentMap.name))
                .arg(JSON.stringify(currentMap.type)));
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
