# Install system deps (including Node.js FIRST)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install packages needed to build gems
RUN apt-get install --no-install-recommends -y build-essential git libpq-dev libvips libyaml-dev pkg-config

# Install gems
COPY vendor/* ./vendor/
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app
COPY . .

# Bootsnap
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# NOW assets precompile (Node already exists)
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile