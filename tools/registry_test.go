package tools

import "testing"

func TestCapabilityQueryFiltersHealthyOnly(t *testing.T) {
	c := &Catalog{Tools: []Entry{
		{Name: "a", Capability: CodeAudit, Risk: ReadOnly},
		{Name: "b", Capability: CodeAudit, Risk: ReadOnly},
		{Name: "c", Capability: ReconPassive, Risk: ReadOnly},
	}}
	r := NewRegistry(c)
	if got := len(r.ByCapability(CodeAudit)); got != 2 {
		t.Fatalf("initial query = %d, want 2", got)
	}
	r.MarkHealth("a", false)
	got := r.ByCapability(CodeAudit)
	if len(got) != 1 || got[0].Name != "b" {
		t.Fatalf("after unhealthy = %v, want only b", got)
	}
}

func TestCapabilityQueryKeepsTwoToolsWithSameCapability(t *testing.T) {
	c := &Catalog{Tools: []Entry{
		{Name: "a", Capability: ReconPassive},
		{Name: "b", Capability: ReconPassive},
	}}
	r := NewRegistry(c)
	if got := len(r.ByCapability(ReconPassive)); got != 2 {
		t.Fatalf("got %d, want 2", got)
	}
}
