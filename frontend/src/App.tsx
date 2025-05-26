import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'
import ArtistCanvas from './components/ArtistCanvas'
import { SearchBar } from './components/SearchBar'
import type { Artist, Tier } from './types'

const tiers: Tier[] = ['headliner', 'support', 'opener']
const stages = ['Dreamy', 'Heavy', 'Groovy']

function App() {
  const [user, setUser] = useState<any>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [searchResults, setSearchResults] = useState<Artist[]>([])
  const [searching, setSearching] = useState(false)
  const [queue, setQueue] = useState<Artist[]>([])

  useEffect(() => {
    // Get current session
    supabase.auth.getSession().then(({ data }) => {
      setUser(data?.session?.user ?? null)
    })

    // Subscribe to auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    return () => subscription.unsubscribe()
  }, [])

  // Search Supabase for artists
  useEffect(() => {
    if (!searchTerm.trim()) {
      setSearchResults([])
      return
    }

    setSearching(true)

    supabase
      .from('artists')
      .select('id, name')
      .ilike('name', `%${searchTerm}%`)
      .then(({ data, error }) => {
        setSearching(false)
        if (error) {
          console.error('Search failed:', error)
          return
        }
        setSearchResults(data || [])
      })
  }, [searchTerm])

  const signInWithGoogle = async () => {
    await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: window.location.origin,
      },
    })
  }

  const signOut = async () => {
    await supabase.auth.signOut()
    setUser(null)
  }

  const handleAddToQueue = (artist: Artist) => {
    setQueue((prev) => [...prev, artist])
  }

  return (
    <div style={{ fontFamily: 'sans-serif', height: '100vh', overflow: 'hidden' }}>
      {user ? (
        <>
          <div style={{ padding: '0.5rem', background: '#f0f0f0' }}>
            Logged in as: <strong>{user.email}</strong>
            <button style={{ marginLeft: '1rem' }} onClick={signOut}>Log out</button>
          </div>
          <div style={{ display: 'flex', height: 'calc(100vh - 40px)' }}>
            <div style={{ width: '300px', padding: '1rem', overflowY: 'auto', background: '#fafafa' }}>
              <SearchBar
                searchTerm={searchTerm}
                searchResults={searchResults}
                searching={searching}
                onChange={setSearchTerm}
                onAdd={handleAddToQueue}
                queue={queue}
              />
            </div>
            <div style={{ flex: 1 }}>
              <ArtistCanvas artists={queue} />
            </div>
          </div>
        </>
      ) : (
        <button onClick={signInWithGoogle}>Log in with Google</button>
      )}
    </div>
  )
}

export default App
