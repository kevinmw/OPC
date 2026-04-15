"""
自定义卡拉 OK 字幕生成器

效果：白色底色 + 逐字变黄色
"""

import sys
import os

# 添加 scripts 目录到路径
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(script_dir, 'scripts'))

from scripts.asr.subtitle_gen import ASSSubtitleStyle, generate_ass_karaoke
from scripts.asr.qwen_asr_engine import asr_align
import json

def create_yellow_white_karaoke_style():
    """创建白色底色 + 黄色高亮的卡拉 OK 样式"""

    style = ASSSubtitleStyle()

    # 修改颜色配置
    style.highlight_color = "&H0000FFFF"  # 黄色 (BGR: FF FF 00)
    style.dim_color = "&H00FFFFFF"        # 白色底色 (BGR: FF FF FF)
    style.color = "&H00FFFFFF"            # 白色

    # 其他样式调整
    style.size = 60                       # 字体大小
    style.bold = True                     # 粗体
    style.border_width = 4                # 边框宽度
    style.border_color = "&H00000000"     # 黑色边框
    style.margin_v = 120                  # 垂直位置

    return style


def generate_karaoke_subtitle(audio_path, language="Chinese", output_path=None):
    """生成卡拉 OK 字幕"""

    if output_path is None:
        output_path = audio_path.replace('.mp3', '_karaoke.ass')
        output_path = output_path.replace('.wav', '_karaoke.ass')
        output_path = output_path.replace('.mp4', '_karaoke.ass')

    print(f"[Karaoke] Audio: {audio_path}")
    print(f"[Karaoke] Output: {output_path}")
    print(f"[Karaoke] Style: White base color -> Yellow highlight")

    # 1. 运行 ASR
    print("[ASR] Running speech recognition...")
    asr_result = asr_align(audio_path, language=language, model_size="0.6B")

    # 2. 创建自定义样式
    style = create_yellow_white_karaoke_style()

    # 3. 生成 ASS 卡拉 OK 字幕
    print("[Karaoke] Generating karaoke subtitles...")
    generate_ass_karaoke(asr_result, output_path, style=style)

    print(f"[SUCCESS] Karaoke subtitle generated: {output_path}")
    print(f"\n[USAGE]")
    print(f"1. Play audio/video with VLC/MPV player")
    print(f"2. Load subtitle: {output_path}")
    print(f"3. Enjoy karaoke effects!")

    return output_path


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description='生成自定义卡拉 OK 字幕')
    parser.add_argument('audio', help='音频文件路径')
    parser.add_argument('--language', '-l', default='Chinese', help='语言')
    parser.add_argument('--output', '-o', help='输出文件路径')

    args = parser.parse_args()

    generate_karaoke_subtitle(args.audio, args.language, args.output)
