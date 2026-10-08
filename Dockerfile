FROM nginx:1.27-alpine

ARG APP_ENV=local
ARG GIT_SHA=dev

COPY site/ /usr/share/nginx/html/
RUN sed -i "s/__APP_ENV__/${APP_ENV}/g; s/__GIT_SHA__/${GIT_SHA}/g" /usr/share/nginx/html/index.html

HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1
