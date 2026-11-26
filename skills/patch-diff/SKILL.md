---
name: patch-diff
description: "Review a patch or diff for introduced vulnerabilities and regressions."
capabilities: [code-audit]
tools_required: [semgrep]
---
# patch-diff

Review a patch or diff for introduced vulnerabilities and regressions.

## When to use
Use this skill when the task requires: review a patch or diff for introduced vulnerabilities and regressions.

## Capabilities required
- code-audit

## Tools required
- semgrep

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

