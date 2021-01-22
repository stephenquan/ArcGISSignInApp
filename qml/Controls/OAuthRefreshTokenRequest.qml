import QtQuick 2.12
import Esri.Runtime.Testing 1.0

Item {
    id: oauthRefreshTokenRequest

    property url portalUrl
    property string oauthClientId
    property string oauthRedirectUri
    property string oauthAuthorizationCode

    readonly property alias oauthRefreshToken: internal.oauthRefreshToken
    readonly property alias token: internal.token
    readonly property alias tokenExpires: internal.tokenExpires
    readonly property alias error: internal.error
    readonly property alias busy: networkRequest.busy

    signal failed()
    signal success()

    QtObject {
        id: internal

        property string oauthRefreshToken
        property string token
        property double tokenExpires
        property int error
        property var params
    }

    QtNetworkRequest {
        id: networkRequest

        method: "POST"
        url: "%1/sharing/rest/oauth2/token".arg(portalUrl)

        property bool busy: readyState === QtReadyState.OPENED
            || readyState == QtReadyState.LOADING
            || readyState == QtReadyState.HEADERS_RECEIVED

        onReadyStateChanged: {
            if (readyState !== QtReadyState.DONE) {
                return;
            }

            if (error !== QtNetworkError.NoError) {
                appWarn(qsTr("Error: OAuthRefreshTokenRequest: Network Error %1 (%2)")
                            .arg(error)
                            .arg(QtNetworkError.stringify(error)) );
                internal.error = error;
                failed();
                return;
            }

            if (!responseText) {
                internal.error = QtNetworkError.ContentNotFoundError;
                failed();
                return;
            }

            let json;
            try {
                json = JSON.parse(responseText);
            }
            catch (err) {
                internal.error = QtNetworkError.UnknownContentError;
                appWarn(qsTr("Error: OAuthRefreshTokenRequest: Unexpected response: %1").arg(responseText));
                failed();
                return;
            }

            let oauthRefreshToken = json["refresh_token"];
            let token = json["access_token"];
            let tokenExpiresIn = json["expires_in"];
            if (!oauthRefreshToken || !token) {
                internal.error = QtNetworkError.UnknownContentError;
                appWarn(qsTr("Error: OAuthRefreshTokenRequest: Unexpected response: %1").arg(responseText));
                failed();
                return;
            }

            internal.oauthRefreshToken = oauthRefreshToken;
            internal.token = token;
            internal.tokenExpires = Date.now() + tokenExpiresIn * 1000;

            appInfo(qsTr("OAuthRefreshTokenRequest: Success (tokenExpires=%2)")
                        .arg(new Date(internal.tokenExpires)) );

            Qt.callLater(success);
        }
    }

    function send() {
        appInfo(qsTr("OAuthRefreshTokenRequest: Sending"));

        internal.oauthRefreshToken = "";
        internal.token = "";
        internal.tokenExpires = 0;
        internal.error = QtNetworkError.NoError;

        internal.params = {
            grant_type: "authorization_code",
            client_id: oauthClientId,
            redirect_uri: oauthRedirectUri,
            code: oauthAuthorizationCode
        };

        networkRequest.send(internal.params);
    }
}
