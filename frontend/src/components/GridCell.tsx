import { useDroppable } from '@dnd-kit/core'
import type { Artist } from '../types'
import { ArtistCard } from './ArtistCard'

type Props = {
  id: string
  artists: Artist[]
}

export function GridCell({ id, artists }: Props) {
  const { setNodeRef, isOver } = useDroppable({ id })

  return (
    <div
      ref={setNodeRef}
      style={{
        minHeight: '150px',
        minWidth: '200px',
        border: '1px dashed #aaa',
        padding: '8px',
        background: isOver ? '#f0f0f0' : 'white',
        display: 'flex',
        flexDirection: 'column',
        flexWrap: 'wrap',
      }}
    >
      {artists.map((artist) => (
        <ArtistCard key={artist.id} artist={artist} />
      ))}
    </div>
  )
}
