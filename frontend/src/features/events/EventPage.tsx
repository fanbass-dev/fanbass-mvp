import { useEffect, useState, useMemo } from 'react'
import { useParams } from 'react-router-dom'
import { supabase } from '../../supabaseClient'
import { useArtistSearch } from '../artists/useArtistSearch'
import { SearchBar } from '../../components/SearchBar'
import { useEvent } from './useEvent'
import { slugify } from './eventUtils'
import { EventForm } from './EventForm'
import { LineupSection } from './LineupSection'
import { ArtistRankingForm } from '../artists/ArtistRankingForm'
import { useEventRankings } from './useEventRankings'
import { normalizeLineupForRanking, areLineupsEqual } from '../../utils/normalizeLineupForRanking'
import type { Event, Artist } from '../../types/types'

export function EventPage() {
  const { eventKey } = useParams()
  const [initialName, setInitialName] = useState('')
  const [initialDate, setInitialDate] = useState('')
  const [useMyView, setUseMyView] = useState(false)

  const { event, setEvent, lineup, setLineup } = useEvent(eventKey)
  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)

  const artistIds = useMemo(() => lineup.flatMap((l) => l.artists.map((a) => a.id)), [lineup])
  const { rankings, updateTier } = useEventRankings(artistIds)

  const normalizedQueue = useMemo(() => {
    return normalizeLineupForRanking(lineup)
  }, [lineup])

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

      if (error) {
        console.error('Failed to update slug:', error)
      } else {
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

  const handleTierChange = async (artistId: string, tier: number) => {
    if (!event) return

    const updated = lineup.map((entry) =>
      entry.artists.some((a) => a.id === artistId) ? { ...entry, tier } : entry
    )

    if (!areLineupsEqual(updated, lineup)) {
      setLineup(updated)
    }

    const { data: setData } = await supabase
      .from('event_sets_view')
      .select('set_id')
      .eq('event_id', event.id)
      .eq('artist_id', artistId)
      .maybeSingle()

    if (setData?.set_id) {
      await supabase
        .from('event_sets')
        .update({ tier })
        .eq('id', setData.set_id)
    }
  }

  const handleSetNoteChange = async (artistId: string, note: string) => {
    if (!event) return

    const updated = lineup.map((entry) =>
      entry.artists.some((a) => a.id === artistId) ? { ...entry, set_note: note } : entry
    )

    if (!areLineupsEqual(updated, lineup)) {
      setLineup(updated)
    }

    const { data: setData } = await supabase
      .from('event_sets_view')
      .select('set_id')
      .eq('event_id', event.id)
      .eq('artist_id', artistId)
      .maybeSingle()

    if (setData?.set_id) {
      await supabase
        .from('event_sets')
        .update({ set_note: note })
        .eq('id', setData.set_id)
    }
  }

  const handleAddArtist = async (artist: Artist) => {
    if (!event) return

    const { data: setData, error: setError } = await supabase
      .from('event_sets')
      .insert([{
        event_id: event.id,
        tier: 1,
        display_name: artist.type === 'b2b' ? artist.name : null,
        set_note: ''
      }])
      .select()
      .single()

    if (setError || !setData) {
      console.error('Failed to insert event_set:', setError)
      return
    }

    // For B2B artists, add all member artists to the set
    const artistIds = artist.type === 'b2b' && artist.member_ids 
      ? artist.member_ids
      : [artist.id]

    const joins = artistIds.map(id => ({
      set_id: setData.id,
      artist_id: id,
      event_id: event.id
    }))

    const { error: joinError } = await supabase
      .from('event_set_artists')
      .insert(joins)

    if (joinError) {
      console.error('Failed to insert event_set_artists:', joinError)
      return
    }

    setLineup(prev => [...prev, {
      set_id: setData.id,
      tier: 1,
      artists: [artist],
      set_note: '',
      display_name: artist.type === 'b2b' ? artist.name : undefined
    }])
  }

  if (!event) return null

  return (
    <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6 text-white">
      <div>
        <h2 className="text-xl font-semibold mb-4">Event Details</h2>
        <EventForm event={event} onUpdate={handleUpdateEventField} />
      </div>

      <div className="border-t border-gray-700 my-8" />

      <SearchBar
        searchTerm={searchTerm}
        searchResults={searchResults}
        searching={searching}
        onChange={setSearchTerm}
        onAdd={(artistOrArtists) => {
          if (Array.isArray(artistOrArtists)) {
            console.warn('Array of artists received - this should not happen with new schema')
            return
          }
          handleAddArtist(artistOrArtists)
        }}
        queue={lineup.flatMap((l) => l.artists)}
      />

      <div className="space-y-6">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-2 md:gap-4">
          <h2 className="text-lg font-semibold">Lineup</h2>
          <button
            onClick={() => setUseMyView((v) => !v)}
            className="bg-gray-700 hover:bg-gray-600 text-white text-sm px-4 py-2 rounded"
          >
            {useMyView ? 'Show Event View' : 'Show My Rankings'}
          </button>
        </div>

        {lineup.length === 0 ? (
          <p className="text-subtle text-sm">No artists added yet. Use search to add them.</p>
        ) : useMyView ? (
          <ArtistRankingForm
            queue={normalizedQueue}
            rankings={rankings}
            updateTier={updateTier}
          />
        ) : (
          <LineupSection
            event={event}
            lineup={lineup}
            setLineup={setLineup}
            onTierChange={handleTierChange}
            onSetNoteChange={handleSetNoteChange}
          />
        )}
      </div>
    </div>
  )
}
