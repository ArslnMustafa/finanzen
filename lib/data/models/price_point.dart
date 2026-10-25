/// One point of a price series, used by the charts.
class PricePoint {
  const PricePoint(this.ts, this.price);

  final DateTime ts;
  final double price;
}

/// Time ranges offered by the asset detail chart.
enum ChartRange {
  hour('1S', 'son 1 saat'),
  day('1G', 'son 24 saat'),
  week('1H', 'son 7 gün'),
  month('1A', 'son 1 ay'),
  year('1Y', 'son 1 yıl'),
  all('Tümü', 'tüm zamanlar');

  const ChartRange(this.label, this.description);

  final String label;
  final String description;
}
