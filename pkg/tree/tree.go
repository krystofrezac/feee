package tree

type Node struct {
	Name         string
	Expanded     bool
	subNodes     []*Node
	id           int
	parent       *Node
	subNodeIndex int
}

var id = 0

func NewTree(name string) *Node {
	n := &Node{
		Name:     name,
		Expanded: true,
		id:       id,
	}
	id++
	return n
}

func (n *Node) Equals(to *Node) bool {
	return n.id == to.id
}

func (n Node) SubNodes() []*Node {
	return n.subNodes
}

func (n *Node) AddSubNode(name string) *Node {
	sub := &Node{
		Name:         name,
		Expanded:     false,
		id:           id,
		parent:       n,
		subNodeIndex: len(n.subNodes),
	}
	id++
	n.subNodes = append(n.subNodes, sub)
	return sub
}

func (n *Node) nextSameLevel() (*Node, bool) {
	nextSubNodeIndex := n.subNodeIndex + 1
	if n.parent != nil && len(n.parent.subNodes) > nextSubNodeIndex {
		nextSameLevel := n.parent.subNodes[nextSubNodeIndex]
		return nextSameLevel, true
	}

	return &Node{}, false
}

func (n *Node) Next() *Node {
	// Try to find sub node
	if n.subNodes != nil && n.Expanded {
		return n.subNodes[0]
	}

	// Try to find same level node
	sameLevel, ok := n.nextSameLevel()
	if ok {
		return sameLevel
	}

	// Try to find upper level node
	current := n
	for current.parent != nil {
		sameLevel, ok := current.parent.nextSameLevel()
		if ok {
			return sameLevel
		}
		current = current.parent
	}

	return nil
}

func (n *Node) lastNested() *Node {
	if n.subNodes == nil {
		return n
	}

	res := n
	for res.Expanded && res.subNodes != nil {
		res = res.subNodes[len(res.subNodes)-1]
	}
	return res
}

func (n *Node) Prev() *Node {
	if n.subNodeIndex == 0 {
		return n.parent
	}

	if n.parent != nil {
		prev := n.parent.subNodes[n.subNodeIndex-1]
		return prev.lastNested()
	}

	return nil
}
