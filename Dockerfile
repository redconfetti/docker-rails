FROM ruby:3.0.4-buster

LABEL maintainer="jason@redconfetti.com"

# Ensure latest version of Node installed
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

# Ensure latest Yarn package installed
ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg
RUN echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
    nodejs \
    yarn

RUN mkdir -p /usr/src/app
COPY Gemfile* /usr/src/app
WORKDIR /usr/src/app
RUN bundle install

COPY . /usr/src/app

CMD ["bin/rails", "s", "-b", "0.0.0.0"]
