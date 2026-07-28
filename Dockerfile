# 베이스 이미지: 공식 nginx (Alpine 경량 버전)
FROM nginx:alpine

# 커스텀 포인트 1: 이미지 메타데이터 (관리자 정보, 앱 이름)
LABEL maintainer="HyunJun Choi <gusrb8983@gmail.com>"
ENV APP_NAME="dev-workstation-mission"

# 커스텀 포인트 2: 기본 nginx 환영 페이지를 자기소개 정적 페이지로 교체
COPY app/ /usr/share/nginx/html/

# 커스텀 포인트 3: 헬스체크 - 30초마다 웹서버가 응답하는지 자동 점검
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80
