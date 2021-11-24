FROM nginx:alpine

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
ENTRYPOINT ["/docker-entrypoint.sh"]

# FIXME: Придумать что-то более красивое, чем это
RUN sed -ri 's/^nginx:x:101:101:/nginx:x:33:33:/' /etc/passwd
RUN mkdir -p /storage
RUN chown -R nginx:nginx /storage
CMD ["nginx", "-g", "daemon off;"]
