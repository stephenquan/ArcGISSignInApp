//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#ifndef __NetworkRequest__
#define __NetworkRequest__

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include <QObject>
#include <QUrl>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include "ReadyState.h"
#include "NetworkError.h"

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class NetworkRequest : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url MEMBER m_Url NOTIFY urlChanged)
    Q_PROPERTY(QString method MEMBER m_Method NOTIFY methodChanged)
    Q_PROPERTY(QString responseType MEMBER m_ResponseType NOTIFY responseTypeChanged)
    Q_PROPERTY(QVariant responseHeaders MEMBER m_ResponseHeaders NOTIFY responseHeadersChanged)
    Q_PROPERTY(QVariant response READ response NOTIFY responseChanged)
    Q_PROPERTY(QString responseText READ responseText NOTIFY responseChanged)
    Q_PROPERTY(ReadyStateEnum::ReadyState readyState MEMBER m_ReadyState NOTIFY readyStateChanged)
    Q_PROPERTY(NetworkErrorEnum::NetworkError error MEMBER m_NetworkError NOTIFY errorChanged)
    Q_PROPERTY(QString errorText READ errorText NOTIFY errorTextChanged)

public:
    NetworkRequest(QObject* parent = nullptr);
    ~NetworkRequest();

    Q_INVOKABLE void send(const QVariant& body = QVariant());

signals:
    void urlChanged();
    void methodChanged();
    void responseHeadersChanged();
    void responseChanged();
    void responseTypeChanged();
    void readyStateChanged();
    void errorChanged();
    void errorTextChanged();

protected:
    QUrl m_Url;
    QString m_Method;
    QString m_ResponseType;
    QNetworkReply* m_NetworkReply;
    QHttpMultiPart* m_MultiPart;
    QVariant m_ResponseHeaders;
    QByteArray m_ResponseBody;
    ReadyStateEnum::ReadyState m_ReadyState;
    NetworkErrorEnum::NetworkError m_NetworkError;
    QString m_ErrorText;

    QNetworkAccessManager* networkAccessManager() const;
    void get(const QVariant& body);
    void get(const QVariantMap& values);
    void post(const QVariantMap& values);

    QVariant response() const;
    QString responseText() const;
    QByteArray responseBody() const { return m_ResponseBody; }
    void setResponseBody(const QByteArray& response);

    static QVariantMap convertHeaders(const QList<QNetworkReply::RawHeaderPair>& rawHeaderPairs);

    QString errorText() const { return m_ErrorText; }
    void setErrorText(const QString& errorText);

    void connectSignals();
    void disconnectSignals();

protected slots:
    void onFinished();

};

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#endif
