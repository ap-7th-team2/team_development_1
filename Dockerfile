FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  node.js \
  npm \
  default-mysql-client

ENV APP_ROOT /team_development_1

WORKDIR ${APP_ROOT}

COPY Gemfile ${APP_ROOT}/Gemfile
COPY Gemfile.lock ${APP_ROOT}/Gemfile.lock

RUN bundle install

COPY . ${APP_ROOT}

CMD [ "ruby", "server.rb" ]
