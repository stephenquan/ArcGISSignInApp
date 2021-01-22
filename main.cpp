#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QJSEngine>
#include "AppFramework.h"
#include "NetworkRequest.h"
#include "Settings.h"
#include "EnumInfo.h"
#include "ReadyState.h"
#include "Networking.h"
#include "File.h"
#include "FileInfo.h"
#include "FileFolder.h"
#include "BinaryData.h"
#include "SettingsFormat.h"

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

template <typename T>
QObject* singletonProvider(QQmlEngine*, QJSEngine*)
{
    return new T();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("ESRI");
    QCoreApplication::setOrganizationDomain("esri.com");
    QCoreApplication::setApplicationName("WebMap App");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<NetworkRequest>("Esri.Runtime.Testing", 1, 0, "QtNetworkRequest");
    qmlRegisterSingletonType<AppFramework>("Esri.Runtime.Testing", 1, 0, "QtAppFramework", singletonProvider<AppFramework>);
    qmlRegisterSingletonType<Settings>("Esri.Runtime.Testing", 1, 0, "QtSettings", singletonProvider<Settings>);
    qmlRegisterUncreatableType<EnumInfo>("Esri.Runtime.Testing", 1, 0, "QtEnumInfo", QStringLiteral("Cannot create QtEnumInfo"));
    qmlRegisterSingletonType<ReadyStateEnum>("Esri.Runtime.Testing", 1, 0, "QtReadyState", singletonProvider<ReadyStateEnum>);
    qmlRegisterSingletonType<SettingsFormatEnum>("Esri.Runtime.Testing", 1, 0, "QtSettingsFormat", singletonProvider<SettingsFormatEnum>);
    qmlRegisterSingletonType<NetworkErrorEnum>("Esri.Runtime.Testing", 1, 0, "QtNetworkError", singletonProvider<NetworkErrorEnum>);
    qmlRegisterSingletonType<Networking>("Esri.Runtime.Testing", 1, 0, "QtNetworking", singletonProvider<Networking>);
    qmlRegisterType<File>("Esri.Runtime.Testing", 1, 0, "QtFile");
    qmlRegisterType<FileInfo>("Esri.Runtime.Testing", 1, 0, "QtFileInfo");
    qmlRegisterType<FileFolder>("Esri.Runtime.Testing", 1, 0, "QtFileFolder");
    qmlRegisterType<BinaryData>("Esri.Runtime.Testing", 1, 0, "QtBinaryData");

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
