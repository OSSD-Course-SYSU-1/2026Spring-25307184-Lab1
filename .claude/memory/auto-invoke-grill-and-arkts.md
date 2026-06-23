---
name: auto-invoke-four-skills-before-edit
description: Before any code edit in this HarmonyOS project, auto-invoke pre-change-notify, grill-me, harmony-next, and arkts-syntax-assistant
metadata:
  type: project
---

Before making ANY code modification in this project (Edit, Write, new file, or refactoring), invoke these three skills in order:

1. **pre-change-notify** — Announce the file path, reason for change, and wait for user approval before any file modification.
2. **grill-me** — Interview the user about design decisions to reach shared understanding before implementation.
3. **harmony-next** — Look up ArkTS/ArkUI API references (component signatures, @ohos modules, API version) to avoid hallucinating non-existent APIs.
4. **arkts-syntax-assistant** — Ensure all ArkTS code follows language restrictions (no `any`/`unknown`, no destructuring, no `for..in`, use `Number()` not `parseInt`, avoid prohibited APIs like `eval`/`Proxy`/`Reflect`).

**Why:** The user wants these four skills to be automatically triggered without having to manually say keywords.

**How to apply:** Before every Edit/Write/new file operation in this project, call Skill("pre-change-notify"), Skill("grill-me"), Skill("harmony-next"), and Skill("arkts-syntax-assistant").
