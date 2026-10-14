import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _items = [
    (
      'Warum verwenden wir Auth0 für den Login?',
      'Wir nutzen Auth0, um Ihnen die höchstmögliche Sicherheit beim Anmelden zu bieten. Auth0 ist ein weltweit '
          'führender Anbieter für Authentifizierungslösungen. Dadurch müssen wir keine Passwörter selbst speichern und '
          'können Ihnen komfortable Funktionen wie den Login via Google oder Apple anbieten.',
    ),
    (
      'Sind meine Anmeldedaten bei Auth0 sicher?',
      'Ja. Auth0 erfüllt strengste Sicherheitsstandards (wie SOC 2, HIPAA, GDPR). Ihre Passwörter werden '
          'verschlüsselt auf den Servern von Auth0 gespeichert. Die Applikation "Synci" hat zu keinem Zeitpunkt Zugriff '
          'auf Ihr Passwort.',
    ),
    (
      'Was kann ich tun, wenn der Login nicht funktioniert?',
      'Da der Login-Prozess extern über Auth0 läuft, hilft oft Folgendes: Prüfen Sie Ihre Internetverbindung, '
          'versuchen Sie es erneut oder nutzen Sie die "Passwort vergessen"-Funktion direkt im Anmeldefenster.',
    ),
    (
      'Wie kann ich mein Konto löschen?',
      'Öffnen Sie in der App den Bereich "Konto" und wählen Sie "Konto löschen". Damit werden Ihr Konto und alle '
          'Ihre Abos endgültig gelöscht; abonnierte Kalender werden danach nicht mehr aktualisiert. Auf synci.ch finden '
          'Sie dieselbe Funktion oben rechts in Ihrem Konto. Falls Sie sich nicht mehr anmelden können, kontaktieren '
          'Sie uns über die Angaben im Impressum, dann löschen wir Ihr Konto für Sie.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Häufige Fragen')),
    body: ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final (index, (question, answer)) in _items.indexed)
          ExpansionTile(
            initiallyExpanded: index == 0,
            title: Text(question),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [Text(answer)],
          ),
      ],
    ),
  );
}

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Impressum & Datenschutz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          section('Kontaktadresse', const [Text('Synci\nIm Baumgarten 4\n6252 Dagmersellen\nSchweiz')]),
          section('Kontakt', [
            InkWell(
              onTap: () => launchUrl(Uri.parse('mailto:mailtosynci@gmail.ch')),
              child: Text(
                'E-Mail: mailtosynci@gmail.ch',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ]),
          section('Vertretungsberechtigte Person(en)', const [Text('Andri Wild')]),
          section('Datenschutz Beauftragte(r)', const [Text('Elias Haas')]),
          section('Handelsregister & Mehrwertsteuer', const [
            Text('Handelsregister: Nicht eingetragen.\nMehrwertsteuer: Nicht mehrwertsteuerpflichtig.'),
          ]),
          section('Haftungsausschluss', const [
            Text(
              'Der Autor übernimmt keinerlei Gewähr hinsichtlich der inhaltlichen Richtigkeit, Genauigkeit, Aktualität, '
              'Zuverlässigkeit und Vollständigkeit der Informationen. Haftungsansprüche gegen den Autor wegen Schäden '
              'materieller oder immaterieller Art, welche aus dem Zugriff oder der Nutzung bzw. Nichtnutzung der '
              'veröffentlichten Informationen, durch Missbrauch der Verbindung oder durch technische Störungen entstanden '
              'sind, werden ausgeschlossen.',
            ),
            SizedBox(height: 8),
            Text(
              'Alle Angebote sind unverbindlich. Der Autor behält es sich ausdrücklich vor, Teile der Seiten oder das '
              'gesamte Angebot ohne gesonderte Ankündigung zu verändern, zu ergänzen, zu löschen oder die '
              'Veröffentlichung zeitweise oder endgültig einzustellen.',
            ),
          ]),
          section('Haftung für Links', const [
            Text(
              'Verweise und Links auf Webseiten Dritter liegen ausserhalb unseres Verantwortungsbereichs. Es wird '
              'jegliche Verantwortung für solche Webseiten abgelehnt. Der Zugriff und die Nutzung solcher Webseiten '
              'erfolgen auf eigene Gefahr des Nutzers oder der Nutzerin.',
            ),
          ]),
          section('Urheberrechte', const [
            Text(
              'Die Urheber- und alle anderen Rechte an Inhalten, Bildern, Fotos oder anderen Dateien auf der Website '
              'gehören ausschliesslich Synci oder den speziell genannten Rechtsinhabern. Für die Reproduktion jeglicher '
              'Elemente ist die schriftliche Zustimmung der Urheberrechtsträger im Voraus einzuholen.',
            ),
          ]),
          section('Datenschutz', const [
            Text(
              'Wir speichern keine Daten, besonders keine personenbezogenen Daten, nur jene, die in der Applikation für '
              'den Betrieb erfasst werden.',
            ),
            SizedBox(height: 8),
            Text('Wir verwenden Auth0 für den Login-Prozess. Wir treten alle Haftungen an diesen Anbieter ab.'),
          ]),
          Text('© ${DateTime.now().year} Synci', style: text.bodySmall),
        ],
      ),
    );
  }
}
