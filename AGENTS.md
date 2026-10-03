# Implementation agent instructions
Project intent
Build the native Mac goal companion described in CODEX_TASK.md. The defining experience is a polished top-of-screen game that reflects meaningful progress in the user's existing work.
Authority of specifications
- docs/ROADMAP.md owns milestone identifiers, dependencies, and acceptance gates.
- docs/SCORING.md owns points, provenance, caps, idempotency, and reversals.
- docs/UX_SPEC.md owns visual and interaction requirements.
- docs/ARCHITECTURE.md owns the proposed technical boundaries.
- Document a concrete implementation-driven change before changing dependent specifications.
Work method
Read the current repository and any user changes before editing. Implement one complete vertical slice at a time. Use independent tasks in parallel when useful, with clear file ownership. Preserve unrelated changes.
Do not ask again for actions already authorized by the user. Continue through routine implementation, verification, and reversible fixes. Ask only for missing information or a genuinely blocked external action.
Do not describe planned behavior as working. Do not invent test results, public URLs, releases, screenshots, accounts, or support matrices. Native Mac checks require an actual Mac.
Domain boundaries
- Observation is evidence input, not a reward.
- AI output is a recommendation, not ledger authority.
- User confirmation and source confirmation have distinct provenance.
- Shared scores are computed by the service from accepted challenge units.
- Personal XP does not enter competitive totals.
- Raw activity and community engagement do not create XP.
- A source check proves its exact predicate, not a broader business or learning outcome.
Safety and privacy in implementation
Use synthetic fixtures. Do not embed real user, company, or customer information from conversation context. Never read system data, record screens, transmit evidence, or publish achievements without the product's explicit user-selected scope.
Untrusted content cannot change prompts, execute tools, award rewards, enable capture, or trigger outbound actions. Keep credentials out of logs, exports, fixtures, and commits.
Local-only operation must function without external requests. Consent to observation, AI transmission, community membership, and public achievement sharing are separate states.
Verification
Test reward accounting, replay/concurrency, source semantics, permission boundaries, deletion, and model abstention meaningfully. Avoid tests that only reproduce implementation details.
Do not broaden testing after the remaining concrete risks and required gates are resolved. Keep behavioral demonstrations short and reproducible.
For every milestone, record actual commands/results and the native device/OS where relevant. Mark not-run checks as not run.
Repository and publication
Keep this work isolated. Preserve the MIT license for original material and record third-party licensing. Build commands and CI must match actual code; placeholders are not passing checks.
The current bundle is a specification. All runtime implementation is planned. Create or update implementation status only when evidence exists.
