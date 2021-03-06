//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include "Settings.h"

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

Settings::Settings(QObject* parent) :
    QObject(parent),
    m_Format(SettingsFormatEnum::NativeFormat),
    m_Settings(nullptr)
{
    open();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

Settings::~Settings()
{
    close();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariant Settings::value(const QString& key) const
{
    return m_Settings->value(key);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Settings::setValue(const QString& key, const QVariant& value)
{
    m_Settings->setValue(key, value);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Settings::remove(const QString& key)
{
    m_Settings->remove(key);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Settings::close()
{
    if (!m_Settings)
    {
        return;
    }

    delete m_Settings;
    m_Settings = nullptr;
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Settings::open()
{
    if (m_Settings)
    {
        return;
    }

    if (m_Path.isEmpty() || m_Path.isNull())
    {
        m_Settings = new QSettings(QSettings::UserScope);
        return;
    }

    m_Settings = new QSettings(m_Path, static_cast<QSettings::Format>(m_Format));
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Settings::setPath(const QString& path)
{
    if (m_Path == path)
    {
        return;
    }

    close();
    m_Path = path;
    open();

    emit pathChanged();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Settings::setFormat(SettingsFormatEnum::SettingsFormat format)
{
    if (m_Format == format)
    {
        return;
    }

    close();
    m_Format = format;
    open();

    emit formatChanged();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
