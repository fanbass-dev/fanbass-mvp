import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'

import { SearchBar } from './components/SearchBar'
import { Queue } from './components/Queue'
import LineupCanvas from './components/LineupCanvas'

import type { Artist } from './types'

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

  const handleSearchChange = async (term: string) => {
    setSearchTerm(term)
    setSearching(true)

    if (term.length < 2) {
      setSearchResults([])
      setSearching(false)
      return
    }

    const { data, error } = await supabase
      .from('artists')
      .select('id, name')
      .ilike('name', `%${term}%`)
      .limit(10)

    if (error) {
      console.error('Search error:', error)
    } else {
      setSearchResults(data ?? [])
    }

    setSearching(false)
  }

  const addToQueue = (artist: Artist) => {
    setQueue([...queue, artist])
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>FanBass MVP</h1>

      {user ? (
        <>
          <p>Logged in as: <strong>{user.email}</strong></p>
          <button onClick={signOut}>Log out</button>

          <SearchBar
            searchTerm={searchTerm}
            searchResults={searchResults}
            searching={searching}
            onChange={handleSearchChange}
            onAdd={addToQueue}
            queue={queue}
          />

          <Queue queue={queue} />

          <h2 style={{ marginTop: '2rem' }}>Lineup Canvas</h2>
          <LineupCanvas />
        </>
      ) : (
        <button onClick={signInWithGoogle}>Log in with Google</button>
      )}
    </div>
  )
}

export default App
