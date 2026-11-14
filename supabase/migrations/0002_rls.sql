-- Finans Takip — Row Level Security
-- 0001_schema.sql'den sonra çalıştır.

-- Kullanıcı verisi: herkes yalnızca kendi satırlarını görür ve değiştirir.
alter table public.profiles  enable row level security;
alter table public.watchlist enable row level security;
alter table public.holdings  enable row level security;
alter table public.alerts    enable row level security;

-- Piyasa verisi: herkese okunur, yazma yalnızca servis rolünde.
alter table public.assets        enable row level security;
alter table public.price_cache   enable row level security;
alter table public.price_history enable row level security;

-- profiles ------------------------------------------------------------

create policy "Kendi profilini görür"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "Kendi profilini günceller"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Profil satırını normalde 0003'teki trigger açar; kullanıcı kendi
-- satırını da ekleyebilsin ki trigger'dan önce gelen bir istek takılmasın.
create policy "Kendi profilini oluşturur"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- watchlist -----------------------------------------------------------

create policy "Kendi izleme listesini görür"
  on public.watchlist for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Kendi izleme listesine ekler"
  on public.watchlist for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Kendi izleme listesini günceller"
  on public.watchlist for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Kendi izleme listesinden siler"
  on public.watchlist for delete
  to authenticated
  using (auth.uid() = user_id);

-- holdings ------------------------------------------------------------

create policy "Kendi varlıklarını görür"
  on public.holdings for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Kendi varlığını ekler"
  on public.holdings for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Kendi varlığını günceller"
  on public.holdings for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Kendi varlığını siler"
  on public.holdings for delete
  to authenticated
  using (auth.uid() = user_id);

-- alerts --------------------------------------------------------------

create policy "Kendi alarmlarını görür"
  on public.alerts for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Kendi alarmını kurar"
  on public.alerts for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Kendi alarmını günceller"
  on public.alerts for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Kendi alarmını siler"
  on public.alerts for delete
  to authenticated
  using (auth.uid() = user_id);

-- Piyasa verisi -------------------------------------------------------
-- Yalnızca okuma politikası tanımlı. service_role RLS'i baypas ettiği için
-- Edge Function'lar yazabilir; anon ve authenticated rolleri yazamaz.

create policy "Varlık listesi herkese açık"
  on public.assets for select
  to anon, authenticated
  using (true);

create policy "Fiyatlar herkese açık"
  on public.price_cache for select
  to anon, authenticated
  using (true);

create policy "Fiyat geçmişi herkese açık"
  on public.price_history for select
  to anon, authenticated
  using (true);
