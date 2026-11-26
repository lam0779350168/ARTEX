package tools

import (
	"path/filepath"
	"testing"
)

func TestCatalogLoadsAndValidates(t *testing.T) {
	c, err := Load(filepath.Join("..", "tools", "catalog.json"))
	if err != nil {
		t.Fatalf("load catalog: %v", err)
	}
	if len(c.Tools) < 50 {
		t.Fatalf("catalog has only %d entries", len(c.Tools))
	}
}

func TestCatalogRejectsBadEnumsAndTimeouts(t *testing.T) {
	base := Entry{Name: "x", Binary: "x", Command: "x", Capability: ReconPassive, Risk: ReadOnly, TimeoutSec: 60, HealthTimeoutSec: 2}
	tests := []struct {
		name string
		mut  func(*Entry)
	}{
		{"capability", func(e *Entry) { e.Capability = "bogus" }},
		{"risk", func(e *Entry) { e.Risk = "bogus" }},
		{"timeout", func(e *Entry) { e.TimeoutSec = 0 }},
		{"health timeout", func(e *Entry) { e.HealthTimeoutSec = 5 }},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			e := base
			tt.mut(&e)
			c := &Catalog{Tools: []Entry{e}}
			if err := c.Validate(); err == nil {
				t.Fatal("expected validation error")
			}
		})
	}
}

func TestCatalogDuplicateNames(t *testing.T) {
	e := Entry{Name: "x", Binary: "x", Capability: ReconPassive, Risk: ReadOnly, TimeoutSec: 60, HealthTimeoutSec: 2}
	c := &Catalog{Tools: []Entry{e, e}}
	if err := c.Validate(); err == nil {
		t.Fatal("expected duplicate name error")
	}
}

func TestHeavyScannersHaveLongTimeouts(t *testing.T) {
	c, err := Load(filepath.Join("..", "tools", "catalog.json"))
	if err != nil {
		t.Fatal(err)
	}
	for _, name := range []string{"nuclei", "sqlmap", "trivy", "semgrep", "garak"} {
		e, ok := c.Get(name)
		if !ok {
			t.Fatalf("missing %s", name)
		}
		if e.TimeoutSec < 300 {
			t.Errorf("%s timeout %d < 300", name, e.TimeoutSec)
		}
	}
}

func TestByCapabilityReturnsAllMatches(t *testing.T) {
	c := &Catalog{Tools: []Entry{
		{Name: "a", Capability: CodeAudit},
		{Name: "b", Capability: CodeAudit},
		{Name: "c", Capability: ReconPassive},
	}}
	if got := len(c.ByCapability(CodeAudit)); got != 2 {
		t.Fatalf("got %d code-audit tools, want 2", got)
	}
}

func TestBuildArgsExpandsTemplate(t *testing.T) {
	e := Entry{Name: "x", Binary: "x", Command: "x -d {target} {args}"}
	got := e.BuildArgs("example.com", "-silent -v")
	want := []string{"-d", "example.com", "-silent", "-v"}
	if len(got) != len(want) {
		t.Fatalf("got %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("got %v, want %v", got, want)
		}
	}
}
