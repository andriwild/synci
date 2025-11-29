import { FC } from "react";
import { Flex, Typography, Collapse } from "antd";
import type { CollapseProps } from 'antd';

const { Title, Paragraph } = Typography;

export const FaqPage: FC = () => {

    const faqItems: CollapseProps['items'] = [
        {
            key: '1',
            label: 'Warum verwenden wir Auth0 für den Login?',
            children: (
                <Paragraph>
                    Wir nutzen Auth0, um Ihnen die höchstmögliche Sicherheit beim Anmelden zu bieten. 
                    Auth0 ist ein weltweit führender Anbieter für Authentifizierungslösungen. 
                    Dadurch müssen wir keine Passwörter selbst speichern und können Ihnen 
                    komfortable Funktionen wie den Login via Google oder Apple anbieten.
                </Paragraph>
            ),
        },
        {
            key: '2',
            label: 'Sind meine Anmeldedaten bei Auth0 sicher?',
            children: (
                <Paragraph>
                    Ja. Auth0 erfüllt strengste Sicherheitsstandards (wie SOC 2, HIPAA, GDPR). 
                    Ihre Passwörter werden verschlüsselt auf den Servern von Auth0 gespeichert. 
                    Die Applikation "Synci" hat zu keinem Zeitpunkt Zugriff auf Ihr Passwort.
                </Paragraph>
            ),
        },
        {
            key: '3',
            label: 'Was kann ich tun, wenn der Login nicht funktioniert?',
            children: (
                <Paragraph>
                    Da der Login-Prozess extern über Auth0 läuft, hilft oft Folgendes:
                    <ul>
                        <li>Überprüfen Sie, ob Sie Pop-ups für diese Seite blockiert haben.</li>
                        <li>Löschen Sie Ihren Browser-Cache und Cookies.</li>
                        <li>Nutzen Sie die "Passwort vergessen"-Funktion direkt im Anmeldefenster.</li>
                    </ul>
                </Paragraph>
            ),
        },
    ];

    return (
        <Flex 
            justify="center" 
            style={{ 
                height: '100%', 
                width: '100%', 
                overflowY: 'auto' 
            }}
        >
            <Flex 
                vertical 
                gap="large" 
                style={{ 
                    maxWidth: 800, 
                    width: '100%', 
                    padding: 24, 
                }}
            >
                <Title level={1}>Häufige Fragen (FAQ)</Title>
                
                <Paragraph>
                    Hier finden Sie Antworten auf die wichtigsten Fragen rund um die Anmeldung und Sicherheit.
                </Paragraph>

                <Collapse items={faqItems} defaultActiveKey={['1']} />
            </Flex>
        </Flex>
    );
};
