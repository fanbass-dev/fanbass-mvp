import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'

type Artist = {
  id: string
  name: string
}

type Event = {
  id: string
  name: string
  reordered_lineup: string[]
}

function App() {
  const [user, setUser] = useState<any>(null)
  const [events, setEvents] = useState<Event[] | null>(null)

  const [searchTerm, setSearchTerm] = useState('')
  const [searchResults, setSearchResults] = useState<Artist[]>([])
  const [searching, setSearching] = useState(false)
  const [queue, setQueue] = useState<Artist[]>([])

  // Auth setup
  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setUser(data?.session?.user ?? null)
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    return () => subscription.unsubscribe()
  }, [])

  const signInWithGoogle = async () => {
    await supabase.auth.signInWithOAuth({ provider: 'google' })
  }

  const signOut = async () => {
    await supabase.auth.signOut()
    setUser(null)
    setEvents(null)
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

  const getArtistName = (id: string) => {
    const match = queue.find((a) => a.id === id)
    return match?.name || id
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>FanBass MVP</h1>

      {user ? (
        <>
          <p>Logged in as: <strong>{user.email}</strong></p>
          <button onClick={signOut}>Log out</button>

          {/* 🎧 Live Search + Queue */}
          <h2>Search Artists</h2>
          <input
            type="text"
            placeholder="Search artists"
            style={{ padding: '0.5rem', marginBottom: '1rem', display: 'block', width: '100%' }}
            value={searchTerm}
            onChange={(e) => handleSearchChange(e.target.value)}
          />

          <div>
            {searching ? (
              <p>Searching...</p>
            ) : (
              searchResults
                .filter((artist) => !queue.some((q) => q.id === artist.id))
                .map((artist) => (
                  <div
                    key={artist.id}
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      marginBottom: '0.5rem',
                    }}
                  >
                    <span>{artist.name}</span>
                    <button onClick={() => addToQueue(artist)}>+ Add</button>
                  </div>
                ))
            )}
          </div>

          <h2>Your Queue</h2>
          <ul>
            {queue.map((artist) => (
              <li key={artist.id} style={{ marginBottom: '0.25rem' }}>
                {artist.name}
              </li>
            ))}
          </ul>

          {/* 🎉 Personalized Events */}
          <h2>Personalized Event Lineup</h2>
          {events ? (
            events.map((event) => (
              <div key={event.id}>
                <h3>{event.name}</h3>
                <ul>
                  {event.reordered_lineup.map((artistId) => (
                    <li key={artistId}>{getArtistName(artistId)}</li>
                  ))}
                </ul>
              </div>
            ))
          ) : (
            <p>No events loaded yet.</p>
          )}
        </>
      ) : (
        <button onClick={signInWithGoogle}>Log in with Google</button>
      )}
    </div>
  )
}

export default App
