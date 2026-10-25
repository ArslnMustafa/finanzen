# Finans Takip — proje bağlamı

Kripto, BIST, ABD hisseleri, TEFAS fonları ve döviz/altın takibi yapan,
portföy ve fiyat alarmı olan bir Flutter uygulaması. Önce web, sonra aynı kod
tabanından iOS/Android. Az kullanıcılı bir test sürümü: ücretsiz API'ler ve
ücretsiz barındırma yeterli, aşırı mühendislikten kaçın, ama ileride büyümeyi
engelleyecek kararlar da alma.

## Çalışma şekli

- Her aşamaya başlamadan önce kısa bir plan çıkar, kullanıcıya göster, sonra
  uygula.
- Her aşamanın sonunda `flutter analyze`, `flutter test` ve `flutter build web`
  ile çalıştığını doğrula.
- Emin olmadığın bir karar varsa (örn. bir API'nin şartları değişmişse)
  varsayım yapmadan önce kullanıcıya sor.

## Kurallar

- Arayüz metinleri **Türkçe**; kod, değişken adları ve commit mesajları
  **İngilizce**.
- Para ve miktar hesapları `Decimal` ile; `double` yalnızca grafik ve yüzde
  gösteriminde.
- Renk, tipografi ve ölçü değerleri yalnızca `lib/theme/` içinde tanımlanır;
  ekranlarda hard-coded değer olmaz.
- Yükseliş/düşüş her zaman `+` / `−` işaretiyle gösterilir (renk tek başına
  yeterli değil).
- Her varlığın veri tazeliği arayüzde görünür: "Canlı", "15 dk gecikmeli",
  "Günlük".
- Gizli anahtar depoya girmez. Üçüncü taraf API anahtarları yalnızca Supabase
  Edge Function secrets içinde durur; istemcide hiçbir anahtar olmaz.
- Ağ hatasında kullanıcıya anlaşılır Türkçe mesaj göster ve son bilinen fiyatı
  "son güncelleme: …" bilgisiyle göstermeye devam et.
- Uygulama yatırım tavsiyesi vermez.
- İkon-only butonlarda `Semantics`/tooltip etiketi, dokunma hedefi en az
  44×44, metin kontrastı en az 4.5:1.

## Mimari

- State: `flutter_riverpod` (`Notifier` / `Provider`, kod üretimi yok).
- Yönlendirme: `go_router`, `StatefulShellRoute` ile dört sekme; web'de yol
  tabanlı URL'ler.
- Tüm fiyat erişimi `PriceProvider` arayüzünden geçer; kaynak değiştirmek tek
  bir sınıfı değiştirmek olmalı.
- Kullanıcı verisi (izleme listesi, varlıklar, alarmlar)
  `UserDataRepository` arayüzünün arkasında; Aşama 4'te bellekten Supabase'e
  geçecek.
- Grafikler `fl_chart`, ikonlar `lucide_icons_flutter`, yazı tipleri
  `google_fonts` (Manrope + JetBrains Mono, tabular rakamlar).

## Tasarım token'ları

Arka plan `#0E1116`, yüzey `#171B22`, alt menü `#12161C`, kenarlık `#262C36`,
ayraç `#1E232B`, ikincil yüzey `#222833`, seçili segment `#2A313C`, ana metin
`#E8EAED`, ikincil metin `#9AA3AE`, ikon kutusu metni `#C9D1DB`, vurgu
`#C6F36B` (üzerinde `#0E1116`), yükseliş `#3DDC97`, düşüş `#FF7A6B`, grafik
ek renkleri `#7FB8FF` / `#FFB86B` / `#5B6474`.

Mobil öncelikli (390×844 referans), web'de içerik ortada en fazla 480 px.

## Aşamalar

1. ✅ Kurulum: tema, router, alt menülü kabuk, dört ekran mock veriyle
2. Supabase: proje bağlantısı, migration'lar, RLS, e-posta + Google giriş
3. Fiyat verisi: `fetch-prices` Edge Function, `price_cache`/`price_history`,
   pg_cron, kripto için Binance WebSocket; mock veriyi değiştir
4. İzleme listesi ve portföy: ekleme/silme, toplam değer, kâr/zarar, dağılım
5. Alarmlar: CRUD, `check-alerts` zamanlanmış fonksiyonu, uygulama içi
   bildirim + e-posta (mobil push sonraki aşama)
6. Yayın: web derlemesi, PWA, ücretsiz barındırma, ortam değişkenleri belgesi

## Planlanan veritabanı (Aşama 2)

`profiles`, `assets`, `price_cache`, `price_history`, `watchlist`,
`holdings`, `alerts`. Kullanıcı tablolarında RLS açık: kullanıcı yalnızca
kendi satırlarını görür. `assets` ve `price_cache` herkese okunur, yalnızca
servis rolü yazar. Para ve miktar alanları `numeric`, `float` değil.
