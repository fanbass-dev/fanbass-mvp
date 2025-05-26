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
  const filteredResults = searchResults.filter(
    (artist) => !queue.some((q) => q.id === artist.id)
  )

  return (
    <div>
      <h2>Search Artists</h2>
      <input
        type="text"
        placeholder="Search artists"
        style={{ padding: '0.5rem', marginBottom: '1rem', display: 'block', width: '80%' }}
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
            <button onClick={() => onAdd(artist)}>+ Add</button>
          </div>
        ))
      )}
    </div>
  )
}
