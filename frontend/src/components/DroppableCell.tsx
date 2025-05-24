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
        minHeight: '60px',
        padding: '8px',
        border: '1px dashed #aaa',
        background: isOver ? '#f0f0f0' : 'white',
      }}
    >
      {artists.map((artist) => (
        <div
          key={artist.id}
          style={{
            padding: '4px 8px',
            marginBottom: '4px',
            background: '#ddd',
          }}
        >
          {artist.name}
        </div>
      ))}
    </div>
  )
}
