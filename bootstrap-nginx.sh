#!/usr/bin/env bash
#
# Required docker envs vars!
# -----------------------------------------------
# $SSL_CERT_B64: base64-encoded cert pem
# $SSL_KEY_B64: base64-encoded cert key
# $BACKEND_SERVICE_HOST: target kubernetes service's host
# $BACKEND_SERVICE_PORT: target kubernetes service's port
# OR you can declare SERVICE_NAME instead of BACKEND_SERVICE_HOST, BACKEND_SERVICE_PORT.
# -----------------------------------------------

mkdir -p /cert
echo $SSL_CERT_B64 | base64 --decode > /cert/cert.pem
echo $SSL_KEY_B64 | base64 --decode > /cert/cert.key

if ! grep -Fxq "daemon off;" /etc/nginx/nginx.conf;
then
    echo "daemon off;" >> /etc/nginx/nginx.conf;
fi

if ! grep -Fxq "error_log /dev/stdout info;" /etc/nginx/nginx.conf;
then
    echo "error_log /dev/stdout info;" >> /etc/nginx/nginx.conf;
fi

if [ -n "${SERVICE_NAME}" ]; then
    eval "BACKEND_SERVICE_HOST=\$${SERVICE_NAME}_SERVICE_HOST"
    eval "BACKEND_SERVICE_PORT=\$${SERVICE_NAME}_SERVICE_PORT"
fi

rm -rf /etc/nginx/sites-enabled/*
cat <<EOF > /etc/nginx/sites-enabled/sslservice
# HTTPS server
server {
    listen 443;
    server_name localhost;

    # disable any limits to avoid HTTP 413 for large image uploads
    client_max_body_size 0;

    # required to avoid HTTP 411: see Issue #1486 (https://github.com/docker/docker/issues/1486)
    chunked_transfer_encoding on;

    # Docker uses host header for proper URL redirects (https://github.com/docker/docker-registry/issues/69)
    proxy_set_header Host \$http_host;

    ssl on;
    ssl_certificate /cert/cert.pem;
    ssl_certificate_key /cert/cert.key;

    ssl_session_timeout 5m;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "HIGH:!aNULL:!MD5 or HIGH:!aNULL:!MD5:!3DES";
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://${BACKEND_SERVICE_HOST}:${BACKEND_SERVICE_PORT};
    }

    access_log /dev/stdout;
}
EOF
