# START / STOP Runbook — aws-ha-secure-webapp

This runbook documents how to safely take the project **offline** (no public access)
and how to **bring it back online** for demonstrations.

---

## Option A — Fast Stop / Start (minutes)
**Use when:** You want quick demos and don’t mind some AWS cost while stopped.

### STOP (Fast)
1. Remove public access (deletes ALB):
   ```bash
   kubectl delete ingress aws-ha-webapp-ingress
