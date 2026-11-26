// Package tools holds the declarative catalogue of executable security tools.
package tools

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

// Closed vocabularies shared with the skill layer and the tool registry.
const (
	ReconPassive = "recon.passive"
	ReconActive  = "recon.active"
	ScanVuln     = "scan.vuln"
	Exploit      = "exploit"
	OSINT        = "osint"
	Cloud        = "cloud"
	CodeAudit    = "code-audit"
)

const (
	ReadOnly    = "read-only"
	ActiveScan  = "active-scan"
	ExploitRisk = "exploit"
)

var capabilities = map[string]bool{
	ReconPassive: true, ReconActive: true, ScanVuln: true,
	Exploit: true, OSINT: true, Cloud: true, CodeAudit: true,
}

var risks = map[string]bool{ReadOnly: true, ActiveScan: true, ExploitRisk: true}

// Entry is one catalogued repo. Command is the default argument template;
// {target} is replaced by the caller's target and {args} by caller arguments.
type Entry struct {
	Name             string `json:"name"`
	Binary           string `json:"binary"`
	Command          string `json:"command"`
	Capability       string `json:"capability"`
	Risk             string `json:"risk"`
	TimeoutSec       int    `json:"timeout_sec"`
	HealthTimeoutSec int    `json:"health_timeout_sec"`
}

// Catalog is the list of all catalogued repos.
type Catalog struct {
	Tools []Entry `json:"tools"`
}

// Load reads and validates a catalogue from disk.
func Load(path string) (*Catalog, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var c Catalog
	if err := json.Unmarshal(b, &c); err != nil {
		return nil, err
	}
	if err := c.Validate(); err != nil {
		return nil, err
	}
	return &c, nil
}

// Validate enforces the closed enums, unique names and timeout bounds.
func (c *Catalog) Validate() error {
	seen := make(map[string]bool, len(c.Tools))
	for _, t := range c.Tools {
		if t.Name == "" || t.Binary == "" {
			return fmt.Errorf("tool entry missing name or binary: %+v", t)
		}
		if seen[t.Name] {
			return fmt.Errorf("duplicate tool name: %s", t.Name)
		}
		seen[t.Name] = true
		if !capabilities[t.Capability] {
			return fmt.Errorf("tool %s: invalid capability %q", t.Name, t.Capability)
		}
		if !risks[t.Risk] {
			return fmt.Errorf("tool %s: invalid risk %q", t.Name, t.Risk)
		}
		if t.TimeoutSec <= 0 {
			return fmt.Errorf("tool %s: timeout_sec must be positive", t.Name)
		}
		if t.HealthTimeoutSec <= 0 || t.HealthTimeoutSec >= 5 {
			return fmt.Errorf("tool %s: health_timeout_sec must be under 5 seconds", t.Name)
		}
	}
	return nil
}

// Get returns a catalog entry by name.
func (c *Catalog) Get(name string) (Entry, bool) {
	for _, t := range c.Tools {
		if t.Name == name {
			return t, true
		}
	}
	return Entry{}, false
}

// ByCapability returns every entry with the given capability, preserving order.
// Two tools sharing a capability are both returned.
func (c *Catalog) ByCapability(capability string) []Entry {
	var out []Entry
	for _, t := range c.Tools {
		if t.Capability == capability {
			out = append(out, t)
		}
	}
	return out
}

// BuildArgs expands the command template without a shell.
func (t Entry) BuildArgs(target, extra string) []string {
	fields := strings.Fields(t.Command)
	if len(fields) > 0 && fields[0] == t.Binary {
		fields = fields[1:]
	}
	out := make([]string, 0, len(fields)+4)
	for _, f := range fields {
		switch f {
		case "{target}":
			if target != "" {
				out = append(out, target)
			}
		case "{args}":
			out = append(out, strings.Fields(extra)...)
		default:
			out = append(out, f)
		}
	}
	return out
}
