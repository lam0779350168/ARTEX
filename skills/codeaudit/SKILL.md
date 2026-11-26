---
name: codeaudit
description: "Audit a source tree for secrets and insecure patterns."
capabilities: [code-audit]
tools_required: [semgrep, gitleaks, trufflehog]
---
# codeaudit

Audit a source tree for secrets and insecure patterns.

## When to use
Use this skill when the task requires: audit a source tree for secrets and insecure patterns.

## Capabilities required
- code-audit

## Tools required
- semgrep
- gitleaks
- trufflehog

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

