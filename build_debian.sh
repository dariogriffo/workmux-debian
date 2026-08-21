workmux_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$workmux_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <workmux_version> <build_version> [architecture]"
    echo "Example: $0 0.1.243 1 arm64"
    echo "Example: $0 0.1.243 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Upstream tags carry a "v" prefix (e.g. v0.1.243).
UPSTREAM_URL="https://github.com/raine/workmux/releases/download/v${workmux_VERSION}"

# Completions are generated from the amd64 binary; they do not depend on the
# target architecture.
COMPLETIONS_RELEASE="workmux-linux-amd64"

# Function to map Debian architecture to the workmux release asset name.
# Upstream names its Linux assets after the Go architecture spelling, which
# happens to match Debian's for the two architectures it publishes. Both are
# statically linked, so they run on every suite we target and need no
# library dependencies.
get_workmux_release() {
    local arch=$1
    case "$arch" in
        "amd64") echo "workmux-linux-amd64" ;;
        "arm64") echo "workmux-linux-arm64" ;;
        *)       echo "" ;;
    esac
}

# The release tarballs contain a bare "workmux" binary with no top-level
# directory, so they are always extracted into a directory we create.
download_release() {
    local release=$1

    rm -rf "$release" || true
    rm -f "${release}.tar.gz" || true

    if ! wget -q "${UPSTREAM_URL}/${release}.tar.gz"; then
        echo "❌ Failed to download ${release}.tar.gz"
        return 1
    fi

    mkdir -p "$release"
    if ! tar -xf "${release}.tar.gz" -C "$release"; then
        echo "❌ Failed to extract ${release}.tar.gz"
        return 1
    fi
    rm -f "${release}.tar.gz"

    if [ ! -f "$release/workmux" ]; then
        echo "❌ Unexpected tarball layout for $release (missing workmux binary)"
        return 1
    fi
    chmod +x "$release/workmux"
}

# Generate the shell completions once, from the amd64 binary.
generate_completions() {
    if [ -f completions/workmux.bash ] && [ -f completions/workmux.fish ] && [ -f completions/_workmux ]; then
        echo "Using existing completions/"
        return 0
    fi

    echo "Generating shell completions from ${COMPLETIONS_RELEASE}..."
    rm -rf completions || true
    mkdir -p completions

    if ! download_release "$COMPLETIONS_RELEASE"; then
        echo "❌ Failed to download ${COMPLETIONS_RELEASE} for completion generation"
        return 1
    fi

    "./${COMPLETIONS_RELEASE}/workmux" completions bash > completions/workmux.bash
    "./${COMPLETIONS_RELEASE}/workmux" completions zsh  > completions/_workmux
    "./${COMPLETIONS_RELEASE}/workmux" completions fish > completions/workmux.fish
    rm -rf "$COMPLETIONS_RELEASE"

    for f in completions/workmux.bash completions/_workmux completions/workmux.fish; do
        if [ ! -s "$f" ]; then
            echo "❌ Completion file $f is empty"
            return 1
        fi
    done
    echo "✅ Completions generated"
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local workmux_release

    workmux_release=$(get_workmux_release "$build_arch")
    if [ -z "$workmux_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $workmux_release"

    if ! download_release "$workmux_release"; then
        echo "❌ Failed to prepare workmux binary for $build_arch"
        return 1
    fi

    # Upstream ships static Linux binaries for amd64/arm64 only, and both work
    # on every Debian suite we target.
    declare -a arr=("bookworm" "trixie" "forky" "sid")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$workmux_VERSION-${BUILD_VERSION}~${dist}_${build_arch}"
        echo "  Building $FULL_VERSION"

        if ! docker build . -t "workmux-$dist-$build_arch" \
            --build-arg DEBIAN_DIST="$dist" \
            --build-arg workmux_VERSION="$workmux_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg WM_RELEASE="$workmux_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "workmux-$dist-$build_arch")"
        if ! docker cp "$id:/workmux_$FULL_VERSION.deb" - > "./workmux_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./workmux_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up extracted directory
    rm -rf "$workmux_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

if ! generate_completions; then
    exit 1
fi

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building workmux $workmux_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la workmux_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
