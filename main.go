package main

import (
	"fmt"
	"strings"

	"github.com/google/uuid"
	"golang.org/x/net/html"
)

// main is a throwaway fixture: it calls html.Parse so govulncheck reports a
// reachable advisory (fixed in golang.org/x/net v0.62.0) and leaves a
// clean-but-outdated module (google/uuid v1.0.0) in the graph, which a
// targeted vuln fix must not touch.
func main() {
	doc, err := html.Parse(strings.NewReader("<html><body><p>fixture</p></body></html>"))
	if err != nil {
		fmt.Println("parse error:", err)
	}
	fmt.Println("nodes:", doc != nil, "run:", uuid.New())
}
