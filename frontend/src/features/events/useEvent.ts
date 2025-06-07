import { useEffect, useState } from 'react'
import { supabase } from '../../supabaseClient'
import type { Event, LineupEntry, Artist } from '../../types/types'

export function useEvent(eventKey: string | undefined) {
  const [event, setEvent] = useState<Event | null>(null)
  const [lineup, setLineup] = useState<LineupEntry[]>([])
  const [creator, setCreator] = useState<{ displayName: string } | null>(null)

  useEffect(() => {
    const loadEvent = async () => {
      if (!eventKey) return

      const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(eventKey)
      const field = isUUID ? 'id' : 'slug'

      const { data: eventData } = await supabase
        .from('events')
        .select('*, created_by')
        .eq(field, eventKey)
        .single()

      if (!eventData) return
      setEvent(eventData)

      // Fetch creator info if available
      if (eventData.created_by) {
        const { data: displayName } = await supabase
          .rpc('get_display_name', { user_id: eventData.created_by })
        
        if (displayName) {
          setCreator({ displayName })
        }
      }

      const { data: viewData, error } = await supabase
        .from('event_sets_view')
        .select('tier, set_note, display_name, set_id, artist_id, artist_name, type')
        .eq('event_id', eventData.id)

      if (error) {
        console.error('Failed to load event_sets_view:', error)
        return
      }

      const grouped = new Map<
        string,
        { tier: number; set_note: string | null; display_name: string | null; artists: Artist[] }
      >()

      for (const row of viewData ?? []) {
        const existing = grouped.get(row.set_id)
        const artist: Artist = { 
          id: row.artist_id, 
          name: row.artist_name,
          type: row.type
        }
        if (existing) {
          existing.artists.push(artist)
        } else {
          grouped.set(row.set_id, {
            tier: row.tier,
            set_note: row.set_note,
            display_name: row.display_name,
            artists: [artist],
          })
        }
      }

      const safeLineup: LineupEntry[] = Array.from(grouped.entries()).map(
        ([setId, entry]) => ({
          set_id: setId,
          tier: entry.tier,
          artists: entry.artists,
          set_note: entry.set_note ?? undefined,
          display_name: entry.display_name ?? undefined,
        })
      )

      setLineup(safeLineup)
    }

    loadEvent()
  }, [eventKey])

  return { event, setEvent, lineup, setLineup, creator }
}

export async function deleteLineupEntry(eventId: string, setId: string) {
  console.log('[deleteLineupEntry]', { eventId, setId })

  // 1. Delete from event_sets by primary key
  const { error: deleteSetError } = await supabase
    .from('event_sets')
    .delete()
    .eq('id', setId)
    .eq('event_id', eventId)

  if (deleteSetError) {
    console.error('Failed to delete from event_sets:', deleteSetError)
    return false
  }

  // 2. Delete from event_set_artists (cleanup join table)
  const { error: deleteArtistsError } = await supabase
    .from('event_set_artists')
    .delete()
    .eq('event_id', eventId)
    .eq('set_id', setId)

  if (deleteArtistsError) {
    console.error('Failed to delete from event_set_artists:', deleteArtistsError)
    return false
  }

  return true
}


