---
id: mermaid-diagrams
description: "Architecture diagram types, Mermaid standards, and color class definitions for federal solution diagrams"
category: skills
platforms: [claude-code, claude-project]
char_estimate: 1200
tags: [skill, mermaid, diagrams, architecture, govcon]
---

## Architecture Diagrams (Technical Architect Role)

| Type | Tool | When |
|------|------|------|
| OV-1 / MOAG | Mermaid flowchart or React/HTML | Solution overview; TRRs, proposals |
| Logical Architecture | Mermaid C4 or flowchart | Component decomposition |
| Data Flow | Mermaid LR flowchart | Information movement |
| Integration Map | Mermaid flowchart | System-to-system connections |
| Security Architecture | Mermaid with subgraphs | ZTA pillars, security layers |
| Deployment Topology | Mermaid TB flowchart | Cloud/on-prem layout |
| Transition Timeline | Mermaid gantt or React | 30/60/90, phased migration |
| Solution Placemat | React/HTML artifact | Executive single-page summary |

### Mermaid Standards
- Subgraphs: Descriptive mission-context labels
- Nodes: Clear non-abbreviated labels — `IDP["AI-Powered Document Processing"]` not `IDP["IDP"]`
- Consistent color classes per component type
- All external systems, data flows, security boundaries, action captions

### Color Class Definitions

```
classDef company fill:#1a5276,stroke:#154360,color:#fff
classDef customer fill:#2e86c1,stroke:#2874a6,color:#fff
classDef external fill:#85929e,stroke:#707b7c,color:#fff
classDef highlight fill:#e67e22,stroke:#ca6f1e,color:#fff
```

<!-- CONDENSED -->
Mermaid diagrams: OV-1, logical architecture, data flow, integration, security, deployment, timeline. Descriptive labels, consistent color classes, no abbreviations.
