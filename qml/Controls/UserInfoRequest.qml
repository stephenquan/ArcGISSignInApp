import QtQuick 2.12
import Esri.Runtime.Testing 1.0

Item {
    id: userInfoRequest

    property url portalUrl
    property string token

    readonly property bool busy: networkRequest.busy || thumbnailRequest.busy

    readonly property alias error: internal.error
    readonly property alias errorString: internal.errorString

    readonly property alias username: internal.username
    readonly property alias userFullName: internal.userFullName
    readonly property alias userDescription: internal.userDescription
    readonly property alias userEmail: internal.userEmail
    readonly property alias userThumbnail: internal.userThumbnail
    readonly property alias userThumbnailUri: internal.userThumbnailUri
    readonly property alias userProperties: internal.userProperties

    signal success()
    signal failed()

    QtObject {
        id: internal
        property int error: QtNetworkError.NoError
        property string errorString
        property string username
        property string userFullName
        property string userDescription
        property string userEmail
        property string userThumbnail
        property string userThumbnailUri
        property var userProperties
    }

    QtNetworkRequest {
        id: networkRequest

        property bool busy: readyState === QtReadyState.OPENED
        || readyState === QtReadyState.LOADING
        || readyState === QtReadyState.HEADERS_RECEIVED

        url: "%1/sharing/rest/community/self".arg(portalUrl)

        onReadyStateChanged: {
            if (readyState !== QtReadyState.DONE) {
                return;
            }

            if (error !== QtNetworkError.NoError) {
                internal.error = error;
                internal.errorString = qsTr("Network Error %1: %2")
                            .arg(error)
                            .arg(QtNetworkError.stringify(error));
                appWarn(qsTr("Error: UserInfoRequest: %1").arg(internal.errorString));
                failed();
                return;
            }

            if (!responseText) {
                internal.error = QtNetworkError.UnknownContentError;
                internal.errorString = qsTr("Empty Content");
                appWarn(qsTr("Error: UserInfoRequest: %1").arg(internal.errorString));
                failed();
                return;
            }

            let json;
            try {
                json = JSON.parse(responseText);
            }
            catch (err) {
                internal.error = QtNetworkError.UnknownContentError;
                internal.errorString = qsTr("Unexpected Content: %1").arg(responseText);
                appWarn(qsTr("Error: UserInfoRequest: %1").arg(internal.errorString));
                failed();
                return;
            }

            let _error = json["error"];
            if (_error) {
                internal.error = QtNetworkError.UnknownContentError;
                internal.errorString = qsTr("Unexpected Content: %1").arg(responseText);
                appWarn(qsTr("Error: UserInfoRequest: %1").arg(internal.errorString));
                failed();
                return;
            }

            internal.username = json["username"];
            internal.userFullName = json["fullName"];
            internal.userDescription = json["description"];
            internal.userEmail = json["email"];
            internal.userThumbnail = json["thumbnail"];
            internal.userProperties = json;

            if (!internal.username) {
                internal.error = QtNetworkError.UnknownContentError;
                internal.errorString = qsTr("Unexpected Content: %1").arg(responseText);
                appWarn(qsTr("Error: UserInfoRequest: %1").arg(internal.errorString));
                failed();
            }

            appInfo( qsTr("UserInfoRequest: Success (username=%1, userThumbnail=%2)" )
                        .arg(JSON.stringify(internal.username))
                    .arg(JSON.stringify(internal.userThumbnail))
                    );

            if (userThumbnail) {
                thumbnailRequest.send();
                return;
            }

            Qt.callLater(success);
        }
    }

    QtNetworkRequest {
        id: thumbnailRequest

        property bool busy: readyState === QtReadyState.OPENED
        || readyState === QtReadyState.LOADING
        || readyState === QtReadyState.HEADERS_RECEIVED

        url: "%1/sharing/rest/community/users/%2/info/%3"
        .arg(portalUrl)
        .arg(username)
        .arg(userThumbnail)
        responseType: "base64"

        onReadyStateChanged: {
            if (readyState !== QtReadyState.DONE) {
                return;
            }

            if (error !== QtNetworkError.NoError) {
                internal.error = error;
                internal.errorString = qsTr("Network Error %1: %2")
                            .arg(error)
                            .arg(QtNetworkError.stringify(error));
                appWarn(qsTr("Error: UserInfoRequest: Thumbnail: %1").arg(internal.errorString));
                failed();
                return;
            }

            if (!response) {
                internal.error = QtNetworkError.UnknownContentError;
                internal.errorString = qsTr("Empty Thumbnail");
                appWarn(qsTr("Error: UserInfoRequest: Thumbnail: %1").arg(internal.errorString));
                failed();
                return;
            }

            let contentType = responseHeaders["Content-Type"];
            let m = contentType.match(/(image\/[a-z]+)/);
            if (m) {
               internal.userThumbnailUri = "data:" + m[1] + ";base64," + response;
            }

            appInfo(qsTr("UserInfoRequest: Thumbnail: Success"));

            Qt.callLater(success);
        }
    }

    function send() {
        appInfo(qsTr( "UserInfoRequest: Sending (portalUrl=%1)")
                .arg(JSON.stringify(portalUrl)));

        internal.error = QtNetworkError.NoError;
        internal.errorString = "";
        internal.username = "";
        internal.userFullName = "";
        internal.userDescription = "";
        internal.userEmail = "";
        internal.userThumbnail = "";
        internal.userThumbnailUri = "";
        internal.userProperties = null;

        let params = {
            f: "pjson"
        };

        if (appProperties.token) {
            params["token"] = appProperties.token;
        }

        networkRequest.send(params);
    }
}
