---
name: rea
description: "Reverse-engineer an artifact and turn findings into testable hypotheses."
capabilities: [code-audit]
tools_required: [semgrep]
---
# rea

Reverse-engineer an artifact and turn findings into testable hypotheses.

## When to use
Use this skill when the task requires: reverse-engineer an artifact and turn findings into testable hypotheses.

## Capabilities required
- code-audit

## Tools required
- semgrep

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

