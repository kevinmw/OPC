# 飞牛OS AI 工具手动安装指南

本指南拆解为可手动执行的命令，方便你逐步操作、排查问题。

## 前置条件

- 飞牛OS 系统（Debian 12 内核）
- NVIDIA GPU
- SSH 或终端访问权限
- uv 已安装（参考 install_tools.sh）

---

## 第一步：创建共享 Python 虚拟环境

在统一目录下创建 Python 3.12 虚拟环境，供多个 AI 工具共享使用：

```bash
uv venv /vol1/1000/tools --python 3.12
```

激活环境并验证：

```bash
source /vol1/1000/tools/bin/activate
python --version
```

> 应输出 `Python 3.12.x`。后续所有 Python 工具都在这个虚拟环境中安装。

---

## 第二步：创建用户主目录

飞牛OS 可能没有为当前用户创建 home 目录，需要手动创建：

```bash
sudo mkdir -p /home/$(whoami)
sudo chown $(whoami) /home/$(whoami)
```

确认目录权限正确：

```bash
ls -ld /home/$(whoami)
```

> 输出应显示当前用户为目录所有者，如 `drwxr-xr-x 2 openclaw openclaw ... /home/openclaw`

---

## 第三步：安装基础依赖

先检查是否已有 NVIDIA 驱动，决定后续是否需要安装：

```bash
nvidia-smi
```

如果提示命令不存在，继续下面的步骤。如果已经能正常输出 GPU 信息，可以跳到第六步。


安装编译工具和内核头文件（编译 NVIDIA 驱动需要）：

```bash
sudo apt update
sudo apt install -y linux-headers-$(uname -r) build-essential dkms wget curl
```

> 飞牛OS 的内核可能是定制版本（如 `6.12.18-trim`），`$(uname -r)` 会自动获取正确版本。如果提示找不到对应的 headers 包，说明飞牛OS 没有提供该版本的头文件，需要联系飞牛OS官方或等待更新。

---

## 第四步：安装 CUDA Toolkit 和 NVIDIA 驱动

下载 CUDA 12.9.0 本地仓库包，安装源、导入密钥、刷新软件源，然后安装 CUDA Toolkit（约 4.4GB，耗时较长）：

```bash
wget https://developer.download.nvidia.com/compute/cuda/12.9.0/local_installers/cuda-repo-debian12-12-9-local_12.9.0-575.51.03-1_amd64.deb
sudo dpkg -i cuda-repo-debian12-12-9-local_12.9.0-575.51.03-1_amd64.deb
sudo cp /var/cuda-repo-debian12-12-9-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-9
```

安装 NVIDIA 驱动（闭源驱动）：

```bash
sudo apt-get install -y cuda-drivers
```

> 驱动编译可能需要几分钟。如果想装开源内核模块驱动，把 `cuda-drivers` 换成 `nvidia-open`。

---

## 第五步：配置环境变量

CUDA 安装在 `/usr/local/cuda`，需要加入 PATH。将以下内容追加到 `~/.bashrc`：

```bash
cat >> ~/.bashrc << 'EOF'

# >>> CUDA >>>
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}
# <<< CUDA <<<
EOF
```

如果通过 SSH 登录，还需要确保 `~/.bash_profile` 存在并加载 `.bashrc`：

```bash
test -f ~/.bash_profile || cat > ~/.bash_profile << 'EOF'
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF
```

让当前终端立即生效：

```bash
source ~/.bashrc
```

---

## 第六步：安装 Claude Code

跳过 onboarding（避免首次启动的交互式设置）：

```bash
echo '{"hasCompletedOnboarding": true}' > ~/.claude.json
```

安装 Claude Code：

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

验证：

```bash
claude --version
```

---

## 第七步：安装 Harbor

Harbor 是本地 AI 模型服务管理工具，用它启动和管理 Ollama、llamacpp 等非常方便。

```bash
curl -fsSL https://raw.githubusercontent.com/av/harbor/refs/heads/main/install.sh | bash
```

验证：

```bash
harbor --version
```

---

## 第八步：配置 Docker（飞牛OS界面操作）

这一步需要在飞牛OS的 Web 管理界面操作：

1. 打开飞牛OS管理界面
2. 进入 **Docker** 设置
3. 配置 Docker 存储目录（建议使用独立磁盘/分区）
4. 启动 Docker 服务

确保当前用户在 docker 组中：

```bash
sudo usermod -aG docker $(whoami)
```

> 加入 docker 组后需要重新登录才能生效。

---

## 第九步：安装 NVIDIA Container Toolkit（飞牛OS界面操作）

让 Docker 容器能访问 GPU：

1. 打开飞牛OS **应用中心**
2. 搜索并安装 **NVIDIA Container Toolkit**

---

## 第十步：重启系统

```bash
sudo reboot
```

---

## 第十一步：重启后验证

逐项检查所有组件是否正常：

```bash
# 检查 NVIDIA 驱动
nvidia-smi

# 检查 CUDA
nvcc --version

# 检查 Docker GPU 支持
docker run --rm --gpus all nvidia/cuda:12.9.0-base-ubuntu22.04 nvidia-smi

# 检查 Claude Code
claude --version

# 检查 Harbor
harbor --version

# 检查 Python 虚拟环境
source /vol1/1000/tools/bin/activate
python --version
```

全部正常就可以继续部署本地模型了。

---

## 第十二步：部署本地模型

用 Harbor 一键下载模型并启动 llamacpp：

```bash
harbor config set llamacpp.model.specifier "--model-url https://modelscope.cn/models/unsloth/gemma-4-E4B-it-GGUF/resolve/master/gemma-4-E4B-it-Q4_K_M.gguf" && harbor up llamacpp
```

> 模型文件约 4GB，下载需要几分钟。下载完成后 llamacpp 容器会自动启动并挂载 GPU。

验证模型服务是否正常：

```bash
# 查看服务状态
harbor ps

# 测试推理
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gemma-4-E4B-it-Q4_K_M","messages":[{"role":"user","content":"你好"}]}'
```

如果想换其他模型，修改 URL 即可：

| 模型 | 命令 |
|------|------|
| Qwen3-8B | `harbor config set llamacpp.model.specifier "--model-url https://modelscope.cn/models/Qwen/Qwen3-8B-GGUF/resolve/master/qwen3-8b-q4_k_m.gguf" && harbor up llamacpp` |

---
