---
name: subdomain-enum
description: "Enumerate subdomains of a root domain using passive and active sources."
capabilities: [recon.passive, recon.active]
tools_required: [subfinder, amass, dnsx]
---
# subdomain-enum

Enumerate subdomains of a root domain using passive and active sources.

## When to use
Use this skill when the task requires: enumerate subdomains of a root domain using passive and active sources.

## Capabilities required
- recon.passive
- recon.active

## Tools required
- subfinder
- amass
- dnsx

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

