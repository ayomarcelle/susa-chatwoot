FROM ruby:3.2.2-alpine3.17

ARG NODE_VERSION="18.18.0"
ARG PNPM_VERSION="8.15.4"

ENV NODE_VERSION=${NODE_VERSION}
ENV PNPM_VERSION=${PNPM_VERSION}
ENV BUNDLE_WITHOUT="development:test"
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV BUNDLE_PATH="/gems"
ENV EXECJS_RUNTIME="Disabled"
ENV BUNDLE_FORCE_RUBY_PLATFORM=1
ENV NODE_OPTIONS="--max-old-space-size=4096 --openssl-legacy-provider"
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Install dependencies
RUN apk update && apk add --no-cache \
  curl git xz tzdata build-base postgresql-dev postgresql-client \
  openssl imagemagick vips ruby-full ruby-dev gcc make musl-dev linux-headers \
  libffi-dev yaml-dev zlib-dev gcompat

# Install Bundler
RUN gem install bundler -v 2.5.16

# Install Node manually (musl-compatible)
RUN curl -fsSL https://unofficial-builds.nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64-musl.tar.xz \
  | tar -xJf - -C /usr/local --strip-components=1

# Install PNPM
RUN npm install -g pnpm@${PNPM_VERSION}

WORKDIR /app

# Install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set force_ruby_platform true \
 && bundle install

# Install Node packages
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# Copy the rest of the app
COPY . .

# Precompile assets
RUN mkdir -p /app/log \
 && SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
