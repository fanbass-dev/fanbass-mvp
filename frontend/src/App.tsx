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
  const [artists, setArtists] = useState<Artist[]>([])
  const [events, setEvents] = useState<Event[] | null>(null)

  const [searchTerm, setSearchTerm] = useState('')
  const [queue, setQueue] = useState<Artist[]>([])

  // Load user + artist data
  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setUser(data?.session?.user ?? null)
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    // Fetch artists from Supabase
    const fetchArtists = async () => {
      const { data, error } = await supabase
        .from('artists')
        .select('id, name')

      if (error) {
        console.error('Failed to fetch artists:', error)
      } else {
        setArtists(data ?? [])
      }
    }

    fetchArtists()
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

  const filteredArtists = artists.filter(
    (artist) =>
      artist.name.toLowerCase().includes(searchTerm.toLowerCase()) &&
      !queue.some((q) => q.id === artist.id)
  )

  const addToQueue = (artist: Artist) => {
    setQueue([...queue, artist])
  }

  const getArtistName = (id: string) => {
    const artist = artists.find((a) => a.id === id)
    return artist?.name || id
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>FanBass MVP</h1>

      {user ? (
        <>
          <p>Logged in as: <strong>{user.email}</strong></p>
          <button onClick={signOut}>Log out</button>

          {/* 🎧 Artist Search & Queue */}
          <h2>Search Artists</h2>
          <input
            type="text"
            placeholder="Search artists"
            style={{ padding: '0.5rem', marginBottom: '1rem', display: 'block', width: '100%' }}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />

          <div>
            {filteredArtists.map((artist) => (
              <div key={artist.id} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                <span>{artist.name}</span>
                <button onClick={() => addToQueue(artist)}>+ Add</button>
              </div>
            ))}
          </div>

          <h2>Your Queue</h2>
          <ul>
            {queue.map((artist) => (
              <li key={artist.id} style={{ marginBottom: '0.25rem' }}>{artist.name}</li>
            ))}
          </ul>

          {/* 🎉 Personalized Events (unchanged) */}
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
