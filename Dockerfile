# The BUILD_ENVIRONMENT arg can either
# be 'development' or 'production'.
# The default value is 'development'
ARG BUILD_ENVIRONMENT=development
FROM ruby:3.3-alpine as base

WORKDIR /app

EXPOSE 3000

RUN gem uninstall bundler
RUN gem install bundler --version 2.5.5

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

FROM base as builder
RUN apk add --update build-base

FROM builder as development_stage
RUN echo 'development environment'
ENV APP_ENV=development

FROM builder as production_stage
RUN echo 'production environment'
ENV APP_ENV=production
RUN bundle config set deployment true

# We don't want the build-base packages in the final
# image of production build. So if the build arg
# BUILD_ENVIRONMENT is passed as `production` then
# it will run `bundle install --deployment`
# We are aliasing our build as current_build, thus
# we can COPY from `current_build` in the
# final_build stage
FROM ${BUILD_ENVIRONMENT}_stage as current_build
RUN bundle install
COPY . /app

FROM base as final_build
COPY --from=current_build /app /app

CMD ["bundle", "exec", "ruby", "main.rb"]
