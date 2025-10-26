#!/usr/bin/env bash

# Shell Library for Chezmoi Scripts
# Provides logging functions with emoji and colors

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m' # No Color

# Text formatting
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# Log level definitions
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_SUCCESS=4

# Default log level (can be overridden by environment variable)
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Core logging function
_log() {
    local level="$1"
    local emoji="$2"
    local color="$3"
    local message="$4"

    if [[ $level -ge $LOG_LEVEL ]]; then
        printf "${color}${emoji} [%s] %s${NC}\n" "$(get_timestamp)" "$message" >&2
    fi
}

# Debug logging (gray color, 🔍 emoji)
log_debug() {
    _log $LOG_LEVEL_DEBUG "🔍" "$GRAY" "$*"
}

# Info logging (blue color, ℹ️ emoji)
log_info() {
    _log $LOG_LEVEL_INFO "ℹ️ " "$BLUE" "$*"
}

# Warning logging (yellow color, ⚠️ emoji)
log_warn() {
    _log $LOG_LEVEL_WARN "⚠️ " "$YELLOW" "$*"
}

# Error logging (red color, ❌ emoji)
log_error() {
    _log $LOG_LEVEL_ERROR "❌" "$RED" "$*"
}

# Success logging (green color, ✅ emoji)
log_success() {
    _log $LOG_LEVEL_SUCCESS "✅" "$GREEN" "$*"
}

# Progress logging (cyan color, 🔄 emoji)
log_progress() {
    _log $LOG_LEVEL_INFO "🔄" "$CYAN" "$*"
}

# Step logging (purple color, 📋 emoji)
log_step() {
    _log $LOG_LEVEL_INFO "📋" "$PURPLE" "$*"
}

# Header logging (bold white color, 📁 emoji)
log_header() {
    echo
    printf "${WHITE}📁 [%s] ${BOLD}=== %s ===${RESET}\n" "$(get_timestamp)" "$*" >&2
    echo
}

# Set log level function
set_log_level() {
    case "$1" in
        "debug"|"DEBUG"|0)
            LOG_LEVEL=$LOG_LEVEL_DEBUG
            ;;
        "info"|"INFO"|1)
            LOG_LEVEL=$LOG_LEVEL_INFO
            ;;
        "warn"|"WARN"|2)
            LOG_LEVEL=$LOG_LEVEL_WARN
            ;;
        "error"|"ERROR"|3)
            LOG_LEVEL=$LOG_LEVEL_ERROR
            ;;
        "success"|"SUCCESS"|4)
            LOG_LEVEL=$LOG_LEVEL_SUCCESS
            ;;
        *)
            log_error "Invalid log level: $1. Valid levels: debug, info, warn, error, success"
            return 1
            ;;
    esac
    log_info "Log level set to: $1"
}

# Check if running in CI environment
is_ci() {
    [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ -n "${GITLAB_CI:-}" ]]
}

# Disable colors in CI environment
if is_ci; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    WHITE=''
    GRAY=''
    NC=''
    BOLD=''
    RESET=''
fi

# Export functions for use in other scripts
export -f log_debug log_info log_warn log_error log_success log_progress log_step log_header set_log_level
