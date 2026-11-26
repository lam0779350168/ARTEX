---
name: web-fingerprint
description: "Fingerprint live web assets: status, titles, technologies and headers."
capabilities: [recon.active]
tools_required: [httpx, whatweb]
---
# web-fingerprint

Fingerprint live web assets: status, titles, technologies and headers.

## When to use
Use this skill when the task requires: fingerprint live web assets: status, titles, technologies and headers.

## Capabilities required
- recon.active

## Tools required
- httpx
- whatweb

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

