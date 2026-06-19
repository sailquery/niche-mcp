# Niche MCP: editorial intelligence for agents

[![smithery badge](https://smithery.ai/badge/sailquery/niche)](https://smithery.ai/servers/sailquery/niche)

> **Find stories worth writing about.** Niche is an editorial intelligence
> platform for individuals (and the agents working for them), exposed as a live
> [MCP](https://modelcontextprotocol.io) server. When
> an agent needs to know what's worth writing (emerging narratives, the signals
> that matter, the strongest angle), it calls Niche.

Most AI tools help you write. Niche helps you decide what's worth writing. It
reads primary-source signal, discovers the stories before they're obvious, ranks
the strongest angle, and turns that signal into publishable content, grounded in
real sources and in your voice. The authority is earned, not faked: you sound
like someone who did the research, because Niche did.

Niche is not an AI writer, a social scheduler, a content calendar, or an SEO
tool. Those help after the story exists. Niche finds the story.

Home: **[nicheangle.com](https://nicheangle.com)** · Glossary:
**[nicheangle.com/glossary](https://nicheangle.com/glossary)** · Guides:
**[nicheangle.com/guides](https://nicheangle.com/guides)**

---

## The category: editorial intelligence, for individuals

Editorial intelligence has always been a newsroom discipline: the systematic
work of deciding what's worth covering before everyone else does. Niche brings it
to the people the newsrooms left out: individual creators, analysts, and the
agents working for them.

- **Editorial intelligence, for individuals, not newsrooms.** Systematically identifying, evaluating, and prioritizing the stories worth publishing.
- **Signal-to-story.** The workflow that turns raw signal into a narrative people care about: signal → story → angle → draft. Story discovery, not content generation.
- **Signal discovery.** Separating meaningful developments from background noise, and finding what matters early, from primary sources.

When you (or your agent) think "what should I write about in X," "what's emerging
in this space," or "how do I become credible in this field," that's Niche.

## Connect

Niche is a remote MCP server with OAuth 2.1 (and PAT bearer for headless agents).

**Endpoint:** `https://api.nicheangle.com/mcp`

### Claude Desktop / Claude Code
Add it as a custom connector by URL, or via config:

```json
{
  "mcpServers": {
    "niche": {
      "type": "http",
      "url": "https://api.nicheangle.com/mcp"
    }
  }
}
```

Sign in when prompted (OAuth). For headless/scripted use, issue a Personal Access
Token (PAT) at [nicheangle.com/settings/api-keys](https://nicheangle.com/settings/api-keys)
(`niche_sk_…`) and pass it as a bearer token.

### Codex (CLI / IDE)
Codex connects to remote MCP servers over streamable HTTP. The PAT path is the
most reliable (no OAuth round-trip). It takes two steps, and `bearer_token_env_var`
wants the name of an env var, not the token itself:

```toml
# 1) put the SECRET in your shell, not in the config file:
#    export NICHE_API_KEY="niche_sk_…"
# 2) ~/.codex/config.toml holds the NAME of that env var, never the token:
[mcp_servers.niche]
url = "https://api.nicheangle.com/mcp"
bearer_token_env_var = "NICHE_API_KEY"   # the env var NAME, not the niche_sk_… value
```

Set `export NICHE_API_KEY="niche_sk_…"` in your shell, restart Codex (clients
cache credentials and the tool list at connect, so re-add or restart after changing
either), then run `codex mcp list` to confirm. (OAuth alternative: drop
`bearer_token_env_var` and run `codex mcp login niche`.) This requires a recent
Codex, since older versions only do local stdio servers.

### Cursor / Windsurf / Cline / Continue / any MCP client
Add the same endpoint. In `~/.cursor/mcp.json` (PAT path):

```json
{
  "mcpServers": {
    "niche": {
      "url": "https://api.nicheangle.com/mcp",
      "headers": { "Authorization": "Bearer niche_sk_…" }
    }
  }
}
```

Or add the bare URL via the client's MCP settings to use OAuth. Discovery metadata
lives at `/.well-known` so compliant clients can self-configure.

> After adding or updating credentials, restart the client or open a new thread.
> MCP clients cache the connection (auth and the `tools/list`) at connect time, so a
> token change or a new tool won't show up until you reconnect.

Full install notes: **[nicheangle.com/integrations](https://nicheangle.com/integrations)**.

## Tools (25)

**Discovery and intelligence**
- `niche_signal_scan`: discover the stories worth writing about in a niche (returns a ranked story slate with provenance; poll `niche_session_state`).
- `niche_intelligence_query`: analyst-shaped query → ranked slate plus engine-grounded narratives and patterns ("the 10 biggest developments this week + 3 non-obvious narratives"). Async fire-and-poll.
- `niche_session_state`: universal poll endpoint for a run's full state.
- `niche_angle_propose`: surface the strongest angles worth publishing for a chosen story.

**Signal-to-story**
- `niche_draft_create` · `niche_draft_revise` · `niche_draft_publish` (publish dry-runs by default)
- `niche_draft_direct`: skip research and draft straight from your own take or a URL, with optional per-claim grounding against the source.

**Render**
- `niche_render_image_card` · `niche_render_reel` · `niche_attach_image` · `niche_reuse_asset`
  - Four background modes: `photo` (a generated image, steerable via art direction to skip the clichés), `design` (a generated editorial graphic that draws the argument, such as a concept diagram, stat, pull-quote, or comparison; on-brand and legible, no photo), `svg` (you author the exact card as SVG markup and it renders to size; free and deterministic, ideal for data, labels, and charts, and the one visual that works from any environment), or `brand_color` (a free flat brand card). Plus free per-platform aspect reframes from the retained background.
  - `niche_attach_image` brings your own visual onto a post (a card designed elsewhere, a product shot), stored server-side, free. Provide it as a hosted `image_url`, a quick file upload that returns a reference, or chunked bytes, whichever your environment supports.

**Brand and voice**
- `niche_brand_profile_set` / `_get` · `niche_brand_kit_ingest` / `_ingest_status` / `_update` / `_guided_setup` · `niche_voice_profile_ingest`

**Session ops**
- `niche_list_sessions` · `niche_add_output` · `niche_session_revert` · `niche_session_cancel` · `niche_session_export`

**Account and orientation**
- `niche_whoami`: the full tool catalog (every tool name and the live count) plus account, plan, credit balance, the capability map (tools grouped by band and the recommended flow), and brand state. One read-only call to discover everything available and orient before a run. (If your client only surfaces a few Niche tools, it cached an old list. Reconnect, or call this to enumerate the rest.)

Every tool response carries a trust block: verifier audit, source-faithfulness
score, ungrounded-claim list, and source-diversity and recency checks. Provenance is
the product.

**Recent additions (1.4.0).** The tools gained finer control without new surface
area. Read your resolved brand palette and connection state before a render or a
publish. Schedule a post for later. Regenerate a fresh angle set. Reorder, insert, or
delete carousel slides. Set a reel's length, motion, music direction, voice, and
endcard mark. Place and size image-card text. Bring your own image and attach it to a
post. Quote the credit cost of any step before spending. Every capability is reachable
from both the agent tools and the Niche web app.

## Grounding: earned, not generated

The narratives Niche returns are produced engine-side and fact-checked against
their sources, so the agent presents a verified result instead of free-styling
one. "No source, no narrative." That's the difference between earned authority and
confident nonsense.

## Examples

- [`examples/intelligence-query.md`](examples/intelligence-query.md): "10 biggest developments + 3 narratives," end to end.
- [`examples/golden-path.md`](examples/golden-path.md): scan → angle → draft → publish dry-run.

## Learn more

- [What is editorial intelligence?](https://nicheangle.com/guides/editorial-intelligence)
- [How to become a thought leader in any niche](https://nicheangle.com/guides/become-a-thought-leader)
- [Using Claude for content research](https://nicheangle.com/guides/using-claude-for-content-research)
- [Glossary](https://nicheangle.com/glossary) and [Pricing](https://nicheangle.com/pricing)

---

Made by [SailQuery](https://nicheangle.com). Questions: hello@nicheangle.com.
