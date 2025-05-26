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
    supabase.auth.getSession().then(({ data }) => {
      setUser(data?.session?.user ?? null)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    return () => subscription.unsubscribe()
  }, [])

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
        <button onClick={signInWithGoogle}>Log in with Google</button>
      )}
    </div>
  )
}

export default App
