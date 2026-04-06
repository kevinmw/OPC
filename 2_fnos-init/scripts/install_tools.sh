#!/bin/bash
set -euo pipefail

CUDA_VERSION="12.9.0"
LOCAL_PKG="cuda-repo-debian12-12-9-local_12.9.0-575.51.03-1_amd64.deb"
CUDA_BRANCH="12-9"
DRIVER_BRANCH="575"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ─── 检查 root 权限 ───
if [[ $EUID -ne 0 ]]; then
    error "请以 root 身份运行: sudo bash install_tools.sh"
fi

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || whoami)}"
REAL_HOME=$(eval echo "~${REAL_USER}")

# ─── 1. 解除 hold 并安装基础依赖 ───
info "解除 libc6 相关包的 hold..."
apt-mark unhold libc6-dev libc6 libc-bin libc-l10n 2>/dev/null || true

info "安装基础依赖..."
apt update
apt install -y linux-headers-$(uname -r) build-essential dkms wget curl

# ─── 2. 安装 Claude Code ───
if sudo -u "${REAL_USER}" bash -c 'source ~/.bashrc 2>/dev/null; command -v claude' &>/dev/null; then
    info "Claude Code 已安装，跳过"
else
    info "配置 Claude Code..."

    CLAUDE_JSON="${REAL_HOME}/.claude.json"
    if [[ ! -f ${CLAUDE_JSON} ]]; then
        echo '{"hasCompletedOnboarding": true}' > "${CLAUDE_JSON}"
        chown "${REAL_USER}" "${CLAUDE_JSON}"
        info "已创建 ${CLAUDE_JSON}"
    else
        info "${CLAUDE_JSON} 已存在，跳过"
    fi

    info "安装 Claude Code..."
    su - "${REAL_USER}" -c 'curl -fsSL https://claude.ai/install.sh | bash'
fi

# ─── 3. 安装 uv ───
if sudo -u "${REAL_USER}" bash -c 'source ~/.bashrc 2>/dev/null; command -v uv' &>/dev/null; then
    info "uv 已安装，跳过"
else
    info "安装 uv..."
    su - "${REAL_USER}" -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
fi

# ─── 4. 安装 Harbor ───
if sudo -u "${REAL_USER}" bash -c 'source ~/.bashrc 2>/dev/null; command -v harbor' &>/dev/null; then
    info "Harbor 已安装，跳过"
else
    info "安装 Harbor..."
    su - "${REAL_USER}" -c 'curl -fsSL https://raw.githubusercontent.com/av/harbor/refs/heads/main/install.sh | bash'
fi

# ─── 5. 下载 CUDA 本地仓库包 ───
if [[ -f /tmp/${LOCAL_PKG} ]]; then
    info "CUDA 本地包已存在，跳过下载"
else
    info "下载 CUDA ${CUDA_VERSION} ..."
    wget -O "/tmp/${LOCAL_PKG}" \
        "https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers/${LOCAL_PKG}"
fi

# ─── 6. 安装本地仓库并导入 keyring ───
if ! dpkg -l cuda-repo-debian12-12-9-local &>/dev/null; then
    info "安装 CUDA 本地仓库..."
    dpkg -i "/tmp/${LOCAL_PKG}"

    info "导入 GPG keyring..."
    cp /var/cuda-repo-debian12-12-9-local/cuda-*-keyring.gpg /usr/share/keyrings/
else
    info "CUDA 本地仓库已安装，跳过"
fi

# ─── 7. 安装 CUDA Toolkit + NVIDIA 驱动 ───
if command -v nvidia-smi &>/dev/null; then
    info "NVIDIA 驱动已安装，跳过"
else
    info "更新软件源..."
    apt update

    info "安装 CUDA Toolkit ${CUDA_VERSION} + Driver ..."
    apt install -y cuda-toolkit-${CUDA_BRANCH} cuda-drivers
fi

# ─── 8. 配置环境变量 ───
info "配置 ${REAL_USER} 的环境变量..."

BASHRC="${REAL_HOME}/.bashrc"
BASH_PROFILE="${REAL_HOME}/.bash_profile"

# 写 .bash_profile，让 SSH login shell 加载 .bashrc
if [[ ! -f ${BASH_PROFILE} ]]; then
    cat > "${BASH_PROFILE}" << 'BPEOF'
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
BPEOF
    info "已创建 ${BASH_PROFILE}"
fi

# 写 CUDA 环境变量到 .bashrc（避免重复添加）
CUDA_BLOCK_MARKER="# >>> CUDA >>>"
if ! grep -q "${CUDA_BLOCK_MARKER}" "${BASHRC}" 2>/dev/null; then
    cat >> "${BASHRC}" << 'EOF'

# >>> CUDA >>>
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}
# <<< CUDA <<<
EOF
    info "已写入 CUDA 环境变量到 ${BASHRC}"
else
    info "CUDA 环境变量已存在，跳过"
fi

chown "${REAL_USER}" "${BASHRC}" "${BASH_PROFILE}"

# ─── 9. 将当前用户加入 docker 组 ───
if getent group docker &>/dev/null; then
    if groups "${REAL_USER}" | grep -q docker; then
        info "${REAL_USER} 已在 docker 组，跳过"
    else
        info "将用户 ${REAL_USER} 加入 docker 组..."
        usermod -aG docker "${REAL_USER}"
    fi
else
    warn "docker 组不存在，跳过（可能还未安装 Docker）"
fi

# ─── 完成 ───
info "全部安装完成！"
lsmod | grep nvidia || warn "nvidia 内核模块尚未加载（需要重启）"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  安装完成！接下来请按以下步骤操作："
echo -e "${GREEN}  1. 在飞牛OS界面配置 Docker 存储目录并启动"
echo -e "${GREEN}  2. 在飞牛OS应用中心安装 NVIDIA Container Toolkit"
echo -e "${GREEN}  3. 重启系统: sudo reboot"
echo -e "${GREEN}  4. 重启后运行 nvidia-smi 验证"
echo -e "${GREEN}  5. 部署本地模型："
echo -e "${GREEN}     harbor config set llamacpp.model.specifier \\"
echo -e "${GREEN}       \"--model-url https://modelscope.cn/models/unsloth/gemma-4-E4B-it-GGUF/resolve/master/gemma-4-E4B-it-Q4_K_M.gguf\" \\"
echo -e "${GREEN}       && harbor up llamacpp"
echo -e "${GREEN}========================================${NC}"
