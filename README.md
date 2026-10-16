# Niche MCP: your niche, followed for you

Niche follows the news in your field and brings the briefing into your assistant.
Read what changed, inspect the reporting, research a topic, and explore angles on
a story, with links back to the sources.

Browse the [public briefings](https://nicheangle.com/n), including Founders and
AI Leaders, or follow a niche you describe at [nicheangle.com](https://nicheangle.com).
Briefings are available on the website and by email. MCP access requires
[Niche Pro](https://nicheangle.com/pricing).

## Connect

Add this remote MCP endpoint in your assistant's connector settings:

```text
https://api.nicheangle.com/mcp
```

Sign in with your Niche account when prompted. The server supports OAuth and
Personal Access Tokens. For clients that use a bearer token, create one in
[API key settings](https://nicheangle.com/settings/api-keys) and supply it through
your client's secret or environment-variable settings. Keep tokens out of shared
configuration files and source control.

The included [mcp.json](mcp.json) contains the endpoint without credentials.
See [connection instructions](https://nicheangle.com/integrations) for setup.
Reconnect your client after a catalog update so it loads the current tools.

## Tools

The briefing product exposes eight tools. The live `tools/list` response is the
reference for supported parameters.

| Tool | Purpose |
| --- | --- |
| `niche_feed_read` | Read a niche's latest briefing or one from a specified date, with stories and source links. |
| `niche_signal_scan` | Research a niche you describe and return a session ID for the sourced story list. |
| `niche_intelligence_query` | Research a question, optionally adding sourced themes or patterns across the stories. |
| `niche_session_state` | Read scan progress, stories, synthesis, and available angles. |
| `niche_angle_propose` | Explore angles on one story from a scan. |
| `niche_list_sessions` | Find your earlier scans by topic or status. |
| `niche_session_cancel` | Stop a running scan. |
| `niche_whoami` | Check your account plan and the server's current tool catalog. |

Start with `niche_feed_read` when a briefing already covers the question. Use a
scan for new research. Scans return a `session_id`; poll `niche_session_state`
until the stories are ready. Request synthesis explicitly when you want themes
or patterns, and wait for it to finish before presenting it.

Story dates and source links matter. A story newly added to a briefing may have
been reported earlier. A quiet briefing or a short result is valid; do not fill
the gap with invented news. Check the reporting and distinguish facts from angles.

## Examples

- [Read a briefing and research a follow-up](examples/golden-path.md)
- [Ask a research question with sourced synthesis](examples/intelligence-query.md)

## About this repository

This repository contains connection metadata, documentation, and examples for
the hosted Niche MCP service. The service runs at the endpoint above.

[How Niche works](https://nicheangle.com/how) ·
[Pricing](https://nicheangle.com/pricing) ·
[Privacy](https://nicheangle.com/privacy)

Questions: hello@nicheangle.com.
