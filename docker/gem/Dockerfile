FROM ruby:2.7.6-bullseye

# rails/gem dependencies and development stuff
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    less \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'Etc/GMT-13' > /etc/timezone \
    && rm /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

ENV APP_PATH /app
RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH
COPY . .

CMD ["./docker/gem/scripts/publish.sh"]
