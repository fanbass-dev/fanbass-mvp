import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { supabase } from '../supabaseClient'
import { SearchBar } from './SearchBar'
import { useArtistSearch } from '../hooks/useArtistSearch'
import type { Artist } from '../types'

type Event = {
  id: string
  name: string
  date: string
  location: string
  num_tiers: number
  status?: string
  slug?: string
}

type LineupEntry = {
  tier: number
  artist: Artist
}

export function EventPage() {
  const { eventKey } = useParams()
  const [event, setEvent] = useState<Event | null>(null)
  const [lineup, setLineup] = useState<LineupEntry[]>([])
  const [initialName, setInitialName] = useState('')
  const [initialDate, setInitialDate] = useState('')

  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)

  useEffect(() => {
    const loadEvent = async () => {
      if (!eventKey) return

      const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(eventKey)
      const field = isUUID ? 'id' : 'slug'

      const { data: eventData } = await supabase
        .from('events')
        .select('*')
        .eq(field, eventKey)
        .single()

      if (!eventData) return

      setEvent(eventData)
      setInitialName(eventData.name)
      setInitialDate(eventData.date)

      const { data: lineupData } = await supabase
        .from('event_lineups')
        .select('tier, artist:artist_id(id, name)')
        .eq('event_id', eventData.id)

      const safeLineup: LineupEntry[] = (lineupData ?? []).map((entry: any) => ({
        tier: entry.tier,
        artist: Array.isArray(entry.artist) ? entry.artist[0] : entry.artist,
      }))

      setLineup(safeLineup)
    }

    loadEvent()
  }, [eventKey])

  const slugify = (name: string, date: string) =>
    `${name}-${date}`
      .toLowerCase()
      .replace(/\s+/g, '-')
      .replace(/[^a-z0-9\-]/g, '')
      .slice(0, 64)

  useEffect(() => {
    const updateSlug = async () => {
      if (!event || !event.name || !event.date) return
      if (event.name === initialName && event.date === initialDate) return

      const newSlug = slugify(event.name, event.date)
      if (event.slug === newSlug) return

      const { error } = await supabase
        .from('events')
        .update({ slug: newSlug })
        .eq('id', event.id)

      if (!error) {
        setEvent((prev) => prev ? { ...prev, slug: newSlug } : prev)
      }
    }

    updateSlug()
  }, [event?.name, event?.date])

  const handleUpdateEventField = async (field: keyof Event, value: string | number) => {
    if (!event) return
    setEvent({ ...event, [field]: value })
    await supabase.from('events').update({ [field]: value }).eq('id', event.id)
  }

  const handleAddArtist = async (artist: Artist) => {
    if (!event) return
    if (lineup.some((entry) => entry.artist.id === artist.id)) return

    const entry = { event_id: event.id, artist_id: artist.id, tier: 1 }
    await supabase.from('event_lineups').insert([entry])
    setLineup((prev) => [...prev, { tier: 1, artist }])
  }

  const handleTierChange = async (artistId: string, tier: number) => {
    if (!event) return
    setLineup((prev) =>
      prev.map((entry) =>
        entry.artist.id === artistId ? { ...entry, tier } : entry
      )
    )

    await supabase
      .from('event_lineups')
      .update({ tier })
      .eq('event_id', event.id)
      .eq('artist_id', artistId)
  }

  const grouped = Array.from({ length: event?.num_tiers || 0 }, (_, i) =>
    lineup.filter((l) => l.tier === i + 1)
  )

  return (
    <div style={{ padding: '1rem', maxWidth: '600px' }}>
      {event && (
        <>
          <h2>
            <input
              value={event.name}
              onChange={(e) => handleUpdateEventField('name', e.target.value)}
              placeholder="Event Name"
              style={{ fontSize: '1.5rem', width: '100%' }}
            />
          </h2>
          <label>
            Date:
            <input
              type="date"
              value={event.date}
              onChange={(e) => handleUpdateEventField('date', e.target.value)}
            />
          </label>
          <br />
          <label>
            Location:
            <input
              value={event.location}
              onChange={(e) => handleUpdateEventField('location', e.target.value)}
            />
          </label>
          <br />
          <label>
            Number of Tiers:
            <input
              type="number"
              min={1}
              max={10}
              value={event.num_tiers}
              onChange={(e) => handleUpdateEventField('num_tiers', Number(e.target.value))}
            />
          </label>

          <SearchBar
            searchTerm={searchTerm}
            searchResults={searchResults}
            searching={searching}
            onChange={setSearchTerm}
            onAdd={handleAddArtist}
            queue={lineup.map((l) => l.artist)}
          />

          {grouped.map((group, i) => (
            <div key={i} style={{ marginTop: '1rem' }}>
              <h4>Tier {i + 1}</h4>
              <ul>
                {group.map((entry) => (
                  <li key={entry.artist.id}>
                    {entry.artist.name}
                    <select
                      value={entry.tier}
                      onChange={(e) =>
                        handleTierChange(entry.artist.id, Number(e.target.value))
                      }
                      style={{ marginLeft: '0.5rem' }}
                    >
                      {Array.from({ length: event.num_tiers }, (_, j) => (
                        <option key={j + 1} value={j + 1}>
                          Tier {j + 1}
                        </option>
                      ))}
                    </select>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </>
      )}
    </div>
  )
}
