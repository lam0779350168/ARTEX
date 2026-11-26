---
name: playwright-cli
description: "Drive an authenticated browser session for authenticated web testing."
capabilities: [recon.active]
tools_required: [httpx]
---
# playwright-cli

Drive an authenticated browser session for authenticated web testing.

## When to use
Use this skill when the task requires: drive an authenticated browser session for authenticated web testing.

## Capabilities required
- recon.active

## Tools required
- httpx

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

