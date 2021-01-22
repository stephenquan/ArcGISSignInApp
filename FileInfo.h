//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#ifndef __FileInfo__
#define __FileInfo__

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include <QObject>
#include <QFileInfo>
#include <QUrl>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class FileInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY fileInfoChanged)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY fileInfoChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileInfoChanged)
    Q_PROPERTY(bool exists READ exists NOTIFY fileInfoChanged)
    Q_PROPERTY(qint64 size READ size NOTIFY fileInfoChanged)

public:
    FileInfo(QObject* parent = nullptr);

signals:
    void fileInfoChanged();

protected:
    QFileInfo* m_FileInfo;
    QUrl m_Url;
    QString m_FilePath;

    QUrl url() const { return m_Url; }
    void setUrl(const QUrl& url);
    QString fileName() const { return m_FileInfo ? m_FileInfo->fileName() : QString(); }
    QString filePath() const { return m_FilePath; }
    void setFilePath(const QString& filePath);
    bool exists() const { return m_FileInfo ? m_FileInfo->exists() : false; }
    qint64 size() const { return m_FileInfo ? m_FileInfo->size() : 0; }

    void _clear();

};

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#endif
