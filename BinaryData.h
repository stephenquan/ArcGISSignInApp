//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#ifndef __BinaryData__
#define __BinaryData__

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include <QObject>
#include <QByteArray>
#include <QVariant>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class BinaryData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QByteArray data MEMBER m_Data NOTIFY dataChanged)
    Q_PROPERTY(QString base64 READ base64 WRITE setBase64 NOTIFY dataChanged)

public:
    BinaryData(QObject* parent = nullptr);

signals:
    void dataChanged();

protected:
    QByteArray m_Data;

    QString base64() const { return QString::fromUtf8(m_Data.toBase64()); }
    void setBase64(const QString& base64) { setProperty("data", QByteArray::fromBase64(base64.toUtf8())); }

};

#endif
