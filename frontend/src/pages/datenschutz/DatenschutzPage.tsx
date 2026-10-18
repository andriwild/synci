import { FC } from "react";
import { Flex, Typography } from "antd";

const { Title, Paragraph, Link, Text } = Typography;

export const DatenschutzPage: FC = () => {

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
                <Title level={1}>Datenschutzerklärung</Title>

                <Paragraph>
                    Diese Erklärung gilt für die Website synci.ch und die Synci-App für iOS und Android. Synci ist
                    kostenlos, zeigt keine Werbung und verkauft keine Daten.
                </Paragraph>

                <section>
                    <Title level={4} style={{ marginTop: 0 }}>Verantwortlich</Title>
                    <Paragraph>
                        Synci, Andri Wild<br />
                        Im Baumgarten 4<br />
                        6252 Dagmersellen<br />
                        Schweiz<br />
                        E-Mail: <Link href="mailto:mailtosynci@gmail.com">mailtosynci@gmail.com</Link>
                    </Paragraph>
                    <Paragraph>
                        Ansprechperson für Datenschutz ist Elias Haas, erreichbar über dieselbe E-Mail-Adresse.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Welche Daten wir bearbeiten</Title>
                    <ul>
                        <li>
                            <Text strong>Ohne Konto:</Text> Sportarten, Ligen und Teams kannst du ohne Konto ansehen.
                            Dabei speichern wir keine Angaben zu deiner Person.
                        </li>
                        <li>
                            <Text strong>Konto:</Text> Wenn du dich anmeldest, speichern wir deine E-Mail-Adresse,
                            deinen Namen und eine Benutzer-ID. Die Anmeldung läuft über E-Mail und Passwort, Google
                            oder Apple.
                        </li>
                        <li>
                            <Text strong>Abos:</Text> die Sportarten, Teams und Events in deinen Abos und deren Namen.
                        </li>
                        <li>
                            <Text strong>Kalender-Abo:</Text> Jedes Abo hat eine eigene Kalender-Adresse. Wer diese
                            Adresse kennt, kann die Termine des Abos abrufen, aber keine Angaben zu deiner Person.
                            Deine Kalender-App (z. B. von Apple, Google oder Microsoft) ruft die Adresse regelmässig
                            ab; dafür gelten die Datenschutzbestimmungen dieses Anbieters.
                        </li>
                        <li>
                            <Text strong>Nutzungsstatistik:</Text> Wir zählen anonym, welche Seiten und Funktionen
                            genutzt werden, mit dem selbst betriebenen Dienst Umami. Erfasst werden zum Beispiel die
                            aufgerufene Seite, Aktionen wie „Sportart ausgewählt“, Browser oder Gerätetyp, Sprache
                            und Bildschirmgrösse. Umami setzt keine Cookies und speichert weder IP-Adressen noch
                            Angaben, die auf dich schliessen lassen.
                        </li>
                        <li>
                            <Text strong>Technische Daten:</Text> Beim Aufruf verarbeitet unser Server deine
                            IP-Adresse und den Zeitpunkt, um die Anfrage zu beantworten und den Betrieb zu sichern.
                        </li>
                        <li>
                            <Text strong>Auf deinem Gerät:</Text> Die Anmeldedaten liegen im Browser bzw. im
                            geschützten Speicher deines Geräts, dazu das zuletzt gewählte Abo.
                        </li>
                    </ul>
                </section>

                <section>
                    <Title level={4}>Wozu</Title>
                    <Paragraph>
                        Wir bearbeiten diese Daten nur, um Synci bereitzustellen: für die Anmeldung, zum Speichern
                        deiner Abos, für die Kalender-Abos und, mit der anonymen Statistik, um Synci zu verbessern.
                        Wir verfolgen dich nicht über andere Apps oder Websites.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Dienstleister</Title>
                    <Paragraph>
                        Für die Anmeldung nutzen wir <Link href="https://auth0.com/privacy" target="_blank">Auth0</Link>{' '}
                        (Okta Inc., USA). Auth0 speichert deine E-Mail-Adresse, deinen Namen und die Anmeldedaten
                        in den USA. Meldest du dich mit Google oder Apple an, erhält Auth0 diese Angaben von dort;
                        dafür gelten zusätzlich die Bestimmungen von Google bzw. Apple.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Aufbewahrung und Löschung</Title>
                    <Paragraph>
                        Wir bewahren deine Daten auf, solange dein Konto besteht. Du kannst es jederzeit selbst
                        löschen: in der App unter „Konto“, auf der Website in deinem Profil, jeweils mit „Konto
                        löschen“. Dabei werden dein Konto bei Auth0 und alle deine Abos sofort gelöscht; die
                        Kalender-Adressen funktionieren danach nicht mehr. Du kannst die Löschung auch per E-Mail
                        verlangen. Die anonyme Statistik bleibt erhalten, da sie keinen Bezug zu dir hat.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Deine Rechte</Title>
                    <Paragraph>
                        Nach dem Schweizer Datenschutzgesetz kannst du Auskunft über deine Daten verlangen und sie
                        berichtigen, löschen oder herausgeben lassen. Schreib uns dazu an{' '}
                        <Link href="mailto:mailtosynci@gmail.com">mailtosynci@gmail.com</Link>. Du kannst dich auch
                        beim <Link href="https://www.edoeb.admin.ch" target="_blank">Eidgenössischen
                        Datenschutz- und Öffentlichkeitsbeauftragten</Link> beschweren.
                    </Paragraph>
                </section>

                <section>
                    <Title level={4}>Änderungen</Title>
                    <Paragraph>
                        Wir passen diese Erklärung an, wenn sich Synci ändert. Es gilt die hier veröffentlichte
                        Fassung.
                    </Paragraph>
                    <Text type="secondary">Stand: 18. Oktober 2026</Text>
                </section>
            </Flex>
        </Flex>
    );
};
