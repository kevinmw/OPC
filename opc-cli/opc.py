#!/usr/bin/env python
"""
opc-cli Windows 包装脚本
解决模块导入问题
"""

import sys
import os

# 添加 scripts 目录到 Python 路径
script_dir = os.path.dirname(os.path.abspath(__file__))
scripts_dir = os.path.join(script_dir, 'scripts')
sys.path.insert(0, scripts_dir)

# 现在导入 opc 主模块
if __name__ == "__main__":
    import opc
    opc.main()
