# Veri kaynakları

Bu dosya hangi varlık türünün hangi kaynaktan geldiğini, verinin ne kadar
taze olduğunu ve ücretsiz kullanım şartları hakkında **doğrulanması gereken**
noktaları tutar. Aşama 1'de uygulama tamamen sahte (mock) veriyle çalışıyor;
aşağıdaki tablo Aşama 3'te kurulacak gerçek bağlantının planı.

## Planlanan kaynaklar

| Varlık türü | Kaynak | Tazelik | Anahtar | Not |
|---|---|---|---|---|
| Kripto | Binance public REST + WebSocket | Canlı | Gerekmiyor | İstemci doğrudan WebSocket'e bağlanabilir; anahtar olmadığı için güvenli. Yedek: CoinGecko |
| ABD hisseleri | Finnhub | Canlı (önbellek 30–60 sn) | Ücretsiz anahtar | Ücretsiz planda dakikalık istek sınırı var |
| BIST hisseleri | Bürküt API | 15 dk gecikmeli | Ücretsiz anahtar | Gecikme arayüzde her satırda yazıyor |
| TEFAS fonları | Bürküt API veya TEFAS public uç noktaları | Günlük | Duruma göre | TEFAS tarafı sıkı istek sınırına sahip; günde birkaç kez çekmek yeterli |
| Döviz / altın | Bürküt API | 15 dk gecikmeli | Ücretsiz anahtar | Gram altın, USD/TRY, EUR/TRY |

Uygulamadaki `DataDelay` değerleri (`live`, `delayed_15m`, `daily`) bu tabloya
göre ayarlanır ve kullanıcıya her listede gösterilir.

## Önbellekleme kuralı

Kripto dışındaki hiçbir varlık için istemci üçüncü taraf API'ye doğrudan
gitmez:

1. Supabase Edge Function (`fetch-prices`) fiyatları çeker.
2. `price_cache` tablosuna yazar (kripto dışı ~30–60 sn, fonlar günde birkaç
   kez), `price_history` tablosuna seyreltilmiş geçmiş noktası ekler.
3. İstemciler yalnızca Supabase'i okur.

Böylece 50 kullanıcı aynı veriyi tek bir dış istekle görür ve ücretsiz
planların istek sınırları kullanıcı sayısıyla büyümez.

Tüm API anahtarları yalnızca Supabase secrets içinde durur; istemci paketinde
hiçbir üçüncü taraf anahtarı bulunmaz.

## Ticari kullanım — doğrulanacak başlıklar

Aşağıdakiler **varsayım değil, soru**. Ücretli kaynağa geçişi kolaylaştırmak
için burada tutuluyor; Aşama 3'e başlamadan önce her birinin güncel şartları
sağlayıcının kendi sayfasından okunmalı:

- **Binance public API** — ticari olmayan test kullanımı için uygun mu, oran
  sınırları ve WebSocket bağlantı başına abonelik sınırı nedir?
- **Finnhub ücretsiz plan** — ücretsiz anahtarla verinin yeniden dağıtımına
  (başka kullanıcılara gösterilmesine) izin veriliyor mu?
- **Bürküt** — ücretsiz kotanın sınırı, BIST verisinin yeniden dağıtım şartı
  ve Borsa İstanbul'un gecikmeli veri kuralları.
- **TEFAS** — public uç noktaların kullanım şartları ve istek sıklığı sınırı.
- **CoinGecko** (yedek) — ücretsiz planda atıf zorunluluğu var mı?

Kaynak değiştirmek tek bir sınıfı değiştirmek demek: `PriceProvider`
arayüzünü (`lib/data/providers/price_provider.dart`) uygulayan yeni bir sınıf
yazmak ve `priceSourceProvider`'ı ona çevirmek yeterli.

## Yasal not

Uygulama yatırım tavsiyesi vermez. Ayarlar ekranına "Veriler bilgi amaçlıdır,
yatırım tavsiyesi değildir" notu Aşama 2'de eklenecek.
