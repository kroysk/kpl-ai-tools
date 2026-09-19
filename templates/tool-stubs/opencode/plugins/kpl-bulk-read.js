import { readFileSync, existsSync } from "node:fs"
import { join } from "node:path"

class KplDeny extends Error {}

function loadPolicy(root) {
  const defaults = {
    minLines: 500,
    bashWide: ["cat", "head", "tail", "less", "more"],
    narrowPipe: ["grep", "rg", "findstr", "awk", "sed"],
    denyMessage:
      "File exceeds the KPL read threshold (default 500 lines). Load skill bulk-read. Use Grep or Read with offset/limit. Do not cat or Read the whole file. After the summary, Read only the span you will edit.",
  }
  const path = join(root, "agents", "io-policy.json")
  if (!existsSync(path)) return defaults
  try {
    return { ...defaults, ...JSON.parse(readFileSync(path, "utf8")) }
  } catch {
    return defaults
  }
}

function lineCount(filePath) {
  if (!filePath || !existsSync(filePath)) return null
  try {
    const text = readFileSync(filePath, "utf8")
    if (text.length === 0) return 0
    return text.split(/\r?\n/).length
  } catch {
    return null
  }
}

function resolveFile(root, rel) {
  if (!rel) return null
  if (existsSync(rel)) return rel
  const joined = join(root, rel)
  if (existsSync(joined)) return joined
  return null
}

function hasNarrowPipe(command, needles) {
  const src = String(command || "")
  return (needles || []).some((n) => new RegExp(`\\|\\s*${n}\\b`, "i").test(src))
}

function isWideBash(command, wide) {
  const alt = (wide || []).map((w) => w.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|")
  return new RegExp(`(^|[;&\\n]|&&|\\|)\\s*(${alt})\\b`, "i").test(String(command || ""))
}

function bashFiles(command) {
  const tokens = String(command || "").match(/"[^"]*"|'[^']*'|[^\s;|&]+/g) || []
  const files = []
  for (const tok of tokens) {
    if (/^(cat|head|tail|less|more)$/i.test(tok)) continue
    if (tok.startsWith("-")) continue
    const unquoted = tok.replace(/^['"]|['"]$/g, "")
    if (/[/\\.]/.test(unquoted)) files.push(unquoted)
  }
  return files
}

export const KplBulkRead = async ({ directory }) => {
  return {
    "tool.execute.before": async (input, output) => {
      try {
        if (process.env.KPL_READ_MIN_LINES === "0") return
        const root = directory || process.cwd()
        const policy = loadPolicy(root)
        let min = Number(policy.minLines) || 500
        if (process.env.KPL_READ_MIN_LINES) {
          const n = Number(process.env.KPL_READ_MIN_LINES)
          if (!Number.isNaN(n)) min = n
        }
        if (min <= 0) return

        const tool = String(input.tool || "").toLowerCase()
        const args = (output && output.args) || {}

        if (tool === "read") {
          if (args.offset != null || args.limit != null) return
          const filePath = args.filePath || args.path || args.file_path
          const resolved = resolveFile(root, filePath)
          if (!resolved) return
          const lines = lineCount(resolved)
          if (lines != null && lines >= min) throw new KplDeny(policy.denyMessage)
          return
        }

        if (tool === "bash") {
          const command = args.command || ""
          if (hasNarrowPipe(command, policy.narrowPipe)) return
          if (!isWideBash(command, policy.bashWide)) return
          for (const rel of bashFiles(command)) {
            const resolved = resolveFile(root, rel)
            if (!resolved) continue
            const lines = lineCount(resolved)
            if (lines != null && lines >= min) throw new KplDeny(policy.denyMessage)
          }
        }
      } catch (err) {
        if (err instanceof KplDeny) throw err
        // fail-open
      }
    },
  }
}
