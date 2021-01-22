//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#ifndef __File__
#define __File__

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include <QObject>
#include <QFile>
#include <QUrl>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class File : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY fileChanged)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY fileChanged)
    Q_PROPERTY(bool exists READ exists NOTIFY fileChanged)
    Q_PROPERTY(qint64 size READ size NOTIFY fileChanged)

public:
    File(QObject* parent = nullptr);

    Q_INVOKABLE bool reset() const;
    Q_INVOKABLE QByteArray readAll() const;

signals:
    void fileChanged();

protected:
    QFile* m_File;
    QUrl m_Url;
    QString m_FilePath;
    QFile::OpenMode m_OpenMode;

    QUrl url() const { return m_Url; }
    void setUrl(const QUrl& url);
    QString filePath() const { return m_FilePath; }
    void setFilePath(const QString& filePath);
    bool exists() const { return m_File ? m_File->exists() : false; }
    qint64 size() const { return m_File ? m_File->size() : 0; }

    void _close();
    bool _open();

};

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#endif
