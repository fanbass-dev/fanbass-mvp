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
        overflow: 'visible',
      }}
    >
      <div
        style={{
          display: 'flex',
          flexWrap: 'wrap',
          alignContent: 'flex-start',
          maxHeight: '100%',
        }}
      >
        {artists.map((artist) => (
          <div
            key={artist.id}
            style={{
              background: '#ddd',
              padding: '4px 6px',
              margin: '0 6px 6px 0',
              borderRadius: '4px',
              minHeight: '28px',
              flex: '0 0 auto',
            }}
          >
            {artist.name}
          </div>
        ))}
      </div>
    </div>
  )
}
