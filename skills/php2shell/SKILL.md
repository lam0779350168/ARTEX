---
name: php2shell
description: "Study PHP deserialization and webshell chains in practice."
capabilities: [exploit]
tools_required: [phpggc]
---
# php2shell

Study PHP deserialization and webshell chains in practice.

## When to use
Use this skill when the task requires: study PHP deserialization and webshell chains in practice.

## Capabilities required
- exploit

## Tools required
- phpggc

Resolution is capability-based: the worker maps required capabilities to registered tools at runtime. No server name is declared here.

## End-to-end test case
Given a target and the required tools registered, ask the planner to perform the task this skill describes; confirm the tool calls carry the required capabilities, results use the standard record shape (`target`, `status`, `findings[]`, `raw_ref`), and the transcript records each step.

