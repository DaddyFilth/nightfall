#!/usr/bin/env bash
# ============================================================
#  setup.sh  –  Nightfall Godot 4 build environment setup
#  Run once on a fresh Termux / Linux ARM64 environment
# ============================================================
set -euo pipefail

# ── config ───────────────────────────────────────────────────
GODOT_VERSION="4.3"
GODOT_TEMPLATE_VERSION="4.3.stable"
GODOT_URL="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.arm64.zip"
TEMPLATE_URL="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_TEMPLATE_VERSION}.export_templates.tpz"
JAVA_PKG="openjdk-17"
PROJECT_DIR="$HOME/nightfall"
GODOT_BIN="$HOME/bin/godot"
TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/${GODOT_TEMPLATE_VERSION}"
ANDROID_SDK="$HOME/android-sdk"
BUILD_TOOLS_VERSION="34.0.0"
KEYSTORE="$HOME/nightfall.keystore"

GREEN='\u001B[0;32m'; YELLOW='\u001B[1;33m'; RED='\u001B[0;31m'; NC='\u001B[0m'
log()  { echo -e "${GREEN}[SETUP]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── 0. system packages ────────────────────────────────────────
log "Installing system packages..."
if command -v pkg &>/dev/null; then
    pkg update -y -q
    pkg install -y -q wget unzip openjdk-17 git python android-tools
elif command -v apt-get &>/dev/null; then
    apt-get update -qq
    apt-get install -y -q wget unzip ${JAVA_PKG} git python3 adb
else
    warn "Unknown package manager — install wget, unzip, java 17, git manually"
fi

export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which javac))))"
export PATH="$JAVA_HOME/bin:$PATH"
java -version 2>&1 | head -1
log "Java OK"

# ── 1. Godot binary ──────────────────────────────────────────
mkdir -p "$HOME/bin"
if [[ ! -f "$GODOT_BIN" ]]; then
    log "Downloading Godot ${GODOT_VERSION}..."
    wget -q --show-progress -O /tmp/godot.zip "$GODOT_URL"
    unzip -o /tmp/godot.zip -d /tmp/godot_extract/
    GODOT_EXTRACTED=$(find /tmp/godot_extract -maxdepth 1 -type f -name "Godot*" | head -1)
    cp "$GODOT_EXTRACTED" "$GODOT_BIN"
    chmod +x "$GODOT_BIN"
    rm -rf /tmp/godot.zip /tmp/godot_extract
    log "Godot binary installed → $GODOT_BIN"
else
    log "Godot binary already present — skipping download"
fi

echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/bin:$PATH"
godot --version

# ── 2. Export templates ──────────────────────────────────────
if [[ ! -d "$TEMPLATE_DIR" ]]; then
    log "Downloading export templates..."
    wget -q --show-progress -O /tmp/templates.tpz "$TEMPLATE_URL"
    mkdir -p "$TEMPLATE_DIR"
    unzip -o /tmp/templates.tpz -d /tmp/tpl_extract/
    mv /tmp/tpl_extract/templates/* "$TEMPLATE_DIR/"
    rm -rf /tmp/templates.tpz /tmp/tpl_extract
    log "Export templates installed → $TEMPLATE_DIR"
else
    log "Export templates already present — skipping"
fi

# ── 3. Android SDK (cmdline-tools) ───────────────────────────
if [[ ! -d "$ANDROID_SDK/cmdline-tools" ]]; then
    log "Setting up Android SDK cmdline-tools..."
    CMDTOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
    wget -q --show-progress -O /tmp/cmdtools.zip "$CMDTOOLS_URL"
    mkdir -p "$ANDROID_SDK/cmdline-tools"
    unzip -o /tmp/cmdtools.zip -d /tmp/cmdtools_extract/
    mv /tmp/cmdtools_extract/cmdline-tools "$ANDROID_SDK/cmdline-tools/latest"
    rm -rf /tmp/cmdtools.zip /tmp/cmdtools_extract
    log "Android cmdline-tools installed"
fi

export ANDROID_HOME="$ANDROID_SDK"
export PATH="$ANDROID_SDK/cmdline-tools/latest/bin:$ANDROID_SDK/platform-tools:$PATH"

# accept licences and install build tools + platform
yes | sdkmanager --licenses &>/dev/null || true
sdkmanager --install \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;${BUILD_TOOLS_VERSION}" \
    --sdk_root="$ANDROID_SDK" -q
log "Android SDK build-tools ${BUILD_TOOLS_VERSION} ready"

# ── 4. Godot Android build template ─────────────────────────
ANDROID_BUILD_TEMPLATE="$PROJECT_DIR/android/build"
if [[ ! -d "$ANDROID_BUILD_TEMPLATE" ]]; then
    log "Installing Godot Android build template into project..."
    export GODOT_SILENCE_ROOT_WARNING=1
    godot --headless --path "$PROJECT_DIR" \
        --install-android-build-template 2>/dev/null || \
    warn "Template install returned non-zero (may be OK if files already exist)"
fi

# ── 5. Keystore ──────────────────────────────────────────────
if [[ ! -f "$KEYSTORE" ]]; then
    log "Generating debug keystore..."
    keytool -genkey -v \
        -keystore "$KEYSTORE" \
        -alias nightfall \
        -keyalg RSA -keysize 2048 \
        -validity 10000 \
        -storepass nightfall123 \
        -keypass nightfall123 \
        -dname "CN=Nightfall,O=DaddyFilth,C=US" \
        2>/dev/null
    log "Keystore created → $KEYSTORE"
else
    log "Keystore already exists — skipping"
fi

# ── 6. Patch export_presets.cfg with SDK + keystore paths ────
log "Patching export_presets.cfg..."
PRESET="$PROJECT_DIR/export_presets.cfg"
if [[ -f "$PRESET" ]]; then
    sed -i "s|android_sdk_path=.*|android_sdk_path="${ANDROID_SDK}"|g" "$PRESET"
    sed -i "s|keystore/debug=.*|keystore/debug="${KEYSTORE}"|g"         "$PRESET"
    sed -i "s|keystore/debug_password=.*|keystore/debug_password="nightfall123"|g" "$PRESET"
    sed -i "s|keystore/debug_user=.*|keystore/debug_user="nightfall"|g" "$PRESET"
    log "export_presets.cfg patched"
fi

# ── 7. Write env file for build.sh ───────────────────────────
cat > "$PROJECT_DIR/.build_env" << ENVEOF
export JAVA_HOME="${JAVA_HOME}"
export ANDROID_HOME="${ANDROID_SDK}"
export GODOT_SILENCE_ROOT_WARNING=1
export PATH="${JAVA_HOME}/bin:${ANDROID_SDK}/cmdline-tools/latest/bin:${ANDROID_SDK}/platform-tools:$HOME/bin:$PATH"
ENVEOF
log ".build_env written — source it before building"

# ── 8. Verify ────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════"
log "Setup complete! Summary:"
echo "  Godot binary  : $(godot --version 2>&1 | head -1)"
echo "  Java          : $(java -version 2>&1 | head -1)"
echo "  Android SDK   : $ANDROID_SDK"
echo "  Keystore      : $KEYSTORE"
echo "  Templates     : $TEMPLATE_DIR"
echo "══════════════════════════════════════════════"
echo ""
log "To build the APK:"
echo "  source $PROJECT_DIR/.build_env"
echo "  cd $PROJECT_DIR && bash build.sh"

