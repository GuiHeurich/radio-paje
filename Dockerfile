# Stage 1: Builder
# Use the official Elixir image for a stable base
FROM elixir:1.16.3-erlang-26.2.2-debian-bookworm-20240124-slim AS builder

# Set build-time arguments
ARG TARGETARCH
ARG NODE_MAJOR=20
ENV MIX_ENV=prod

# Install build dependencies: git for fetching deps, curl for Node.js, build-essential for C extensions
RUN apt-get update && apt-get install -y build-essential curl git && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && apt-get install -y nodejs

# Set the working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.rebar --force && mix local.hex --force

# --- Correct Dependency Caching Layer ---
# First, copy only the files that define your dependencies
COPY mix.exs mix.lock ./
COPY assets/package.json assets/package-lock.json ./assets/

# Then, fetch the dependencies. This layer is only rebuilt if the lockfiles change.
RUN mix deps.get --only prod
RUN mix deps.compile
RUN npm install --prefix ./assets

# --- Correct Application Code and Compilation Layer ---
# Now, copy the rest of your application source code
COPY . .

# Compile the application. This layer is rebuilt if any of your Elixir code changes.
RUN mix compile

# Build the frontend assets
RUN mix esbuild.install --if-missing
RUN mix assets.deploy

# Finally, build the release for the target architecture
RUN mix release --arch ${TARGETARCH}

# --- Stage 2: Packager ---
# This stage creates the final tarball from the clean build
FROM scratch AS packager

# Copy the entire release from the builder stage
COPY --from=builder /app/_build/prod/rel/radio_backend /

# Create the final tarball
RUN tar -czf "/radio_backend-release.tar.gz" .
