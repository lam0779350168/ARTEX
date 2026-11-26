---
name: bbot-recon
description: "Run broad passive+active OSINT and asset discovery with BBOT."
capabilities: [recon.active, osint]
tools_required: [bbot]
---
# bbot-recon

Run broad passive+active OSINT and asset discovery with BBOT.

## When to use
Use this skill when the task requires: run broad passive+active OSINT and asset discovery with BBOT.

## Capabilities required
- recon.active
- osint

## Tools required
- bbot

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

