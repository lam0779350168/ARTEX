---
name: hacktricks
description: "Look up and apply documented offensive techniques during an assessment."
capabilities: [recon.active, scan.vuln]
tools_required: [nuclei, subfinder]
---
# hacktricks

Look up and apply documented offensive techniques during an assessment.

## When to use
Use this skill when the task requires: look up and apply documented offensive techniques during an assessment.

## Capabilities required
- recon.active
- scan.vuln

## Tools required
- nuclei
- subfinder

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

