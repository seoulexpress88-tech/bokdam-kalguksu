# 복담칼국수

서울 송파구 가락동(경찰병원역) 복담칼국수 소개 사이트입니다.

- HTML + CSS + 바닐라 JavaScript, 빌드 과정 없는 정적 사이트
- Supabase로 메뉴·영업시간 관리, 방문 후기, 예약·단체 문의

## 파일

| 파일 | 내용 |
| --- | --- |
| `index.html` | 사이트 전체 (화면, 스타일, 스크립트) |
| `config.js` | Supabase 주소와 공개 키 |
| `supabase/schema.sql` | 테이블·권한(RLS)·초기 데이터. Supabase SQL Editor에서 실행 |

## 키 관리

`config.js`에는 **공개 키(`sb_publishable_...`)만** 넣습니다. 공개 키는 브라우저에 노출되도록 만들어진 키이며,
할 수 있는 일은 `schema.sql`의 RLS 정책으로 제한됩니다.

비밀 키(`sb_secret_...`)는 이 저장소에 절대 커밋하지 마세요. 필요하면 `.env`에 보관합니다(`.gitignore`로 제외됨).

## 운영

- 메뉴·가격 변경: Supabase Table Editor → `menu_items` (`is_available`을 끄면 사이트에서 숨김)
- 영업시간 변경: `business_hours` (0=일 … 6=토)
- 후기 숨기기: `reviews`에서 `is_visible` 끄기
- 예약 문의 확인: `inquiries` (사이트에서는 열람 불가)

## 로컬에서 보기

`index.html`을 브라우저로 열면 됩니다.
