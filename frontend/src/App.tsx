import { useState, useEffect } from 'react'
import { useAuth } from './hooks/useAuth'
import ArtistCanvas from './components/ArtistCanvas'
import { SearchBar } from './components/SearchBar'
import type { Artist, Tier } from './types'
import { useArtistSearch } from './hooks/useArtistSearch'

const tiers: Tier[] = ['headliner', 'support', 'opener']
const stages = ['Dreamy', 'Heavy', 'Groovy']

function App() {
  const { user, signIn, signOut } = useAuth()
  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)
  const [queue, setQueue] = useState<Artist[]>([])

  const handleAddToQueue = (artist: Artist) => {
    setQueue((prev) => [...prev, artist])
  }

  return (
    <div style={{ fontFamily: 'sans-serif', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      {user ? (
        <>
          <div style={{
            padding: '0.5rem',
            background: '#f0f0f0',
            zIndex: 2,
            position: 'relative'
          }}>
            Logged in as: <strong>{user.email}</strong>
            <button style={{ marginLeft: '1rem' }} onClick={signOut}>Log out</button>
          </div>

          <div style={{ display: 'flex', flex: 1, minHeight: 0 }}>
            <div style={{
              width: '300px',
              padding: '1rem',
              overflowY: 'auto',
              background: '#fafafa',
              position: 'relative',
              zIndex: 2
            }}>
              <SearchBar
                searchTerm={searchTerm}
                searchResults={searchResults}
                searching={searching}
                onChange={setSearchTerm}
                onAdd={handleAddToQueue}
                queue={queue}
              />
            </div>

            <div style={{ flex: 1, overflow: 'hidden', position: 'relative', zIndex: 0 }}>
              <ArtistCanvas artists={queue} />
            </div>
          </div>
        </>
      ) : (
        <button onClick={signIn}>Log in with Google</button>
      )}
    </div>
  )
}

export default App
