package tools

import "time"

// RegistryEntry is the discoverable projection of a catalog entry.
type RegistryEntry struct {
	Name       string
	Capability string
	Risk       string
	Healthy    bool
	LastHealth time.Time
}

// Registry holds in-memory health state for catalogued servers.
type Registry struct {
	entries map[string]*RegistryEntry
}

// NewRegistry seeds one entry per catalog tool, all initially healthy.
func NewRegistry(c *Catalog) *Registry {
	r := &Registry{entries: make(map[string]*RegistryEntry, len(c.Tools))}
	for _, t := range c.Tools {
		r.entries[t.Name] = &RegistryEntry{
			Name: t.Name, Capability: t.Capability, Risk: t.Risk, Healthy: true,
		}
	}
	return r
}

// MarkHealth records a health probe result; a failed probe removes the entry
// from capability queries immediately.
func (r *Registry) MarkHealth(name string, ok bool) {
	if e, found := r.entries[name]; found {
		e.Healthy = ok
		e.LastHealth = time.Now()
	}
}

// ByCapability returns only healthy tools with the requested capability.
func (r *Registry) ByCapability(capability string) []RegistryEntry {
	var out []RegistryEntry
	for _, e := range r.entries {
		if e.Capability == capability && e.Healthy {
			out = append(out, *e)
		}
	}
	return out
}
