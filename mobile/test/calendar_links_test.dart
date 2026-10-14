import 'package:flutter_test/flutter_test.dart';
import 'package:synci/features/calendar/calendar_links.dart';

void main() {
  test('Feed-Adresse ohne Schema, mit Port nur wenn angegeben', () {
    expect(calendarFeedAddress(Uri.parse('https://synci.ch/'), 'abc'), 'synci.ch/api/calendars/abc/subscribe');
    expect(
      calendarFeedAddress(Uri.parse('http://localhost:8080/'), 'abc'),
      'localhost:8080/api/calendars/abc/subscribe',
    );
  });

  test('Abo-Links je Kalender', () {
    const feed = 'synci.ch/api/calendars/abc/subscribe';

    expect(calendarSubscribeUri(CalendarProvider.apple, feed).toString(), 'webcal://$feed');
    expect(
      calendarSubscribeUri(CalendarProvider.google, feed).toString(),
      'https://calendar.google.com/calendar/r?cid=webcal%3A%2F%2Fsynci.ch%2Fapi%2Fcalendars%2Fabc%2Fsubscribe',
    );
    final outlook = calendarSubscribeUri(CalendarProvider.outlook, feed);
    expect(outlook.host, 'outlook.live.com');
    expect(outlook.queryParameters['url'], 'https://$feed');
    expect(outlook.queryParameters['name'], 'Sportevents-Synci');
  });
}
