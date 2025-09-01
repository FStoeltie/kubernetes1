# Step 2: Understanding Falco Rules

Falco uses rules to detect suspicious activity. Let's explore how these rules work.

## View Default Falco Configuration

Falco configuration and rules are stored in `/etc/falco/`. Let's examine the structure:

```bash
ls -la /etc/falco/
```{{exec}}

## Look at the Main Configuration

Let's examine the main Falco configuration file:

```bash
cat /etc/falco/falco.yaml | head -30
```{{exec}}

## Examine Default Rules

Falco comes with many built-in rules. Let's look at some of them:

```bash
head -50 /etc/falco/falco_rules.yaml
```{{exec}}

## List All Available Rules

Let's see what rules are currently loaded:

```bash
falco --list | head -20
```{{exec}}

## Understanding Rule Structure

A typical Falco rule has these components:

- **Rule name**: Unique identifier
- **Description**: What the rule detects  
- **Condition**: The logic that triggers the alert
- **Output**: The alert message format
- **Priority**: Severity level (DEBUG, INFO, NOTICE, WARNING, ERROR, CRITICAL, ALERT, EMERGENCY)

## Create a Custom Rule

Let's create a simple custom rule to detect when someone reads sensitive files:

```bash
sudo tee /etc/falco/falco_rules.local.yaml > /dev/null << 'EOF'
- rule: Read sensitive file untrusted
  desc: an attempt to read any sensitive file (e.g. files containing user/password/authentication information)
  condition: >
    open_read and sensitive_files and not proc_name_exists_in_list(proc.name, trusted_programs)
  output: >
    Sensitive file opened for reading (user=%user.name user_loginuid=%user.loginuid
    command=%proc.cmdline file=%fd.name parent=%proc.pname pcmdline=%proc.pcmdline gparent=%proc.aname[2])
  priority: WARNING
  tags: [filesystem, mitre_credential_access, mitre_discovery]

- list: trusted_programs
  items: [vi, vim, nano, cat, more, less, emacs]

- list: sensitive_files
  items: [/etc/passwd, /etc/shadow, /etc/sudoers, /root/.ssh, /home/*/.ssh]
EOF
```{{exec}}

## Verify the Custom Rule

Check that our custom rule file was created:

```bash
cat /etc/falco/falco_rules.local.yaml
```{{exec}}

## Test Rule Validation

Validate that our custom rule is syntactically correct:

```bash
falco --validate /etc/falco/falco_rules.local.yaml
```{{exec}}

## Restart Falco to Load New Rules

Restart the Falco service to load our new custom rules:

```bash
sudo systemctl restart falco
```{{exec}}

Check that Falco restarted successfully:

```bash
sudo systemctl status falco --no-pager
```{{exec}}

**Great!** You've now created a custom Falco rule that will detect when untrusted programs read sensitive files.
