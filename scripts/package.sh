#!/bin/bash
set -e

# ============================================================================
# Project:        APEX Horizon Digital Instrument Cluster HMI
# File:           scripts/package.sh
# Description:    Automated OS build & standalone zip package generator
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    PLATFORM_NAME="macOS"
    ;;
  Linux)
    PLATFORM_NAME="Linux"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PLATFORM_NAME="Windows"
    ;;
  *)
    PLATFORM_NAME="$OS"
    ;;
esac

PACKAGE_NAME="ApexCluster-${PLATFORM_NAME}-${ARCH}"
ZIP_NAME="${PACKAGE_NAME}.zip"

echo "========================================================"
echo "APEX Horizon Cluster - Standalone OS Build & Packaging"
echo "Target Platform : ${PLATFORM_NAME} (${ARCH})"
echo "Package Name    : ${ZIP_NAME}"
echo "========================================================"

cd "$ROOT_DIR"

if [ ! -f "$BUILD_DIR/ApexClusterApp" ] && [ ! -f "$BUILD_DIR/ApexClusterApp.exe" ]; then
  echo "Building application binary..."
  if command -v make >/dev/null 2>&1 && [ -f "Makefile" ]; then
    make build
  else
    cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
    cmake --build build --config Release --parallel
  fi
fi

PACKAGE_DIR="$ROOT_DIR/package/${PACKAGE_NAME}"
rm -rf "$ROOT_DIR/package"
mkdir -p "$PACKAGE_DIR"

if [ -f "$BUILD_DIR/ApexClusterApp" ]; then
  cp "$BUILD_DIR/ApexClusterApp" "$PACKAGE_DIR/"
  chmod +x "$PACKAGE_DIR/ApexClusterApp"
  
  cat << 'EOF' > "$PACKAGE_DIR/run.sh"
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="$DIR:$LD_LIBRARY_PATH"
"$DIR/ApexClusterApp" "$@"
EOF
  chmod +x "$PACKAGE_DIR/run.sh"
elif [ -f "$BUILD_DIR/ApexClusterApp.exe" ]; then
  cp "$BUILD_DIR/ApexClusterApp.exe" "$PACKAGE_DIR/"
  if command -v windeployqt >/dev/null 2>&1; then
    windeployqt --qmldir qml "$PACKAGE_DIR/ApexClusterApp.exe"
  fi
else
  echo "Error: Application binary not found in $BUILD_DIR"
  exit 1
fi

cat << EOF > "$PACKAGE_DIR/README.txt"
APEX Horizon Digital Instrument Cluster HMI
Standalone Build Package: ${PACKAGE_NAME}

Launch Instructions:
- Linux / macOS: Run ./run.sh or ./ApexClusterApp
- Windows: Run ApexClusterApp.exe

Controls:
- [ F12 ] / [ Tab ] : Toggle ECU Diagnostic Test Bench
- [ A ]             : Start / Stop Autonomous Drive Demo
- [ O ]             : Toggle Active Ignition / Standby
- [ Arrow Keys ]    : Throttle & Menu Navigation
EOF

cd "$ROOT_DIR/package"
rm -f "$ROOT_DIR/$ZIP_NAME"
zip -r "$ROOT_DIR/$ZIP_NAME" "${PACKAGE_NAME}"
cd "$ROOT_DIR"
rm -rf "$ROOT_DIR/package"

echo "========================================================"
echo "Successfully created standalone package:"
echo "Archive: $ROOT_DIR/$ZIP_NAME"
ls -lh "$ROOT_DIR/$ZIP_NAME"
echo "========================================================"
