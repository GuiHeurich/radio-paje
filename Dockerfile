# Stage 1: Build the Elixir release
FROM elixir:1.16.0-otp-25 AS builder

# Set target architecture for cross-compilation
ENV CC=aarch64-linux-gnu-gcc \
    CXX=aarch64-linux-gnu-g++

# Install build dependencies, including the cross-compiler toolchain
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    # Add the cross-compiler for aarch64
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu && \
    rm -rf /var/lib/apt/lists/*

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

# Set the release environment
ENV MIX_ENV=prod

# Compile assets and build the final release
RUN mix compile
RUN mix assets.deploy
# --- FIX: Use `mix release` to actually build the release ---
RUN mix release

# Stage 2: Package the release
# We use a simple image here just to hold the files for export.
# The `docker/build-push-action` will export the contents of this stage.
FROM debian:stable-slim AS release_holder

# Copy the built release from the builder stage
COPY --from=builder /app/_build/prod/rel/radio_backend /release
