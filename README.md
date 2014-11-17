docker-nginx-sslproxy
=====================

Dockerized nginx proxy w/ SSL suppport

## How to use

First, you have to write environment file.
Here are all list of env vars

* `SSL_CERT_B64`: Base64 encoded SSL cert (.crt or .pem) file. Use `cat <CERT_PATH> | base64` command to get this string.
* `SSL_KEY_B64`: Base64 encoded SSL key (.key) file. Use `cat <KEY_PATH> | base64` command to get this string.
* `BACKEND_SERVICE_HOST`: Host ip(or domain) of backend service.
* `BACKEND_SERVICE_PORT`: Port of backend service.

You can give `SERVICE_NAME` instead of `BACKEND_SERVICE_HOST` and `BACKEND_SERVICE_PORT`. This is useful if you want to run this image in a [Kubernetes](https://github.com/googlecloudplatform/kubernetes) cluster.

After that, you can run it by docker.

```
$ git clone https://github.com/devsisters/docker-nginx-sslproxy.git
$ cd docker-nginx-sslproxy
$ docker build -t sslproxy .
$ docker run --env-file <ENV_FILE_PATH> --publish=443:443 -d sslproxy
```
