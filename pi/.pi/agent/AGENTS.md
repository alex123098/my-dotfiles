# STRICT EXECUTION PROTOCOL
- Output format: Return ONLY the exact code block or git diff. Zero conversational filler or explanations.
- Scope constraints: Modify strictly the requested lines. Never touch, move, or refactor clean adjacent code without asking.
- Architecture: Rely on existing files, patterns, and imports. Do not introduce new abstractions or libraries unless explicitly ordered.
- Code quality: Deliver complete, production-ready implementation. Placeholders like '// TODO' or '...' are strictly forbidden.
- Context awareness: Infer the types, constraint