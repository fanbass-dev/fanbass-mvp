import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'

type ArtistRanking = {
  artist_id: string
  rank: number
}

type Event = {
  id: string
  name: string
  reordered_lineup: string[]
}

type Artist = {
  id: string
  name: string
}

function App() {
  const [user, setUser] = useState<any>(null)
  const [rankings, setRankings] = useState<ArtistRanking[]>([{ artist_id: '', rank: 1 }])
  const [events, setEvents] = useState<Event[] | null>(null)
  const [artists, setArtists] = useState<Artist[]>([])

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setUser(data?.session?.user ?? null)
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    fetch(`${process.env.REACT_APP_API_BASE_URL}/artists`)
      .then((res) => res.json())
      .then((data) => setArtists(data))
  }, [])

  const signInWithGoogle = async () => {
    await supabase.auth.signInWithOAuth({ provider: 'google' })
  }

  const signOut = async () => {
    await supabase.auth.signOut()
    setUser(null)
    setEvents(null)
  }

  const handleRankingChange = (index: number, field: keyof ArtistRanking, value: string | number) => {
    const updated = [...rankings]
    updated[index][field] = field === 'rank' ? Number(value) : value
    setRankings(updated)
  }

  const addRanking = () => {
    setRankings([...rankings, { artist_id: '', rank: rankings.length + 1 }])
  }

  const submitRankings = async () => {
    const token = (await supabase.auth.getSession()).data.session?.access_token
    const baseUrl = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8000'

    const res = await fetch(`${baseUrl}/rankings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(rankings),
    })

    if (res.ok) {
      const eventsRes = await fetch(`${baseUrl}/events`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      const data = await eventsRes.json()
      setEvents(data)
    } else {
      alert('Failed to submit rankings')
    }
  }

  const getArtistName = (id: string) => {
    return artists.find((a) => a.id === id)?.name || id
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>FanBass MVP</h1>

      {user ? (
        <>
          <p>Logged in as: <strong>{user.email}</strong></p>
          <button onClick={signOut}>Log out</button>

          <h2>Rank Artists</h2>
          {rankings.map((r, i) => (
            <div key={i} style={{ marginBottom: '0.5rem' }}>
              <input
                placeholder="Artist ID"
                value={r.artist_id}
                onChange={(e) => handleRankingChange(i, 'artist_id', e.target.value)}
                style={{ marginRight: '0.5rem' }}
              />
              <input
                type="number"
                placeholder="Rank"
                value={r.rank}
                onChange={(e) => handleRankingChange(i, 'rank', e.target.value)}
                style={{ width: '60px' }}
              />
            </div>
          ))}
          <button onClick={addRanking} style={{ marginRight: '0.5rem' }}>+ Add Another</button>
          <button onClick={submitRankings}>Submit Rankings</button>

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
