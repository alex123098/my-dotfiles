---
name: "wiki-grill-me"
description: "Interview the user relentlessly about a plan or design, leveraging LLM wiki knowledge to ground questions in past decisions, entities, concepts, and project context. Like grill-me but wiki-informed. Use when the user wants to stress-test a plan, get grilled on their design, or mentions \"grill me\" — AND an LLM wiki exists (or may exist) with relevant project/personal knowledge."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---
## When to Use
Use when the user wants to stress-test a plan, get grilled on their design, or mentions "grill me" — AND an LLM wiki exists (or may exist) with relevant project/personal knowledge. The wiki layer adds context from past decisions, entities, concepts, sources, and insights that a plain grill-me would miss. Also use pre-emptively before major design decisions to surface past learnings.

## Procedure
1. **Recall wiki context before starting.** Call `wiki_recall(query="<user's plan/design topic>")` to find all relevant wiki pages — past decisions, entities, concepts, sources, and skills. Read the top 3-5 matching pages. This grounds the entire grill in what is already known.
2. **Open with wiki-informed framing.** Start the interview by summarizing what the wiki already says about the user's context, past decisions, and relevant entities. Example: "You've previously decided on X for Y reason. Does your current plan Z align with that, or are you diverging?" This surfaces contradictions and hidden assumptions.
3. **Grill one decision at a time.** Walk down each branch of the design tree one question at a time. For each question, first use `wiki_search(query="<relevant terms>")` to see if the wiki has relevant knowledge. If yes, reference it in the question. If not, explore the codebase via `find` or filesystem tools instead. Always provide your recommended answer.
4. **Reference wiki knowledge in every question.** When asking about a specific entity, concept, or past decision, cite the wiki page: 'According to [[concepts/your-service-architecture]], you opted for event-driven communication. Does this design respect that constraint?' This makes the wiki a living decision log.
5. **Save wiki insights after each major branch.** After resolving a significant decision branch, call `wiki_observe(title="<short title>", content="<decision and rationale>")` to record the decision. This builds the wiki while you work.
6. **Create wiki pages for new entities/concepts.** If the discussion surfaces a new entity, concept, or pattern not yet in the wiki, call `wiki_ensure_page(type="entity"|"concept", title="<name>", content="<summary>")` to capture it with wikilinks back to the decision that produced it.
7. **Retro at the end.** Call `wiki_retro(slug="<kebab-case>", title="<short title>", body="<key decisions, design rationale, and resolution>")` to save a durable insight from the session. The insight will be auto-surfaced by wiki_recall in future sessions, creating a compounding knowledge base.

## Pitfalls
- **Do not read every wiki page.** Review the wiki_recall results and only read the 3-5 most relevant ones. Reading everything wastes context and distracts from the user's plan.
- **Do not let wiki context override the user's current intent.** The wiki is reference, not authority. If the user wants to diverge from a past decision, explore that divergence — don't treat past wiki pages as immutable constraints.
- **Do not ask multiple questions at once.** Like grill-me, ask one question at a time. Each question should resolve one branch of the decision tree before moving on.
- **Do not save wiki pages for trivial filler.** Only create wiki pages for genuinely new entities or concepts that emerged from the discussion — not every throwaway idea.
- **Wiki may be empty or sparse.** If wiki_recall returns nothing relevant, fall through to the standard grill-me behavior (codebase exploration + pure design questioning). Do not let an empty wiki stall the process.

## Verification
1. The user confirms their plan has been thoroughly examined from all angles relevant to their context.
2. At least one wiki_recall call was made at the start to surface relevant knowledge.
3. Major decision branches were recorded via wiki_observe during the session.
4. A wiki_retro call was made at the end to save a durable insight.
5. Any genuinely new entities or concepts that surfaced have wiki pages created for them.
6. The conversation resolved each branch of the decision tree, reaching shared understanding.