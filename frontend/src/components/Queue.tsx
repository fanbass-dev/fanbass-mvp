import { DraggableArtist } from './DraggableArtist'
import type { Artist } from '../types'

type Props = {
  queue: Artist[]
}

export function Queue({ queue }: Props) {
  return (
    <div>
      <h2>Your Queue</h2>
      {queue.length === 0 ? (
        <p>No artists added yet.</p>
      ) : (
        queue.map((artist) => (
          <DraggableArtist key={artist.id} artist={artist} />
        ))
      )}
    </div>
  )
}
