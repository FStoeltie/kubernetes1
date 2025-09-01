# Step 3: Creating Rules and Detecting Activity

Now let's create a custom rule and then trigger security events to see how Falco detects them.

## Create a Simple Custom Rule

First, let's create a custom rule to detect when someone reads sensitive files:

```bash
sudo tee /etc/falco/falco_rules.local.yaml > /dev/null << 'EOF'
- rule: Read sensitive file untrusted
  desc: an attempt to read any sensitive file (e.g. files containing user/password/authentication information)
  condition: >
    open_read and sensitive_files and not proc_name_exists_in_list(proc.name, trusted_programs)
  output: >
    Sensitive file opened for reading (user=%user.name command=%proc.cmdline file=%fd.name)
  priority: WARNING
  tags: [filesystem, mitre_credential_access]

- list: trusted_programs
  items: [vi, vim, nano, systemd, systemctl]

- list: sensitive_files
  items: [/etc/passwd, /etc/shadow, /etc/sudoers]
EOF
```{{exec}}

## Restart Falco to Load the New Rule

```bash
sudo systemctl restart falco
sleep 3
```{{exec}}

Verify Falco restarted successfully:

```bash
sudo systemctl status falco --no-pager
```{{exec}}

## Monitor Falco Alerts

Open a new terminal and start monitoring Falco alerts:

```bash
sudo journalctl -u falco -f
```{{exec}}

Keep this running and continue with the commands below in another terminal.

## Generate Security Events

Let's trigger some alerts by accessing sensitive files:

### 1. Read /etc/passwd (should trigger our custom rule)
```bash
cat /etc/passwd > /dev/null
```{{exec}}

### 2. Try to access /etc/shadow
```bash
sudo cat /etc/shadow > /dev/null
```{{exec}}

### 3. Look at system directories
```bash
ls -la /root/ > /dev/null 2>&1 || true
```{{exec}}

### 4. Access SSH directories
```bash
ls -la /etc/ssh/ > /dev/null
```{{exec}}

## Generate Process-Related Events

### 1. Run network commands
```bash
netstat -tulpn > /dev/null 2>&1 || true
ss -tulpn > /dev/null 2>&1 || true
```{{exec}}

### 2. Look at running processes
```bash
ps aux > /dev/null
```{{exec}}

### 3. Create and access files
```bash
touch /tmp/test-file.txt
echo "test content" > /tmp/test-file.txt
cat /tmp/test-file.txt > /dev/null
```{{exec}}

## Check for Recent Alerts

View recent Falco alerts to see what was detected:

```bash
sudo journalctl -u falco --since="2 minutes ago" | grep -E "(WARNING|ERROR|CRITICAL)"
```{{exec}}

## Clean Up

Remove test files:

```bash
rm -f /tmp/test-file.txt
```{{exec}}

**Great!** Go back to your Falco monitoring terminal to see all the security events that were detected. You should see alerts for:
- Sensitive file access (from our custom rule)
- Various system activities detected by default rules

**Congratulations!** You've successfully created a custom Falco rule and observed real-time security monitoring in action.
