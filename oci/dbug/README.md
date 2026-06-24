# dbug

[![GitHub](https://img.shields.io/badge/source-codx%2Fimages-181717?logo=github)](https://github.com/codx/images/tree/main/oci/dbug)
[![GHCR](https://img.shields.io/badge/ghcr.io-codx%2Fdbug-181717?logo=github)](https://github.com/codx/images/pkgs/container/dbug)
[![Docker Hub](https://img.shields.io/badge/docker%20hub-codo%2Fdbug-2496ED?logo=docker)](https://hub.docker.com/r/codo/dbug)
[![Image Size](https://img.shields.io/docker/image-size/codo/dbug/latest?logo=docker&label=size)](https://hub.docker.com/r/codo/dbug/tags)

Network debugging and troubleshooting container. Built on Alpine with
[apko](https://github.com/chainguard-dev/apko)/[melange](https://github.com/chainguard-dev/melange).

## Quick start

```bash
# Kubernetes — standalone pod
kubectl run dbug --rm -it --image codo/dbug -- fish

# Kubernetes — attach to existing pod's network/PID namespace
kubectl debug -it <pod> --image codo/dbug --target <container> -- fish

# Kubernetes — debug a node
kubectl debug -it node/<node> --image codo/dbug -- fish

# Docker
docker run --rm -it codo/dbug
```

## What's included

| Category                | Tools                                                                       |
| ----------------------- | --------------------------------------------------------------------------- |
| Shell & Editor          | fish, helix, tmux                                                            |
| Connectivity            | curl, xh, socat, netcat-openbsd, openssh-client, openssl                     |
| Discovery & Diagnostics | nmap, mtr, fping, iperf3, bind-tools (dig), ldns (drill), iputils            |
| Capture & Analysis      | tcpdump, ngrep, iftop                                                        |
| Routing & Firewall      | iproute2, ethtool, bridge-utils, conntrack-tools, iptables, nftables, ipset |
| System                  | procps, htop, lsof, strace, ltrace, util-linux, file, less                  |
| Data & CLI              | jq, yq, eza, fd, ripgrep, git, starship, tealdeer (tldr)                     |

## Recipes

Common command references for each area:

<!-- BEGIN RECIPES -->
### Shell shortcuts

```bash
# Aliases — l (eza), ll (long list), e/o (editor), f (fd), g (git), c (cat)
l
# Search with rg (case-insensitive)
r "pattern"
# Open rg matches in editor
ro "pattern"
# Navigate up 1/2/3 levels
..
# Show all available dbug topic pages
tldr --list | grep dbug
```

### Packet capture

```bash
# Capture all traffic on a port
tcpdump -i any -nn port 443
# Capture DNS traffic and show query names
tcpdump -i any -nn port 53
# Write capture to file for later analysis
tcpdump -i any -w /tmp/cap.pcap
# Analyze a pcap with the interactive TUI
termshark -r /tmp/cap.pcap
# Live tshark capture filtered by protocol
tshark -i any -f 'port 53' -Y 'dns'
# Grep packet payloads for a pattern
ngrep -q -d any 'pattern' port 80
# Capture only N packets then stop
tcpdump -i any -nn -c 100 port 8080
```

### DNS

```bash
# Query a specific DNS server
dig @dns-server example.com
# Query a specific record type
dig example.com AAAA
# Trace the full delegation chain
dig +trace example.com
# Short answer only
dig +short example.com
# Reverse DNS lookup
dig -x 1.2.3.4
# DNSSEC validation with drill
drill -S example.com
# Query a specific DNS server with drill
drill @dns-server example.com MX
# Check all records for a domain
dig example.com ANY +noall +answer
```

### HTTP / gRPC / WebSocket

```bash
# GET request with headers displayed
xh https://example.com
# POST JSON payload
xh POST https://example.com/api key=value
# Follow redirects and show TLS info with curl
curl -vsSL https://example.com
# Send request with custom headers
curl -H 'Authorization: Bearer token' https://example.com/api
# List gRPC services
grpcurl -plaintext host:port list
# Call a gRPC method
grpcurl -plaintext -d '{"key":"value"}' host:port package.Service/Method
# WebSocket connection
websocat ws://host:port/path
```

### Network diagnostics

```bash
# Scan common ports on a host
nmap -sT host
# Scan specific ports
nmap -sT -p 80,443,8080 host
# Continuous traceroute with latency stats
mtr --tcp -P 443 host
# Ping sweep a subnet
fping -a -g 10.0.0.0/24
# Ping with an inline latency sparkline
prettyping host
# TCP port forwarding with socat
socat TCP-LISTEN:local_port,fork TCP:remote_host:remote_port
# Run iperf3 server
iperf3 -s
# Run iperf3 client to test bandwidth
iperf3 -c server_host
# Interactive traceroute TUI
trip host
# Check conntrack table
conntrack -L
```

### TLS / certificates

```bash
# Show certificate chain for a host
openssl s_client -connect host:443 -showcerts </dev/null
# Show certificate expiry date
openssl s_client -connect host:443 </dev/null 2>/dev/null | openssl x509 -noout -dates
# Show full certificate details
openssl s_client -connect host:443 </dev/null 2>/dev/null | openssl x509 -noout -text
# Test with a specific SNI hostname
openssl s_client -connect ip:443 -servername hostname
# Test a specific TLS version
openssl s_client -connect host:443 -tls1_2
# Verify a local certificate file
openssl x509 -in cert.pem -noout -text
# Check if a certificate and key match (compare md5 output)
openssl x509 -noout -modulus -in cert.pem | openssl md5
# Check if a key matches (compare with above)
openssl rsa -noout -modulus -in key.pem | openssl md5
# Generate a self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj '/CN=hostname'
```

### Kubernetes

```bash
# Attach to an existing pod's network namespace
kubectl debug -it pod --image codo/dbug --target container -- fish
# Debug a node directly
kubectl debug -it node/node --image codo/dbug -- fish
# Run a standalone debug pod
kubectl run dbug --rm -it --image codo/dbug -- fish
# Run a debug pod in a specific namespace
kubectl run dbug --rm -it -n namespace --image codo/dbug -- fish
```

<!-- END RECIPES -->
