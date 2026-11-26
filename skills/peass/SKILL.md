---
name: peass
description: "Local privilege-escalation enumeration on a host."
capabilities: [exploit]
tools_required: [linpeas]
---
# peass

Local privilege-escalation enumeration on a host.

## When to use
Use this skill when the task requires: local privilege-escalation enumeration on a host.

## Capabilities required
- exploit

## Tools required
- linpeas

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

