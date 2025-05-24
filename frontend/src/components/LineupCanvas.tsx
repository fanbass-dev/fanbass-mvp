import {
  Background,
  Controls,
  MiniMap,
  Node,
  ReactFlow,
  ReactFlowProvider,
  useEdgesState,
  useNodesState,
  OnNodesChange,
  OnEdgesChange,
  OnNodeDragStop,
  NodeDragHandler,
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

export default function LineupCanvas({ queuedArtists }: Props) {
  const [nodes, setNodes, onNodesChange] = useNodesState([])
  const [edges, setEdges, onEdgesChange] = useEdgesState([])

  // Snap position to the center of the nearest cell
  const snapToGrid = (x: number, y: number): { x: number; y: number } => {
    const snapX = Math.round(x / CELL_WIDTH) * CELL_WIDTH
    const snapY = Math.round(y / CELL_HEIGHT) * CELL_HEIGHT
    return { x: snapX, y: snapY }
  }

  // On drag stop, snap node to grid
  const handleNodeDragStop: OnNodeDragStop = useCallback(
    (_event, node) => {
      const snapped = snapToGrid(node.position.x, node.position.y)
      setNodes((nds) =>
        nds.map((n) =>
          n.id === node.id ? { ...n, position: snapped } : n
        )
      )
    },
    [setNodes]
  )

  // Inject new queued artists into the canvas (Queue column only)
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
      {/* TIER GUIDES */}
      {tiers.map((tier) => (
        <div
          key={tier}
          style={{
            position: 'absolute',
            top: `${tierY[tier]}px`,
            left: 0,
            right: 0,
            height: `${CELL_HEIGHT}px`,
            background: 'rgba(0,0,0,0.03)',
            borderTop: '1px solid #aaa',
            pointerEvents: 'none',
            zIndex: 1,
          }}
        >
          <div
            style={{
              position: 'absolute',
              left: 4,
              top: 4,
              fontSize: 12,
              background: 'rgba(255,255,255,0.6)',
              padding: '2px 4px',
              borderRadius: 4,
            }}
          >
            {tier.toUpperCase()}
          </div>
        </div>
      ))}

      {/* STAGE GUIDES */}
      {stages.map((stage) => (
        <div
          key={stage}
          style={{
            position: 'absolute',
            left: `${stageX[stage]}px`,
            top: 0,
            height: '100%',
            width: `${CELL_WIDTH}px`,
            borderLeft: '1px solid #aaa',
            pointerEvents: 'none',
            zIndex: 1,
          }}
        >
          <div
            style={{
              position: 'absolute',
              top: 4,
              left: 4,
              fontSize: 12,
              background: 'rgba(255,255,255,0.6)',
              padding: '2px 4px',
              borderRadius: 4,
            }}
          >
            {stage}
          </div>
        </div>
      ))}

      <ReactFlowProvider>
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodesChange={onNodesChange as OnNodesChange}
          onEdgesChange={onEdgesChange as OnEdgesChange}
          onNodeDragStop={handleNodeDragStop as NodeDragHandler}
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
