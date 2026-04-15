# 🎤 OPC CLI Windows 完整使用指南

> Windows 平台上的 AI 语音合成与识别工具

## 📋 目录

- [系统要求](#系统要求)
- [安装步骤](#安装步骤)
- [快速开始](#快速开始)
- [TTS 语音合成](#tts-语音合成)
- [Dashboard 管理面板](#dashboard-管理面板)
- [常见问题](#常见问题)
- [高级配置](#高级配置)

---

## 系统要求

### 硬件要求
- ✅ **GPU**: NVIDIA GPU（推荐 RTX 3060 或更高）
- ✅ **显存**: 最低 6GB（推荐 8GB+）
- ✅ **内存**: 16GB RAM
- ✅ **存储**: 10GB 可用空间

### 软件要求
- ✅ **操作系统**: Windows 10/11（64位）
- ✅ **Python**: 3.10 - 3.13
- ✅ **CUDA**: 12.4 或更高版本
- ✅ **Node.js**: 18+ （用于 Dashboard）

---

## 安装步骤

### 1. 安装 PyTorch + CUDA

访问 [PyTorch 官网](https://pytorch.org/get-started/locally/) 获取适合您 CUDA 版本的安装命令。

```bash
# CUDA 12.4（推荐）
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# CUDA 12.6
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
```

验证安装：
```bash
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"
```

### 2. 安装 qwen-tts

```bash
pip install -U qwen-tts
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

### 4. 验证安装

```bash
# 测试 edge-tts（在线）
python opc.py tts "你好，世界！" -e edge-tts

# 测试 qwen-tts（本地）
python opc.py tts "你好，世界！" -e qwen --speaker Vivian
```

---

## 快速开始

### 基础 TTS 命令

```bash
# 进入目录
cd D:\Learning\xiaotian\github\OPC\opc-cli

# 生成语音文件
python opc.py tts "你好，我是 opc-cli！" -e qwen --speaker Vivian

# 生成并播放
python opc.py say "你好，我是 opc-cli！" -e qwen --speaker Vivian

# 查看配置
python opc.py config --show

# 列出可用音色
python opc.py voices -e qwen
```

### 输出文件位置

默认输出到临时目录：
```
C:\Users\Kevin\AppData\Local\Temp\opc_tts_output.mp3
```

---

## TTS 语音合成

### 可用引擎

| 引擎 | 描述 | 速度 | 质量 | 离线 |
|------|------|------|------|------|
| **edge-tts** | 微软在线 TTS | ⚡ 快 | ✅ 好 | ❌ |
| **qwen** | 本地 AI 模型 | 🐢 慢 | 🌟 优秀 | ✅ |

### edge-tts 使用（在线）

```bash
# 基础使用
python opc.py tts "Hello World" -e edge-tts

# 调整语速、音调、音量
python opc.py tts "你好" -e edge-tts --rate +20% --pitch +5Hz --volume +50%

# 指定音色
python opc.py tts "你好" -e edge-tts --voice zh-CN-XiaoxiaoNeural

# 列出所有音色（322种）
python opc.py voices -e edge-tts
```

### qwen-tts 使用（本地）

#### 1. CustomVoice（内置音色）

```bash
# 基础使用
python opc.py tts "你好" -e qwen --speaker Vivian

# 带情绪指令
python opc.py tts "你好" -e qwen --speaker Vivian --instruct "用愤怒的语气说"

# 指定语言
python opc.py tts "Hello" -e qwen --speaker Ryan --language English
```

#### 2. VoiceDesign（声音设计）

```bash
# 自然语言描述声音
python opc.py tts "哥哥，你回来啦！" -e qwen --mode voice_design --instruct "体现撒娇稚嫩的萝莉女声，音调偏高且起伏明显"

# 更多示例
python opc.py tts "Welcome" -e qwen --mode voice_design --instruct "Deep male voice, slow tempo, authoritative"
```

#### 3. VoiceClone（声音克隆）

```bash
# 需要参考音频和文本
python opc.py tts "测试声音克隆" -e qwen --mode voice_clone \
  --ref-audio "path/to/ref.wav" \
  --ref-text "参考文本内容"

# 仅使用 x-vector（质量较低但不需要参考文本）
python opc.py tts "测试" -e qwen --mode voice_clone \
  --ref-audio "ref.wav" \
  --x-vector-only
```

### 可用音色（9种内置）

| 音色 | 描述 | 性别 | 语言 |
|------|------|------|------|
| **Vivian** | 明亮、略带棱角感的年轻女性 | 女 | 中文 |
| **Serena** | 温暖、温柔的年轻女性 | 女 | 中文 |
| **Uncle_Fu** | 成熟男性，音色低沉柔和 | 男 | 中文 |
| **Dylan** | 年轻北京男性，清晰自然 | 男 | 北京话 |
| **Eric** | 活泼成都男性，略带沙哑 | 男 | 四川话 |
| **Ryan** | 富有节奏感的动态男声 | 男 | 英语 |
| **Aiden** | 阳光美国男性，中频清晰 | 男 | 英语 |
| **Ono_Anna** | 活泼的日语女性，轻快灵活 | 女 | 日语 |
| **Sohee** | 温暖感人的韩语女性 | 女 | 韩语 |

### 模型大小选择

根据您的显存选择：

| 显存 | 推荐模型 | 性能 |
|------|----------|------|
| 6GB | 0.6B | 基础 |
| 8GB | 0.6B | 推荐 ✅ |
| 12GB+ | 1.7B | 最佳 |

配置模型大小：
```bash
python opc.py config --set-model-size 0.6B
```

---

## Dashboard 管理面板

### 启动 Dashboard

Dashboard 提供 Web 界面来管理 Cut 视频剪辑功能。

#### 步骤 1: 安装 Node.js 依赖

```bash
cd D:\Learning\xiaotian\github\OPC\opc-cli\dashboard\server
npm install
```

#### 步骤 2: 构建（首次使用）

```bash
npm run build
```

#### 步骤 3: 启动 Dashboard 服务器

```bash
node server-prod.js
```

Dashboard 将在 http://localhost:12080 启动

### 访问 Dashboard

- **首页**: http://localhost:12080/
- **Cut 编辑器**: http://localhost:12080/skill/cut/editor

### Dashboard 功能

1. **技能管理**
   - 查看已注册的技能列表
   - 启动/停止技能服务

2. **Cut 视频剪辑**
   - 输入视频文件路径
   - （可选）输入 ASR JSON 文件
   - 点击"启动剪辑服务"
   - 在 iframe 中访问编辑器

### Dashboard API

#### 获取技能列表
```bash
curl http://localhost:12080/api/skills
```

#### 获取 Cut 状态
```bash
curl http://localhost:12080/api/skill/cut/status
```

#### 启动 Cut 服务
```bash
curl -X POST http://localhost:12080/api/skill/cut/init \
  -H "Content-Type: application/json" \
  -d '{
    "video": "D:\\path\\to\\video.mp4",
    "json": "D:\\path\\to\\asr_result.json",
    "port": 12082
  }'
```

#### 停止 Cut 服务
```bash
curl -X POST http://localhost:12080/api/skill/cut/stop
```

### 远程访问配置

如果需要从远程机器访问 Dashboard：

```bash
# 设置监听所有接口
python opc.py config --set-dashboard-host 0.0.0.0

# 设置端口
python opc.py config --set-dashboard-port 12080

# 重启 Dashboard
node server-prod.js
```

然后从远程机器访问：`http://<your-ip>:12080`

---

## 常见问题

### Q1: 如何解决 "SoX not found" 警告？

这是可选依赖，不影响核心功能。如需安装：

1. 下载 SoX: http://sox.sourceforge.net/
2. 解压并添加到 PATH
3. 或使用 Chocolatey: `choco install sox`

### Q2: 模型加载很慢怎么办？

首次加载需要下载模型（约 1.7GB）。您可以：

1. 使用本地 ComfyUI 模型（已配置）
2. 检查网络连接
3. 耐心等待（约 2-5 分钟）

### Q3: GPU 显存不足怎么办？

```bash
# 使用更小的模型
python opc.py config --set-model-size 0.6B

# 或使用 CPU（会很慢）
# 修改模型加载代码设置 device_map="cpu"
```

### Q4: 如何更改输出目录？

```bash
# 设置输出目录
python opc.py config --set-output-dir "D:\\output"

# 设置工作目录
python opc.py config --set-workspace "D:\\workspace"
```

### Q5: Dashboard 无法启动？

```bash
# 检查 Node.js 版本
node --version  # 应该 >= 18

# 重新安装依赖
cd dashboard/server
rm -rf node_modules package-lock.json
npm install
npm run build
```

---

## 高级配置

### 配置文件位置

```
C:\Users\Kevin\.opc_cli\opc\config.json
```

### 主要配置项

```json
{
  "tts_engine": "qwen",
  "qwen_model_size": "0.6B",
  "qwen_mode": "custom_voice",
  "qwen_speaker": "Vivian",
  "qwen_language": "Auto",
  "backend": "cuda",
  "model_cache_dir": "D:\\AI\\ComfyUI-aki-v3\\ComfyUI\\models\\TTS",
  "model_source": "modelscope",
  "output_dir": "C:\\Users\\Kevin\\AppData\\Local\\Temp",
  "dashboard_host": "0.0.0.0",
  "dashboard_port": 12080,
  "cut_server_port": 12082
}
```

### 批量处理示例

```bash
# 创建批处理脚本
for /L %i in (1,1,10) do (
  python opc.py tts "第 %i 句话" -e qwen --speaker Vivian -o "output_%i.mp3"
)
```

### 与 ComfyUI 集成

您的本地模型路径：
```
D:\AI\ComfyUI-aki-v3\ComfyUI\models\TTS\Qwen\
```

opc-cli 已配置使用这些模型，无需重复下载。

---

## 性能优化

### GPU 优化

```bash
# 安装 FlashAttention（减少显存，提速）
pip install -U flash-attn --no-build-isolation
```

### 模型选择建议

| 使用场景 | 推荐模型 |
|----------|----------|
| 日常测试 | edge-tts（在线） |
| 高质量输出 | qwen 0.6B |
| 专业制作 | qwen 1.7B |
| 实时应用 | edge-tts |
| 批量处理 | qwen 0.6B |

### 批量生成优化

```python
import asyncio
from qwen_tts import Qwen3TTSModel

model = Qwen3TTSModel.from_pretrained(
    "D:\\AI\\ComfyUI-aki-v3\\ComfyUI\\models\\TTS\\Qwen\\Qwen3-TTS-12Hz-0.6B-CustomVoice",
    device_map="cuda:0",
    dtype=torch.bfloat16,
)

texts = ["第一句", "第二句", "第三句"]
wavs, sr = model.generate_custom_voice(
    text=texts,
    language=["Chinese"] * len(texts),
    speaker=["Vivian"] * len(texts),
)
```

---

## 总结

### 您现在拥有的功能

✅ **TTS 语音合成**
- edge-tts（在线，322 音色）
- qwen-tts（本地，9 音色，3 模式）

✅ **模型管理**
- 本地 ComfyUI 模型集成
- 自动模型缓存
- 多模型支持（0.6B/1.7B）

✅ **Dashboard**
- Web 管理界面
- Cut 视频剪辑功能
- 远程访问支持

✅ **Windows 完全支持**
- GPU 加速（CUDA）
- 系统托盘集成
- 批处理支持

### 下一步

1. 测试不同音色和模式
2. 探索 Dashboard 功能
3. 尝试视频剪辑（Cut）
4. 集成到您的项目中

---

## 技术支持

- 📧 问题反馈：https://github.com/kevinmw/OPC/issues
- 📚 完整文档：https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice
- 🎥 视频教程：https://www.bilibili.com/video/BV1aXQbBcEFk

---

**享受 AI 语音合成吧！** 🎉
