---
name: secret-scan
description: "Find leaked credentials in repositories and history; verify liveness at runtime."
capabilities: [code-audit]
tools_required: [gitleaks, trufflehog]
---
# secret-scan

Find leaked credentials in repositories and history; verify liveness at runtime.

## When to use
Use this skill when the task requires: find leaked credentials in repositories and history; verify liveness at runtime.

## Capabilities required
- code-audit

## Tools required
- gitleaks
- trufflehog

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

