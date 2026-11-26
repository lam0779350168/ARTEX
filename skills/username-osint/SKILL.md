---
name: username-osint
description: "Find public accounts and registered services for a username or email address using OSINT lookup tools."
capabilities: [osint]
tools_required: [sherlock, maigret, holehe]
---
# username-osint

Find public accounts and registered services for a username or email address using OSINT lookup tools.

## When to use
Use this skill when the task requires: search a username across public sites with Sherlock or Maigret, or check which services are registered to an email address with Holehe.

## Capabilities required
- osint

## Tools required
- sherlock
- maigret
- holehe

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.
