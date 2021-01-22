//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#ifndef __Settings__
#define __Settings__

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include <QObject>
#include <SettingsFormat.h>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class Settings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(SettingsFormatEnum::SettingsFormat format READ format WRITE setFormat NOTIFY formatChanged)

public:
    Settings(QObject* parent = nullptr);
    virtual ~Settings();

    Q_INVOKABLE QVariant value(const QString& key) const;
    Q_INVOKABLE void setValue(const QString& key, const QVariant& value);
    Q_INVOKABLE void remove(const QString& key);

signals:
    void pathChanged();
    void formatChanged();

protected:
    SettingsFormatEnum::SettingsFormat m_Format;
    QString m_Path;
    QSettings* m_Settings;

    void close();
    void open();

    QString path() const { return m_Path; }
    void setPath(const QString& path);

    SettingsFormatEnum::SettingsFormat format() const { return m_Format; }
    void setFormat(SettingsFormatEnum::SettingsFormat format);

};

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#endif

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
