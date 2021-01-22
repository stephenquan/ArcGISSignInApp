#ifndef __Networking__
#define __Networking__

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#include <QObject>
#include <QQmlParserStatus>
#include <QIODevice>
#include <QList>
#include <QSslKey>
#include <QSslCertificate>
#include <QVariant>

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class QNetworkAccessManager;
class QNetworkReply;
class QAuthenticator;

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

class Networking : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(QString user MEMBER m_User NOTIFY userChanged)
    Q_PROPERTY(QString password MEMBER m_Password NOTIFY passwordChanged)
    Q_PROPERTY(QString realm MEMBER m_Realm NOTIFY realmChanged)
    Q_PROPERTY(QVariant pkcs12 READ pkcs12 WRITE setPkcs12 NOTIFY pkcs12Changed)

public:
    Networking(QObject* parent = nullptr);

    // QNetworkAccessManager
    Q_INVOKABLE void clearAccessCache();

    // PKCS#12
    Q_INVOKABLE QVariant importPkcs12(const QVariant& pkcs12Data, const QString& passPhrase) const;

    // Misc
    static Networking* networking() { return g_Networking; }
    void classBegin() Q_DECL_OVERRIDE;
    void componentComplete() Q_DECL_OVERRIDE;

signals:
    void userChanged();
    void passwordChanged();
    void realmChanged();
    void authenticationRequired(const QUrl& url);
    void pkcs12Changed();

protected:
    QString m_User;
    QString m_Password;
    QString m_Realm;

    static Networking* g_Networking;
    QNetworkAccessManager* networkAccessManager() const;

    QList<QSslCertificate> m_CACertificates;

    QVariant importPkcs12(const QString& pkcs12FilePath, const QString& passPhrase) const;
    QVariant importPkcs12( const QUrl& pkcs12FileUrl, const QString& passPhrase ) const;
    QVariant importPkcs12(const QByteArray& pkcs12FileData, const QString& passPhrase) const;
    QVariant importPkcs12(QIODevice* pkcs12Device, const QString& passPhrase) const;

    QVariant pkcs12() const;
    void setPkcs12(const QVariant& pkcs12);
    void setPkcs12( const QString& privateKey, const QString& certificate, const QStringList& caCertificates );
    void setPkcs12( const QSslKey& privateKey, const QSslCertificate& certificate, const QList<QSslCertificate>& caCertificates );
    void clearPkcs12();

protected slots:
    void onAuthenticationRequired(QNetworkReply *reply, QAuthenticator *authenticator);

};

//----------------------------------------------------------------------
//
//----------------------------------------------------------------------

#endif
