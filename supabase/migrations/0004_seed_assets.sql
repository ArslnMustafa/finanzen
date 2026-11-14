-- Finans Takip — başlangıç varlık listesi
-- 0003_profile_trigger.sql'den sonra çalıştır.
--
-- Aşama 1'de uygulamanın içinde duran katalog. Fiyatlar burada değil;
-- onları Aşama 3'te fetch-prices Edge Function'ı price_cache'e yazacak.

insert into public.assets
  (id, symbol, display_symbol, name, type, source, data_delay, currency, unit)
values
  -- Kripto: Binance public akışı, anahtar gerektirmez.
  ('btc',    'BTCUSDT',   'BTC',  'Bitcoin',                     'crypto',   'Binance', 'live',        'USD', 'BTC'),
  ('eth',    'ETHUSDT',   'ETH',  'Ethereum',                    'crypto',   'Binance', 'live',        'USD', 'ETH'),
  ('sol',    'SOLUSDT',   'SOL',  'Solana',                      'crypto',   'Binance', 'live',        'USD', 'SOL'),
  ('avax',   'AVAXUSDT',  'AVAX', 'Avalanche',                   'crypto',   'Binance', 'live',        'USD', 'AVAX'),
  -- BIST: 15 dakika gecikmeli.
  ('thyao',  'THYAO',     null,   'Türk Hava Yolları',           'bist',     'Bürküt',  'delayed_15m', 'TRY', 'lot'),
  ('asels',  'ASELS',     null,   'Aselsan',                     'bist',     'Bürküt',  'delayed_15m', 'TRY', 'lot'),
  ('tuprs',  'TUPRS',     null,   'Tüpraş',                      'bist',     'Bürküt',  'delayed_15m', 'TRY', 'lot'),
  ('sise',   'SISE',      null,   'Şişecam',                     'bist',     'Bürküt',  'delayed_15m', 'TRY', 'lot'),
  -- ABD hisseleri.
  ('aapl',   'AAPL',      null,   'Apple',                       'us_stock', 'Finnhub', 'live',        'USD', 'adet'),
  ('nvda',   'NVDA',      null,   'NVIDIA',                      'us_stock', 'Finnhub', 'live',        'USD', 'adet'),
  ('msft',   'MSFT',      null,   'Microsoft',                   'us_stock', 'Finnhub', 'live',        'USD', 'adet'),
  -- TEFAS fonları: günde bir kez.
  ('afa',    'AFA',       null,   'Ak Portföy Yeni Teknolojiler','fund',     'TEFAS',   'daily',       'TRY', 'adet'),
  ('ipb',    'IPB',       null,   'İş Portföy BIST Teknoloji',   'fund',     'TEFAS',   'daily',       'TRY', 'adet'),
  -- Döviz ve altın.
  ('usdtry', 'USDTRY',    null,   'Amerikan Doları',             'fx',       'Bürküt',  'delayed_15m', 'TRY', 'USD'),
  ('eurtry', 'EURTRY',    null,   'Euro',                        'fx',       'Bürküt',  'delayed_15m', 'TRY', 'EUR'),
  ('gram',   'GRAMALTIN', 'GRAM', 'Gram Altın',                  'commodity','Bürküt',  'delayed_15m', 'TRY', 'gram')
on conflict (id) do update set
  symbol         = excluded.symbol,
  display_symbol = excluded.display_symbol,
  name           = excluded.name,
  type           = excluded.type,
  source         = excluded.source,
  data_delay     = excluded.data_delay,
  currency       = excluded.currency,
  unit           = excluded.unit;
