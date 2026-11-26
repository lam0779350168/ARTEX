---
name: vuln-scan
description: "Run a broad vulnerability scan over an asset set."
capabilities: [scan.vuln]
tools_required: [nuclei, dalfox]
---
# vuln-scan

Run a broad vulnerability scan over an asset set.

## When to use
Use this skill when the task requires: run a broad vulnerability scan over an asset set.

## Capabilities required
- scan.vuln

## Tools required
- nuclei
- dalfox

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

