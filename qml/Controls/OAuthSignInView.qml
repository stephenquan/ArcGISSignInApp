import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebView 1.1
import Esri.Runtime.Testing 1.0

Item {
    property url portalUrl: "https://www.arcgis.com"
    property string oauthClientId: "survey123"
    property string oauthRedirectUri: "urn:ietf:wg:oauth:2.0:oob"
    property string locale: "en"
    property bool hideCancel: false
    readonly property alias url: webView.url
    readonly property alias title: webView.title

    readonly property alias oauthRefreshToken: oauthRefreshTokenRequest.oauthRefreshToken
    readonly property alias token: oauthRefreshTokenRequest.token
    readonly property alias tokenExpires: oauthRefreshTokenRequest.tokenExpires

    readonly property string oauthUrl:
        !!portalUrl && !!oauthClientId && !!oauthRedirectUri
    ? "%1/sharing/rest/oauth2/authorize/?client_id=%2&grant_type=code&response_type=code&expiration=-1&redirect_uri=%3&locale=en&hidecancel=%4"
    .arg(portalUrl)
    .arg(oauthClientId)
    .arg(oauthRedirectUri)
    .arg(hideCancel ? "true" : "false")
    : ""

    signal accepted()
    signal rejected()

    QtObject {
        id: internal
        property string oauthAuthorizationCode
    }

    WebView {
        id: webView

        anchors.fill: parent
        visible: !internal.oauthAuthorizationCode

        url: oauthUrl

        onTitleChanged: {
            let m;
            if ((m = title.match(/^Denied error=(.*)$/))) {
                rejected();
                return;
            }
            if ((m = title.match(/^SUCCESS code=(.*)$/))) {
                internal.oauthAuthorizationCode = m[1];
                appInfo(qsTr("OAuthSignInView: AuthorizationCode acquired"));
                Qt.callLater(oauthRefreshTokenRequest.send);
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent

        running: webView.loading
        || oauthRefreshTokenRequest.busy
    }

    OAuthRefreshTokenRequest {
        id: oauthRefreshTokenRequest

        portalUrl: oauthSignInView.portalUrl
        oauthAuthorizationCode: internal.oauthAuthorizationCode
        oauthRedirectUri: oauthSignInView.oauthRedirectUri
        oauthClientId: oauthSignInView.oauthClientId

        onFailed: {
            appWarn(qsTr("OAuthSignInView: Failed"));
        }

        onSuccess: {
            appInfo(qsTr("OAuthSignInView: Success"));

            Qt.callLater(oauthSignInView.accepted);
        }
    }

    function refresh() {
        appInfo("OAuthSignInView: Refresh");

        internal.oauthAuthorizationCode = "";

        webView.url = oauthUrl;
        Qt.callLater(webView.reload);
    }
}
