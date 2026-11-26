---
name: firecrawl-osint
description: "Collect public web content into structured, LLM-ready documents for open-source research."
capabilities: [osint]
tools_required: [firecrawl]
---
# firecrawl-osint

Collect public web content into structured, LLM-ready documents for open-source research.

## When to use
Use this skill when the task requires: collect public web content into structured, LLM-ready documents for open-source research.

## Capabilities required
- osint

## Tools required
- firecrawl

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

