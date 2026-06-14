# Example — the golden path (signal → story → angle → draft → publish)

The full editorial workflow as agent tool calls. Each step returns fast; you poll
`niche_session_state` for the slow stages (discovery, generation).

```
# 1. Discover the stories worth writing about
niche_signal_scan(niche = "AI infrastructure for solo developers")
  → { session_id, status: "initializing" }

# 2. Poll until the ranked slate is ready
niche_session_state(session_id)
  → status: "cp1_awaiting_story", stories: [ {id, title, summary, provenance, ...}, ... ]

# 3. Pick a story → get the strongest angles worth publishing
niche_angle_propose(session_id, story_id = "story_3")
  → angles: [ {id, frame, hook, tension, cta_direction, ...}, ... ]

# 4. Lock an angle → platform-native drafts (in the user's voice)
niche_draft_create(session_id, angle_id = "angle_2")
  → poll niche_session_state until outputs[] is populated
  → each output carries a trust block (verifier audit, source faithfulness, ungrounded claims)

# 5. Publish — the ONLY irreversible step. dry_run defaults to true.
niche_draft_publish(session_id, platform = "linkedin", dry_run = true)
```

## Notes for agents

- **Bind a brand profile** with `brand_id` (set via `niche_brand_profile_set`) to
  thread voice, lexicon, framing, and verifier overrides through every stage.
- **Trust block on every output** — check `source_faithfulness_score` and the
  ungrounded-claim list before presenting or publishing.
- **Poll, don't hammer** — `niche_session_state` supports a `wait` long-poll.
- Skip discovery entirely with the "bring your own content" path: hand Niche your
  Substack / article / take and it drafts straight from it (signal-to-story).
