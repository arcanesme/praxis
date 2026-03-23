---
name: infrastructure
version: 1.0.0
description: Infrastructure as Code — Terraform, Azure, compliance, drift detection
activation: /kit:infrastructure
deactivation: /kit:off
skills_chain:
  - phase: plan
    skills: []
    status: planned
  - phase: apply
    skills: []
    status: planned
  - phase: drift
    skills: []
    status: planned
  - phase: compliance
    skills: []
    status: planned
mcp_servers: []
rules:
  - infrastructure.md
removal_condition: >
  Remove when infrastructure work is fully handled by a dedicated IaC pipeline
  with no manual Claude-driven operations remaining.
---

# Infrastructure Kit

## Purpose
Chain infrastructure-as-code skills into a phased workflow for planning,
applying, drift detection, and compliance checking against Azure/Terraform
environments.

## Skills Chain

| # | Phase | Command | What It Provides |
|---|-------|---------|-----------------|
| 1 | Plan | `/infra:plan` | Terraform plan + review, flag destructive changes |
| 2 | Apply | `/infra:apply` | Gated behind plan approval, write result to vault |
| 3 | Drift | `/infra:drift` | Detect configuration drift via `terraform plan -detailed-exitcode` |
| 4 | Compliance | `/infra:compliance` | NIST CSF mapping, public endpoint check, missing tags |

## Workflow Integration

This kit operates WITHIN the Praxis workflow:
- **Praxis** structures the work (discuss → plan → execute → verify → simplify → ship)
- **This kit** adds infrastructure-specific rules and commands

## Prerequisites

Run `install.sh` in this directory to check for required CLI tools.
Verify with `/kit:infrastructure` after install.
