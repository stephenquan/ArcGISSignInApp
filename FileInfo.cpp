//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include "FileInfo.h"

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

FileInfo::FileInfo(QObject* parent) :
    QObject(parent),
    m_FileInfo(nullptr)
{
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void FileInfo::setUrl(const QUrl& url)
{
    if (m_Url == url)
    {
        return;
    }

    if (!url.isValid() || url.isEmpty())
    {
        emit fileInfoChanged();
        return;
    }

    _clear();

    m_Url = url;
    m_FilePath = m_Url.toLocalFile();
    m_FileInfo = new QFileInfo(m_FilePath);

    emit fileInfoChanged();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void FileInfo::setFilePath(const QString& filePath)
{
    if (m_FilePath == filePath)
    {
        return;
    }

    _clear();

    if (filePath.isEmpty() || filePath.isNull())
    {
        emit fileInfoChanged();
        return;
    }

    setUrl(QUrl::fromLocalFile(filePath));
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void FileInfo::_clear()
{
    if (!m_FileInfo)
    {
        return;
    }

    delete m_FileInfo;
    m_FileInfo = nullptr;
    m_FilePath.clear();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
