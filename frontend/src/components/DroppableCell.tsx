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
        display: 'grid',
        gridAutoFlow: 'column',
        gridAutoRows: 'min-content',
        gap: '6px',
        overflow: 'hidden', // optional, can use 'auto' if you want scroll
      }}
    >
      {artists.map((artist) => (
        <div
          key={artist.id}
          style={{
            background: '#ddd',
            padding: '4px 6px',
            borderRadius: '4px',
            whiteSpace: 'nowrap',
          }}
        >
          {artist.name}
        </div>
      ))}
    </div>
  )
}
