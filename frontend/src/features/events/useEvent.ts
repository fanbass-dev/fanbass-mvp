import { useEffect, useState } from 'react'
import { supabase } from '../../supabaseClient'
import type { Event, LineupEntry } from '../../types/types'

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

  return { event, setEvent, lineup, setLineup }
}
