---
name: api-security
description: "Test an API for authz, injection and token weaknesses."
capabilities: [scan.vuln]
tools_required: [nuclei, arjun, jwt_tool.py]
---
# api-security

Test an API for authz, injection and token weaknesses.

## When to use
Use this skill when the task requires: test an API for authz, injection and token weaknesses.

## Capabilities required
- scan.vuln

## Tools required
- nuclei
- arjun
- jwt_tool.py

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

