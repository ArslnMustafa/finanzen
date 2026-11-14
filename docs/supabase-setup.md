# Supabase kurulumu (Aşama 2)

Bu dosya, panelde tıklanacak yerleri sırayla anlatır. Tahmini süre 15–20
dakika. Supabase arayüzü zaman zaman değişiyor; bir başlığı bulamazsan
adımın ne yaptığına bak, karşılığı yakın bir yerdedir.

## 1. Proje

1. supabase.com → **New project**
2. Ad: `finanzen` · Bölge: **Frankfurt (eu-central-1)** (Türkiye'ye en yakını)
3. Veritabanı şifresini belirle ve bir parola yöneticisine kaydet. Bu şifre
   yalnızca doğrudan Postgres bağlantısı için gerekir; uygulama kullanmaz.
4. Proje hazır olana kadar ~2 dakika bekle.

## 2. Tabloları kur

**SQL Editor** → **New query**. `supabase/migrations/` altındaki dört dosyayı
**sırayla** yapıştırıp çalıştır:

1. `0001_schema.sql` — tablolar, enum'lar, index'ler
2. `0002_rls.sql` — Row Level Security politikaları
3. `0003_profile_trigger.sql` — kayıt olanlar için otomatik profil satırı
4. `0004_seed_assets.sql` — 16 varlık

Kontrol: **Table Editor**'de yedi tablo görünmeli ve `assets` 16 satır
içermeli. **Authentication → Policies** sayfasında her kullanıcı tablosunda
"RLS enabled" yazmalı.

## 3. Uygulamanın anahtarları

**Project Settings → API Keys** sayfasından iki değer:

- **Project URL** — `https://<proje-ref>.supabase.co`
- **Publishable key** — `sb_publishable_...` (eski projelerde `anon` JWT'si)

Bunlar herkese açık olacak şekilde tasarlanmıştır; veriyi RLS korur. Depoya
girmezler, çalıştırırken `--dart-define` ile geçilirler:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<proje-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

**`service_role` / secret anahtarı hiçbir yerde istemciye girmez.** O, Aşama
3'te Edge Function secrets içinde duracak.

## 4. E-posta ile giriş

**Authentication → Providers → Email** açık olmalı (varsayılan açıktır).

Test sürümünde doğrulama e-postasıyla uğraşmak istemiyorsan
**Confirm email** seçeneğini kapat; kayıt olan kişi anında giriş yapar.
Açık bırakırsan uygulama "e-postana bağlantı gönderdik" mesajını gösterir —
ücretsiz planın varsayılan SMTP'si saatte birkaç e-posta ile sınırlıdır.

**Authentication → URL Configuration**:

- **Site URL**: geliştirirken `http://localhost:5000` (ya da `flutter run`
  hangi portu yazdıysa), yayına çıkınca gerçek adres
- **Redirect URLs**: aynı adresleri buraya da ekle

## 5. Google ile giriş (isteğe bağlı)

1. Google Cloud Console → **APIs & Services → Credentials** →
   **Create credentials → OAuth client ID** → tür: **Web application**
2. **Authorized redirect URIs** alanına şunu ekle:
   `https://<proje-ref>.supabase.co/auth/v1/callback`
3. Oluşan **Client ID** ve **Client Secret** değerlerini Supabase'de
   **Authentication → Providers → Google** alanına gir ve sağlayıcıyı aç.
   Bu iki değeri başka hiçbir yere yazma.

Mobil (iOS/Android) için ayrıca platforma özel istemci kimlikleri gerekir;
onu mobil derlemeye geçtiğimiz aşamada ekleyeceğiz. Uygulamada Google
düğmesi yalnızca Supabase yapılandırıldığında görünür.

## 6. Doğrulama

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
```

- Giriş ekranı açılmalı (anahtarsız çalıştırırsan demo kullanıcı ile doğrudan
  ana sayfa açılır).
- Kayıt ol → ana sayfadaki selamlama yazdığın adı göstermeli.
- **Table Editor → profiles** içinde bir satır oluşmuş olmalı.
- Ayarlar → **Çıkış yap** seni giriş ekranına döndürmeli.

Bir hata görürsen tarayıcı konsolundaki mesajı not al; Supabase tarafındaki
karşılığı **Logs → Auth** sayfasında görünür.
