//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include "Networking.h"
#include <QDebug>
#include <QQmlEngine>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QAuthenticator>
#include <QFile>
#include <QBuffer>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

Networking* Networking::g_Networking = nullptr;

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QString kPropertyPKCS12PrivateKey = QStringLiteral( "privateKey" );
QString kPropertyPKCS12Certificate = QStringLiteral( "certificate" );
QString kPropertyPKCS12CaCertificates = QStringLiteral( "caCertificates" );

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

Networking::Networking(QObject* parent) :
    QObject(parent)
{
    g_Networking = this;
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Networking::clearAccessCache()
{
    QNetworkAccessManager* _networkAccessManager = networkAccessManager();
    if (!_networkAccessManager)
    {
        qDebug() << Q_FUNC_INFO << "QNetworkAccessManager unexpectantly null";
        return;
    }

    _networkAccessManager->clearAccessCache();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Networking::classBegin()
{
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Networking::componentComplete()
{
    QNetworkAccessManager* _networkAccessManager = networkAccessManager();
    if (!_networkAccessManager)
    {
        qDebug() << Q_FUNC_INFO << "QNetworkAccessManager unexpectantly null";
        return;
    }

    connect(_networkAccessManager, &QNetworkAccessManager::authenticationRequired, this, &Networking::onAuthenticationRequired);

}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QNetworkAccessManager* Networking::networkAccessManager() const
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

void Networking::onAuthenticationRequired(QNetworkReply *reply, QAuthenticator *authenticator)
{
    if (m_User.isEmpty())
    {
        return;
    }

    emit authenticationRequired(reply ? reply->url() : QUrl());

    authenticator->setUser(m_User);
    authenticator->setPassword(m_Password);
    authenticator->setRealm(m_Realm);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariant Networking::importPkcs12(const QVariant& pkcs12Data, const QString& passPhrase) const
{
    switch (pkcs12Data.type())
    {
    case QVariant::String:
        return importPkcs12(pkcs12Data, passPhrase);

    case QVariant::Url:
        return importPkcs12( pkcs12Data.toUrl(), passPhrase );

    case QVariant::ByteArray:
        return importPkcs12( pkcs12Data.toByteArray(), passPhrase );

    default:
        break;
    }

    qDebug() << Q_FUNC_INFO << "Unexpected Parameter. (pkcs12.type: " << pkcs12Data.type() << ")";

    return QVariant();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariant Networking::importPkcs12(const QString& pkcs12FilePath, const QString& passPhrase) const
{
    QFile file(pkcs12FilePath);
    bool ok = file.open(QIODevice::ReadOnly);
    if (!ok)
    {
        qDebug() << Q_FUNC_INFO << "Cannot open pkcs12 file: " << pkcs12FilePath;
        qDebug() << Q_FUNC_INFO << "File.Error: Error " << file.error() << " - " << file.errorString();
        return QVariant();
    }

    QVariant result = importPkcs12(&file, passPhrase);
    file.close();

    qDebug() << "Result: " << result;

    return result;
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariant Networking::importPkcs12( const QUrl& pkcs12FileUrl, const QString& passPhrase ) const
{
    if ( pkcs12FileUrl.isLocalFile() )
    {
        return importPkcs12( pkcs12FileUrl.toLocalFile(), passPhrase );
    }

    if ( pkcs12FileUrl.scheme() == "qrc" )
    {
        return importPkcs12( ":" + pkcs12FileUrl.path(), passPhrase );
    }

    qDebug() << Q_FUNC_INFO << "Unsupported url: " << pkcs12FileUrl;

    return QVariant();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariant Networking::importPkcs12(const QByteArray& pkcs12FileData, const QString& passPhrase) const
{

    QBuffer buffer;
    buffer.open(QIODevice::ReadWrite);
    buffer.write(pkcs12FileData);
    buffer.reset();
    return importPkcs12(dynamic_cast<QIODevice*>(&buffer), passPhrase);
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariant Networking::importPkcs12(QIODevice* pkcs12Device, const QString& passPhrase) const
{
    QSslKey privateKey;
    QSslCertificate certificate;
    QList<QSslCertificate> caCertificates;
    bool ok = QSslCertificate::importPkcs12(pkcs12Device, &privateKey, &certificate, &caCertificates, passPhrase.toUtf8());
    if (!ok)
    {
        return QVariant();
    }

    QStringList _caCertificates;
    foreach ( QSslCertificate caCertificate, caCertificates )
    {
        if ( caCertificate.isNull() )
        {
            continue;
        }
        _caCertificates.append( QString::fromUtf8( caCertificate.toPem() ) );
    }

    QVariantMap _pkcs12;
    _pkcs12[ kPropertyPKCS12PrivateKey ] = QString::fromUtf8( privateKey.toPem() );
    _pkcs12[ kPropertyPKCS12Certificate ] = QString::fromUtf8( certificate.toPem() );
    _pkcs12[ kPropertyPKCS12CaCertificates ] = _caCertificates;
    return _pkcs12;
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

QVariant Networking::pkcs12() const
{
    QSslConfiguration cfg = QSslConfiguration::defaultConfiguration();
    QSslKey privateKey = cfg.privateKey();
    QSslCertificate certificate = cfg.localCertificate();

    if ( privateKey.isNull() || certificate.isNull() )
    {
        return QVariant();
    }

    QStringList _caCertificates;
    foreach ( QSslCertificate caCertificate, m_CACertificates )
    {
        if ( caCertificate.isNull() )
        {
            continue;
        }
        _caCertificates.append( QString::fromUtf8( caCertificate.toPem() ) );
    }

    QVariantMap _pkcs12;
    _pkcs12[ kPropertyPKCS12PrivateKey ] = QString::fromUtf8( privateKey.toPem() );
    _pkcs12[ kPropertyPKCS12Certificate ] = QString::fromUtf8( certificate.toPem() );
    _pkcs12[ kPropertyPKCS12CaCertificates ] = _caCertificates;
    return _pkcs12;
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Networking::setPkcs12(const QVariant& pkcs12)
{
    if ( pkcs12.isNull() || !pkcs12.isValid() )
    {
        clearPkcs12();
        return;
    }

    QVariantMap _pkcs12 = pkcs12.toMap();
    if ( _pkcs12.isEmpty() )
    {
        return;
    }

    QString _privateKey = _pkcs12[ kPropertyPKCS12PrivateKey ].toString();
    QString _certificate = _pkcs12[ kPropertyPKCS12Certificate ].toString();
    QStringList _caCertificates = _pkcs12[ kPropertyPKCS12CaCertificates ].toStringList();
    setPkcs12( _privateKey, _certificate, _caCertificates );
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Networking::setPkcs12( const QString& privateKey, const QString& certificate, const QStringList& caCertificates )
{
    QSslKey _privateKey( privateKey.toUtf8(), QSsl::Rsa );
    QSslCertificate _certificate( certificate.toUtf8() );

    QList<QSslCertificate> _caCertificates;
    foreach ( QString caCertificate, caCertificates )
    {
        QSslCertificate _caCertificate( caCertificate.toUtf8() );
        if ( _caCertificate.isNull() )
        {
            continue;
        }
        _caCertificates.append( _caCertificate );
    }

    setPkcs12( _privateKey, _certificate, _caCertificates );
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Networking::setPkcs12( const QSslKey& privateKey, const QSslCertificate& certificate, const QList<QSslCertificate>& caCertificates )
{
    QSslConfiguration cfg = QSslConfiguration::defaultConfiguration();

    bool changes = false;
    if ( privateKey != cfg.privateKey() )
    {
        changes = true;
    }
    if ( certificate != cfg.localCertificate() )
    {
        changes = true;
    }
    if ( caCertificates != m_CACertificates )
    {
        changes = true;
    }
    if ( !changes )
    {
        return;
    }

    m_CACertificates = caCertificates;
    QList<QSslCertificate> _caCertificates = QSslConfiguration::systemCaCertificates();
    _caCertificates.append( m_CACertificates );

    cfg.setCaCertificates( _caCertificates );
    cfg.setPrivateKey( privateKey );
    cfg.setLocalCertificate( certificate );

    QSslConfiguration::setDefaultConfiguration( cfg );

    emit pkcs12Changed();
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

void Networking::clearPkcs12()
{
    setPkcs12( QSslKey(), QSslCertificate(), QList<QSslCertificate>() );
}

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
