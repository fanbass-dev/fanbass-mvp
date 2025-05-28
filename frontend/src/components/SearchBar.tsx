import type { Artist } from '../types'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onChange: (term: string) => void
  onAdd: (artist: Artist) => void
  queue: Artist[]
}

export function SearchBar({
  searchTerm,
  searchResults,
  searching,
  onChange,
  onAdd,
  queue,
}: Props) {
  const isInQueue = (artistId: string) =>
    queue.some((a) => a.id === artistId)

  const filteredResults = searchResults.filter(
    (artist) => !isInQueue(artist.id)
  )

  return (
    <div>
      <h2>Search Artists</h2>
      <input
        type="text"
        placeholder="Search artists"
        style={{
          padding: '0.5rem',
          marginBottom: '1rem',
          display: 'block',
          width: '90%',
        }}
        value={searchTerm}
        onChange={(e) => onChange(e.target.value)}
      />
      {searching ? (
        <p>Searching...</p>
      ) : (
        filteredResults.map((artist) => (
          <div
            key={artist.id}
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              marginBottom: '0.5rem',
            }}
          >
            <span>{artist.name}</span>
            <button
              onClick={() => {
                console.log('Adding artist:', artist)
                onAdd(artist)
              }}
            >
              + Add
            </button>
          </div>
        ))
      )}
    </div>
  )
}
