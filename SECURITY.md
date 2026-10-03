# Security and privacy

Goal Layer currently has a local contributor foundation and an M1 native spike in development. No public beta, hosted service, support window, or signing/notarization route has been verified. GitHub private vulnerability reporting is enabled for the public source repository. There are no released versions with a maintenance guarantee.

## Reporting

Use [Report a vulnerability](https://github.com/mrrkrieg/goal-layer/security/advisories/new) for private security reports. Enabling the route was verified through GitHub REST (`enabled: true`); an end-to-end test report has not been sent. There is no guaranteed response SLA during this prototype. Do not post exploit details, credentials, captured content, or private artifacts in public issues.

Describe the affected source revision/environment, boundary crossed, minimal synthetic reproduction, and impact. Omit real credentials and customer data.

## Implementation boundaries

M1 is a synthetic native presentation spike. Observation and network integrations are out of scope; no real goal/evidence store or reward ledger is claimed. Later milestones must preserve these contracts:

- Manual personal use works without an account, model, or observation permission.
- Observation, AI transmission, community membership, and sharing are separate consent states.
- Activity context and AI recommendations do not independently accept completions or award XP. Source confirmation is limited to the exact predicate checked.
- Untrusted page text, artifacts, OCR, model output, and chat cannot execute tools, change policy, enable capture, grant rewards, or send outbound messages.
- Credentials use Keychain when credential features begin; they never appear in fixtures, logs, exports, or source. A local SQLite file is not automatically encrypted.
- Pause and scope revocation invalidate pending work through privacy epochs; late callbacks cannot create observation-derived rewards. Already transmitted content cannot be recalled by pausing the app.
- Local-only mode disables off-machine requests. A separately configured same-Mac loopback model is distinct from a LAN or hosted endpoint.
- Community membership does not authorize access to private goals or evidence. Explicit sharing previews the exact card, attachments, and audience. The service authorizes membership and derives challenge scores from accepted units.

The implementation contracts for permission checks, payload bounds, pause races, retention, deletion, model validation, and future public URL verification are in [Architecture](docs/ARCHITECTURE.md). The [Roadmap](docs/ROADMAP.md) specifies their required acceptance evidence. These are requirements until their individual gates pass.

## Development and release handling

Use only synthetic fixtures and redact native recordings/logs before inclusion. Keep local data, captures, signing material, model keys, tokens, and database files outside tracked source. A report of forbidden content requires removing it from the deliverable and reviewing history/artifacts before publication; an ignore rule does not remove an already tracked secret.

Before a distributed binary release, maintainers must verify private reporting, dependency/asset notices, build provenance, signing/notarization, install/upgrade and migration recovery, offline and denied-permission operation, export/deletion, and the actual tested platform matrix. No automatic updater is currently promised.
