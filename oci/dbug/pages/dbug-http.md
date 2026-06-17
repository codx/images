# dbug-http

> HTTP, gRPC, and SMTP testing with curl, xh, grpcurl, and swaks.

- GET request with headers displayed:

`xh {{https://example.com}}`

- POST JSON payload:

`xh POST {{https://example.com/api}} key=value`

- Follow redirects and show TLS info with curl:

`curl -vsSL {{https://example.com}}`

- Send request with custom headers:

`curl -H 'Authorization: Bearer {{token}}' {{https://example.com/api}}`

- List gRPC services:

`grpcurl -plaintext {{host}}:{{port}} list`

- Call a gRPC method:

`grpcurl -plaintext -d '{{{"key":"value"}}}' {{host}}:{{port}} {{package.Service/Method}}`

- Send a test email via SMTP:

`swaks --to {{user@example.com}} --server {{smtp-host}}:{{25}}`

- WebSocket connection:

`websocat ws://{{host}}:{{port}}/{{path}}`
