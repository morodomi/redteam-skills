# Recommended Hooks

Add to ~/.claude/settings.json:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$TOOL_INPUT\" | grep -qF -- '--no-verify'; then echo 'BLOCK: --no-verify is prohibited' >&2; exit 2; fi"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Session ended: Remember to run tests'"
          }
        ]
      }
    ]
  }
}
```

## Usage

1. Copy the above
2. Add to ~/.claude/settings.json
3. Restart Claude Code

## Notes

- exit 2: Block (feedback to Claude)
- exit 0: Allow
- TOOL_INPUT: Passed as JSON
