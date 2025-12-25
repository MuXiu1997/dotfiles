## Language Preference
- **Always respond in Chinese**: Regardless of the language used in the user's query, always provide responses in Chinese, unless explicitly requested otherwise (e.g., for translation tasks).
- **Technical Terminology**: Maintain standard English technical terms when necessary, but ensure the overall explanation and context are in Chinese.

## Scripting & Execution Preferences
Unless otherwise specified, when I ask for a script, always follow these defaults:
1. **Runtime**: Deno.
2. **Shebang**: Use `#!/usr/bin/env -S deno run --quiet --allow-all --no-config --ext=ts` as the first line.
3. **Library**: Use the `zx` library for shell operations with: `import { $ } from 'npm:zx@8.8.5'`.
4. **Coding Style**: Execute shell commands using zx's template strings (e.g., $`cat ${file}`).
5. **Execution**: If you need to run the script for me, use the following command in the terminal:
   `deno run --quiet --allow-all --no-config --ext=ts <filepath>`

### zx
#### Changes the current working directory.
cd('/tmp')
await $`pwd` // => /tmp
