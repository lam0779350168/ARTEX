---
name: artex
description: "Operate this ARTEX build: deploy, create tasks, run tools and export findings."
capabilities: [recon.active, scan.vuln]
tools_required: [nuclei, httpx]
---
# artex

Operate this ARTEX build: deploy, create tasks, run tools and export findings.

## When to use
Use this skill when the task requires: operate this ARTEX build: deploy, create tasks, run tools and export findings.

## Capabilities required
- recon.active
- scan.vuln

## Tools required
- nuclei
- httpx

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

