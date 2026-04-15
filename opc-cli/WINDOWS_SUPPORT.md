# Windows 平台支持补丁

> 为 opc-cli 添加 Windows + PyTorch + CUDA 支持

## 📋 问题分析

opc-cli 原本只支持 Linux (CUDA) 和 macOS (MLX)，但实际上 **qwen-tts 完全支持 Windows**！

根据 [HuggingFace 官方文档](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)：
- ✅ qwen-tts 包在 Windows 上完全支持
- ✅ 支持 CUDA 设备
- ✅ 安装简单：`pip install -U qwen-tts`

## 🔧 解决方案

### 1. 修改 `pyproject.toml` - 添加 Windows 支持

将以下依赖：
```toml
# ── Linux + NVIDIA GPU (CUDA 12.4) ──
"torch>=2.5.0,<2.10.0; sys_platform == 'linux'"
"torchaudio>=2.5.0,<2.10.0; sys_platform == 'linux'"
"qwen-tts; sys_platform == 'linux'"
"qwen-asr; sys_platform == 'linux'"
```

修改为：
```toml
# ── Linux + Windows + NVIDIA GPU (CUDA 12.4) ──
"torch>=2.5.0,<2.10.0; sys_platform == 'linux' or sys_platform == 'win32'"
"torchaudio>=2.5.0,<2.10.0; sys_platform == 'linux' or sys_platform == 'win32'"
"qwen-tts; sys_platform == 'linux' or sys_platform == 'win32'"
"qwen-asr; sys_platform == 'linux' or sys_platform == 'win32'"
```

### 2. 修改 `scripts/shared/platform.py` - Windows 自动检测

将以下代码：
```python
def _auto_detect_backend() -> str:
    """Auto-detect backend from OS."""
    return "mlx" if is_macos() else "cuda"
```

修改为：
```python
def is_windows() -> bool:
    """Check if running on Windows."""
    return platform.system() == 'Windows'


def _auto_detect_backend() -> str:
    """Auto-detect backend from OS."""
    if is_macos():
        return "mlx"
    elif is_windows() or is_linux():
        return "cuda"
    return "cuda"  # 默认使用 cuda
```

### 3. 配置本地模型路径

您已经有这些模型在 `D:\AI\ComfyUI-aki-v3\ComfyUI\models\TTS\Qwen\`：

- `Qwen3-TTS-12Hz-1.7B-CustomVoice`
- `Qwen3-TTS-12Hz-1.7B-VoiceDesign`
- `Qwen3-TTS-12Hz-1.7B-Base`
- `Qwen3-TTS-12Hz-0.6B-CustomVoice`
- `Qwen3-TTS-12Hz-0.6B-Base`
- `Qwen3-TTS-Tokenizer-12Hz`

配置模型缓存目录：
```bash
opc config --set-model-cache-dir "D:\AI\ComfyUI-aki-v3\ComfyUI\models\TTS"
```

## 🚀 安装步骤

### 1. 安装 PyTorch (Windows + CUDA)

访问 [PyTorch 官网](https://pytorch.org/get-started/locally/) 获取适合您 CUDA 版本的安装命令。

例如（CUDA 12.4）：
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

### 2. 安装 qwen-tts 和 qwen-asr

```bash
pip install -U qwen-tts qwen-asr
```

可选（减少 GPU 内存使用）：
```bash
pip install -U flash-attn --no-build-isolation
```

### 3. 安装 opc-cli 依赖

```bash
cd D:\Learning\xiaotian\github\OPC\opc-cli
uv sync
```

### 4. 测试安装

```bash
# 测试 edge-tts（在线）
uv run python scripts/opc.py tts "你好" -e edge-tts

# 测试 qwen-tts（本地模型）
uv run python scripts/opc.py tts "你好" -e qwen --speaker Vivian

# 查看配置
uv run python scripts/opc.py config --show
```

## 📝 配置文件示例

`~/.opc_cli/opc/config.json`:
```json
{
  "tts_engine": "qwen",
  "qwen_model_size": "1.7B",
  "qwen_mode": "custom_voice",
  "qwen_speaker": "Vivian",
  "qwen_language": "Auto",
  "backend": "cuda",
  "model_cache_dir": "D:\\AI\\ComfyUI-aki-v3\\ComfyUI\\models\\TTS",
  "model_source": "local"
}
```

## ⚠️ 注意事项

1. **GPU 要求**: 需要 NVIDIA GPU 并安装 CUDA
2. **性能**: Windows 上可能比 Linux 稍慢
3. **依赖**: 确保安装了正确版本的 PyTorch 和 CUDA

## 🎯 快速验证

```python
import torch
from qwen_tts import Qwen3TTSModel

# 检查 CUDA 可用性
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA device: {torch.cuda.get_device_name(0)}")

# 加载模型（使用本地路径）
model = Qwen3TTSModel.from_pretrained(
    "D:\\AI\\ComfyUI-aki-v3\\ComfyUI\\models\\TTS\\Qwen\\Qwen3-TTS-12Hz-1.7B-CustomVoice",
    device_map="cuda:0",
    dtype=torch.bfloat16
)
print("Model loaded successfully!")
```

## 📚 参考资源

- [Qwen3-TTS 官方文档](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)
- [Qwen3-TTS 安装指南](https://mintlify.com/QwenLM/Qwen3-TTS/installation)
- [PyTorch Windows 安装](https://pytorch.org/get-started/locally/)
