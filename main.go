package main

import (
	"os"
	"path/filepath"
	"sort"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/krystofrezac/feee/pkg/tree"
)

type model struct {
	tree   *tree.Node
	active *tree.Node
	debug  string
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	m.debug = ""

	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "q":
			return m, tea.Quit
		case "j":

			if n := m.active.Next(); n != nil {
				m.active = n
			}
		case "k":
			if p := m.active.Prev(); p != nil {
				m.active = p
			}
		case "l":
			m.active.Expanded = true
		case "h":
			m.active.Expanded = false
		}
	}

	return m, nil
}

func (m model) View() string {
	res := renderTree(m, m.tree, 0)
	res += "\n" + m.debug
	return res
}

func main() {
	t, err := getTree()
	if err != nil {
		os.Exit(1)
	}

	p := tea.NewProgram(
		model{
			tree:   t,
			active: t,
		},
		tea.WithAltScreen(),
	)

	if _, err := p.Run(); err != nil {
		os.Exit(1)
	}
}

func addDirSubNodes(parent *tree.Node, path string) error {
	dir, err := os.ReadDir(path)
	if err != nil {
		return err
	}

	sort.Slice(dir, func(i, j int) bool {
		iItem := dir[i]
		jItem:=dir[j]
		
		if iItem.IsDir() &&!jItem.IsDir(){
			return true
		}
		if !iItem.IsDir() && jItem.IsDir(){
			return false
		}

		return strings.Compare(dir[i].Name(), dir[j].Name()) < 0
	})

	for _, item := range dir {
		node := parent.AddSubNode(item.Name())
		if item.IsDir() {
			err := addDirSubNodes(node, filepath.Join(path, item.Name()))
			if err != nil {
				return err
			}
		}

	}

	return nil
}

func getTree() (*tree.Node, error) {
	wd, err := os.Getwd()
	if err != nil {
		return &tree.Node{}, err
	}

	folderName := filepath.Base(wd)

	topNode := tree.NewTree(folderName)

	err = addDirSubNodes(topNode, wd)
	if err != nil {
		return &tree.Node{}, err
	}

	return topNode, nil
}
