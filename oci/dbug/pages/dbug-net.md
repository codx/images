# dbug-net

> Network scanning, diagnostics, and connectivity with nmap, mtr, fping, socat, and iperf.

- Scan common ports on a host:

`nmap -sT {{host}}`

- Scan specific ports:

`nmap -sT -p {{80,443,8080}} {{host}}`

- Continuous traceroute with latency stats:

`mtr --tcp -P {{443}} {{host}}`

- Ping sweep a subnet:

`fping -a -g {{10.0.0.0/24}}`

- Pretty ping with graph:

`prettyping {{host}}`

- TCP port forwarding with socat:

`socat TCP-LISTEN:{{local_port}},fork TCP:{{remote_host}}:{{remote_port}}`

- Run iperf3 server:

`iperf3 -s`

- Run iperf3 client to test bandwidth:

`iperf3 -c {{server_host}}`

- Interactive traceroute TUI:

`trip {{host}}`

- Check conntrack table:

`conntrack -L`
