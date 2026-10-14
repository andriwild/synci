enum CalendarProvider {
  apple('Apple Kalender'),
  google('Google Kalender'),
  outlook('Outlook');

  const CalendarProvider(this.label);

  final String label;
}

String calendarFeedAddress(Uri backendUrl, String syncConfigId) {
  final path = backendUrl.path.endsWith('/') ? backendUrl.path : '${backendUrl.path}/';
  return '${backendUrl.authority}${path}api/calendars/$syncConfigId/subscribe';
}

Uri calendarSubscribeUri(CalendarProvider provider, String feedAddress) => switch (provider) {
  CalendarProvider.apple => Uri.parse('webcal://$feedAddress'),
  CalendarProvider.google => Uri.https('calendar.google.com', '/calendar/r', {'cid': 'webcal://$feedAddress'}),
  CalendarProvider.outlook => Uri.https('outlook.live.com', '/calendar/0/addcalendar', {
    'source': 'fromUrl',
    'url': 'https://$feedAddress',
    'name': 'Sportevents-Synci',
  }),
};
