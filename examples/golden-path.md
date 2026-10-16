# Read a briefing and research a follow-up

Ask your assistant:

> Read the latest Founders briefing. Tell me what changed and link to the reporting.

Example tool arguments:

```json
{"name":"niche_feed_read","arguments":{"niche":"founders"}}
```

Use the returned reporting dates, source links, and story status. `quiet` means
there is no new briefing content; `no_edition` means a briefing is not available.
A dated read accepts `date` in `YYYY-MM-DD` format.

For a follow-up that needs fresh research:

```json
{"name":"niche_signal_scan","arguments":{"niche":"Shopify updates and AI tools for founders","recency":"week","recency_strict":true}}
```

Keep the returned `session_id`. Poll `niche_session_state` with that ID and
`wait: 30`. When the status is `cp1_awaiting_story`, inspect `stories` and their
source links. If the scan fails, report the failure rather than treating it as
an empty news day.

To explore an angle, call `niche_angle_propose` with that `session_id` and a
`story_id` from the returned list. Poll until `cp2_awaiting_angle` and read
`angles`. Present the angle as interpretation and keep its supporting sources
visible.
