# Research a question with sourced synthesis

Ask your assistant:

> What changed in AI developer tools this week? Find up to ten developments and
> identify themes supported by the reporting.

Example tool arguments:

```json
{
  "name": "niche_intelligence_query",
  "arguments": {
    "subject": "AI developer tools and new model releases",
    "count": 10,
    "window": "week",
    "recency_strict": true,
    "synthesis": "narratives"
  }
}
```

The call returns a `session_id`. Poll `niche_session_state` using that ID until
`status` is `cp1_awaiting_story`. The sourced developments are in `stories`.
Synthesis may finish later: use `wait_until: "synthesis"` with `wait: 30` until
it arrives or a shortfall is reported.

Present the returned themes with their supporting stories and source links.
Fewer than ten developments is a valid result when reporting is limited.
Do not invent themes to reach a requested count.

Use `synthesis: "patterns"` to request broader developments, or `"none"` for
stories only. The optional `lens` can be `mainstream`, `emerging`, or `investment`.
For an existing briefing, use `niche_feed_read` instead of starting a scan.
