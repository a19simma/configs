import { expect, mock, test } from 'claude-code/testing'

const BAND = {
  plugin: 'io-meter',
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 120 },
  viewport: { columns: 125, rows: 40 },
} as const

test('band shows context, api split and slowest tools', async ($, on) => {
  const clock = mock.clock(on)
  let tokens = 40_000

  on('session.usage', async () => ({
    value: {
      startedAt: 0,
      rateLimits: [],
      cost: { usd: 1.5 },
      context: { tokens, window: 1_000_000, breakdown: { rawMaxTokens: 200_000 } },
    },
  }) as never)

  on('session.measure', async (_$, e) => ({ changed: e.changed }))

  on('tool.call', async (_$, e) => {
    await clock.sleep(e.tool === 'Bash' ? 3_000 : 200)
    return { result: 'ok' } as never
  })

  on('turn.step', async function* (_$, e) {
    await clock.sleep(e.agentId ? 4_000 : 2_000)
    return { turnId: e.turnId, index: e.index, answer: '', toolUses: [], stopReason: 'end_turn', usage: null } as never
  })

  const run = async (p: Promise<unknown>) => {
    await clock.settle()
    await clock.advance(5_000)
    await p
  }

  await run($.tool.call({ tool: 'Bash', command: 'sleep 3' } as never))
  await run($.tool.call({ tool: 'Bash', command: 'sleep 3' } as never))
  await run($.tool.call({ tool: 'Read', file_path: '/etc/hosts' } as never))
  await run($.tool.call({ tool: 'Agent', description: 'x', prompt: 'y' } as never))
  await run($.tool.call({ tool: 'mcp__plane__issue_create', title: 'a' } as never))
  await run($.tool.call({ tool: 'mcp__plane__issue_list', query: 'b' } as never))

  const drain = async (s: AsyncIterable<unknown>) => {
    for await (const _ of s) void _
  }
  const step = (agentId?: string) =>
    drain($.turn.step({ turnId: 't', index: 0, model: 'm', messageCount: 1, ...(agentId ? { agentId } : {}) } as never) as never)

  await run(step())
  await run(step())
  await run(step('sub-1'))

  const measured = { context: { window: 1_000_000 }, rateLimits: [], changed: ['context'] } as never
  await $.session.measure(measured)
  tokens = 150_000
  await $.session.measure(measured)

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ ...BAND, surface } as never)
    const shown = (await ui.findAll({ type: 'Text' })).map(t => t.text).join('|')

    expect(shown).toMatch(/Storm/)
    expect(shown).toMatch(/75% of context/)
    expect(shown).toMatch(/150\.0k \/ 200\.0k/)
    expect(shown).toMatch(/▲ \+110\.0k/)
    expect(shown).toMatch(/\$1\.50/)
    expect(shown).toMatch(/^.*total \(p90\) │ api \|4\.0s\| \(2\.0s\)\| \+ sub \|4\.0s\| \(4\.0s\)/)
    expect(shown).toMatch(/Bash 6\.0s \(3\.0s\)/)
    expect(shown).toMatch(/Read 0\.2s \(0\.2s\)/)
    expect(shown).not.toMatch(/Agent/)
    expect(shown).toMatch(/│ plane 0\.4s \(0\.2s\)/)
    expect(shown).not.toMatch(/mcp__/)
    await ui.unmount()
  }
})

test('band yields to a survey', async ($, on) => {
  on('ui.render', async ($$, e) => {
    const { Text } = $$.ui.resolve(e)
    return h(Text, { key: 'engine' }, 'engine') as never
  })
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal', props: { ...BAND.props, hasSurvey: true } } as never)
  expect(await ui.find({ type: 'Text', text: 'engine' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: /context/ })).toBeUndefined()
  await ui.unmount()
})
