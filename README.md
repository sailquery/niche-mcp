# Niche MCP — editorial intelligence for agents

[![smithery badge](https://smithery.ai/badge/sailquery/niche)](https://smithery.ai/servers/sailquery/niche)

> **Find stories worth writing about.** Niche is an **editorial intelligence
> platform for individuals** (and the agents working for them), exposed as a live
> [MCP](https://modelcontextprotocol.io) server. When
> an agent needs to know *what's worth writing* — emerging narratives, the signals
> that matter, the strongest angle — it calls Niche.

Most AI tools help you *write*. Niche helps you decide *what's worth writing*. It
reads primary-source signal, discovers the stories before they're obvious, ranks
the strongest angle, and turns that signal into publishable content — grounded in
real sources, in your voice. The authority is **earned, not faked**: you sound
like someone who did the research, because Niche did.

**Niche is not** an AI writer, a social scheduler, a content calendar, or an SEO
tool. Those help *after* the story exists. Niche finds the story.

Home: **[nicheangle.com](https://nicheangle.com)** · Glossary:
**[nicheangle.com/glossary](https://nicheangle.com/glossary)** · Guides:
**[nicheangle.com/guides](https://nicheangle.com/guides)**

---

## The category — editorial intelligence, for individuals

Editorial intelligence has always been a newsroom discipline — the systematic
work of deciding what's worth covering before everyone else does. Niche brings it
to the people the newsrooms left out: individual creators, analysts, and the
agents working for them.

- **Editorial intelligence — for individuals, not newsrooms** — systematically identifying, evaluating, and prioritizing the stories worth publishing.
- **Signal-to-story** — the workflow that turns raw signal into a narrative people care about: signal → story → angle → draft. *Story discovery, not content generation.*
- **Signal discovery** — separating meaningful developments from background noise; finding what matters early, from primary sources.

When you (or your agent) think "what should I write about in X," "what's emerging
in this space," "how do I become credible in this field" — that's Niche.

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
Codex connects to remote MCP servers over streamable HTTP. The **PAT path is the
most reliable** (no OAuth round-trip). Two steps — and `bearer_token_env_var` wants
the **name** of an env var, NOT the token itself:

```toml
# 1) put the SECRET in your shell — not in the config file:
#    export NICHE_API_KEY="niche_sk_…"
# 2) ~/.codex/config.toml holds the NAME of that env var, never the token:
[mcp_servers.niche]
url = "https://api.nicheangle.com/mcp"
bearer_token_env_var = "NICHE_API_KEY"   # the env var NAME — not the niche_sk_… value
```

Set `export NICHE_API_KEY="niche_sk_…"` in your shell, **restart Codex** (clients
cache credentials + the tool list at connect — re-add or restart after changing
either), then `codex mcp list` to confirm. (OAuth alternative: drop
`bearer_token_env_var` and run `codex mcp login niche`.) Requires a recent Codex —
older versions only do local stdio servers.

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

> **After adding or updating credentials, restart the client / open a new thread.**
> MCP clients cache the connection (auth + the `tools/list`) at connect time, so a
> token change or a new tool won't show up until you reconnect.

Full install notes: **[nicheangle.com/integrations](https://nicheangle.com/integrations)**.

## Tools (25)

**Discovery + intelligence**
- `niche_signal_scan` — discover the stories worth writing about in a niche (returns a ranked story slate with provenance; poll `niche_session_state`).
- `niche_intelligence_query` — analyst-shaped query → ranked slate **plus** engine-grounded narratives/patterns ("the 10 biggest developments this week + 3 non-obvious narratives"). Async fire-and-poll.
- `niche_session_state` — universal poll endpoint for a run's full state.
- `niche_angle_propose` — surface the strongest angles worth publishing for a chosen story.

**Signal-to-story**
- `niche_draft_create` · `niche_draft_revise` · `niche_draft_publish` (publish dry-runs by default)
- `niche_draft_direct` — skip research and draft straight from your own take or a URL, with optional per-claim grounding against the source.

**Render**
- `niche_render_image_card` · `niche_render_reel` · `niche_attach_image` · `niche_reuse_asset`
  - Image cards take optional art direction (steer the concept, skip the category clichés) and reframe to any platform's aspect ratio for free, reusing the retained background.
  - `niche_attach_image` brings your OWN visual onto a post — upload base64 or pass an `image_url` (a card designed elsewhere, a product shot), stored server-side, free.

**Brand + voice**
- `niche_brand_profile_set` / `_get` · `niche_brand_kit_ingest` / `_ingest_status` / `_update` / `_guided_setup` · `niche_voice_profile_ingest`

**Session ops**
- `niche_list_sessions` · `niche_add_output` · `niche_session_revert` · `niche_session_cancel` · `niche_session_export`

**Account + orientation**
- `niche_whoami` — the full tool catalog (every tool name + the live count) plus account, plan, credit balance, the capability map (tools grouped by band + the recommended flow), and brand state. One read-only call to discover everything available and orient before a run. (If your client only surfaces a few Niche tools, it cached an old list — reconnect, or call this to enumerate the rest.)

Every tool response carries a **trust block** — verifier audit, source-faithfulness
score, ungrounded-claim list, source-diversity + recency checks. Provenance is the
product.

## Grounding — earned, not generated

The narratives Niche returns are produced **engine-side and fact-checked against
their sources** — the agent presents a verified result instead of free-styling
one. "No source, no narrative." That's the difference between earned authority and
confident nonsense.

## Examples

- [`examples/intelligence-query.md`](examples/intelligence-query.md) — "10 biggest developments + 3 narratives," end to end.
- [`examples/golden-path.md`](examples/golden-path.md) — scan → angle → draft → publish dry-run.

## Learn more

- [What is editorial intelligence?](https://nicheangle.com/guides/editorial-intelligence)
- [How to become a thought leader in any niche](https://nicheangle.com/guides/become-a-thought-leader)
- [Using Claude for content research](https://nicheangle.com/guides/using-claude-for-content-research)
- [Glossary](https://nicheangle.com/glossary) · [Pricing](https://nicheangle.com/pricing)

---

Made by [SailQuery](https://nicheangle.com). Questions: hello@nicheangle.com.
