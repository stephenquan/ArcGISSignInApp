import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import Esri.Runtime.Testing 1.0
import "../AppControls"
import "../Controls"

Page {
    id: page

    title: qsTr("Sign In")

    //property alias portalUrl: oauthSignInView.portalUrl
    property url portalUrl
    property alias oauthClientId: oauthSignInView.oauthClientId
    property alias oauthRedirectUri: oauthSignInView.oauthRedirectUri

    property alias refreshToken: oauthSignInView.oauthRefreshToken
    property alias token: oauthSignInView.token
    property alias tokenExpires: oauthSignInView.tokenExpires

    property string pkiFileName
    property alias pkiFileData: pkiBinaryData.base64
    property alias pkiPassword: pkiPasswordTextInput.text
    property alias pkiFolder: pkiFileDialog.folder

    property bool hasRefresh: true

    property Button refreshButton: Button {
        onClicked: refresh()
    }

    property Button menuButton: Button {
        onClicked: menuClicked()
    }

    signal accepted()
    signal rejected()

    background: Rectangle {
        color: styles.windowColor
    }

    Flickable {
        id: flickable

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: (parent.width - 20) * 80 / 100

        contentWidth: frame.width
        contentHeight: frame.height
        clip: true
        topMargin: Math.max((parent.height - frame.height) / 2, 0)

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

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter

                    SVGImage {
                        Layout.preferredWidth: styles.smallIconSize
                        Layout.preferredHeight: styles.smallIconSize

                        source: "../Images/portal-32.svg"
                    }

                    Text {
                        text: currentPortal ? qsTr("%1 (%2)")
                                              .arg(currentPortal.url)
                                              .arg(currentPortal.type) : ""
                        font.pointSize: styles.textPointSize
                    }
                }

                AppSeparator {
                }

                OAuthSignInView {
                    id: oauthSignInView

                    Layout.fillWidth: true
                    Layout.preferredHeight: page.height * 80 / 100

                    portalUrl: currentPortal && currentPortal.type === "OAuth" ? page.portalUrl : ""
                    visible: !!currentPortal && currentPortal.type === "OAuth"

                    onAccepted: {
                        appProperties.oauthRefreshToken = oauthRefreshToken;
                        appProperties.token = token;
                        appProperties.tokenExpires = tokenExpires;
                        appProperties.save();
                        userInfoRequest.send();
                    }

                    onRejected: {
                        page.rejected()
                    }
                }

                Frame {
                    Layout.fillWidth: true

                    visible: !!currentPortal && currentPortal.type === "PKI"

                    background: Rectangle {
                        color: "white"
                    }

                    ColumnLayout {
                        width: parent.width

                        AppSeparator {
                        }

                        AppTextInput {
                            imageSource: "../Images/user-32.svg"
                            text: pkiFileName
                            placeholderText: qsTr("PKI File")
                            button1.source: "../Images/ellipsis-32.svg"
                            button1.onClicked: pkiFileDialog.open()
                        }

                        AppTextInput {
                            id: pkiPasswordTextInput

                            imageSource: "../Images/lock-32.svg"
                            placeholderText: qsTr("PKI Password")
                            echoMode: button1.pressed
                                      ? TextInput.Normal
                                      : TextInput.Password
                            button1.source: button1.pressed
                                            ? "../Images/view-visible-32.svg"
                                            : "../Images/view-mixed-32.svg"

                            onTextChanged: clearError()
                        }

                        AppSeparator {
                        }

                        AppButton {
                            id: pkiSignInButton

                            Layout.alignment: Qt.AlignHCenter

                            text: qsTr("Sign In")
                            icon.source: "../Images/sign-in-32.svg"

                            onClicked: pkiSignIn()
                        }

                        AppSeparator {
                            visible: internal.errorString
                        }

                        AppText {
                            text: internal.errorString
                            visible: internal.errorString
                            horizontalAlignment: Qt.AlignHCenter
                            color: "red"
                        }

                        AppSeparator {
                        }
                    }
                }

                Frame {
                    Layout.fillWidth: true

                    visible: !!currentPortal && currentPortal.type === "IWA"

                    background: Rectangle {
                        color: "white"
                    }

                    ColumnLayout {
                        width: parent.width

                        AppSeparator {
                        }

                        AppTextInput {
                            imageSource: "../Images/user-32.svg"
                            text: QtNetworking.user
                            placeholderText: qsTr("IWA Username")

                            onTextChanged: QtNetworking.user = text
                            onAccepted: nextItemInFocusChain().forceActiveFocus()
                        }

                        AppTextInput {
                            imageSource: "../Images/lock-32.svg"
                            text: QtNetworking.password
                            placeholderText: qsTr("IWA Password")
                            echoMode: button1.pressed
                                      ? TextInput.Normal
                                      : TextInput.Password
                            button1.source: button1.pressed
                                            ? "../Images/view-visible-32.svg"
                                            : "../Images/view-mixed-32.svg"

                            onTextChanged: QtNetworking.password = text
                            onAccepted: nextItemInFocusChain().forceActiveFocus()
                        }

                        AppTextInput {
                            imageSource: "../Images/organization-32.svg"
                            text: QtNetworking.realm
                            placeholderText: qsTr("IWA Realm")

                            onTextChanged: QtNetworking.realm = text
                            onAccepted: iwaSignIn()
                        }

                        AppSeparator {
                        }

                        AppButton {
                            Layout.alignment: Qt.AlignHCenter

                            text: qsTr("Sign In")
                            icon.source: "../Images/sign-in-32.svg"
                            enabled: !userInfoRequest.busy

                            onClicked: iwaSignIn()
                        }

                        AppSeparator {
                            visible: internal.errorString
                        }

                        AppText {
                            text: internal.errorString
                            visible: internal.errorString
                            horizontalAlignment: Qt.AlignHCenter
                            color: "red"
                        }

                        AppSeparator {
                        }

                    }
                }

                AppSeparator {
                }
            }
        }
    }

    QtObject {
        id: internal

        property string errorString: ""
    }

    FileDialog {
        id: pkiFileDialog

        onAccepted: {
            pkiFileInfo.url = fileUrl;
            if (!pkiFileInfo.exists) {
                return;
            }

            pkiFileName = pkiFileInfo.fileName;

            pkiFile.url = fileUrl;
            pkiBinaryData.data = pkiFile.readAll();
        }
    }

    QtFile {
        id: pkiFile
    }

    QtFileInfo {
        id: pkiFileInfo
    }

    QtBinaryData {
        id: pkiBinaryData
    }

    Connections {
        target: userInfoRequest

        onFailed: {
            internal.errorString = userInfoRequest.errorString;
        }

        onSuccess: {
            page.accepted();
        }
    }

    Menu {
        id: menu

        MenuItem {
            text: qsTr("Select Portal ...")
            font.pointSize: styles.textPointSize

            onClicked: selectPortal()
        }
    }

    function refresh() {
        if (currentPortal) {
            if (currentPortal.type === "OAuth") {
                oauthSignInView.refresh();
            }
        }
    }

    function menuClicked() {
        menu.popup();
    }

    function selectPortal() {
        stackView.push(selectPortalComponent);
    }

    function clearError() {
        internal.errorString = "";
    }

    function pkiSignIn() {
        clearError();

        QtNetworking.pkcs12 = QtNetworking.importPkcs12(pkiBinaryData.data, pkiPassword);
        if (!QtNetworking.pkcs12) {
            internal.errorString = qsTr("Invalid PKI File or Password");
            return;
        }

        userInfoRequest.send();
    }

    function iwaSignIn() {
        clearError();

        QtNetworking.clearAccessCache();

        userInfoRequest.send();
    }
}
