#!/bin/bash
# =============================================================================
# AuthVault - Android Keystore Setup Script
# Creates and manages Android signing keystore for release builds
# Copyright 2025-2026 AuthVault Team
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYSTORE_DIR="$SCRIPT_DIR/keystore"

# Sudo password
SUDO_PASS="LO3QERKYFWAVIRZQS7JNHNHKMGCIZTRB"

# Default values
DEFAULT_KEY_ALIAS="authvault"
DEFAULT_KEY_VALIDITY=10000  # days (~27 years)
DEFAULT_STORE_PASS=""
DEFAULT_KEY_PASS=""

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  AuthVault - Android Keystore Setup                         ║${NC}"
    echo -e "${CYAN}║  Create and manage signing keys for Android releases        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_step() { echo -e "${CYAN}▸${NC} $1"; }

sudo_cmd() {
    if echo "$SUDO_PASS" | sudo -S echo "" 2>/dev/null; then
        echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null
    else
        "$@" 2>/dev/null || true
    fi
}

# =============================================================================
# Keystore Functions
# =============================================================================

check_java() {
    print_step "Checking Java installation..."
    
    if ! command -v keytool &> /dev/null; then
        print_error "keytool not found. Installing Java..."
        sudo_cmd apt-get update -qq 2>/dev/null || true
        sudo_cmd apt-get install -y default-jdk 2>/dev/null || true
        
        if ! command -v keytool &> /dev/null; then
            print_error "Java installation failed. Please install manually:"
            echo "  sudo apt-get install default-jdk"
            return 1
        fi
    fi
    
    print_status "Java installed: $(java -version 2>&1 | head -1)"
    return 0
}

check_existing_keystore() {
    if [ -f "$KEYSTORE_DIR/authvault.keystore" ]; then
        print_warning "Existing keystore found!"
        echo ""
        echo "  Location: $KEYSTORE_DIR/authvault.keystore"
        echo ""
        print_info "Options:"
        echo "  1) Use existing keystore"
        echo "  2) Create new keystore (will backup existing)"
        echo "  3) View keystore info"
        echo "  4) Exit"
        echo ""
        read -p "Select option (1-4): " choice
        
        case "$choice" in
            1)
                print_status "Using existing keystore"
                return 0
                ;;
            2)
                print_step "Backing up existing keystore..."
                local backup_name="authvault.keystore.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$KEYSTORE_DIR/authvault.keystore" "$KEYSTORE_DIR/$backup_name"
                cp "$KEYSTORE_DIR/.keystore_pass" "$KEYSTORE_DIR/.keystore_pass.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
                print_status "Backup created: $backup_name"
                return 1  # Signal to create new
                ;;
            3)
                if [ -f "$KEYSTORE_DIR/.keystore_pass" ]; then
                    local pass=$(cat "$KEYSTORE_DIR/.keystore_pass")
                    keytool -list -v -keystore "$KEYSTORE_DIR/authvault.keystore" -storepass "$pass" 2>/dev/null || \
                    keytool -list -v -keystore "$KEYSTORE_DIR/authvault.keystore" 2>&1 | head -20
                else
                    keytool -list -v -keystore "$KEYSTORE_DIR/authvault.keystore" 2>&1 | head -20
                fi
                exit 0
                ;;
            4)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
    else
        return 1  # No existing keystore
    fi
}

get_password() {
    local prompt="$1"
    local confirm="$2"
    local password=""
    local confirm_password=""
    
    echo ""
    read -sp "$prompt" password
    echo ""
    
    if [ -n "$confirm" ]; then
        read -sp "Confirm password: " confirm_password
        echo ""
        
        if [ "$password" != "$confirm_password" ]; then
            print_error "Passwords do not match!"
            return 1
        fi
    fi
    
    echo "$password"
}

