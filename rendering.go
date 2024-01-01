package main

import (
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/krystofrezac/feee/pkg/tree"
)

func renderIndent(size int) string {
	res := ""
	for i := 0; i < size; i++ {
		res = res + "  "
	}
	return res
}

var activeStyle = lipgloss.NewStyle().Background(lipgloss.Color("#f00"))

func renderTree(m model, node *tree.Node, level int) string {
	var res strings.Builder

	icon := "-"
	if node.SubNodes()!=nil {
		if node.Expanded {
			icon = "▼"
		}else {
			icon = "►"
		}
	}

	name := node.Name
	if m.active.Equals(node) {
		name = activeStyle.Render(name)
	}

	res.WriteString(renderIndent(level))
	res.WriteString(icon)
	res.WriteString(" ")
	res.WriteString(name)
	res.WriteString("\n")

	subNodes := node.SubNodes()
	if subNodes != nil && node.Expanded {
		for _, subNode := range subNodes {
			res.WriteString(renderTree(m, subNode, level+1))
		}
	}

	return res.String()
}
