---
name: edr-bypass-re
description: "Read-only study of EDR evasion techniques and detection engineering notes."
capabilities: [code-audit]
tools_required: [claude-bughunter]
---
# edr-bypass-re

Read-only study of EDR evasion techniques and detection engineering notes.

## When to use
Use this skill when the task requires: read-only study of EDR evasion techniques and detection engineering notes.

## Capabilities required
- code-audit

## Tools required
- claude-bughunter

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

