#!/usr/bin/env bash
# scripts/update-charts.sh
# Checks for upstream image updates and bumps Helm chart versions automatically.

# Repository Root
REPO_ROOT=$(git rev-parse --show-toplevel)
UPDATES_FOUND=""
ERRORS_FOUND=""

# Fetch latest version from different sources
fetch_latest() {
    local source_type=$1
    local source_data=$2
    local version=""

    case "$source_type" in
        "github-release")
            version=$(curl -sL "https://api.github.com/repos/$source_data/releases/latest" | jq -r '.tag_name // empty')
            ;;
        "dockerhub-tags")
            version=$(curl -s "https://registry.hub.docker.com/v2/repositories/$source_data/tags?page_size=100" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V -r | head -1)
            ;;
        "dockerhub-tags-pattern")
            local repo="${source_data%%:*}"
            local pattern="${source_data#*:}"
            version=$(curl -s "https://registry.hub.docker.com/v2/repositories/$repo/tags?page_size=100" | jq -r '.results[].name' | grep -E "$pattern" | sort -V -r | head -1)
            ;;
        *)
            return 1
            ;;
    esac
    echo "$version"
}

# Apply sed pattern if provided
apply_pattern() {
    local version=$1
    local pattern=$2
    if [ -z "$pattern" ]; then
        echo "$version"
    else
        echo "$version" | sed "$pattern"
    fi
}

# Bump semver patch version (0.1.9 -> 0.1.10)
bump_version() {
    local version=$1
    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"
    patch=$((patch + 1))
    echo "$major.$minor.$patch"
}

# Main loop through charts
for chart_dir in "$REPO_ROOT"/*/; do
    chart_yaml="$chart_dir/Chart.yaml"
    [ -f "$chart_yaml" ] || continue

    chart_name=$(basename "$chart_dir")
    echo "Checking chart: $chart_name"

    # Parse metadata
    source_type=$(grep "version-source:" "$chart_yaml" | sed 's/.*version-source: *//' | tr -d ' ' || true)
    source_pattern=$(grep "version-pattern:" "$chart_yaml" | sed 's/.*version-pattern: *//' | sed 's/^"\(.*\)"$/\1/' || true)
    current_app_version=$(grep "^appVersion:" "$chart_yaml" | head -1 | sed 's/.*appVersion: *"\([^"]*\)".*/\1/' || true)
    current_chart_version=$(grep "^version:" "$chart_yaml" | head -1 | sed 's/.*version: *//' | tr -d ' ' || true)

    if [ -z "$source_type" ]; then
        echo "  Skipping: No version-source found."
        continue
    fi

    # Fetch and clean latest
    echo "  Source image: $source_type"
    if ! latest_raw=$(fetch_latest "${source_type%%:*}" "${source_type#*:}" 2>&1); then
        echo "  Error: Unsupported source type '${source_type%%:*}'."
        ERRORS_FOUND="$ERRORS_FOUND\n- **$chart_name**: unsupported source type '${source_type%%:*}'"
        continue
    fi

    latest_clean=$(apply_pattern "$latest_raw" "$source_pattern")

    if [ -z "$latest_clean" ]; then
        echo "  Error: Could not fetch latest version."
        ERRORS_FOUND="$ERRORS_FOUND\n- **$chart_name**: could not fetch latest version from $source_type"
        continue
    fi

    echo "  Current: $current_app_version | Latest: $latest_clean"

    # Compare and Update
    if [ "$current_app_version" != "$latest_clean" ]; then
        new_chart_version=$(bump_version "$current_chart_version")
        echo "  🚀 Update found! Bumping to App: $latest_clean | Chart: $new_chart_version"

        # Update Chart.yaml
        sed -i.bak \
            -e "s|^appVersion:.*|appVersion: \"$latest_clean\"|" \
            -e "s|^version:.*|version: $new_chart_version|" \
            "$chart_yaml"
        rm -f "$chart_yaml.bak"

        UPDATES_FOUND="$UPDATES_FOUND\n- **$chart_name**: $current_app_version ➔ $latest_clean (Chart v$new_chart_version)"
    else
        echo "  Up to date."
    fi
done

# Output summary for GH Actions
if [ -n "$UPDATES_FOUND" ]; then
    echo -e "$UPDATES_FOUND" > "$REPO_ROOT/update_summary.txt"
fi

if [ -n "$ERRORS_FOUND" ]; then
    echo -e "$ERRORS_FOUND" > "$REPO_ROOT/errors_summary.txt"
fi

exit 0
