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
import {
  normalizeLineupForRanking,
  areLineupsEqual,
  type B2BSet,
} from '../../utils/normalizeLineupForRanking'
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

  const [b2bSets, setB2bSets] = useState<B2BSet[]>([])

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

  useEffect(() => {
    const loadB2Bs = async () => {
      const { data, error } = await supabase
        .from('b2b_sets')
        .select('id, name, artist_ids')

      if (error) {
        console.error('Failed to load b2b_sets:', error)
      } else {
        setB2bSets(data || [])
      }
    }

    loadB2Bs()
  }, [])

  const normalizedQueue = useMemo(() => {
    return normalizeLineupForRanking(lineup, b2bSets)
  }, [lineup, b2bSets])

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
          const addOne = async (artist: Artist) => {
            if (!event) return

            if (lineup.some((entry) => entry.artists.some((a) => a.id === artist.id))) return

            const { data: setData, error: setError } = await supabase
              .from('event_sets')
              .insert([{ event_id: event.id, tier: 1, display_name: null, set_note: '' }])
              .select()
              .single()

            if (setError || !setData) {
              console.error('Failed to insert event_set:', setError)
              return
            }

            const { error: joinError } = await supabase
              .from('event_set_artists')
              .insert([{ set_id: setData.id, artist_id: artist.id }])

            if (joinError) {
              console.error('Failed to insert into event_set_artists:', joinError)
              return
            }

            setLineup((prev) => [
              ...prev,
              {
                set_id: setData.id,
                tier: 1,
                artists: [artist],
                set_note: '',
                display_name: '',
              },
            ])
          }

          if (Array.isArray(artistOrArtists)) {
            ; (async () => {
              if (!event) return

              const { data: setData, error: setError } = await supabase
                .from('event_sets')
                .insert([{ event_id: event.id, tier: 1, display_name: null, set_note: '' }])
                .select()
                .single()

              if (setError || !setData) {
                console.error('Failed to insert B2B event_set:', setError)
                return
              }

              const joins = artistOrArtists.map((artist) => ({
                set_id: setData.id,
                artist_id: artist.id,
              }))

              const { error: joinError } = await supabase
                .from('event_set_artists')
                .insert(joins)

              if (joinError) {
                console.error('Failed to insert B2B artists:', joinError)
                return
              }

              setLineup((prev) => [
                ...prev,
                {
                  set_id: setData.id,
                  tier: 1,
                  artists: artistOrArtists,
                  set_note: '',
                  display_name: '',
                },
              ])
            })()
          } else {
            addOne(artistOrArtists)
          }
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