generate_keystore() {
    print_step "Generating Android signing keystore..."
    echo ""
    
    # Ensure keystore directory exists
    mkdir -p "$KEYSTORE_DIR"
    
    # Get keystore password
    print_info "Choose a strong password for the keystore"
    print_info "Minimum 6 characters, mix of letters and numbers recommended"
    echo ""
    
    local store_pass=""
    local key_pass=""
    
    # Try to get password interactively if terminal supports it
    if [ -t 0 ]; then
        store_pass=$(get_password "Enter keystore password: " "confirm")
        key_pass=$(get_password "Enter key password (or same as keystore): " "")
        
        if [ -z "$key_pass" ]; then
            key_pass="$store_pass"
        fi
    else
        # Non-interactive mode - generate random password
        print_info "Non-interactive mode - generating secure random password"
        store_pass=$(openssl rand -base64 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%' | head -c 32)
        key_pass="$store_pass"
    fi
    
    if [ -z "$store_pass" ] || [ ${#store_pass} -lt 6 ]; then
        print_error "Password must be at least 6 characters!"
        return 1
    fi
    
    # Generate keystore
    print_step "Creating keystore with keytool..."
    
    keytool -genkey -v \
        -keystore "$KEYSTORE_DIR/authvault.keystore" \
        -alias "$DEFAULT_KEY_ALIAS" \
        -keyalg RSA \
        -keysize 2048 \
        -validity $DEFAULT_KEY_VALIDITY \
        -storepass "$store_pass" \
        -keypass "$key_pass" \
        -dname "CN=AuthVault, OU=Mobile, O=AuthVault Labs, L=Jakarta, ST=Jakarta, C=ID" \
        2>&1 | tee /tmp/keystore-gen.log
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        print_status "Keystore generated successfully!"
        
        # Save password securely
        echo "$store_pass" > "$KEYSTORE_DIR/.keystore_pass"
        chmod 600 "$KEYSTORE_DIR/.keystore_pass"
        
        # Set permissions
        chmod 600 "$KEYSTORE_DIR/authvault.keystore"
        
        print_status "Password saved to: $KEYSTORE_DIR/.keystore_pass"
        
        return 0
    else
        print_error "Failed to generate keystore"
        return 1
    fi
}

# =============================================================================
# Gradle Configuration
# =============================================================================

setup_gradle_config() {
    print_step "Configuring Gradle for signing..."
    echo ""
    
    local flutter_dir="$SCRIPT_DIR/../flutter"
    local android_dir="$flutter_dir/android"
    local gradle_file="$android_dir/app/build.gradle"
    local key_properties="$android_dir/key.properties"
    
    if [ ! -d "$android_dir" ]; then
        print_warning "Android directory not found: $android_dir"
        return 0
    fi
    
    # Create key.properties
    print_info "Creating key.properties..."
    cat > "$key_properties" << EOF
storePassword=$(cat "$KEYSTORE_DIR/.keystore_pass")
keyPassword=$(cat "$KEYSTORE_DIR/.keystore_pass")
keyAlias=$DEFAULT_KEY_ALIAS
storeFile=../key.properties
EOF
    
    # Make key.properties readable only by owner
    chmod 600 "$key_properties"
    
    print_status "key.properties created"
    
    # Check if build.gradle has signing config
    if grep -q "signingConfigs" "$gradle_file" 2>/dev/null; then
        print_status "Gradle already has signing configuration"
    else
        print_info "Manual Gradle configuration required"
        echo ""
        echo "Add this to $gradle_file:"
        echo ""
        echo "android {"
        echo "    signingConfigs {"
        echo "        release {"
        echo "            keyAlias 'authvault'"
        echo "            keyPassword System.properties['keyPassword']"
        echo "            storeFile file('../keystore/authvault.keystore')"
        echo "            storePassword System.properties['storePassword']"
        echo "        }"
        echo "    }"
        echo "    buildTypes {"
        echo "        release {"
        echo "            signingConfig signingConfigs.release"
        echo "        }"
        echo "    }"
        echo "}"
        echo ""
    fi
    
    return 0
}

# =============================================================================
# Backup Functions
# =============================================================================

backup_keystore() {
    print_step "Creating keystore backup..."
    echo ""
    
    local backup_dir="$KEYSTORE_DIR/backups"
    mkdir -p "$backup_dir"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="authvault_backup_$timestamp"
    
    # Backup keystore
    cp "$KEYSTORE_DIR/authvault.keystore" "$backup_dir/$backup_name.keystore"
    
    # Backup password
    if [ -f "$KEYSTORE_DIR/.keystore_pass" ]; then
        cp "$KEYSTORE_DIR/.keystore_pass" "$backup_dir/$backup_name.pass"
    fi
    
    # Create backup archive
    cd "$backup_dir"
    tar -czf "$backup_name.tar.gz" "$backup_name.keystore" "$backup_name.pass" 2>/dev/null || \
    tar -czf "$backup_name.tar.gz" "$backup_name.keystore" 2>/dev/null || true
    
    print_status "Backup created:"
    echo "  - $backup_dir/$backup_name.tar.gz"
    echo "  - $backup_dir/$backup_name.keystore"
    echo ""
    print_warning "IMPORTANT: Store backup in a secure location (offline recommended)"
    print_warning "Losing the keystore means you cannot update your app on Play Store!"
    
    return 0
}

# =============================================================================
# Info Functions
# =============================================================================

show_keystore_info() {
    print_step "Keystore Information..."
    echo ""
    
    if [ ! -f "$KEYSTORE_DIR/authvault.keystore" ]; then
        print_error "Keystore not found!"
        return 1
    fi
    
    echo "Location: $KEYSTORE_DIR/authvault.keystore"
    echo "Alias: $DEFAULT_KEY_ALIAS"
    echo "Validity: $DEFAULT_KEY_VALIDITY days (~$(( DEFAULT_KEY_VALIDITY / 365 )) years)"
    echo ""
    
    if [ -f "$KEYSTORE_DIR/.keystore_pass" ]; then
        local pass=$(cat "$KEYSTORE_DIR/.keystore_pass")
        print_info "Listing keystore contents..."
        keytool -list -v -keystore "$KEYSTORE_DIR/authvault.keystore" -storepass "$pass" 2>/dev/null || \
        keytool -list -keystore "$KEYSTORE_DIR/authvault.keystore" 2>&1 | head -20
    else
        print_warning "Password file not found"
        keytool -list -keystore "$KEYSTORE_DIR/authvault.keystore" 2>&1 | head -20
    fi
    
    echo ""
    return 0
}

verify_signature() {
    local apk_file="$1"
    
    if [ -z "$apk_file" ] || [ ! -f "$apk_file" ]; then
        print_error "APK file not found: $apk_file"
        return 1
    fi
    
    print_step "Verifying APK signature..."
    echo ""
    
    # Check for apksigner
    if command -v apksigner &> /dev/null; then
        apksigner verify --verbose "$apk_file" 2>&1 | tee /tmp/apk-verify.log
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            print_status "APK signature verified!"
            return 0
        else
            print_error "APK signature verification failed"
            return 1
        fi
    else
        print_warning "apksigner not found, using jarsigner..."
        jarsigner -verify -verbose -certs "$apk_file" 2>&1 | head -20
        print_info "Install apksigner for better verification:"
        echo "  sudo apt-get install apksigner"
        return 0
    fi
}

# =============================================================================
# Main Flow
# =============================================================================

main() {
    print_header
    
    local action="${1:-setup}"
    
    case "$action" in
        setup|create)
            check_java || exit 1
            echo ""
            
            if ! check_existing_keystore; then
                generate_keystore
                if [ $? -eq 0 ]; then
                    backup_keystore
                    setup_gradle_config
                    
                    echo ""
                    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
                    echo -e "${GREEN}║  Keystore Setup Complete!                                   ║${NC}"
                    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
                    echo ""
                    print_info "Keystore location: $KEYSTORE_DIR/authvault.keystore"
                    print_info "Password file: $KEYSTORE_DIR/.keystore_pass"
                    echo ""
                    print_warning "BACKUP YOUR KEYSTORE IMMEDIATELY!"
                    print_warning "Without it, you cannot update your app on Play Store!"
                    echo ""
                    print_info "To build signed APKs:"
                    echo "  ./scripts/auto-build.sh android release"
                    echo ""
                fi
            else
                echo ""
                print_status "Keystore already configured"
                show_keystore_info
            fi
            ;;
        
        info)
            show_keystore_info
            ;;
        
        backup)
            backup_keystore
            ;;
        
        verify)
            if [ -n "$2" ]; then
                verify_signature "$2"
            else
                print_error "Please specify APK file to verify"
                echo "Usage: $0 verify <apk-file>"
                exit 1
            fi
            ;;
        
        help|--help|-h)
            echo "Usage: $0 [action]"
            echo ""
            echo "Actions:"
            echo "  setup, create  - Create new keystore (default)"
            echo "  info           - Show keystore information"
            echo "  backup         - Create backup of keystore"
            echo "  verify <apk>   - Verify APK signature"
            echo "  help           - Show this help"
            echo ""
            ;;
        
        *)
            print_error "Unknown action: $action"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
