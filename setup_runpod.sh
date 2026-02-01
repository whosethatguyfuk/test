#!/bin/bash
# Run on RunPod. Upload this + config.h + vanity.cu to same folder, then run.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd /workspace

if [ ! -f "$SCRIPT_DIR/config.h" ] || [ ! -f "$SCRIPT_DIR/vanity.cu" ] || [ ! -f "$SCRIPT_DIR/gpu-common.mk" ]; then
    echo "ERROR: config.h, vanity.cu, gpu-common.mk must be in the same folder as this script."
    exit 1
fi

echo "Cloning solanity..."
GIT_TERMINAL_PROMPT=0 git clone https://github.com/mcf-rocks/solanity.git vanity-grinder
cd vanity-grinder

echo "Copying config.h, vanity.cu, gpu-common.mk..."
cp "$SCRIPT_DIR/config.h" src/config.h
cp "$SCRIPT_DIR/vanity.cu" src/cuda-ecc-ed25519/vanity.cu
cp "$SCRIPT_DIR/gpu-common.mk" src/gpu-common.mk

echo "Building (5-10 min)..."
export PATH=/usr/local/cuda/bin:$PATH
make clean 2>/dev/null || true
make -j$(nproc) V=release

echo ""
echo "=== DONE ==="
echo "Run: cd /workspace/vanity-grinder/src/release"
echo "Single GPU: LD_LIBRARY_PATH=. ./cuda_ed25519_vanity"
echo ""
echo "8 GPUs:"
echo '  for i in 0 1 2 3 4 5 6 7; do CUDA_VISIBLE_DEVICES=$i LD_LIBRARY_PATH=. ./cuda_ed25519_vanity > ../../out_gpu$i.txt 2>&1 & done'
echo '  tail -f ../../out_gpu0.txt'
