import { useEffect, useState } from 'react'
import { supabase } from '../../supabaseClient'
import type { Event, LineupEntry, Artist } from '../../types/types'

export function useEvent(eventKey: string | undefined) {
  const [event, setEvent] = useState<Event | null>(null)
  const [lineup, setLineup] = useState<LineupEntry[]>([])

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

      const { data: viewData, error } = await supabase
        .from('event_sets_view')
        .select('tier, set_note, display_name, set_id, artist_id, artist_name')
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
        const artist: Artist = { id: row.artist_id, name: row.artist_name }
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

  return { event, setEvent, lineup, setLineup }
}

export async function deleteLineupEntry(eventId: string, setId: string) {
  const { error: deleteLineupError } = await supabase
    .from('event_lineups')
    .delete()
    .eq('event_id', eventId)
    .eq('b2b_set_id', setId)

  if (deleteLineupError) {
    console.error('Failed to delete event_lineup entry:', deleteLineupError)
    return false
  }

  const { count, error: countError } = await supabase
    .from('event_lineups')
    .select('*', { count: 'exact', head: true })
    .eq('b2b_set_id', setId)

  if (countError) {
    console.error('Failed to check b2b_set usage:', countError)
    return false
  }

  if (count === 0) {
    const { error: deleteSetError } = await supabase
      .from('b2b_sets')
      .delete()
      .eq('id', setId)

    if (deleteSetError) {
      console.error('Failed to delete orphaned b2b_set:', deleteSetError)
    }
  }

  return true
}
