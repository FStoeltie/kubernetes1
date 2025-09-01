# Step 3: Detecting Suspicious Activity

Now let's trigger some security events and see how Falco detects them in real-time.

## Monitor Falco Alerts

First, let's start monitoring Falco alerts. Open a new terminal and run:

```bash
sudo journalctl -u falco -f
```{{exec}}

Keep this running in the background. You can open another terminal tab or split the terminal.

## Generate Basic Security Events

Let's trigger some basic alerts by accessing sensitive files:

### 1. Read /etc/passwd
```bash
cat /etc/passwd
```{{exec}}

### 2. Try to access /etc/shadow
```bash
sudo cat /etc/shadow
```{{exec}}

### 3. Look at system directories
```bash
ls -la /root/
```{{exec}}

### 4. Access SSH directories
```bash
ls -la ~/.ssh/ 2>/dev/null || echo "No .ssh directory found"
ls -la /etc/ssh/
```{{exec}}

## Check for Alerts

Go back to your Falco monitoring terminal. You should see alerts like:
- `Sensitive file opened for reading`
- `Read sensitive file untrusted`

## Generate Process-Related Events

Let's trigger some process monitoring alerts:

### 1. Run network scanning commands
```bash
netstat -tulpn
ss -tulpn
```{{exec}}

### 2. Look at running processes
```bash
ps aux | head -10
```{{exec}}

### 3. Access system files
```bash
sudo cat /proc/version
```{{exec}}

## Create Suspicious File Activities

### 1. Try to modify system files
```bash
sudo touch /etc/test-file
sudo rm /etc/test-file 2>/dev/null || true
```{{exec}}

### 2. Access binary directories
```bash
ls -la /bin/ | head -5
ls -la /usr/bin/ | head -5
```{{exec}}

### 3. Create files in unusual locations
```bash
sudo touch /tmp/suspicious-script.sh
echo "#!/bin/bash" | sudo tee /tmp/suspicious-script.sh > /dev/null
sudo chmod +x /tmp/suspicious-script.sh
```{{exec}}

## Advanced: Network Activity Monitoring

### 1. Make network connections
```bash
curl -s http://example.com > /dev/null || true
```{{exec}}

### 2. DNS lookups
```bash
nslookup google.com || true
```{{exec}}

## Review All Alerts

Check your Falco monitoring terminal to see all the different types of security events that were detected.

You can also view recent alerts with:

```bash
sudo journalctl -u falco --since="5 minutes ago" | grep -E "(WARNING|ERROR|CRITICAL)"
```{{exec}}

## Clean Up

Remove the test files we created:

```bash
sudo rm -f /tmp/suspicious-script.sh
```{{exec}}

**Congratulations!** You've successfully triggered and observed various types of Falco security alerts on a Linux system. You can see how Falco monitors file access, process execution, and network activities in real-time.
