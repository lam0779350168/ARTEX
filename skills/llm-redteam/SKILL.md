---
name: llm-redteam
description: "Red-team an LLM surface you own: prompt injection, jailbreak and data leakage probes."
capabilities: [scan.vuln]
tools_required: [garak, promptfoo, pyrit]
---
# llm-redteam

Red-team an LLM surface you own: prompt injection, jailbreak and data leakage probes.

## When to use
Use this skill when the task requires: red-team an LLM surface you own: prompt injection, jailbreak and data leakage probes.

## Capabilities required
- scan.vuln

## Tools required
- garak
- promptfoo
- pyrit

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

