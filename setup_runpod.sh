#!/bin/bash
# Run on RunPod. Upload this + config.h + vanity.cu to same folder, then run.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd /workspace

if [ ! -f "$SCRIPT_DIR/config.h" ] || [ ! -f "$SCRIPT_DIR/vanity.cu" ]; then
    echo "ERROR: config.h and vanity.cu must be in the same folder as this script."
    echo "Upload setup_runpod.sh, config.h, vanity.cu to same folder in /workspace"
    exit 1
fi

echo "Cloning solanity..."
GIT_TERMINAL_PROMPT=0 git clone https://github.com/mcf-rocks/solanity.git vanity-grinder
cd vanity-grinder

echo "Copying config.h and vanity.cu..."
cp "$SCRIPT_DIR/config.h" src/config.h
cp "$SCRIPT_DIR/vanity.cu" src/cuda-ecc-ed25519/vanity.cu

echo "Patching gpu-common.mk for RTX 4090..."
sed -i 's/sm_70$/sm_70,sm_86,sm_89/' src/gpu-common.mk

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
