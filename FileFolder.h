//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#ifndef __FileFolder__
#define __FileFolder__

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include <QObject>
#include <QDir>
#include <QUrl>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class FileFolder : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY fileFolderChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY fileFolderChanged)
    Q_PROPERTY(bool exists READ exists NOTIFY fileFolderChanged)

public:
    FileFolder(QObject* parent = nullptr);
    FileFolder(const QString& path, QObject* parent = nullptr);

    Q_INVOKABLE QString filePath(const QString& fileName) const { return m_Dir.filePath(fileName); }

signals:
    void fileFolderChanged();

protected:
    QDir m_Dir;
    QUrl m_Url;
    QString m_Path;

    QUrl url() const { return m_Url; }
    void setUrl(const QUrl& url);
    QString path() const { return m_Path; }
    void setPath(const QString& path);
    bool exists() const { return m_Dir.exists(); }

};

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#endif
