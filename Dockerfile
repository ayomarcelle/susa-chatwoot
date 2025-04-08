FROM ruby:3.2.2

# Node & Yarn for JS build
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get update -qq \
 && apt-get install -y nodejs yarn postgresql-client

# Chatwoot setup
RUN mkdir /app
WORKDIR /app
COPY . /app

RUN gem install bundler && bundle install
RUN yarn install --pure-lockfile && yarn build

ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
