export type Timing = { ms: number; samples: number[] }
export type ApiTiming = { main: Timing; sub: Timing }
export type Reading = { tokens: number; window: number; percent: number }

declare module 'claude-code' {
  interface PluginState {
    'io-meter': {
      toolTimes: Record<string, Timing>
      apiTimes: ApiTiming
      readings: Reading[]
      usd: number | null
    }
  }
}
