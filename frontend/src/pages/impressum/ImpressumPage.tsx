import { FC } from "react";
import { Flex, Typography } from "antd";

const { Title, Paragraph, Link, Text } = Typography;

export const ImpressumPage: FC = () => {

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
                <Title level={1}>Impressum & Datenschutz</Title>

                <section>
                    <Title level={4} style={{ marginTop: 0 }}>Kontaktadresse</Title>
                    <Paragraph>
                        Synci<br />
                        Im Baumgarten 4<br />
                        6252 Dagmersellen<br />
                        Schweiz
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Kontakt</Title>
                    <Paragraph>
                        E-Mail: <Link href="mailto:mailtosynci@gmail.ch">mailtosynci@gmail.ch</Link>
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Vertretungsberechtigte Person(en)</Title>
                    <Paragraph>
                        Andri Wild
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Datenschutz Beauftragte(r)</Title>
                    <Paragraph>
                        Elias Haas
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Handelsregister & Mehrwertsteuer</Title>
                    <Paragraph>
                        <Text strong>Handelsregister:</Text> Nicht eingetragen.<br />
                        <Text strong>Mehrwertsteuer:</Text> Nicht mehrwertsteuerpflichtig.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Haftungsausschluss</Title>
                    <Paragraph>
                        Der Autor übernimmt keinerlei Gewähr hinsichtlich der inhaltlichen Richtigkeit, Genauigkeit, Aktualität, Zuverlässigkeit und Vollständigkeit der Informationen. Haftungsansprüche gegen den Autor wegen Schäden materieller oder immaterieller Art, welche aus dem Zugriff oder der Nutzung bzw. Nichtnutzung der veröffentlichten Informationen, durch Missbrauch der Verbindung oder durch technische Störungen entstanden sind, werden ausgeschlossen.
                    </Paragraph>
                    <Paragraph>
                        Alle Angebote sind unverbindlich. Der Autor behält es sich ausdrücklich vor, Teile der Seiten oder das gesamte Angebot ohne gesonderte Ankündigung zu verändern, zu ergänzen, zu löschen oder die Veröffentlichung zeitweise oder endgültig einzustellen.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Haftung für Links</Title>
                    <Paragraph>
                        Verweise und Links auf Webseiten Dritter liegen ausserhalb unseres Verantwortungsbereichs. Es wird jegliche Verantwortung für solche Webseiten abgelehnt. Der Zugriff und die Nutzung solcher Webseiten erfolgen auf eigene Gefahr des Nutzers oder der Nutzerin.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Urheberrechte</Title>
                    <Paragraph>
                        Die Urheber- und alle anderen Rechte an Inhalten, Bildern, Fotos oder anderen Dateien auf der Website gehören ausschliesslich <strong>Synci</strong> oder den speziell genannten Rechtsinhabern. Für die Reproduktion jeglicher Elemente ist die schriftliche Zustimmung der Urheberrechtsträger im Voraus einzuholen.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Datenschutz</Title>
                    <Paragraph>
                        Wir speichern keine Daten, besonders keine personenbezogenen Daten, nur jene, die in der Applikation für den Betrieb erfasst werden.
                    </Paragraph>
                    <Paragraph>
                        Wir verwenden <Link href='https://support.auth0.com/center/s/sitemap' target="_blank">Auth0</Link> für den Login-Prozess. Wir treten alle Haftungen an diesen Anbieter ab.
                    </Paragraph>
                </section>

                <div style={{ marginTop: 24, borderTop: '1px solid #f0f0f0', paddingTop: 12 }}>
                    <Text type="secondary">© {new Date().getFullYear()} Synci</Text>
                </div>
            </Flex>
        </Flex>
    );
};
