# dbug-capture

> Packet capture and traffic analysis with tcpdump, tshark, termshark, and ngrep.

- Capture all traffic on a port:

`tcpdump -i any -nn port {{443}}`

- Capture DNS traffic and show query names:

`tcpdump -i any -nn port 53`

- Write capture to file for later analysis:

`tcpdump -i any -w /tmp/cap.pcap`

- Analyze a pcap with the interactive TUI:

`termshark -r /tmp/cap.pcap`

- Live tshark capture filtered by protocol:

`tshark -i any -f 'port {{53}}' -Y '{{dns}}'`

- Grep packet payloads for a pattern:

`ngrep -q -d any '{{pattern}}' port {{80}}`

- Capture only N packets then stop:

`tcpdump -i any -nn -c {{100}} port {{8080}}`
