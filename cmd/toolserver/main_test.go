package main

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/Autumn-27/artex/tools"
)

var testEntry = tools.Entry{
	Name: "does-not-exist-binary", Binary: "definitely-not-installed-artex",
	Command: "definitely-not-installed-artex {args}", Capability: tools.ReconPassive,
	Risk: tools.ReadOnly, TimeoutSec: 60, HealthTimeoutSec: 2,
}

func decodeResult(t *testing.T, res response) map[string]any {
	t.Helper()
	b, err := json.Marshal(res.Result)
	if err != nil {
		t.Fatal(err)
	}
	var out map[string]any
	if err := json.Unmarshal(b, &out); err != nil {
		t.Fatal(err)
	}
	return out
}

func TestInitializeAdvertisesCapabilityAndRisk(t *testing.T) {
	res := handle(context.Background(), testEntry, request{Method: "initialize"})
	if res.Error != nil {
		t.Fatalf("error: %v", res.Error)
	}
	got := decodeResult(t, res)
	if got["capability"] != tools.ReconPassive || got["risk"] != tools.ReadOnly {
		t.Fatalf("bad tags: %v", got)
	}
}

func TestToolsListHasOneTool(t *testing.T) {
	res := handle(context.Background(), testEntry, request{Method: "tools/list"})
	got := decodeResult(t, res)
	list, ok := got["tools"].([]any)
	if !ok || len(list) != 1 {
		t.Fatalf("tools/list = %v", got)
	}
}

func TestPing(t *testing.T) {
	res := handle(context.Background(), testEntry, request{Method: "ping"})
	if decodeResult(t, res)["status"] != "ok" {
		t.Fatal("ping did not return ok")
	}
}

func TestToolsCallMissingBinaryIsExplicit(t *testing.T) {
	params, _ := json.Marshal(callParams{
		Name:      testEntry.Name,
		Arguments: map[string]any{"target": "example.com", "args": "-silent"},
	})
	res := handle(context.Background(), testEntry, request{Method: "tools/call", Params: params})
	got := decodeResult(t, res)
	if got["status"] != "not_installed" {
		t.Fatalf("status = %v", got["status"])
	}
	if got["target"] != "example.com" {
		t.Fatalf("target = %v", got["target"])
	}
	if got["raw_ref"] == "" {
		t.Fatal("raw_ref must be present even when the binary is missing")
	}
	if _, ok := got["findings"].([]any); !ok {
		t.Fatalf("findings = %v", got["findings"])
	}
}

func TestUnknownMethodIsRPCError(t *testing.T) {
	res := handle(context.Background(), testEntry, request{Method: "nope"})
	if res.Error == nil || res.Error.Code != -32601 {
		t.Fatalf("expected method-not-found error, got %+v", res)
	}
}
