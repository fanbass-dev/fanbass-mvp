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
        height: '150px',
        minWidth: '200px',
        border: '1px dashed #aaa',
        padding: '6px',
        background: isOver ? '#f0f0f0' : 'white',
        columnCount: 2,
        columnGap: '8px',
        overflow: 'hidden',
      }}
    >
      {artists.map((artist) => (
        <div key={artist.id} style={{ breakInside: 'avoid' }}>
          <ArtistCard artist={artist} />
        </div>
      ))}
    </div>
  )
}
