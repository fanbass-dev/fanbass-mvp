import { useDraggable } from '@dnd-kit/core'
import type { Artist } from '../types'

export function DraggableArtist({ artist }: { artist: Artist }) {
  const { attributes, listeners, setNodeRef, transform } = useDraggable({
    id: artist.id,
  })

  return (
    <div
      ref={setNodeRef}
      {...attributes}
      {...listeners}
      style={{
        padding: '4px 8px',
        marginBottom: '4px',
        background: '#eee',
        cursor: 'grab',
        transform: transform
          ? `translate(${transform.x}px, ${transform.y}px)`
          : undefined,
      }}
    >
      {artist.name}
    </div>
  )
}
