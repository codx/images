# dbug-tls

> TLS/SSL certificate inspection and testing with openssl.

- Show certificate chain for a host:

`openssl s_client -connect {{host}}:{{443}} -showcerts </dev/null`

- Show certificate expiry date:

`openssl s_client -connect {{host}}:{{443}} </dev/null 2>/dev/null | openssl x509 -noout -dates`

- Show full certificate details:

`openssl s_client -connect {{host}}:{{443}} </dev/null 2>/dev/null | openssl x509 -noout -text`

- Test with a specific SNI hostname:

`openssl s_client -connect {{ip}}:{{443}} -servername {{hostname}}`

- Test a specific TLS version:

`openssl s_client -connect {{host}}:{{443}} -tls1_2`

- Verify a local certificate file:

`openssl x509 -in {{cert.pem}} -noout -text`

- Check if a certificate and key match (compare md5 output):

`openssl x509 -noout -modulus -in {{cert.pem}} | openssl md5`

- Check if a key matches (compare with above):

`openssl rsa -noout -modulus -in {{key.pem}} | openssl md5`

- Generate a self-signed certificate:

`openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj '/CN={{hostname}}'`
