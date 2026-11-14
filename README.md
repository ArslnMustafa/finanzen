# Finans Takip

Kripto, BIST hisseleri, ABD hisseleri, TEFAS fonları ve döviz/altın
fiyatlarını tek yerde takip eden, portföy ve fiyat alarmı özellikleri olan
Flutter uygulaması. Önce web, aynı kod tabanından iOS ve Android.

**Durum: Aşama 2 tamamlandı.** Dört ana ekran tasarıma uygun şekilde
çalışıyor; giriş/kayıt, profil ve veritabanı şeması Supabase'e bağlı.
Fiyatlar hâlâ sahte (mock) veriden geliyor — gerçek fiyat akışı Aşama 3.

## Çalıştırma

Anahtarsız (demo modu: sahte kullanıcı + mock fiyatlar):

```bash
flutter pub get
flutter run -d chrome
```

Supabase'e bağlı:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<proje-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

Kurulum adımları: [`docs/supabase-setup.md`](docs/supabase-setup.md).
Anahtarlar depoya girmez; `.env.example` hangi değerlerin gerektiğini
listeler.

Doğrulama:

```bash
flutter analyze
flutter test
flutter build web --release    # çıktı: build/web
```

Web derlemesini yerelde denemek için:

```bash
cd build/web && python3 -m http.server 8000
```

> Web'de URL'ler `/markets`, `/portfolio` gibi gerçek yollar kullanıyor
> (`usePathUrlStrategy`). Barındırma tarafında bilinmeyen yolların
> `index.html`'e yönlendirilmesi gerekir (Vercel/Netlify'da tek satırlık bir
> rewrite kuralı).

## Yapı

```
lib/
  main.dart            giriş noktası, Türkçe yerel ayar, Supabase kurulumu
  app/                 router (go_router), uygulama kabuğu, alt menü
  theme/               renk, tipografi, yarıçap ve boşluk token'ları
  core/
    config/            derleme zamanı ayarları (--dart-define)
    format/            para ve sayı biçimlendirme (tr_TR)
    calc/              portföy ve kur hesapları (Decimal ile)
    errors/            hata tipleri ve Türkçe mesajlar
    widgets/           ortak arayüz parçaları
  data/
    models/            Asset, Quote, Holding, AlertRule …
    providers/         PriceProvider arayüzü + mock implementasyonu, Riverpod
    repositories/      piyasa ve kullanıcı verisi erişimi
    mock/              Aşama 1'in örnek verisi
  features/            auth, home, markets, asset_detail, portfolio,
                       alerts, settings
supabase/
  migrations/          tablolar, RLS politikaları, profil trigger'ı, varlıklar
docs/
  data-sources.md      kaynaklar, tazelik ve doğrulanacak kullanım şartları
  supabase-setup.md    panelde adım adım kurulum
```

### Oturum

`AuthRepository` arayüzünün iki uygulaması var: Supabase ve demo. Anahtar
verilmediğinde demo devreye girer, sahte bir kullanıcıyla uygulama açılır —
böylece backend olmadan da geliştirme yapılabilir. Oturumu olmayan kullanıcı
router tarafından `/giris` ekranına yönlendirilir.

### Kaynak değiştirmek

Tüm fiyat erişimi `PriceProvider` arayüzünden geçer
(`lib/data/providers/price_provider.dart`). Gerçek veriye geçmek, bu arayüzü
uygulayan yeni bir sınıf yazıp `priceSourceProvider`'ı ona çevirmek demek;
ekranlar değişmez.

## Teknoloji

Flutter · Riverpod · go_router · fl_chart · intl (tr_TR) · decimal ·
google_fonts (Manrope + JetBrains Mono) · lucide ikonları.

Para ve miktar hesapları `Decimal` ile yapılır, `double` yalnızca grafik ve
yüzde gösteriminde kullanılır.

## Sonraki aşamalar

3. Fiyat verisi: `fetch-prices` Edge Function, `price_cache`/`price_history`,
   pg_cron, kripto için Binance WebSocket
4. İzleme listesi ve portföyün Supabase'e taşınması
5. Alarmlar: CRUD + `check-alerts` zamanlanmış fonksiyonu
6. Yayın: PWA ayarları, ücretsiz barındırmaya deploy

Veriler bilgi amaçlıdır, yatırım tavsiyesi değildir.
