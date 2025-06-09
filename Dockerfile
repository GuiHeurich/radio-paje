FROM elixir:1.18.4-otp-27 AS builder

ARG TARGETARCH

# Install build dependencies
RUN apt-get update && apt-get install -y build-essential curl git && rm -rf /var/lib/apt/lists/*

# Install Node.js for asset compilation
ARG NODE_MAJOR=20
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash -
RUN apt-get install -y nodejs

WORKDIR /app

RUN mix local.rebar --force && mix local.hex --force

# Copy over the dependency files
COPY mix.exs mix.lock ./
COPY assets/package.json assets/package-lock.json ./assets/

# Install dependencies
RUN mix deps.get --only prod
RUN npm install --prefix ./assets

# Copy the rest of the application source code
COPY . .

# Compile assets and build the release
RUN mix esbuild.install --if-missing
RUN mix assets.deploy
RUN MIX_ENV=prod mix release --arch ${TARGETARCH}

FROM scratch AS packager

# Copy the entire release from the builder stage
COPY --from=builder /app/_build/prod/rel/radio_backend /

# Create the final tarball
RUN tar -czf "/radio_backend-release.tar.gz" .
