---
name: api-recon
description: "Map undocumented API endpoints and parameter surfaces on a target."
capabilities: [recon.active, osint]
tools_required: [httpx, katana, feroxbuster]
---
# api-recon

Map undocumented API endpoints and parameter surfaces on a target.

## When to use
Use this skill when the task requires: map undocumented API endpoints and parameter surfaces on a target.

## Capabilities required
- recon.active
- osint

## Tools required
- httpx
- katana
- feroxbuster

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

