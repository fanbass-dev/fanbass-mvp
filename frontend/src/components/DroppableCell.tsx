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
        display: 'flex',
        flexWrap: 'wrap',
        alignContent: 'flex-start',
        gap: '6px',
        overflow: 'hidden',
      }}
    >
      {artists.map((artist) => (
        <div
          key={artist.id}
          style={{
            padding: '4px 6px',
            background: '#ddd',
            borderRadius: '4px',
            minWidth: '60px',
            flex: '0 0 auto',
          }}
        >
          {artist.name}
        </div>
      ))}
    </div>
  )
}
