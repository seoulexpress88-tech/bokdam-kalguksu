-- 복담칼국수 사이트용 Supabase 스키마
-- Supabase 대시보드 > SQL Editor 에 전체를 붙여넣고 Run 하세요. 여러 번 실행해도 안전합니다.

-- ─────────────────────────────────────────────
-- 1. 메뉴
-- ─────────────────────────────────────────────
create table if not exists public.menu_items (
  id             bigint generated always as identity primary key,
  name           text     not null,
  price          integer  not null check (price >= 0),
  category       text     not null default 'single' check (category in ('single', 'set')),
  is_recommended boolean  not null default false,
  is_available   boolean  not null default true,
  sort_order     integer  not null default 0
);

-- ─────────────────────────────────────────────
-- 2. 영업시간 (day_of_week: 0=일, 1=월 … 6=토)
-- ─────────────────────────────────────────────
create table if not exists public.business_hours (
  day_of_week smallint primary key check (day_of_week between 0 and 6),
  open_time   time,
  close_time  time,
  is_closed   boolean not null default false
);

-- ─────────────────────────────────────────────
-- 3. 방문 후기 (손님이 작성, 누구나 열람)
-- ─────────────────────────────────────────────
create table if not exists public.reviews (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  name       text     not null check (char_length(name) between 1 and 20),
  rating     smallint not null check (rating between 1 and 5),
  content    text     not null check (char_length(content) between 1 and 300),
  is_visible boolean  not null default true   -- 사장님이 false 로 바꾸면 사이트에서 숨겨짐
);

-- ─────────────────────────────────────────────
-- 4. 예약·단체 문의 (손님은 작성만, 열람은 대시보드에서만)
-- ─────────────────────────────────────────────
create table if not exists public.inquiries (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  name       text     not null check (char_length(name) between 1 and 20),
  phone      text     not null check (phone ~ '^[0-9-]{9,14}$'),
  visit_date date     not null,
  party_size smallint not null check (party_size between 1 and 100),
  message    text     check (char_length(message) <= 500),
  status     text     not null default 'new' check (status in ('new', 'confirmed', 'done', 'canceled'))
);

-- ─────────────────────────────────────────────
-- 권한 (RLS)
-- ─────────────────────────────────────────────
alter table public.menu_items     enable row level security;
alter table public.business_hours enable row level security;
alter table public.reviews        enable row level security;
alter table public.inquiries      enable row level security;

revoke all on public.menu_items, public.business_hours, public.reviews, public.inquiries from anon, authenticated;

-- 메뉴·영업시간: 읽기만
grant select on public.menu_items, public.business_hours to anon, authenticated;
drop policy if exists "menu public read" on public.menu_items;
create policy "menu public read" on public.menu_items for select using (true);
drop policy if exists "hours public read" on public.business_hours;
create policy "hours public read" on public.business_hours for select using (true);

-- 후기: 보이는 후기 읽기 + 이름/별점/내용만 작성 가능
grant select (id, created_at, name, rating, content) on public.reviews to anon, authenticated;
grant insert (name, rating, content) on public.reviews to anon, authenticated;
drop policy if exists "reviews public read" on public.reviews;
create policy "reviews public read" on public.reviews for select using (is_visible);
drop policy if exists "reviews public insert" on public.reviews;
create policy "reviews public insert" on public.reviews for insert with check (true);

-- 문의: 작성만 가능 (읽기 권한 없음 → 개인정보는 대시보드에서만 확인)
grant insert (name, phone, visit_date, party_size, message) on public.inquiries to anon, authenticated;
drop policy if exists "inquiries public insert" on public.inquiries;
create policy "inquiries public insert" on public.inquiries for insert
  with check (visit_date >= (now() at time zone 'Asia/Seoul')::date);

-- ─────────────────────────────────────────────
-- 초기 데이터 (카카오맵 기준, 2026-10-20)
-- ─────────────────────────────────────────────
insert into public.menu_items (name, price, category, is_recommended, sort_order)
select * from (values
  ('해물칼국수',                    10000, 'single', true,  1),
  ('매생이굴죽',                    10000, 'single', true,  2),
  ('해물수제비',                    10000, 'single', false, 3),
  ('속초식 해초비빔밥',             10000, 'single', false, 4),
  ('수제 굴림만두',                  7000, 'single', false, 5),
  ('해물칼국수 + 굴림만두',         12000, 'set',    false, 6),
  ('매생이굴죽 + 굴림만두',         12000, 'set',    false, 7),
  ('속초식 해초비빔밥 + 굴림만두',  12000, 'set',    false, 8)
) as v(name, price, category, is_recommended, sort_order)
where not exists (select 1 from public.menu_items);

insert into public.business_hours (day_of_week, open_time, close_time, is_closed) values
  (0, null,    null,    true),
  (1, '11:00', '15:00', false),
  (2, '11:00', '15:00', false),
  (3, '11:00', '15:00', false),
  (4, '11:00', '15:00', false),
  (5, '11:00', '15:00', false),
  (6, null,    null,    true)
on conflict (day_of_week) do nothing;

-- 스키마 캐시 새로고침
notify pgrst, 'reload schema';
