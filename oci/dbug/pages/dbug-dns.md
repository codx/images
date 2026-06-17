# dbug-dns

> DNS troubleshooting with dig, drill, and bind-tools.

- Query a specific DNS server:

`dig @{{dns-server}} {{example.com}}`

- Query a specific record type:

`dig {{example.com}} {{AAAA}}`

- Trace the full delegation chain:

`dig +trace {{example.com}}`

- Short answer only:

`dig +short {{example.com}}`

- Reverse DNS lookup:

`dig -x {{1.2.3.4}}`

- DNSSEC validation with drill:

`drill -S {{example.com}}`

- Query a specific DNS server with drill:

`drill @{{dns-server}} {{example.com}} {{MX}}`

- Check all records for a domain:

`dig {{example.com}} ANY +noall +answer`
