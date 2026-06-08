#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
# ]
# ///

import sys
import json
import re

def modify_command(command: str) -> str:
    # 1. 移除 --trailer "Made-with: Cursor"
    # 兼容转义引号 \" 和普通引号 "
    new_command = re.sub(r'--trailer\s+["\\]+Made-with:\s*Cursor["\\]+', '', command)

    # 2. 处理 git commit 并添加 mise exec --
    # 针对复合命令如 cd apps/server && git commit
    if "git commit" in new_command and "mise exec -- git commit" not in new_command:
        new_command = re.sub(r'\bgit commit\b', 'mise exec -- git commit', new_command)

    # 3. 替换连续的普通空格为单个空格，但保留换行符（heredoc 重要）
    new_command = re.sub(r' +', ' ', new_command).strip()

    return new_command

def main():
    try:
        # 从 stdin 读取 JSON
        input_str = sys.stdin.read()
        if not input_str:
            sys.exit(0)

        input_data = json.loads(input_str)
    except Exception:
        sys.exit(0)

    # --- 识别客户端类型 ---
    # Cursor 通常包含 cursor_version 字段，或者 hook_event_name 是小驼峰
    # Claude Code 通常包含 session_id 且 hook_event_name 是大驼峰
    is_cursor = "cursor_version" in input_data or input_data.get("hook_event_name") == "preToolUse"

    # --- 统一提取命令 ---
    # Claude: tool_input.command
    # Cursor: command (beforeShellExecution) 或 tool_input.command (preToolUse)
    tool_input = input_data.get("tool_input", {})
    command = input_data.get("command") or tool_input.get("command", "")
    tool_name = input_data.get("tool_name")

    # --- 逻辑判断 (兼容 Shell/Bash 工具名) ---
    if (tool_name in ["Shell", "Bash", None]) and ("git commit" in command):
        new_command = modify_command(command)

        # --- 针对不同客户端返回对应的 Schema ---
        if is_cursor:
            # Cursor Schema: 扁平结构，使用 updated_input (下划线)
            output = {
                "decision": "allow",
                "updated_input": {
                    "command": new_command
                },
                "reason": "Cursor Hook (uv): Added mise prefix and removed Cursor trailer"
            }
        else:
            # Claude Schema: 嵌套结构，使用 updatedInput (小驼峰)
            event_name = input_data.get("hook_event_name", "PreToolUse")
            output = {
                "hookSpecificOutput": {
                    "hookEventName": event_name,
                    "permissionDecision": "allow",
                    "updatedInput": {
                        "command": new_command
                    },
                    "permissionDecisionReason": "Claude Hook (uv): Added mise prefix and removed Cursor trailer"
                }
            }

        print(json.dumps(output))
    else:
        # 非目标命令，直接退出让原始流程继续
        sys.exit(0)

if __name__ == "__main__":
    main()
