import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "../AppControls"
import "../Controls"

Page {
    title: qsTr( "User Information" )

    readonly property bool busy: oauthTokenRequest.busy

    readonly property Button refreshButton: Button {
        onClicked: refresh()
    }

    background: Rectangle {
        color: styles.windowColor
    }

    Flickable {
        id: flickable

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 3 / 4

        topMargin: Math.max((parent.height - contentHeight) / 2, 0)
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

                spacing: 10

                AppSeparator {
                }

                UserThumbnail {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 128
                    Layout.preferredHeight: 128
                }

                AppSeparator {
                }

                AppText {
                    text: qsTr("Not Signed In")
                    font.bold: true
                    horizontalAlignment: Qt.AlignHCenter
                    visible: !appProperties.username
                }

                AppText {
                    text: appProperties.userFullName
                    font.bold: true
                    horizontalAlignment: Qt.AlignHCenter
                    visible: appProperties.username && appProperties.userFullName
                }

                AppTextLayout {
                    Layout.alignment: Qt.AlignHCenter

                    text: appProperties.username
                    imageSource: "../Images/user-32.svg"
                    visible: appProperties.username
                }

                AppTextLayout {
                    Layout.alignment: Qt.AlignHCenter

                    text: appProperties.userEmail
                    imageSource: "../Images/envelope-32.svg"
                    visible: appProperties.username && appProperties.userEmail
                }

                AppTextLayout {
                    Layout.alignment: Qt.AlignHCenter

                    text: currentPortal ? qsTr("%1 (%2)")
                                          .arg(currentPortal.url)
                                          .arg(currentPortal.type) : ""
                    imageSource: "../Images/portal-32.svg"
                    visible: currentPortal
                }

                AppSeparator {
                }

                AppButton {
                    Layout.alignment: Qt.AlignHCenter

                    text: qsTr("Sign In")
                    icon.source: "../Images/sign-in-32.svg"
                    visible: !appProperties.username

                    onClicked: signIn()
                }

                AppButton {
                    Layout.alignment: Qt.AlignHCenter

                    text: qsTr("Sign Out")
                    icon.source: "../Images/sign-out-32.svg"
                    visible: appProperties.username

                    onClicked: signOut()
                }

                AppSeparator {
                }

                AppText {
                    text: qsTr("Token Expiry")
                    color: appProperties.token && oauthTokenRequest.busy ? "grey" : "black"
                    font.bold: styles.heading1Bold
                    visible: appProperties.token
                }

                AppText {
                    text: qsTr( "%1 (expired %2 ago)" )
                    .arg(new Date(appProperties.tokenExpires) )
                    .arg(durationToString(currentTime - appProperties.tokenExpires) )
                    color: oauthTokenRequest.busy ? "grey" : "red"
                    visible: appProperties.token && currentTime > appProperties.tokenExpires
                }

                AppText {
                    text: qsTr( "%1 (valid for %2)" )
                    .arg(new Date(appProperties.tokenExpires) )
                    .arg(durationToString(appProperties.tokenExpires - currentTime) )
                    visible: appProperties.token && currentTime <= appProperties.tokenExpires
                    color: oauthTokenRequest.busy ? "grey" : "black"
                }

                AppSeparator {
                    visible: appProperties.token
                }

                AppText {
                    text: qsTr("Token")
                    color: oauthTokenRequest.busy ? "grey" : "black"
                    font.bold: styles.heading1Bold
                    visible: appProperties.token
                }

                AppText {
                    text: appProperties.token
                    color: oauthTokenRequest.busy ? "grey" : "black"
                    visible: appProperties.token
                }

                AppSeparator {
                    visible: appProperties.oauthRefreshToken
                }

                AppText {
                    text: qsTr( "OAuth Refresh Token" )
                    font.bold: styles.heading1Bold
                    visible: appProperties.oauthRefreshToken
                }

                AppText {
                    text: appProperties.oauthRefreshToken
                    visible: appProperties.oauthRefreshToken
                }

                AppSeparator {
                    visible: appProperties.token
                }

            }
        }

    }

    function refresh() {
        if (!appProperties.oauthRefreshToken) {
            return;
        }

        oauthTokenRequest.send();
    }

}
