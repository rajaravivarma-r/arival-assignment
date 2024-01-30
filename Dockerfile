FROM ruby:3.3-alpine

WORKDIR /app

EXPOSE 3000

RUN apk add --update build-base postgresql-dev

RUN gem uninstall bundler
RUN gem install bundler --version 2.5.5

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install

COPY . /app


CMD ["bundle", "exec", "puma", "--port", "3000", "--bind", "tcp://0.0.0.0"]
