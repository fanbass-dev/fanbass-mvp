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
        gridTemplateColumns: 'repeat(auto-fill, 100px)',
        overflow: 'hidden',
        gap: '6px',
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
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          {artist.name}
        </div>
      ))}
    </div>
  )
}
