#ifndef __EnumInfo__
#define __EnumInfo__

#include <QObject>
#include <QMetaEnum>

class EnumInfo : public QObject
{
    Q_OBJECT

public:
    EnumInfo( QObject* parent = nullptr, QMetaEnum metaEnum = QMetaEnum() ) :
        QObject( parent ),
        m_metaEnum( metaEnum )
    {
    }

    Q_INVOKABLE QString stringify( int value ) const
    {
        return m_metaEnum.valueToKey( static_cast< int >( value ) );
    }

    Q_INVOKABLE int parse( const QString& key ) const
    {
        return m_metaEnum.keyToValue( key.toUtf8() );
    }

    Q_INVOKABLE QVariant strings() const
    {
        QVariantList list;
        for ( int i = 0; i <  m_metaEnum.keyCount(); i ++ )
        {
            list.append( QString::fromUtf8( m_metaEnum.key( i ) ) );
        }
        return list;
    }

    Q_INVOKABLE QVariant values() const
    {
        QVariantList list;
        for ( int i = 0; i <  m_metaEnum.keyCount(); i ++ )
        {
            list.append( QVariant( m_metaEnum.value( i ) ) );
        }
        return list;
    }

protected:
    QMetaEnum m_metaEnum;

};

#endif
