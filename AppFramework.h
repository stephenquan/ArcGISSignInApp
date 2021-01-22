//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#ifndef __AppFramework__
#define __AppFramework__

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include <QObject>
#include <QDir>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class FileFolder;

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class AppFramework : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString qtVersion READ qtVersion CONSTANT)
    Q_PROPERTY(QString userHomePath READ userHomePath CONSTANT)
    Q_PROPERTY(FileFolder* userHomeFolder READ userHomeFolder CONSTANT)

public:
    AppFramework(QObject * parent = nullptr);

protected:
    QString qtVersion() const { return qVersion(); }
    QString userHomePath() const { return QDir::homePath(); }
    FileFolder* userHomeFolder() const;

};

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#endif
