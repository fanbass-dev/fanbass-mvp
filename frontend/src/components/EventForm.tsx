import { useState } from 'react'
import { supabase } from '../supabaseClient'
import { SearchBar } from './SearchBar'
import { useArtistSearch } from '../hooks/useArtistSearch'
import type { Artist } from '../types'

type TieredArtist = Artist & { tier?: number }

export function EventForm() {
  const [name, setName] = useState('')
  const [date, setDate] = useState('')
  const [location, setLocation] = useState('')
  const [numTiers, setNumTiers] = useState(3)
  const [selectedArtists, setSelectedArtists] = useState<TieredArtist[]>([])
  const [submitting, setSubmitting] = useState(false)
  const [success, setSuccess] = useState(false)

  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)

  const handleAddArtist = (artist: Artist) => {
    if (!selectedArtists.some(a => a.id === artist.id)) {
      setSelectedArtists(prev => [...prev, { ...artist, tier: 1 }])
    }
  }

  const handleSubmit = async () => {
    setSubmitting(true)
    setSuccess(false)

    const user = (await supabase.auth.getUser()).data.user
    if (!user) return alert('You must be logged in')

    const { data: event, error: eventError } = await supabase
      .from('events')
      .insert([{ name, date, location, num_tiers: numTiers, created_by: user.id }])
      .select()
      .single()

    if (eventError || !event) {
      alert('Error creating event: ' + eventError?.message)
      setSubmitting(false)
      return
    }

    const lineupInserts = selectedArtists.map((artist) => ({
      event_id: event.id,
      artist_id: artist.id,
      tier: artist.tier ?? 1,
    }))

    const { error: lineupError } = await supabase
      .from('event_lineups')
      .insert(lineupInserts)

    if (lineupError) {
      alert('Error adding lineup: ' + lineupError.message)
      setSubmitting(false)
      return
    }

    setSubmitting(false)
    setSuccess(true)
    setName('')
    setDate('')
    setLocation('')
    setSearchTerm('')
    setNumTiers(3)
    setSelectedArtists([])
  }

  return (
    <div style={{ padding: '1rem', maxWidth: '600px' }}>
      <h2>Create Event</h2>
      <label>
        Event Name:
        <input value={name} onChange={e => setName(e.target.value)} />
      </label>
      <br />
      <label>
        Date:
        <input type="date" value={date} onChange={e => setDate(e.target.value)} />
      </label>
      <br />
      <label>
        Location:
        <input value={location} onChange={e => setLocation(e.target.value)} />
      </label>
      <br />
      <label>
        Number of Tiers:
        <input
          type="number"
          min={1}
          max={10}
          value={numTiers}
          onChange={e => setNumTiers(Number(e.target.value))}
        />
      </label>
      <br />
      <br />
      <SearchBar
        searchTerm={searchTerm}
        searchResults={searchResults}
        searching={searching}
        onChange={setSearchTerm}
        onAdd={handleAddArtist}
        queue={selectedArtists}
      />
      <h4>Selected Artists & Tiers:</h4>
      <ul>
        {selectedArtists.map((artist) => (
          <li key={artist.id} style={{ marginBottom: '0.5rem' }}>
            {artist.name}
            <select
              style={{ marginLeft: '0.5rem' }}
              value={artist.tier ?? 1}
              onChange={(e) => {
                const tier = Number(e.target.value)
                setSelectedArtists(prev =>
                  prev.map(a =>
                    a.id === artist.id ? { ...a, tier } : a
                  )
                )
              }}
            >
              {Array.from({ length: numTiers }, (_, i) => (
                <option key={i + 1} value={i + 1}>
                  Tier {i + 1}
                </option>
              ))}
            </select>
          </li>
        ))}
      </ul>
      <button disabled={submitting} onClick={handleSubmit}>
        {submitting ? 'Creating...' : 'Create Event'}
      </button>
      {success && <p style={{ color: 'green' }}>Event created!</p>}
    </div>
  )
}
