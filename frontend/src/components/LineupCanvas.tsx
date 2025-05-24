import {
  Background,
  Controls,
  MiniMap,
  Node,
  ReactFlow,
  ReactFlowProvider,
  useEdgesState,
  useNodesState,
  useReactFlow,
} from 'reactflow'
import 'reactflow/dist/style.css'
import { useEffect, useCallback } from 'react'
import type { Artist, Tier } from '../types'

// Layout definitions
const tiers: Tier[] = ['headliner', 'support', 'opener']
const stages = ['Queue', 'Dreamy', 'Heavy', 'Groovy']

const tierY: Record<Tier, number> = {
  headliner: 0,
  support: 200,
  opener: 400,
}

const stageX: Record<string, number> = {
  Queue: -300,
  Dreamy: 0,
  Heavy: 300,
  Groovy: 600,
}

const CELL_WIDTH = 200
const CELL_HEIGHT = 150

type Props = {
  queuedArtists: Artist[]
}

function CanvasGrid() {
  const { viewport } = useReactFlow()

  return (
    <svg
      style={{
        position: 'absolute',
        inset: 0,
        zIndex: 0,
        pointerEvents: 'none',
      }}
    >
      <g
        transform={`translate(${viewport.x}, ${viewport.y}) scale(${viewport.zoom})`}
      >
        {tiers.map((tier) => (
          <rect
            key={tier}
            x={-1000}
            y={tierY[tier]}
            width={3000}
            height={CELL_HEIGHT}
            fill="rgba(0,0,0,0.03)"
            stroke="lightgray"
            strokeDasharray="2 2"
          />
        ))}

        {tiers.map((tier) => (
          <text
            key={`label-${tier}`}
            x={-290}
            y={tierY[tier] + 20}
            fill="#555"
            fontSize={12}
            fontWeight="bold"
          >
            {tier.toUpperCase()}
          </text>
        ))}

        {stages.map((stage) => (
          <text
            key={`stage-${stage}`}
            x={stageX[stage] + 4}
            y={-10}
            fill="#555"
            fontSize={12}
            fontWeight="bold"
          >
            {stage}
          </text>
        ))}
      </g>
    </svg>
  )
}

export default function LineupCanvas({ queuedArtists }: Props) {
  const [nodes, setNodes, onNodesChange] = useNodesState([])
  const [edges, setEdges, onEdgesChange] = useEdgesState([])

  const snapToGrid = (x: number, y: number): { x: number; y: number } => {
    const snapX = Math.round(x / CELL_WIDTH) * CELL_WIDTH
    const snapY = Math.round(y / CELL_HEIGHT) * CELL_HEIGHT
    return { x: snapX, y: snapY }
  }

  const handleNodeDragStop = useCallback(
    (_event: any, node: any) => {
      const snapped = snapToGrid(node.position.x, node.position.y)
      setNodes((nds) =>
        nds.map((n) =>
          n.id === node.id ? { ...n, position: snapped } : n
        )
      )
    },
    [setNodes]
  )

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
    <div style={{ height: '80vh', border: '1px solid #ccc', position: 'relative' }}>
      <ReactFlowProvider>
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodesChange={onNodesChange}
          onEdgesChange={onEdgesChange}
          onNodeDragStop={handleNodeDragStop}
          fitView
        >
          <CanvasGrid />
          <Background gap={24} />
          <Controls />
          <MiniMap />
        </ReactFlow>
      </ReactFlowProvider>
    </div>
  )
}
