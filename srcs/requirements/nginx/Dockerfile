FROM alpine:3.21

# without list cache
RUN apk update && apk add --no-cache \
nginx \
openssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/http.d/default.conf
COPY tools/setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup.sh && setup.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
