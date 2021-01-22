//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include "File.h"

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

File::File(QObject* parent) :
    QObject(parent),
    m_File(nullptr),
    m_OpenMode(QFile::ReadOnly)
{
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void File::setUrl(const QUrl& url)
{
    if (m_Url == url)
    {
        return;
    }

    _close();

    if (!url.isValid() || url.isEmpty())
    {
        emit fileChanged();
        return;
    }

    m_Url = url;
    m_FilePath = m_Url.toLocalFile();

    _open();

    emit fileChanged();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void File::setFilePath(const QString& filePath)
{
    if (m_FilePath == filePath)
    {
        return;
    }

    _close();

    if (filePath.isEmpty() || filePath.isNull())
    {
        emit fileChanged();
        return;
    }

    setUrl(QUrl::fromLocalFile(filePath));
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

bool File::reset() const
{
    if (!m_File)
    {
        return true;
    }

    return m_File->reset();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void File::_close()
{
    if (m_File)
    {
        m_File->close();
        delete m_File;
        m_File = nullptr;
    }

    m_Url = QUrl();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

bool File::_open()
{
    if (m_File)
    {
        _close();
    }

    m_File = new QFile(m_FilePath);
    return m_File->open(m_OpenMode);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QByteArray File::readAll() const
{
    if (!m_File)
    {
        return QByteArray();
    }

    return m_File->readAll();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
