#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# === Step 1: Install KernelSU Next ===
#if [ ! -d "$(pwd)/KernelSU-Next" ]; then
#    echo -e "${GREEN}[+] Installing KernelSU Next...${NC}"
#    curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
#else
#    echo -e "${GREEN}[!] KernelSU Next already present...${NC}"
#fi

# === Step 1: Install KernelSU ===
if [ ! -d "$(pwd)/KernelSU" ]; then
    echo -e "${GREEN}[+] Installing KernelSU...${NC}"
    curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s v0.9.5
else
    echo -e "${GREEN}[!] KernelSU is already present...${NC}"
fi

# === Step 2: Toolchain check ===
if [ ! -d "$(pwd)/toolchain" ]; then
    echo -e "${GREEN}[+] Downloading toolchain...${NC}"
    git clone --depth=1 https://gitlab.com/neel0210/toolchain.git
else
    echo -e "${GREEN}[!] Clang already ready...${NC}"
fi

# === Step 3: AnyKernel3 check ===
if [ ! -d "$(pwd)/AnyKernel3" ]; then
    echo -e "${GREEN}[+] Downloading AnyKernel3...${NC}"
    git clone -b a22x https://github.com/makruf1954/AnyKernel3.git AnyKernel3
else
    echo -e "${GREEN}[!] AnyKernel3 already ready...${NC}"
fi

# === Step 4: Export build variables ===
export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=t
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# === Step 5: Start building kernel ===
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y a22x_defconfig
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all)

# === Step 6: Copy kernel image ===
if [ -f "$(pwd)/out/arch/arm64/boot/Image.gz-dtb" ]; then
    cp $(pwd)/out/arch/arm64/boot/Image.gz-dtb $(pwd)/AnyKernel3/
elif [ -f "$(pwd)/out/arch/arm64/boot/Image.gz" ]; then
    cp $(pwd)/out/arch/arm64/boot/Image.gz $(pwd)/AnyKernel3/
elif [ -f "$(pwd)/out/arch/arm64/boot/Image" ]; then
    cp $(pwd)/out/arch/arm64/boot/Image $(pwd)/AnyKernel3/
else
    echo -e "${RED}Build failed: no kernel image found.${NC}"
    exit 1
fi

# === Step 7: Pack AnyKernel3 zip ===
cd AnyKernel3
zip -r9 "../AnyKernel3-$(date +%Y%m%d-%H%M).zip" ./*
cd ..
