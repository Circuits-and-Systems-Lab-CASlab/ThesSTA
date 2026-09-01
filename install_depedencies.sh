#!/usr/bin/env bash
set -e

echo "=== Checking & Installing Build Dependencies for LibreEDA ==="

# Helper function to run commands with sudo if not root
run_cmd() {
    if [ "$EUID" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# 1. Define required system packages
REQUIRED_PACKAGES=(
    build-essential
    wget
    gcc-11
    g++-11
    cmake
    libgtk2.0-dev
    pkg-config
    flex
    bison
    python3
    tcl8.6
    tcl8.6-dev
    libgsl-dev
    libsuitesparse-dev
    libfftw3-dev
    libreadline-dev
    zlib1g-dev
    libx11-dev
    gnuplot
    libncurses-dev
    libssl-dev
    libffi-dev
    libsqlite3-dev
    tk-dev
    libgdbm-dev
    libc6-dev
    libbz2-dev
)

# 2. Check for missing standard APT packages
MISSING_PACKAGES=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

# 3. Install missing standard APT packages
if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo "Missing packages detected: ${MISSING_PACKAGES[*]}"
    echo "Installing missing packages..."
    run_cmd apt-get update
    run_cmd apt-get install -y "${MISSING_PACKAGES[@]}"
else
    echo "All required standard APT packages are already installed!"
fi

# 4. Set GCC-11 and G++-11 as default compilers
echo "Configuring GCC-11 as default compiler..."
run_cmd update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 --slave /usr/bin/g++ g++ /usr/bin/g++-11
run_cmd update-alternatives --set gcc /usr/bin/gcc-11

# 5. Handling of libvte-dev across different distro versions
if ! dpkg -s "libvte-dev" >/dev/null 2>&1; then
    echo "Checking availability of libvte-dev in APT repositories..."
    run_cmd apt-get update >/dev/null 2>&1 || true

    # Check if libvte-dev exists directly in system repositories (e.g., Ubuntu 24.04 and earlier)
    if apt-cache show libvte-dev >/dev/null 2>&1; then
        echo "Installing libvte-dev via APT..."
        run_cmd apt-get install -y libvte-dev
    else
        echo "Installing libvte-dev from source..."
        run_cmd apt-get install intltool -y
        
        BUILD_DIR=${HOME}/vte-build
        CURR_DIR=${PWD}
        mkdir -p ${BUILD_DIR} && cd "$BUILD_DIR"
        
        wget https://download.gnome.org/sources/vte/0.28/vte-0.28.2.tar.xz
        tar -xf vte-0.28.2.tar.xz
        cd vte-0.28.2
        
        # Run configure and make as user, make install as root
        ./configure --prefix=/usr --libexecdir=/usr/lib/vte --disable-static --disable-python
        make -j"$(nproc)"
        run_cmd make install
        
        # Clean up build files
        cd ${CURR_DIR}
        rm -rf "$BUILD_DIR"
    fi
else
    echo "libvte-dev is already installed!"
fi

# 6. Ensure Tcl headers are in /usr/include if needed
if [ -d "/usr/include/tcl8.6" ] && [ ! -f "/usr/include/tcl.h" ]; then
    echo "Copying Tcl headers to /usr/include/..."
    run_cmd cp -r /usr/include/tcl8.6/* /usr/include/
fi

export LibreEDA_INSTALL_DIR="Tool/build/"
export LIBREEDA_ROOT="Tool/build"

echo "=== Environment Ready ==="
echo "Active GCC version:"
gcc --version | head -n 1

