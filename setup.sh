#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# LOGGING HELPERS
# ------------------------------------------------------------
info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

# ------------------------------------------------------------
# CLEANUP HANDLER
# ------------------------------------------------------------
rollback() {
    error "An error occurred. Performing git reset..."
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        git reset --hard
	git reset
    else
        error "Not a git repository — skipping reset"
    fi
    exit 1
}
trap rollback ERR INT

# ------------------------------------------------------------
# MAIN SCRIPT
# ------------------------------------------------------------
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

info "Running setup_device.sh..."
sudo BM_DEVICE_PW="${BM_DEVICE_PW:-}" "$SCRIPT_DIR/setup_device.sh"

info "Running setup_server.sh..."
BM_SITE_PW="${BM_SITE_PW:-}" "$SCRIPT_DIR/setup_server.sh"

info "Running setup_network.sh..."
BM_AP_PW="${BM_AP_PW:-}" "$SCRIPT_DIR/setup_network.sh"

success "All setup scripts completed successfully!"

info "Rebooting system..."
sudo reboot

