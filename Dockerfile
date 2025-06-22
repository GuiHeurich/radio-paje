# Use the official Elixir image for a stable base
# This single stage will be our builder
FROM elixir:1.16.3-erlang-26.2.2-debian-bookworm-20240124-slim AS builder

# Set build-time arguments
ARG TARGETARCH
ARG NODE_MAJOR=20
ENV MIX_ENV=prod

# Install build dependencies
RUN apt-get update && apt-get install -y build-essential curl git && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && apt-get install -y nodejs

# Set the working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.rebar --force && mix local.hex --force

# --- Correct Dependency Caching Layer ---
# Copy dependency definition files
COPY mix.exs mix.lock ./
COPY assets/package.json assets/package-lock.json ./assets/

# Fetch and compile dependencies
RUN mix deps.get --only prod
RUN mix deps.compile
RUN npm install --prefix ./assets

# --- Correct Application Code and Compilation Layer ---
# Now, copy the rest of your application source code
COPY . .

# Compile the application
RUN mix compile

# Build the frontend assets
RUN mix esbuild.install --if-missing
RUN mix assets.deploy

# Build the release for the target architecture
RUN mix release --arch ${TARGETARCH}

# --- Create the final tarball IN THIS STAGE ---
# This is the final output of our build process
RUN cd _build/prod/rel/radio_backend && tar -czf "/app/radio_backend-release.tar.gz" .
