---
name: reddit-opinions
description: Reddit-only public opinion research for products, recommendations, purchases, brands, services, places, policies, controversies, and general topics. Use when Codex should find what real Reddit users say, compare sentiment and tradeoffs, surface India-specific opinions when relevant, or recommend options based on Reddit evidence rather than SEO articles or generic web summaries.
---

# Reddit Opinions

## Purpose

Use this skill to research public opinion from Reddit only. It is inspired by `last30days`, but deliberately removes multi-platform search and fixed recency constraints.

The goal is to answer: what do Reddit users actually think, complain about, recommend, avoid, and repeatedly agree or disagree on?

## Source Contract

- Use Reddit as the only opinion source.
- Do not use X, YouTube, TikTok, Instagram, Hacker News, Polymarket, review blogs, news articles, ecommerce pages, or SEO listicles as evidence.
- Web search is allowed only to find Reddit threads, subreddits, and Reddit URLs.
- Prefer direct Reddit URLs in citations.
- If Reddit evidence is thin, say so instead of filling gaps from non-Reddit sources.
- Do not impose a "last 30 days" window unless the user explicitly asks for recency.

## Intent Parsing

Classify the request before searching:

- `recommendation`: best X, which X should I buy, alternatives, product picks, services, courses, apps, tools.
- `comparison`: X vs Y, compare X and Y, is X better than Y.
- `public-opinion`: what do people think about X, sentiment around X, reputation, controversy.
- `product-research`: complaints, pros and cons, real user experience, buyer research.
- `india-focused`: explicitly India-related, or implicitly India-sensitive due to pricing, availability, service quality, jobs, education, finance, health, government, travel, local brands, ecommerce, food, telecom, housing, or culture.

If the topic is too broad to search well, ask one concise clarifying question. Otherwise proceed.

## India Focus Rule

Make the research India-aware when:

- The user mentions India, Indian cities, INR, Indian marketplaces, Indian brands, Indian institutions, or Indian demographics.
- The decision depends on India-specific availability, pricing, warranty, service, regulation, culture, or local alternatives.
- The topic is a recommendation where global Reddit advice may not transfer well to India.

For India-aware topics, include Indian communities and search terms before global ones.

Strong default Indian subreddits:

- General: `india`, `IndiaSpeaks`, `AskIndia`, `IndianSocial`
- Money and consumer: `IndiaInvestments`, `CreditCardsIndia`, `IndianGaming`, `CarsIndia`, `indianbikes`
- Tech and careers: `developersIndia`, `Indian_Academia`, `JEENEETards`, `CATpreparation`
- City/local: `bangalore`, `mumbai`, `delhi`, `hyderabad`, `pune`, `chennai`, `kolkata`, `gurgaon`, `noida`
- Shopping and service context: add search terms like `India`, `INR`, `Flipkart`, `Amazon India`, `service center`, `warranty`, `after sales`, `delivery`.

Use judgment. Do not force India framing when it is irrelevant.

## Search Workflow

Run 3 to 6 focused Reddit searches. Use both subreddit-scoped and site-wide queries.

Recommended query patterns:

- `site:reddit.com/r/{subreddit} {topic} reddit`
- `site:reddit.com {topic} reddit review`
- `site:reddit.com {topic} worth it reddit`
- `site:reddit.com {topic} problems reddit`
- `site:reddit.com {topic} alternative reddit`
- `site:reddit.com {topic} India reddit`
- `site:reddit.com {topic} INR reddit`
- `site:reddit.com "{topic A}" "{topic B}" reddit`

For recommendations, search for both positive and negative evidence:

- `{category} best reddit`
- `{category} avoid reddit`
- `{product} worth it reddit`
- `{product} problems reddit`
- `{product} alternative reddit`

For product research, include complaint vocabulary:

- `bad experience`
- `regret`
- `scam`
- `warranty`
- `after sales`
- `refund`
- `customer service`
- `long term review`

For comparisons, search each item alone plus head-to-head:

- `{A} vs {B} reddit`
- `{A} worth it reddit`
- `{B} worth it reddit`
- `{A} {B} alternative reddit`

## Evidence Selection

Prioritize:

1. First-person comments from users who bought, used, tried, switched from, or rejected the product.
2. Threads with multiple independent users converging on the same point.
3. Recent threads when the domain changes quickly, such as apps, phones, AI tools, prices, regulations, availability, or services.
4. India-specific threads for India-sensitive decisions.
5. Detailed negative experiences, because they reveal practical risks.

Deprioritize:

