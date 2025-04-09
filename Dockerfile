FROM ruby:3.2.2-alpine

# Set envs
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV BUNDLER_VERSION=2.5.6
ENV BUNDLE_WITHOUT="development:test"
ENV BUNDLE_PATH="/gems"
ENV BUNDLE_FORCE_RUBY_PLATFORM=1
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

# Install dependencies
RUN apk update && apk add --no-cache \
  build-base postgresql-dev git curl tzdata \
  nodejs npm yarn vips libffi-dev yaml-dev zlib-dev

# Install bundler
RUN gem install bundler -v $BUNDLER_VERSION

# Create app dir
WORKDIR /app

# Copy gem files and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle _2.5.6_ config set force_ruby_platform true && \
    bundle _2.5.6_ install

# Copy node dependencies and install with pnpm
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install

# Copy the rest of the app
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# Expose port
EXPOSE 3000

# Start command
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
