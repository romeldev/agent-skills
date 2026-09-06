# Changelog

All notable changes to this skill are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/) and adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

- Nothing yet.

## [1.0.0] - 2026-09-05

### Added

- Initial release of the `worktree-runtime` skill.
- Skill contract (`SKILL.md`): Activation Contract, Hard Rules, Decision Gates,
  Execution Steps, Output Contract.
- Reference scripts (`assets/`): `port-audit.sh` (listen-port inventory and
  free-port check) and `health-check.sh` (HTTP verification loop with args,
  stdin, or file input).
- Stack-agnostic discovery (`assets/stack-detectors.md`): how to recognize each
  framework family's port mechanism from the files present.
- Minimal port convention (`assets/convention.md`) used only when the project
  declares none, with the requirement to record it in the project policy file.
- Report template (`assets/report-template.md`) enforcing evidence-based output.
- Install guide for common agent harnesses (`references/multi-harness-install.md`)
  and honest design rationale (`references/rationale.md`).
- Verification: scripts tested against a live host; independent review passed
  with two defects fixed (stdin mode of `health-check.sh`, mislabeled error
  message).
- Policy-first priority: `AGENTS.md`/`CLAUDE.md` project instructions win over
  the skill's generic flow (Hard Rule 2 and Execution Step 2).