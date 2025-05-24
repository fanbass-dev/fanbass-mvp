import {
  Background,
  Controls,
  MiniMap,
  Node,
  ReactFlow,
  ReactFlowProvider,
  useEdgesState,
  useNodesState,
} from 'reactflow'
import 'reactflow/dist/style.css'
import { useEffect } from 'react'
import type { Artist, Tier } from '../types'

const tiers: Tier[] = ['headliner', 'support', 'opener']
const stages = ['Queue', 'Dreamy', 'Heavy', 'Groovy']

const tierY: Record<Tier, number> = {
  headliner: 0,
  support: 200,
  opener: 400,
}

// Add a queue staging area at x = -300
const stageX: Record<string, number> = {
  Queue: -300,
  Dreamy: 0,
  Heavy: 300,
  Groovy: 600,
}

type Props = {
  queuedArtists: Artist[]
}

export default function LineupCanvas({ queuedArtists }: Props) {
  const [nodes, setNodes, onNodesChange] = useNodesState([])
  const [edges, setEdges, onEdgesChange] = useEdgesState([])

  // Inject new queued artists into the canvas, in the "Queue" column
  useEffect(() => {
    const newNodes: Node[] = queuedArtists.map((artist, i) => ({
      id: `queue-${artist.id}`,
      data: { label: artist.name },
      position: {
        x: stageX['Queue'],
        y: tierY.opener + i * 60,
      },
      type: 'default',
    }))

    setNodes((prev) => {
      const existingIds = new Set(prev.map((n) => n.id))
      const merged = [...prev]
      for (const n of newNodes) {
        if (!existingIds.has(n.id)) merged.push(n)
      }
      return merged
    })
  }, [queuedArtists])

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
