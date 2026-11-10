# 베이스: 공식 nginx 경량 이미지 (정적 웹 서버)
FROM nginx:alpine

# 이미지 메타데이터 (이미지가 무엇인지 설명)
LABEL org.opencontainers.image.title="mission1-web"
LABEL org.opencontainers.image.description="mission1 custom nginx web server"

# 환경 변수 (설정 값을 코드와 분리)
ENV APP_ENV=dev

# 기본 페이지 교체 (커스텀 콘텐츠)
COPY site/ /usr/share/nginx/html/

# 컨테이너 상태 점검
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD wget -q -O /dev/null http://localhost/ || exit 1
