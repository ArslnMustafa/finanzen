-- Finans Takip — tablolar
-- Supabase SQL Editor'de bu dosyayı en başta çalıştır.

-- Enum'lar: istemcideki AssetType, DataDelay ve AlertCondition ile birebir.
create type public.asset_type as enum (
  'crypto', 'bist', 'us_stock', 'fund', 'fx', 'commodity'
);

create type public.data_delay as enum ('live', 'delayed_15m', 'daily');

create type public.alert_condition as enum ('above', 'below');

-- updated_at alanını kendiliğinden güncelleyen ortak trigger.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Kullanıcı profili. auth.users ile aynı id'yi taşır.
create table public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  display_name  text,
  base_currency text not null default 'TRY',
  created_at    timestamptz not null default now()
);

-- Takip edilebilen varlıklar. Fiyat kaynağı ve gecikme bilgisi burada durur.
create table public.assets (
  id             text primary key,
  symbol         text not null,
  display_symbol text,
  name           text not null,
  type           public.asset_type not null,
  source         text not null,
  data_delay     public.data_delay not null,
  currency       text not null default 'TRY',
  unit           text,
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  unique (symbol, source)
);

create index assets_type_idx on public.assets (type) where is_active;

-- Son bilinen fiyat. Edge Function yazar, istemciler okur.
create table public.price_cache (
  asset_id       text primary key references public.assets (id) on delete cascade,
  price          numeric(24, 8) not null,
  change_24h     numeric(24, 8) not null default 0,
  change_pct_24h numeric(10, 4) not null default 0,
  high_24h       numeric(24, 8),
  low_24h        numeric(24, 8),
  updated_at     timestamptz not null default now()
);

-- Grafikler için seyreltilmiş fiyat geçmişi.
create table public.price_history (
  asset_id text not null references public.assets (id) on delete cascade,
  ts       timestamptz not null,
  price    numeric(24, 8) not null,
  primary key (asset_id, ts)
);

create index price_history_recent_idx
  on public.price_history (asset_id, ts desc);

-- İzleme listesi.
create table public.watchlist (
  user_id    uuid not null references auth.users (id) on delete cascade,
  asset_id   text not null references public.assets (id) on delete cascade,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  primary key (user_id, asset_id)
);

create index watchlist_order_idx on public.watchlist (user_id, sort_order);

-- Kullanıcının sahip olduğu varlıklar.
create table public.holdings (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  asset_id   text not null references public.assets (id) on delete restrict,
  quantity   numeric(32, 12) not null check (quantity > 0),
  avg_cost   numeric(24, 8) not null check (avg_cost >= 0),
  currency   text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index holdings_user_idx on public.holdings (user_id);

create trigger holdings_touch_updated_at
  before update on public.holdings
  for each row execute function public.touch_updated_at();

-- Fiyat alarmları.
create table public.alerts (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users (id) on delete cascade,
  asset_id          text not null references public.assets (id) on delete cascade,
  condition         public.alert_condition not null,
  target_price      numeric(24, 8) not null check (target_price > 0),
  is_active         boolean not null default true,
  last_triggered_at timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index alerts_user_idx on public.alerts (user_id);

-- check-alerts fonksiyonu yalnızca açık alarmları tarar.
create index alerts_active_idx on public.alerts (asset_id) where is_active;

create trigger alerts_touch_updated_at
  before update on public.alerts
  for each row execute function public.touch_updated_at();
