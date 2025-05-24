import { useDroppable } from '@dnd-kit/core'
import type { Artist } from '../types'

type Props = {
  id: string
  artists: Artist[]
}

export function DroppableCell({ id, artists }: Props) {
  const { setNodeRef, isOver } = useDroppable({ id })

  return (
    <div
      ref={setNodeRef}
      style={{
        height: '150px',
        padding: '8px',
        border: '1px dashed #aaa',
        background: isOver ? '#f0f0f0' : 'white',
        columnWidth: '100px',
        columnGap: '8px',
        overflow: 'hidden',
      }}
    >
      {artists.map((artist) => (
        <div
          key={artist.id}
          style={{
            breakInside: 'avoid',
            background: '#ddd',
            padding: '4px 6px',
            marginBottom: '6px',
            borderRadius: '4px',
          }}
        >
          {artist.name}
        </div>
      ))}
    </div>
  )
}
