// Command toolserver exposes one catalogued tool as a small JSON-RPC server.
// Each repo runs its own process: toolserver --tool <name>.
package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/Autumn-27/artex/tools"
)

type request struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      any             `json:"id"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params"`
}

type response struct {
	JSONRPC string  `json:"jsonrpc"`
	ID      any     `json:"id"`
	Result  any     `json:"result,omitempty"`
	Error   *rpcErr `json:"error,omitempty"`
}

type rpcErr struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

type callParams struct {
	Name      string         `json:"name"`
	Arguments map[string]any `json:"arguments"`
}

type finding struct {
	Title  string `json:"title,omitempty"`
	Detail string `json:"detail,omitempty"`
}

type record struct {
	Target   string    `json:"target"`
	Status   string    `json:"status"`
	Findings []finding `json:"findings"`
	RawRef   string    `json:"raw_ref"`
}

func main() {
	catalogPath := flag.String("catalog", "tools/catalog.json", "path to the tool catalog")
	toolName := flag.String("tool", "", "catalog entry to serve")
	flag.Parse()

	if *toolName == "" {
		fmt.Fprintln(os.Stderr, "--tool is required")
		os.Exit(2)
	}
	c, err := tools.Load(*catalogPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, "catalog:", err)
		os.Exit(1)
	}
	entry, ok := c.Get(*toolName)
	if !ok {
		fmt.Fprintln(os.Stderr, "unknown tool:", *toolName)
		os.Exit(2)
	}

	dec := json.NewDecoder(os.Stdin)
	enc := json.NewEncoder(os.Stdout)
	for {
		var req request
		if err := dec.Decode(&req); err != nil {
			if errors.Is(err, io.EOF) {
				return
			}
			fmt.Fprintln(os.Stderr, "decode:", err)
			return
		}
		res := handle(context.Background(), entry, req)
		if err := enc.Encode(res); err != nil {
			fmt.Fprintln(os.Stderr, "encode:", err)
			return
		}
	}
}

func handle(ctx context.Context, entry tools.Entry, req request) response {
	res := response{JSONRPC: "2.0", ID: req.ID}
	switch req.Method {
	case "initialize":
		res.Result = map[string]any{
			"name": entry.Name, "capability": entry.Capability, "risk": entry.Risk,
		}
	case "tools/list":
		res.Result = map[string]any{"tools": []map[string]any{{
			"name":        entry.Name,
			"description": fmt.Sprintf("%s (%s, %s)", entry.Name, entry.Capability, entry.Risk),
			"inputSchema": map[string]any{
				"type": "object",
				"properties": map[string]any{
					"target": map[string]any{"type": "string"},
					"args":   map[string]any{"type": "string"},
				},
			},
		}}}
	case "ping":
		res.Result = map[string]any{"status": "ok"}
	case "tools/call":
		var p callParams
		if err := json.Unmarshal(req.Params, &p); err != nil {
			res.Error = &rpcErr{Code: -32602, Message: "invalid params"}
			return res
		}
		target, _ := p.Arguments["target"].(string)
		extra, _ := p.Arguments["args"].(string)
		res.Result = run(ctx, entry, target, extra)
	default:
		res.Error = &rpcErr{Code: -32601, Message: "method not found"}
	}
	return res
}

func run(ctx context.Context, entry tools.Entry, target, extra string) record {
	if _, err := exec.LookPath(entry.Binary); err != nil {
		return record{
			Target: target, Status: "not_installed", Findings: []finding{},
			RawRef: writeRaw(entry.Name, []byte("binary not installed: "+entry.Binary+"\n")),
		}
	}
	ctx, cancel := context.WithTimeout(ctx, time.Duration(entry.TimeoutSec)*time.Second)
	defer cancel()

	args := entry.BuildArgs(target, extra)
	cmd := exec.CommandContext(ctx, entry.Binary, args...)
	out, err := cmd.CombinedOutput()

	rawRef := writeRaw(entry.Name, out)
	status := "ok"
	if errors.Is(ctx.Err(), context.DeadlineExceeded) {
		status = "timeout"
	} else if err != nil {
		status = "error"
	}
	return record{Target: target, Status: status, Findings: []finding{}, RawRef: rawRef}
}

func writeRaw(name string, out []byte) string {
	dir := filepath.Join("data", "toolraw")
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return ""
	}
	path := filepath.Join(dir, fmt.Sprintf("%s-%d.txt", name, time.Now().UnixNano()))
	if err := os.WriteFile(path, out, 0o600); err != nil {
		return ""
	}
	return path
}
