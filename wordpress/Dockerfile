FROM debian:buster-slim

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y nano nginx php-fpm php-mysql curl

COPY ./start.sh /start.sh
COPY ./nginx/default.conf /etc/nginx/sites-available/default


RUN chmod +x /start.sh

EXPOSE 80

ENTRYPOINT ["/start.sh"]
