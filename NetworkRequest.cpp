//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include "NetworkRequest.h"
#include <QQmlEngine>
#include <QUrlQuery>
#include <QNetworkRequest>
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QDebug>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

NetworkRequest::NetworkRequest(QObject* parent) :
    QObject(parent),
    m_Method(QStringLiteral("GET")),
    m_NetworkReply(nullptr),
    m_MultiPart(nullptr),
    m_ReadyState(ReadyStateEnum::UNSENT)
{
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

NetworkRequest::~NetworkRequest()
{
    if (m_MultiPart)
    {
        m_MultiPart->deleteLater();
        m_MultiPart = nullptr;
    }

    if (m_NetworkReply)
    {
        disconnectSignals();
        m_NetworkReply->deleteLater();
        m_NetworkReply = nullptr;
    }
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void NetworkRequest::send(const QVariant& body)
{
    setResponseBody(QByteArray());
    setProperty("responseHeaders", QVariant());
    setProperty("readyState", ReadyStateEnum::OPENED);
    setProperty("error", NetworkErrorEnum::NoError);
    setErrorText(QString());

    if (m_Method.compare("POST", Qt::CaseInsensitive) == 0)
    {
        post(body.toMap());
        return;
    }

    get(body);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QNetworkAccessManager* NetworkRequest::networkAccessManager() const
{
    QQmlEngine* engine = qmlEngine(this);
    if (!engine)
    {
        return nullptr;
    }

    return engine->networkAccessManager();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void NetworkRequest::get(const QVariant& body)
{
    get(body.toMap());
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void NetworkRequest::get(const QVariantMap& values)
{
    QNetworkAccessManager* _networkAccessManager = networkAccessManager();
    if (!_networkAccessManager)
    {
        qDebug() << Q_FUNC_INFO << __LINE__;
        return;
    }

    QUrl _url(m_Url);
    QUrlQuery urlQuery;
    foreach (QString key, values.keys())
    {
        urlQuery.addQueryItem(key, values[key].toString());
    }
    _url.setQuery(urlQuery.query());

    QNetworkRequest req(_url);
    m_NetworkReply = _networkAccessManager->get(req);

    connectSignals();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------:0

void NetworkRequest::post(const QVariantMap& values)
{
    QNetworkAccessManager* _networkAccessManager = networkAccessManager();
    if (!_networkAccessManager)
    {
        qDebug() << Q_FUNC_INFO << __LINE__;
        return;
    }

    m_MultiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    foreach (QString key, values.keys())
    {
        QHttpPart textPart;
        textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"" + key + "\""));
        textPart.setBody(values[key].toString().toUtf8());
        m_MultiPart->append(textPart);
    }

    QNetworkRequest req(m_Url);
    m_NetworkReply = _networkAccessManager->post(req, m_MultiPart);
    m_MultiPart->setParent(m_NetworkReply);

    connectSignals();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void NetworkRequest::onFinished()
{
    if (!m_NetworkReply)
    {
        return;
    }

    QByteArray responseBody = m_NetworkReply->readAll();
    setResponseBody(responseBody);
    setProperty("error", m_NetworkReply->error());
    setErrorText(m_NetworkReply->errorString());
    setProperty("responseHeaders", convertHeaders(m_NetworkReply->rawHeaderPairs()));

    disconnectSignals();

    if (m_MultiPart)
    {
        m_MultiPart->deleteLater();
        m_MultiPart = nullptr;
    }

    m_NetworkReply->deleteLater();
    m_NetworkReply = nullptr;

    setProperty("readyState", ReadyStateEnum::DONE);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariant NetworkRequest::response() const
{
    if (m_ResponseType.compare("base64", Qt::CaseInsensitive) == 0)
    {
        return QString::fromLatin1(m_ResponseBody.toBase64());
    }

    if (m_ResponseType.compare("binary", Qt::CaseInsensitive) == 0)
    {
        return m_ResponseBody;
    }

    return responseText();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QString NetworkRequest::responseText() const
{
    return QString::fromUtf8(m_ResponseBody);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void NetworkRequest::setResponseBody(const QByteArray& responseBody)
{
    if (m_ResponseBody == responseBody)
    {
        return;
    }

    m_ResponseBody = responseBody;

    emit responseChanged();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void NetworkRequest::connectSignals()
{
    connect(m_NetworkReply, &QNetworkReply::finished, this, &NetworkRequest::onFinished);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void NetworkRequest::disconnectSignals()
{
    disconnect(m_NetworkReply, &QNetworkReply::finished, this, &NetworkRequest::onFinished);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariantMap NetworkRequest::convertHeaders(const QList<QNetworkReply::RawHeaderPair>& rawHeaderPairs)
{
    QVariantMap headers;
    foreach (const QNetworkReply::RawHeaderPair& rawHeaderPair, rawHeaderPairs)
    {
        QString key = QString::fromUtf8(rawHeaderPair.first);
        QString value = QString::fromUtf8(rawHeaderPair.second);
        headers[key] = value;
    }
    return headers;
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void NetworkRequest::setErrorText(const QString& errorText)
{
    if (m_ErrorText == errorText)
    {
        return;
    }

    m_ErrorText = errorText;

    emit errorTextChanged();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