- Jokes without substance.
- One-line opinions with no reasoning.
- Obvious astroturfing or promotional posts.
- Brand-owned or moderator-announcement posts unless the comments contain useful user reactions.
- Very old threads for fast-changing topics unless the user asks for historical context.

## Engagement and Mention Analysis

When Reddit search results expose engagement signals, use them. Do not treat all mentions equally.

Check:

- Thread upvotes, comment counts, and subreddit size when visible.
- Comment upvotes when visible, especially highly upvoted first-person comments.
- Repeated mentions across multiple independent comments in the same thread.
- Repeated mentions across multiple independent threads and subreddits.
- High-upvote dissenting comments, because they often reveal the strongest caveats.
- Whether support is broad or concentrated in one community, one fan subreddit, or one viral thread.
- Whether mentions are organic recommendations or just people listing familiar brands.

Interpretation rules:

- Cross-thread repetition is stronger than many comments in one thread.
- A detailed 20-upvote ownership comment can beat a vague 500-upvote joke.
- One high-upvote negative comment should not dominate unless other users corroborate it.
- If a product is mentioned often but without reasons, mark it as popular but weakly evidenced.
- If a product is mentioned less often but with detailed first-person praise, rank it as high-signal.
- If engagement data is unavailable, say the ranking is based on comment substance and cross-thread recurrence.

## Recommendation Scoring

Rank by signal quality, not mention count.

Use this weighting:

- First-person ownership or usage with specifics: strongest.
- Repeated independent agreement across threads: strong.
- Clear tradeoff explanation: strong.
- India-specific price, support, or availability evidence: strong for Indian users.
- Vague praise: weak.
- Pure popularity or upvotes without reasoning: weak.
- Promotional posts: ignore unless comments are independently useful.

Always separate:

- `Recommended`: evidence supports choosing it.
- `Conditional`: good only for a specific use case or budget.
- `Avoid / be careful`: recurring complaints or poor fit.
- `Not enough Reddit evidence`: mentions exist but are too thin.

## Output Format

Keep the answer concise and evidence-led. Do not add a trailing `Sources:` block.

Use this structure for most runs:

```markdown
What Reddit says:

**Main read** - One paragraph summarizing the strongest opinion pattern.

**Where people agree** - The recurring points Reddit users converge on.

**Where people disagree** - The split, caveats, or context-dependent disagreements.

**India-specific read** - Include only when relevant. Explain local pricing, service, availability, cultural, or city-specific differences.

Recommendations:
1. **Pick / option** - Why Reddit supports it, best for whom, key caveat.
2. **Pick / option** - Why Reddit supports it, best for whom, key caveat.
3. **Pick / option** - Why Reddit supports it, best for whom, key caveat.

Evidence notes:
- [r/subreddit thread title](reddit-url) - what this thread contributed.
- [r/subreddit thread title](reddit-url) - what this thread contributed.
- [r/subreddit thread title](reddit-url) - what this thread contributed.
```

For non-recommendation public-opinion research, replace `Recommendations` with:

```markdown
Key patterns:
1. **Pattern** - Evidence and caveat.
2. **Pattern** - Evidence and caveat.
3. **Pattern** - Evidence and caveat.
```

For comparisons, use:

```markdown
Reddit verdict:

**Short answer** - Who Reddit prefers, for what use case, and why.

| Dimension | Option A | Option B |
|---|---|---|
| Best for | ... | ... |
| Praised for | ... | ... |
| Complaints | ... | ... |
| India caveat | ... | ... |

Bottom line:
- Choose A if ...
- Choose B if ...
- Avoid both if ...
```

## Citation Rules

- Cite Reddit evidence inline using markdown links.
- Use thread links when available.
- Cite subreddit names as links when thread URLs are unavailable.
- Do not cite non-Reddit sources as opinion evidence.
- Do not dump raw URLs.
- Do not fabricate exact vote counts, dates, or quotes.
- Quote Reddit users only when the wording matters and the excerpt is short.

## Quality Checks

Before answering, verify:

- Every opinion claim is grounded in Reddit evidence.
- Engagement signals were checked where available: upvotes, comment counts, comment frequency, and cross-thread recurrence.
- India-specific conclusions use India-specific threads or are clearly labeled as inference.
- Recommendations are ranked by signal quality, not just frequency.
- Negative evidence and caveats are included.
- Thin evidence is acknowledged.
- No non-Reddit public-opinion sources are used.

## Follow-Up Mode

After a research answer, retain the topic context for follow-up questions in the same conversation. If the user asks a narrower follow-up about the same topic, answer from the gathered Reddit evidence unless they explicitly request fresh research.
