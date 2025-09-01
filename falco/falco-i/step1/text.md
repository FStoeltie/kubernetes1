# Step 1: Install Falco

In this step, you'll install Falco directly on a Linux system using the official package repository.

## Add the Falco Repository

First, let's add the official Falco repository and GPG key:

```bash
curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
```{{exec}}

```bash
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list
```{{exec}}

## Update Package Lists

Update the package lists to include the Falco repository:

```bash
sudo apt-get update -y
```{{exec}}

## Install Falco

Now install Falco and its kernel module:

```bash
sudo apt-get install -y dkms make linux-headers-$(uname -r)
sudo apt-get install -y falco
```{{exec}}

## Check Falco Installation

Verify that Falco is installed correctly:

```bash
falco --version
```{{exec}}

## Start Falco Service

Enable and start the Falco service:

```bash
sudo systemctl enable falco
sudo systemctl start falco
```{{exec}}

## Check Falco Status

Verify that Falco is running:

```bash
sudo systemctl status falco
```{{exec}}

## View Falco Logs

Check that Falco is working and monitoring system events:

```bash
sudo journalctl -u falco -f --lines=10
```{{exec}}

You should see Falco starting up and beginning to monitor system events. Press `Ctrl+C` to stop following the logs when you're ready to proceed.

**Note:** Falco is now running as a system service and monitoring all system calls on this machine!
