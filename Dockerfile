#
# Nginx Dockerfile
#
# https://github.com/dockerfile/nginx
#

# Pull base image.
FROM ubuntu:14.04
MAINTAINER Devsisters SE team <se@devsisters.com>

# Install Nginx.
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install python-software-properties && DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common

RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  chown -R www-data:www-data /var/lib/nginx

# Define working directory.
WORKDIR /

# Bootstrapping nginx SSL configueration as well as some nginx settings (ie. pipes logs to stdout)
COPY bootstrap-nginx.sh /bootstrap-nginx.sh
COPY run-nginx.sh /run-nginx.sh

# Define default command.
CMD ["bash", "run-nginx.sh"]

# Expose ports.
EXPOSE 443
