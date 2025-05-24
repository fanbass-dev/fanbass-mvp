import ReactFlow, {
  Background,
  Controls,
  MiniMap,
  ReactFlowProvider,
  Node,
  useNodesState,
  useEdgesState,
} from 'reactflow'
import 'reactflow/dist/style.css'

import type { Tier } from '../types'

const tiers: Tier[] = ['headliner', 'support', 'opener']
const stages = ['Dreamy', 'Heavy', 'Groovy']

// Maps each tier to a vertical Y-coordinate
const tierY: Record<Tier, number> = {
  headliner: 0,
  support: 200,
  opener: 400,
}

// Maps each stage to an X-coordinate
const stageX: Record<string, number> = {
  Dreamy: 0,
  Heavy: 300,
  Groovy: 600,
}

// Sample static artist nodes for demo purposes
const initialNodes: Node[] = [
  {
    id: 'a1',
    data: { label: 'Artist One' },
    position: { x: stageX['Dreamy'], y: tierY['headliner'] },
    type: 'default',
  },
  {
    id: 'a2',
    data: { label: 'Artist Two' },
    position: { x: stageX['Heavy'], y: tierY['support'] },
    type: 'default',
  },
  {
    id: 'a3',
    data: { label: 'Artist Three' },
    position: { x: stageX['Groovy'], y: tierY['opener'] },
    type: 'default',
  },
]

export default function LineupCanvas() {
  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes)
  const [edges, setEdges, onEdgesChange] = useEdgesState([])

  return (
    <div style={{ height: '80vh', border: '1px solid #ccc' }}>
      <ReactFlowProvider>
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodesChange={onNodesChange}
          onEdgesChange={onEdgesChange}
          fitView
        >
          <Background gap={24} />
          <Controls />
          <MiniMap />
        </ReactFlow>
      </ReactFlowProvider>
    </div>
  )
}
