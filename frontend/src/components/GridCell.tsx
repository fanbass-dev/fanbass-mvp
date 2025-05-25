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
        display: 'grid',
        gridAutoFlow: 'column',
        gridAutoRows: '48px',
        gridAutoColumns: '100px', // 👈 this replaces template-columns
        gap: '8px',
        alignContent: 'start',
      }}
    >
      {artists.map((artist) => (
        <ArtistCard key={artist.id} artist={artist} />
      ))}
    </div>
  )
}
