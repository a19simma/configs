import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Reading, Timing } from '../types'

const EMPTY: Timing = { ms: 0, samples: [] }

const tools = atom({ plugin: 'io-meter', key: 'toolTimes' } as const, {})
const api = atom({ plugin: 'io-meter', key: 'apiTimes' } as const, { main: EMPTY, sub: EMPTY })
const readings = atom({ plugin: 'io-meter', key: 'readings' } as const, [])
const usd = atom({ plugin: 'io-meter', key: 'usd' } as const, null)

const SKIP = new Set(['Agent'])
const TOP = 5
const HISTORY = 12
const SAMPLES = 200
const BARS = '▁▂▃▄▅▆▇█'

const FORECAST = [
  { upTo: 25, icon: '☀', word: 'Clear', color: 'yellow' },
  { upTo: 50, icon: '☁', word: 'Cloudy', color: 'cyan' },
  { upTo: 75, icon: '☂', word: 'Showers', color: 'blue' },
  { upTo: 90, icon: '☇', word: 'Storm', color: 'magenta' },
  { upTo: Infinity, icon: '↯', word: 'Compact soon', color: 'red' },
]

function fmt(ms: number): string {
  if (ms < 10_000) return (ms / 1000).toFixed(1) + 's'
  if (ms < 60_000) return Math.round(ms / 1000) + 's'
  const m = Math.floor(ms / 60_000)
  return m + 'm' + String(Math.round((ms % 60_000) / 1000)).padStart(2, '0')
}

function short(n: number): string {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + 'M'
  if (n >= 1_000) return (n / 1_000).toFixed(1) + 'k'
  return String(n)
}

function bucket(tool: string): string {
  const m = /^mcp__(.+?)__/.exec(tool)
  return m ? m[1] : tool
}

function add(t: Timing, ms: number): Timing {
  return { ms: t.ms + ms, samples: [...t.samples, ms].slice(-SAMPLES) }
}

function p90(t: Timing): number {
  const sorted = [...t.samples].sort((x, y) => x - y)
  return sorted[Math.ceil(sorted.length * 0.9) - 1] ?? 0
}

function forecastFor(percent: number) {
  return FORECAST.find(f => percent < f.upTo) ?? FORECAST[FORECAST.length - 1]
}

function chart(rs: Reading[]): string {
  const top = Math.max(...rs.map(r => r.tokens), 1)
  return rs.map(r => BARS[Math.min(BARS.length - 1, Math.floor((r.tokens / top) * (BARS.length - 1)))]).join('')
}

function trend(rs: Reading[]): string {
  const [prev, last] = rs.slice(-2)
  if (!prev || !last) return ''
  const delta = last.tokens - prev.tokens
  if (delta > 0) return '▲ +' + short(delta)
  if (delta < 0) return '▼ ' + short(-delta)
  return 'steady'
}

async function measure($: EngineInterface) {
  const { context: c, cost } = await $.session.usage({ breakdown: 'summary' })
  await update($, usd, () => cost?.usd ?? null)
  const window = Math.min(c.window, c.breakdown?.rawMaxTokens ?? c.window)
  if (!window) return
  const tokens = c.tokens ?? 0
  const reading: Reading = { tokens, window, percent: Math.round((tokens / window) * 100) }
  await update($, readings, rs => {
    const last = rs[rs.length - 1]
    if (last && last.tokens === reading.tokens && last.window === reading.window) return rs
    return [...rs.filter(r => r.tokens > 0), reading].slice(-HISTORY)
  })
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const result = await next(e)
    await measure($)
    return result
  })

  on('session.measure', async ($, e, next) => {
    await measure($)
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    const t0 = await $.clock.now()
    const result = await next(e)
    if (!SKIP.has(e.tool)) {
      const ms = (await $.clock.now()) - t0
      const key = bucket(e.tool)
      await update($, tools, all => ({ ...all, [key]: add(all[key] ?? EMPTY, ms) }))
    }
    return result
  })

  on('turn.step', async function* ($, e, next) {
    const t0 = await $.clock.now()
    const result = yield* next(e)
    const ms = (await $.clock.now()) - t0
    await update($, api, a => (e.agentId ? { ...a, sub: add(a.sub, ms) } : { ...a, main: add(a.main, ms) }))
    return result
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)

    const rs = await read($, readings)
    const cost = await read($, usd)
    const a = await read($, api)
    const t = await read($, tools)
    const wide = (e.viewport?.columns ?? 80) >= 60
    const { Box, Text } = $.ui.resolve(e)

    const top = Object.entries(t)
      .sort((x, y) => y[1].ms - x[1].ms)
      .slice(0, TOP)
    const toolMs = Object.values(t).reduce((s, v) => s + v.ms, 0)

    const now = rs[rs.length - 1]
    const f = now && forecastFor(now.percent)
    const tr = trend(rs)

    const ctxRow = now && f && (
      <Box flexDirection="row">
        <Text color={f.color} bold>
          {f.icon} {f.word}
        </Text>
        <Text>  {now.percent}% of context</Text>
        <Text dimColor>  {short(now.tokens)} / {short(now.window)}</Text>
        {wide && <Text dimColor>   last turns </Text>}
        {wide && <Text color={f.color}>{chart(rs)}</Text>}
        {wide && tr !== '' && <Text dimColor>  {tr}</Text>}
        {cost !== null && <Text dimColor>  · ${cost.toFixed(2)}</Text>}
      </Box>
    )

    const ioRow = (
      <Box flexDirection="row">
        <Text dimColor>total (p90) │ api </Text>
        <Text>{fmt(a.main.ms)}</Text>
        <Text dimColor> ({fmt(p90(a.main))})</Text>
        {a.sub.samples.length > 0 && <Text dimColor> + sub </Text>}
        {a.sub.samples.length > 0 && <Text>{fmt(a.sub.ms)}</Text>}
        {a.sub.samples.length > 0 && <Text dimColor> ({fmt(p90(a.sub))})</Text>}
        <Text dimColor> │ tools </Text>
        <Text>{fmt(toolMs)}</Text>
        {wide &&
          top.map(([name, s]) => (
            <Text key={name} dimColor>
              {' │ '}{name} {fmt(s.ms)} ({fmt(p90(s))})
            </Text>
          ))}
      </Box>
    )

    return (
      <Box flexDirection="column" paddingX={1}>
        {ctxRow}
        {ioRow}
      </Box>
    )
  })
}
