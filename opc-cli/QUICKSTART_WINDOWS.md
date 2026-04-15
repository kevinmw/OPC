# 🚀 opc-cli Windows 快速安装指南

## ✅ 您已有的资源

- ✅ 完整的 Qwen3-TTS 模型（6个）
- ✅ SenseVoiceSmall ASR 模型
- ✅ ComfyUI 已可用 Qwen3TTS

## 📋 安装步骤

### 1️⃣ 安装 PyTorch + CUDA（5分钟）

访问 https://pytorch.org/get-started/locally/ 选择您的配置，或使用以下命令：

```bash
# CUDA 12.4 (推荐)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

### 2️⃣ 安装 qwen-tts 和 qwen-asr（2分钟）

```bash
pip install -U qwen-tts qwen-asr
```

可选（减少 GPU 内存使用）：
```bash
pip install -U flash-attn --no-build-isolation
```

### 3️⃣ 安装 opc-cli 依赖（1分钟）

```bash
cd D:\Learning\xiaotian\github\OPC\opc-cli
uv sync
```

### 4️⃣ 运行测试（1分钟）

```bash
python test_windows.py
```

### 5️⃣ 配置本地模型路径（1分钟）

```bash
uv run python scripts/opc.py config --set-model-cache-dir "D:\AI\ComfyUI-aki-v3\ComfyUI\models\TTS"
```

## 🎯 快速验证

### 测试 edge-tts（在线）
```bash
uv run python scripts/opc.py tts "你好，世界！" -e edge-tts
```

### 测试 qwen-tts（本地）
```bash
uv run python scripts/opc.py tts "你好，世界！" -e qwen --speaker Vivian
```

### 生成并播放
```bash
uv run python scripts/opc.py say "你好，世界！" -e qwen --speaker Vivian
```

## 🎤 可用音色（9种）

| 音色 | 描述 | 语言 |
|------|------|------|
| Vivian | 明亮、略带棱角感的年轻女性 | 中文 |
| Serena | 温暖、温柔的年轻女性 | 中文 |
| Uncle_Fu | 成熟男性，音色低沉柔和 | 中文 |
| Dylan | 年轻北京男性，清晰自然 | 北京方言 |
| Eric | 活泼成都男性，略带沙哑 | 四川方言 |
| Ryan | 富有节奏感的动态男声 | 英语 |
| Aiden | 阳光美国男性，中频清晰 | 英语 |
| Ono_Anna | 活泼的日语女性，轻快灵活 | 日语 |
| Sohee | 温暖感人的韩语女性 | 韩语 |

## 🎨 三种模式

### 1. CustomVoice（内置音色）
```bash
uv run python scripts/opc.py tts "你好" -e qwen --speaker Vivian
```

### 2. VoiceDesign（声音设计）
```bash
uv run python scripts/opc.py tts "你好" -e qwen --mode voice_design --instruct "温柔的女声，音调偏高"
```

### 3. VoiceClone（声音克隆）
```bash
uv run python scripts/opc.py tts "你好" -e qwen --mode voice_clone --ref-audio ref.wav --ref-text "参考文本"
```

## ⚙️ 配置文件

位置：`~/.opc_cli/opc/config.json`

```json
{
  "tts_engine": "qwen",
  "qwen_model_size": "1.7B",
  "qwen_mode": "custom_voice",
  "qwen_speaker": "Vivian",
  "qwen_language": "Auto",
  "backend": "cuda",
  "model_cache_dir": "D:\\AI\\ComfyUI-aki-v3\\ComfyUI\\models\\TTS"
}
```

## 🔧 常用命令

```bash
# 查看配置
uv run python scripts/opc.py config --show

# 设置默认引擎
uv run python scripts/opc.py config --set-engine qwen

# 设置默认音色
uv run python scripts/opc.py config --set-speaker Vivian

# 列出可用音色
uv run python scripts/opc.py voices -e qwen

# 发现播放设备
uv run python scripts/opc.py discover

# ASR 语音识别
uv run python scripts/opc.py asr audio.mp3 --language Chinese

# 生成字幕
uv run python scripts/opc.py asr audio.mp3 --format srt
```

## ❓ 常见问题

### Q: 提示 PyTorch 未安装？
A: 运行 `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124`

### Q: 提示 qwen-tts 未安装？
A: 运行 `pip install -U qwen-tts qwen-asr`

### Q: 模型加载失败？
A: 检查模型路径配置：`uv run python scripts/opc.py config --show`

### Q: CUDA 不可用？
A: 确保安装了 NVIDIA GPU 驱动和 CUDA 工具包

## 📚 更多信息

- [完整文档](./SKILL.md)
- [Windows 支持详情](./WINDOWS_SUPPORT.md)
- [Qwen3-TTS 官方文档](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)

## 🎉 开始使用

```bash
# 第一次运行
uv run python scripts/opc.py say "你好，我是 opc-cli！" -e qwen --speaker Vivian
```

祝您使用愉快！🎊
