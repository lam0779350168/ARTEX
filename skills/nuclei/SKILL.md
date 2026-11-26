---
name: nuclei
description: "Run template-based vulnerability scans against targets."
capabilities: [scan.vuln]
tools_required: [nuclei]
mcps: ScopeSentry, browser-nosandbox, browser
---
# nuclei

Run template-based vulnerability scans against targets.

## When to use
Use this skill when the task requires: run template-based vulnerability scans against targets.

## Capabilities required
- scan.vuln

## Tools required
- nuclei

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

