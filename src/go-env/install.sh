#!/bin/bash
set -e

# Logging mechanism for debugging
LOG_FILE="/tmp/go-env-install.log"
log_debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] $*" >> "$LOG_FILE"
}

# Initialize logging
log_debug "=== GO-ENV INSTALL STARTED ==="
log_debug "Script path: $0"
log_debug "PWD: $(pwd)"
log_debug "Environment: USER=$USER HOME=$HOME"

# Go Environment Fragment - Detects official DevContainer Go feature installation
echo "Creating Go environment fragment..."

# Get username from environment or default to babaji
USERNAME=${USERNAME:-"babaji"}
USER_HOME="/home/${USERNAME}"

# 🧩 Create Self-Healing Environment Fragment
create_environment_fragment() {
    local feature_name="go-env"
    local fragment_file_skel="/etc/skel/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc"
    local fragment_file_user="$USER_HOME/.ohmyzsh_source_load_scripts/.${feature_name}.zshrc"
    
    # Create fragment content with self-healing detection
    local fragment_content='# 🐹 Go Environment Fragment
# Self-healing detection and environment setup for official DevContainer Go feature

# Check if Go is available
go_available=false

# Check for Go in common DevContainer locations
for go_path in "/usr/local/go/bin" "/go/bin" "/usr/bin" "/usr/local/bin"; do
    if [ -d "$go_path" ] && [ -x "$go_path/go" ]; then
        if [[ ":$PATH:" != *":$go_path:"* ]]; then
            export PATH="$go_path:$PATH"
        fi
        go_available=true
        break
    fi
done

# If Go is found, set up Go environment
if command -v go >/dev/null 2>&1; then
    go_available=true
    
    # Set GOPATH if not already set
    if [ -z "$GOPATH" ]; then
        export GOPATH="$HOME/go"
        mkdir -p "$GOPATH"
    fi
    
    # Add GOPATH/bin to PATH
    if [ -d "$GOPATH/bin" ] && [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
        export PATH="$GOPATH/bin:$PATH"
    fi
    
    # Set GOROOT if Go is in a non-standard location
    GO_VERSION_OUTPUT="$(go version 2>/dev/null || true)"
    if [ -n "$GO_VERSION_OUTPUT" ]; then
        GOROOT="$(go env GOROOT 2>/dev/null || true)"
        if [ -n "$GOROOT" ]; then
            export GOROOT
        fi
    fi
fi

# If Go is not available, cleanup this fragment
if [ "$go_available" = false ]; then
    echo "Go removed, cleaning up environment"
    rm -f "$HOME/.ohmyzsh_source_load_scripts/.go-env.zshrc"
fi'

    # Create fragment for /etc/skel
    if [ -d "/etc/skel/.ohmyzsh_source_load_scripts" ]; then
        echo "$fragment_content" > "$fragment_file_skel"
    fi

    # Create fragment for existing user
    if [ -d "$USER_HOME/.ohmyzsh_source_load_scripts" ]; then
        echo "$fragment_content" > "$fragment_file_user"
        if [ "$USER" != "$USERNAME" ]; then
            chown ${USERNAME}:${USERNAME} "$fragment_file_user" 2>/dev/null || chown ${USERNAME}:users "$fragment_file_user" 2>/dev/null || true
        fi
    elif [ -d "$USER_HOME" ]; then
        # Create the directory if it doesn't exist
        mkdir -p "$USER_HOME/.ohmyzsh_source_load_scripts"
        echo "$fragment_content" > "$fragment_file_user"
        if [ "$USER" != "$USERNAME" ]; then
            chown -R ${USERNAME}:${USERNAME} "$USER_HOME/.ohmyzsh_source_load_scripts" 2>/dev/null || chown -R ${USERNAME}:users "$USER_HOME/.ohmyzsh_source_load_scripts" 2>/dev/null || true
        fi
    fi
    
    echo "Self-healing environment fragment created: .go-env.zshrc"
}

# Call the fragment creation function
create_environment_fragment

echo "Go environment fragment installation completed."

log_debug "=== GO-ENV INSTALL COMPLETED ==="
# Auto-trigger build Tue Sep 23 20:03:14 BST 2025
# Auto-trigger build Sun Sep 28 03:45:20 BST 2025
