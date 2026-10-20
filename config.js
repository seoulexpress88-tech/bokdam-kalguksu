// Supabase 연결 설정
//
// 여기에는 "공개 키(Publishable key, sb_publishable_...)"만 넣으세요.
//   - 공개 키는 원래 브라우저에 보여도 되는 키입니다. 손님이 할 수 있는 일은
//     supabase/schema.sql 의 RLS 정책(메뉴 읽기, 후기 쓰기, 문의 쓰기)으로만 제한됩니다.
//   - 이 파일은 사이트와 함께 배포되어야 하므로 GitHub 에 올라가도 괜찮습니다.
//
// ⚠️ "비밀 키(Secret key, sb_secret_...)"나 service_role 키는 절대 여기에 넣지 마세요.
//   비밀 키는 RLS 를 무시하고 모든 데이터(손님 연락처 포함)를 읽고 지울 수 있습니다.
//   필요하면 .env 파일에만 보관하세요(.gitignore 로 GitHub 업로드에서 제외됨).
window.SUPABASE_CONFIG = {
  url: 'https://hdikjsimtgasmxpvhxkd.supabase.co',
  publishableKey: 'sb_publishable_i38Mql1lpA-AUTTuxmxfOA_3Y9cHli6'
};
