# MoonChartSVG Competition Acceptance Checklist

## Repository

- [x] GitHub: https://github.com/Mitsuha11zz/MoonChartSVG
- [x] GitLink: https://gitlink.org.cn/Mitsuha/MoonChartSVG
- [x] Module namespace: `Mitsuha11zz/MoonChartSVG`
- [x] Apache-2.0 license at repository root
- [x] 37 meaningful commits currently present

## Core behavior

- [x] Nine chart types share Builder-style APIs
- [x] Pie, donut, and radar coordinates cover all quadrants
- [x] Single-slice pie and donut charts use complete-circle paths
- [x] Axis steps support small and large numeric ranges
- [x] Non-positive pie/donut data avoids invalid coordinates
- [x] Quoted CSV, escaped quotes, embedded newlines, and CRLF are supported
- [x] Empty statistics do not divide by zero or index empty arrays
- [x] SVG/XML/HTML user text is escaped
- [x] Builder inputs are defensively copied

## Required gates

- [x] `moon check --deny-warn --target all`
- [x] `moon fmt --check`
- [x] `moon info --target all`
- [x] `moon test --deny-warn --target all`
- [x] `moon coverage analyze`
- [x] `moon run cmd/main`
- [x] CI explicitly runs check, format, info, test, and coverage

The current CLI has no `--deny-warn` option for `moon fmt` or `moon info`.
`moon fmt --check` and a clean all-target `moon info` run are the documented
equivalent gates for this toolchain.

## Current evidence

- [x] 25 MoonBit files
- [x] 5,280 MoonBit lines
- [x] 93 tests
- [x] Version prepared as `0.1.7`
- [x] Proposal Markdown kept concise
- [x] One-page proposal PDF generator included
- [ ] Publish `0.1.7` and verify `moon add Mitsuha11zz/MoonChartSVG`
- [ ] Confirm the newest GitHub Actions run after pushing this revision
