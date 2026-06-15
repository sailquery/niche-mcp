# Example: the intelligence query

The analyst move: get an intelligence answer, not a single post. This is the same
engine the Niche web app uses, so you and the app get the same grounded narratives.

## Prompt your agent

> "Find the 10 biggest developments in defense tech this week and three non-obvious
> narratives I could publish on LinkedIn."

The agent maps that to:

```
niche_intelligence_query(
  subject = "defense tech, the week's biggest developments",
  count   = 10,
  window  = "week",
  synthesis = "narratives",
  platform  = "linkedin"
)
```

Returns a `session_id` immediately (non-blocking). Poll `niche_session_state`
until `status == cp1_awaiting_story`:

- `stories[]`: the ranked slate of ~10 developments, each with provenance.
- `synthesis[]`: the engine-grounded narratives, each citing real
  `supporting_story_id`s. If the engine can only ground fewer than asked, it
  returns fewer and says why (`synthesis_shortfall_note`). No source, no
  narrative.

Present the narratives rather than synthesizing your own. They're already
fact-checked against the slate.

## Lenses

- `lens: "emerging"`: surface low-coverage, pre-mainstream signal (inverts the authority re-rank).
- `lens: "investment"`: bias toward funding, raise, and term-sheet markers; pairs with `synthesis: "patterns"`.

## Turn a narrative into a post

Pick the narrative's supporting story and draft from there, with no new research run:

```
niche_angle_propose(session_id, story_id)   # the strongest angles for that story
niche_draft_create(session_id, angle_id)    # platform-native draft
niche_draft_publish(session_id, ..., dry_run=true)
```
