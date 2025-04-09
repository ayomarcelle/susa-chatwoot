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

# Install required system packages
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    git \
    curl \
    tzdata \
    nodejs \
    yarn \
    vips \
    libffi-dev \
    yaml-dev \
    zlib-dev

# Install required bundler version
RUN gem install bundler -v "$BUNDLER_VERSION"

WORKDIR /app

# Copy and install Ruby deps
COPY Gemfile Gemfile.lock ./
RUN bundle _${BUNDLER_VERSION}_ config set force_ruby_platform true && \
    bundle _${BUNDLER_VERSION}_ install

# Copy and install Node deps
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy app files
COPY . .

# Compile assets
RUN mkdir -p /app/log && \
    SECRET_KEY_BASE=dummytoken bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
