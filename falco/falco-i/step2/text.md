# Step 2: Understanding Falco Rule Loading Order

Falco reads multiple rule files in a specific order. Understanding this order is crucial for rule management and troubleshooting.

## Explore the Falco Directory

Let's look at what files are in the Falco configuration directory:

```bash
ls -la /etc/falco/
```{{exec}}

## Find the Main Configuration

Look at the main Falco configuration to understand how rules are loaded:

```bash
grep -n "rules_file" /etc/falco/falco.yaml
```{{exec}}

This shows you which rule files Falco will load and in what order.

## Examine Rule Files in Detail

Let's check what rule files actually exist:

```bash
ls -la /etc/falco/*.yaml
```{{exec}}

## Check File Timestamps

Sometimes the order matters based on when files were created or modified:

```bash
ls -lt /etc/falco/*.yaml
```{{exec}}

## Test Falco's Rule Loading

Run Falco in dry-run mode to see exactly which files it processes:

```bash
sudo falco --dry-run 2>&1 | grep -i "loading\|rules"
```{{exec}}

## Your Task: Discover the Loading Order

Based on your exploration above, determine the order in which Falco reads rule files.

Write the filenames (just the filename, not the full path) in the correct order from **first to last** into a file called `/tmp/rule-order.txt`.

Each filename should be on its own line, like this:
```
first-file.yaml
second-file.yaml
third-file.yaml
```

Create your answer file:

```bash
nano /tmp/rule-order.txt
```{{exec}}

**Hint:** Look carefully at the output from the `grep "rules_file"` command and the `--dry-run` output.

<details>
<summary><strong>🔍 Click here if you need help finding the answer</strong></summary>

The rule loading order can be found in the `rules_file` section of `/etc/falco/falco.yaml`. 

Look for a section that looks like this:
```yaml
rules_file:
  - /etc/falco/falco_rules.yaml
  - /etc/falco/falco_rules.local.yaml  
  - /etc/falco/k8s_audit_rules.yaml
```

The files are loaded in the order they appear in this list. Write just the filenames (without the full path) in your answer file.

</details>

<details>
<summary><strong>💡 Click here to see the typical answer (try to solve it yourself first!)</strong></summary>

The typical rule loading order is:
```
falco_rules.yaml
falco_rules.local.yaml
k8s_audit_rules.yaml
```

**Why this order matters:**
- `falco_rules.yaml` contains the default rules
- `falco_rules.local.yaml` can override or add to the default rules
- `k8s_audit_rules.yaml` contains Kubernetes-specific audit rules

</details>
