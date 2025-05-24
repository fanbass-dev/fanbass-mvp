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
    width: '100px',
    height: '48px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    textAlign: 'center',
    background: '#eee',
    padding: '6px',
    borderRadius: '6px',
    fontSize: 13,
    fontWeight: 500,
    cursor: 'grab',
    userSelect: 'none',
    overflow: 'hidden',
    lineHeight: '1.2',
    wordBreak: 'break-word',
    whiteSpace: 'normal',
  }

  return (
    <div
      ref={setNodeRef}
      {...attributes}
      {...listeners}
      style={style}
    >
      {artist.name}
    </div>
  )
}
