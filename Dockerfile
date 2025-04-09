FROM ruby:3.2.2-alpine3.17

ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLER_VERSION=2.5.16 \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_FORCE_RUBY_PLATFORM=1 \
    BUNDLE_PATH="/gems" \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    EXECJS_RUNTIME=Disabled

# Install system dependencies
RUN apk update && apk add --no-cache \
  build-base \
  curl \
  git \
  tzdata \
  postgresql-dev \
  nodejs \
  yarn \
  vips \
  libffi-dev \
  yaml-dev \
  zlib-dev

# Install bundler version required by Gemfile.lock
RUN gem install bundler -v "$BUNDLER_VERSION"

# Set up app directory
WORKDIR /app

# Copy Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle _${BUNDLER_VERSION}_ config set force_ruby_platform true && \
    bundle _${BUNDLER_VERSION}_ install

# Copy Node.js dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy rest of app
COPY . .

# Precompile assets
RUN mkdir -p /app/log && \
    SECRET_KEY_BASE=dummytoken bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
