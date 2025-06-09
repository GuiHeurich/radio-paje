FROM elixir:1.18.4-otp-27 AS builder

ARG TARGETARCH

# Install build dependencies
ENV CC=aarch64-linux-gnu-gcc \
    CXX=aarch64-linux-gnu-g++ \
    KERL_CONFIGURE_OPTIONS="--host=aarch64-linux-gnu --build=x86_64-pc-linux-gnu"

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

# Compile assets and build the release
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix assets.deploy
RUN MIX_ENV=prod mix phx.gen.release

FROM scratch AS packager

# Copy the entire release from the builder stage
COPY --from=builder /app/_build/prod/rel/radio_backend /

# Create the final tarball
RUN tar -czf "/radio_backend-release.tar.gz" .
