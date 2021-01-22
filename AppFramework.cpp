#include "AppFramework.h"
#include "FileFolder.h"
#include <QQmlEngine>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

AppFramework::AppFramework(QObject * parent) :
    QObject(parent)
{
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

FileFolder* AppFramework::userHomeFolder() const
{
    FileFolder* fileFolder = new FileFolder(userHomePath());
    QQmlEngine::setObjectOwnership(fileFolder, QQmlEngine::JavaScriptOwnership);
    return fileFolder;
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
