FROM ruby:3.0.4-buster

LABEL maintainer="jason@redconfetti.com"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
    nodejs

RUN mkdir -p /usr/src/app
COPY Gemfile* /usr/src/app
WORKDIR /usr/src/app
RUN bundle install

COPY . /usr/src/app

CMD ["bin/rails", "s", "-b", "0.0.0.0"]
