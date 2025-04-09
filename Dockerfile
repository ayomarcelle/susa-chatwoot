FROM ruby:3.2.2-alpine3.17

ENV BUNDLER_VERSION=2.5.16
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV BUNDLE_WITHOUT="development:test"
ENV BUNDLE_PATH="/gems"
ENV BUNDLE_FORCE_RUBY_PLATFORM=1

# Install base packages
RUN apk add --no-cache \
  build-base \
  curl \
  git \
  postgresql-dev \
  tzdata \
  yaml-dev \
  zlib-dev \
  libffi-dev \
  vips \
  nodejs=18.19.1-r0 \
  npm \
  && gem install bundler -v 2.5.16
  
WORKDIR /app

# Copy Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config set force_ruby_platform true \
  && bundle install

# Copy JS dependencies
COPY package.json pnpm-lock.yaml ./

# Install PNPM and deps
RUN npm install -g pnpm@8.15.4 \
  && pnpm install

# Copy rest of app
COPY . .

# Precompile assets
RUN mkdir -p /app/log \
  && SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
