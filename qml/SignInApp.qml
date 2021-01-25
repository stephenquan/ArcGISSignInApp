import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Esri.Runtime.Testing 1.0
import "Controls"
import "Pages"

Page {
    id: signInApp

    property alias currentPage: stackView.currentItem
    property double currentTime: Date.now()
    readonly property var currentPortal: getCurrentPortal(appProperties.portals)
    readonly property var currentMap: getCurrentMap(appProperties.maps)
    property bool initializing: true

    title: qsTr("ArcGIS Sign In App")

    header: AppHeader {
        id: appHeader
    }

    StackView {
        id: stackView

        anchors.fill: parent

        initialItem: StartPage {
        }
    }

    BusyIndicator {
        anchors.centerIn: parent

        running: initializing
                 || oauthTokenRequest.busy
                 || userInfoRequest.busy
    }

    AppStyles {
        id: styles
    }

    QtObject {
        id: appProperties


        property var defaultPortals: ( [ {
                                              url: "https://www.arcgis.com",
                                              type: "OAuth",
                                              selected: true,
                                              protected: true
                                          }, {
                                              url: "https://portalpkids.ags.esri.com/gis",
                                              type: "PKI",
                                              selected: false
                                          }, {
                                              url: "https://rqawiniwa02pt.ags.esri.com/gis",
                                              type: "IWA",
                                              selected: false
                                          }, {
                                              url: "https://rqawinpki03pt.ags.esri.com/gis",
                                              type: "PKI",
                                              selected: false
                                          } ] )
        property var defaultMaps: ( [ {
                                           name: "Public Web Map (Public)",
                                           type: "WebMap",
                                           url: "https://www.arcgis.com/home/item.html?id=716b600dbbac433faa4bec9220c76b3a",
                                           selected: true,
                                           protected: true
                                       }, {
                                           name: "World Street Map (Public)",
                                           type: "VectorTiledLayer",
                                           url: "http://www.arcgis.com/home/item.html?id=de26a3cf4cc9451298ea173c4b324736",
                                           selected: false,
                                           protected: true
                                       }, {
                                           name: "World Population (PKI)",
                                           type: "WebMap",
                                           url: "https://rqawinpki03pt.ags.esri.com/gis/home/item.html?id=4612e617516344dabe834024a78885cc",
                                           selected: false
                                       }, {
                                           name: "World Population (IWA)",
                                           type: "WebMap",
                                           url: "https://rqawiniwa02pt.ags.esri.com/gis/home/item.html?id=4ef979c4206b4f13ae19b99391383974",
                                           selected: false
                                       }, {
                                           name: "World Population (OAuth)",
                                           type: "WebMap",
                                           url: "https://melbournedev.maps.arcgis.com/home/item.html?id=818dff1b77db44b38a6d287dc9f5d659",
                                           selected: false
                                       } ] )

        property var portals: defaultPortals
        property var maps: defaultMaps
        property bool rememberMe: true
        property string oauthClientId: "survey123"
        property string oauthRedirectUri: "urn:ietf:wg:oauth:2.0:oob"
        property string oauthRefreshToken
        property string pkiFileName
        property string pkiFileData
        property string pkiPassword
        property string token
        property double tokenExpires
        property string username
        property string userFullName
        property string userDescription
        property string userEmail
        property string userThumbnail
        property string userThumbnailUri
        property var userProperties

        function load() {
            let values = ({});
            try {
                values = JSON.parse(QtSettings.value("values"));
            }
            catch (parseValuesError) {
            }

            let securedValues = ({});
            try {
                securedValues = JSON.parse(QtSettings.value("securedValues"));
            }
            catch (parseSecuredValuesError) {
            }

            portals = values["portals"] || portals;
            maps = values["maps"] || maps;

            oauthClientId = securedValues["oauthClientId"] || oauthClientId;
            oauthRedirectUri = securedValues["oauthRedirectUri"] || oauthRedirectUri;
            oauthRefreshToken = securedValues["oauthRefreshToken"] || oauthRefreshToken;
            QtNetworking.user = securedValues["iwaUser"] || QtNetworking.user;
            QtNetworking.password = securedValues["iwaPassword"] || QtNetworking.password;
            QtNetworking.realm = securedValues["iwaRealm"] || QtNetworking.realm;
            pkiFileName = securedValues["pkiFileName"] || pkiFileName;
            pkiFileData = securedValues["pkiFileData"] || pkiFileData;
            pkiPassword = securedValues["pkiPassword"] || pkiPassword;
            token = securedValues["token"] || token;
            tokenExpires = securedValues["tokenExpires"] || tokenExpires;
            username = securedValues["username"] || username;
            userFullName = securedValues["userFullName"] || userFullName;
            userDescription = securedValues["userDescription"] || userFullName;
            userEmail = securedValues["userEmail"] || userEmail;
            userThumbnail = securedValues["userThumbnail"] || userThumbnail;
            userThumbnailUri = securedValues["userThumbnailUri"] || userThumbnailUri;
            userProperties = securedValues["userProperties"] || userProperties;

            pkiBinaryData.base64 = pkiFileData;
            QtNetworking.pkcs12 = QtNetworking.importPkcs12(pkiBinaryData.data, pkiPassword);

            appInfo(qsTr("WebMapApp: Properties: Load (username=%1, fullName=%2, token=%3, tokenExpires=%4)")
                    .arg(JSON.stringify(username))
                    .arg(JSON.stringify(userFullName))
                    .arg(JSON.stringify(token))
                    .arg(tokenExpires ? new Date(tokenExpires) : ""));
        }

        function save() {
            let values = {
                portals,
                maps
            };

            let securedValues = {
                oauthClientId,
                oauthRedirectUri,
                oauthRefreshToken,
                iwaUser: QtNetworking.user,
                iwaPassword: QtNetworking.password,
                iwaRealm: QtNetworking.realm,
                pkiFileName,
                pkiFileData,
                pkiPassword,
                token,
                tokenExpires,
                username,
                userFullName,
                userDescription,
                userEmail,
                userThumbnail,
                userThumbnailUri,
                userProperties,
                maps
            };

            QtSettings.setValue("values", JSON.stringify(values));
            QtSettings.setValue("securedValues", JSON.stringify(securedValues));

            appInfo(qsTr("WebMapApp: Properties: Save (username=%1, token=%2, tokenExpires=%3)")
                    .arg(JSON.stringify(username))
                    .arg(JSON.stringify(token))
                    .arg(tokenExpires ? new Date(tokenExpires) : ""));
        }
    }

    OAuthTokenRequest {
        id: oauthTokenRequest

        portalUrl: currentPortal ? currentPortal.url : ""
        oauthClientId: appProperties.oauthClientId
        oauthRefreshToken: appProperties.oauthRefreshToken

        onFailed: {

        }

        onSuccess: {
            appProperties.token = token;
            appProperties.tokenExpires = tokenExpires;
            appProperties.save();

            userInfoRequest.send();
        }
    }

    UserInfoRequest {
        id: userInfoRequest

        portalUrl: currentPortal ? currentPortal.url : ""
        token: appProperties.token

        onFailed: {

        }

        onSuccess: {
            appProperties.username = username;
            appProperties.userFullName = userFullName;
            appProperties.userDescription = userDescription;
            appProperties.userEmail = userEmail;
            appProperties.userThumbnail = userThumbnail;
            appProperties.userThumbnailUri = userThumbnailUri;
            appProperties.userProperties = userProperties;
            appProperties.save();
        }
    }

    Connections {
        target: QtNetworking

        function onAuthenticationRequired() {
            appInfo("WebAMapApp: AuthenticationRequired: ", url);
        }
    }

    Timer {
        id: heartBeatTimer

        running: true
        repeat: true
        interval: 1000
        onTriggered: currentTime = Date.now()
    }

    QtBinaryData {
        id: pkiBinaryData
    }

    Component {
        id: aboutComponent

        AboutPage {
        }
    }

    Component {
        id: userComponent

        UserPage {
        }
    }

    Component {
        id: selectPortalComponent

        SelectPortalPage {
        }
    }


    Component {
        id: signInComponent

        SignInPage {
            portalUrl: currentPortal ? currentPortal.url : ""
            oauthClientId: appProperties.oauthClientId
            oauthRedirectUri: appProperties.oauthRedirectUri
            pkiFileName: appProperties.pkiFileName
            pkiFileData: appProperties.pkiFileData
            pkiPassword: appProperties.pkiPassword

            onAccepted: {
                appProperties.oauthRefreshToken = refreshToken;
                appProperties.token = token;
                appProperties.tokenExpires = tokenExpires;
                appProperties.pkiFileName = pkiFileName;
                appProperties.pkiFileData = pkiFileData;
                appProperties.pkiPassword = pkiPassword;
                appProperties.save();
                Qt.callLater(stackView.pop);
            }

            onRejected: {
                stackView.pop();
            }
        }
    }

    function durationToString( milliseconds ) {
        let p = "";
        if ( milliseconds < 0 ) {
            milliseconds = -milliseconds;
            p = "-";
        }
        let s = Math.floor( milliseconds / 1000);
        let m = 0;
        let h = 0;
        if (s >= 60) {
            m = Math.floor(s / 60);
            s = s % 60;
        }
        if (m >= 60) {
            h = Math.floor( m / 60);
            m = m % 60;
        }
        return p + [
                    ( "" + h ).padStart( 2, "0" ),
                    ( "" + m ).padStart( 2, "0" ),
                    ( "" + s ).padStart( 2, "0" )
                ].join(":");
    }

    function appWarn(...params) {
        console.warn("W", Qt.formatDateTime(new Date(), "HH:mm:ss"), ...params);
    }

    function appInfo(...params) {
        console.info("I", Qt.formatDateTime(new Date(), "HH:mm:ss"), ...params);
    }

    function refreshToken() {
        oauthTokenRequest.send();
    }

    function refreshUserInfo() {
        userInfoRequest.send();
    }

    function getCurrentPortal(portals) {
        return portals ? portals.find( p => p.selected ) : null;
    }

    function getCurrentMap(maps) {
        return maps ? maps.find( m => m.selected ) : null;
    }

    function init() {
        initializing = true;
        QtSettings.path = QtAppFramework.userHomeFolder.filePath("WebMapApp.ini");
        QtSettings.format = QtSettingsFormat.IniFormat;
        appProperties.load();
        currentPortalChanged();
        currentMapChanged();
        initializing = false;

        appInfo(qsTr("WebMapApp: Init (username=%1, fullName=%2, currentPortal.url=%3, currentPortal.type=%4)")
                .arg(JSON.stringify(appProperties.username))
                .arg(JSON.stringify(appProperties.userFullName))
                .arg(JSON.stringify(currentPortal ? currentPortal.url : null))
                .arg(JSON.stringify(currentPortal ? currentPortal.type : null)));

        if (appProperties.username
                && currentPortal.type === "OAuth"
                && appProperties.oauthRefreshToken) {
            oauthTokenRequest.send();
        }
    }

    function signIn() {
        stackView.push(signInComponent);
    }

    function signOut() {
        appProperties.oauthRefreshToken = "";
        appProperties.token = "";
        appProperties.tokenExpires = 0;
        QtNetworking.user = "";
        QtNetworking.password = "";
        QtNetworking.realm = "";
        appProperties.pkiFileName = "";
        appProperties.pkiFileData = "";
        appProperties.pkiPassword = "";
        appProperties.username = "";
        appProperties.userFullName = "";
        appProperties.userDescription = "";
        appProperties.userEmail = "";
        appProperties.userThumbnail = "";
        appProperties.userThumbnailUri = "";
        appProperties.userProperties = null;
        appProperties.save();
    }

    Component.onCompleted: Qt.callLater(init)

}
