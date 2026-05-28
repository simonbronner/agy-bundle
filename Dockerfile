# ==========================================
# Builder Stage: Download and Verify Binaries
# ==========================================
FROM debian:bookworm-slim AS builder

# Install dependencies needed for downloading and verifying files
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Retrieve and stage agy binaries for all supported platforms
RUN set -ex; \
    BASE_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests"; \
    for platform in darwin_amd64 darwin_arm64 linux_amd64 linux_arm64 windows_amd64; do \
        # Fetch manifest JSON \
        manifest=$(curl -fsSL "$BASE_URL/$platform.json"); \
        url=$(echo "$manifest" | jq -r '.url'); \
        sha512=$(echo "$manifest" | jq -r '.sha512'); \
        \
        # Convert platform underscore names (e.g., darwin_arm64 -> darwin-arm64) \
        target_dir="/dist/$(echo "$platform" | sed 's/_/-/')"; \
        mkdir -p "$target_dir"; \
        \
        # Download and verify checksum \
        echo "Downloading $platform from $url..."; \
        curl -fsSL -o "temp_file" "$url"; \
        actual_hash=$(sha512sum "temp_file" | cut -d' ' -f1); \
        if [ "$actual_hash" != "$sha512" ]; then \
            echo "Security Halt: Checksum verification failed for $platform!"; \
            exit 1; \
        fi; \
        \
        # Extract and bundle \
        if echo "$url" | grep -q "\.tar\.gz$"; then \
            tar -xzf "temp_file" -C "$target_dir"; \
            # The archive contains a binary named 'antigravity'. Rename it to 'agy' for consistency \
            if [ -f "$target_dir/antigravity" ]; then \
                mv "$target_dir/antigravity" "$target_dir/agy"; \
            fi; \
            chmod +x "$target_dir/agy"; \
        else \
            # Windows direct binary download \
            mv "temp_file" "$target_dir/agy.exe"; \
        fi; \
        rm -f temp_file; \
    done

# ==========================================
# Final Stage: Lightweight Distribution Image
# ==========================================
FROM alpine:latest

# Copy the bundled binaries from the builder stage
COPY --from=builder /dist /dist

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run entrypoint script by default
ENTRYPOINT ["/entrypoint.sh"]
