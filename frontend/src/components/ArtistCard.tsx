import { useDraggable } from '@dnd-kit/core'
import { CSS } from '@dnd-kit/utilities'
import type { Artist } from '../types'

type Props = {
  artist: Artist
}

export function ArtistCard({ artist }: Props) {
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: artist.id,
  })

  const style = {
    transform: CSS.Translate.toString(transform),
    opacity: isDragging ? 0.5 : 1,
    transition: 'box-shadow 0.2s ease',
    boxShadow: isDragging ? '0 0 6px rgba(0,0,0,0.2)' : undefined,
  }

  return (
    <div
      ref={setNodeRef}
      {...attributes}
      {...listeners}
      style={{
        ...style,
        background: '#eee',
        padding: '6px 10px',
        borderRadius: '6px',
        margin: '4px 0',
        cursor: 'grab',
        fontSize: 14,
        fontWeight: 500,
        userSelect: 'none',
      }}
    >
      {artist.name}
    </div>
  )
}
