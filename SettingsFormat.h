#ifndef __SettingsFormat__
#define __SettingsFormat__

#include <QSettings>
#include "EnumInfo.h"

class SettingsFormatEnum : public EnumInfo
{
    Q_OBJECT

public:
    SettingsFormatEnum(QObject* parent = nullptr) :
        EnumInfo(parent, QMetaEnum::fromType<SettingsFormat>()) { }

    enum SettingsFormat
    {
        NativeFormat = QSettings::NativeFormat,
        IniFormat = QSettings::IniFormat,
#if defined(Q_OS_WIN) || defined(Q_CLANG_QDOC)
        Registry32Format = QSettings::Registry32Format,
        Registry64Format = QSettings::Registry64Format,
#else
        Registry32Format,
        Registry64Format,
#endif
        InvalidFormat = QSettings::InvalidFormat
    };

    Q_ENUM(SettingsFormat)

};

#endif
