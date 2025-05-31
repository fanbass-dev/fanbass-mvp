import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { supabase } from '../../supabaseClient'
import { useArtistSearch } from '../artists/useArtistSearch'
import { SearchBar } from '../../components/SearchBar'
import { useEvent } from './useEvent'
import { slugify } from './eventUtils'
import { EventForm } from './EventForm'
import { LineupSection } from './LineupSection'
import type { Event } from '../../types/types'
import type { Artist } from '../../types/types'

export function EventPage() {
  const { eventKey } = useParams()
  const [initialName, setInitialName] = useState('')
  const [initialDate, setInitialDate] = useState('')

  const { event, setEvent, lineup, setLineup } = useEvent(eventKey)
  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)

  useEffect(() => {
    if (event) {
      setInitialName(event.name)
      setInitialDate(event.date)
    }
  }, [event])

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
        setEvent((prev) => (prev ? { ...prev, slug: newSlug } : prev))
      }
    }

    updateSlug()
  }, [event, initialName, initialDate, setEvent])

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

  return (
    <div style={{ padding: '1rem', maxWidth: '600px' }}>
      {event && (
        <>
          <EventForm event={event} onUpdate={handleUpdateEventField} />

          <SearchBar
            searchTerm={searchTerm}
            searchResults={searchResults}
            searching={searching}
            onChange={setSearchTerm}
            onAdd={handleAddArtist}
            queue={lineup.map((l) => l.artist)}
          />

          <LineupSection
            event={event}
            lineup={lineup}
            onTierChange={handleTierChange}
          />
        </>
      )}
    </div>
  )
}
