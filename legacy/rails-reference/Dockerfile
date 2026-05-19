FROM --platform=linux/amd64 ruby:2.2.4

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle \
    PATH=/bundle/bin:$PATH \
    RAILS_ENV=development

RUN sed -i \
      -e 's/deb.debian.org/archive.debian.org/g' \
      -e 's/security.debian.org/archive.debian.org/g' \
      -e '/jessie-updates/d' \
      /etc/apt/sources.list \
  && apt-get -o Acquire::Check-Valid-Until=false update \
  && apt-get install -y --no-install-recommends \
      git \
      imagemagick \
      libpq-dev \
      nodejs \
      postgresql-client \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# The legacy Gemfile uses git:// for irwi. Modern GitHub requires HTTPS.
RUN git config --global url."https://github.com/".insteadOf git://github.com/

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 1.12.5 --no-document \
  && bundle _1.12.5_ install --jobs=4 --retry=3

COPY . .
RUN cp config/database.docker.yml config/database.yml \
  && cp config/sunspot.docker.yml config/sunspot.yml \
  && chmod +x bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

