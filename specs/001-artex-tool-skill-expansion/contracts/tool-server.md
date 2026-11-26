# Contract: Tool Server Protocol

One process per catalogued repo, launched as `toolserver --tool <name>`. Frames are newline-delimited JSON on stdin/stdout; stderr is reserved for diagnostics.

## initialize

Request: `{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}`

Response: `{"jsonrpc":"2.0","id":1,"result":{"name":"<catalog name>","capability":"<enum>","risk":"<enum>"}}`

## tools/list

Request: `{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}`

Response: `{"jsonrpc":"2.0","id":2,"result":{"tools":[{"name":"<catalog name>","description":"...","inputSchema":{...}}]}}`

Rule: `tools` contains at least one element.

## tools/call

Request: `{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"<catalog name>","arguments":{"target":"example.com","args":"-silent"}}}`

Response (success):

```json
{"jsonrpc":"2.0","id":3,"result":{"target":"example.com","status":"ok","findings":[],"raw_ref":"data/toolraw/<name>-<id>.txt"}}
```

Response (binary absent):

```json
{"jsonrpc":"2.0","id":3,"result":{"target":"example.com","status":"not_installed","findings":[],"raw_ref":"data/toolraw/<name>-<id>.txt"}}
```

Rules: no approval, sandbox or scope field is added; arguments are passed only to the declared binary; output is captured and referenced, never returned as raw text.

## ping

Request: `{"jsonrpc":"2.0","id":4,"method":"ping","params":{}}`

Response: `{"jsonrpc":"2.0","id":4,"result":{"status":"ok"}}`

Rule: answers in under 5 seconds, independent of the tool timeout.

## Error shape

Unknown method or invalid catalog name: `{"jsonrpc":"2.0","id":N,"error":{"code":-32601,"message":"..."}}`.
