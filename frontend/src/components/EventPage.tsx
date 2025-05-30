import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { supabase } from '../supabaseClient'
import type { Artist } from '../types'

type Event = {
  id: string
  name: string
  date: string
  location: string
  num_tiers: number
}

type LineupEntry = {
  tier: number
  artist: Artist
}

export function EventPage() {
  const { slug, id } = useParams()
  const [event, setEvent] = useState<Event | null>(null)
  const [lineup, setLineup] = useState<LineupEntry[]>([])

  useEffect(() => {
  const loadEvent = async () => {
    const field = slug ? 'slug' : 'id'
    const value = slug || id

    const { data: eventData } = await supabase
      .from('events')
      .select('*')
      .eq(field, value)
      .single()

    if (!eventData) return

    const { data: lineupData } = await supabase
      .from('event_lineups')
      .select('tier, artist:artist_id(id, name)')
      .eq('event_id', eventData.id)

    setEvent(eventData)

    const safeLineup: LineupEntry[] = (lineupData ?? []).map((entry: any) => ({
      tier: entry.tier,
      artist: Array.isArray(entry.artist) ? entry.artist[0] : entry.artist,
    }))

    setLineup(safeLineup)
  }

  loadEvent()
}, [slug, id])


  const grouped = Array.from({ length: event?.num_tiers || 0 }, (_, i) =>
    lineup.filter((l) => l.tier === i + 1)
  )

  return (
    <div style={{ padding: '1rem' }}>
      {event && (
        <>
          <h2>{event.name}</h2>
          <p>{event.date} — {event.location}</p>
          {grouped.map((group, i) => (
            <div key={i} style={{ marginTop: '1rem' }}>
              <h4>Tier {i + 1}</h4>
              <ul>
                {group.map((entry) => (
                  <li key={entry.artist.id}>{entry.artist.name}</li>
                ))}
              </ul>
            </div>
          ))}
        </>
      )}
    </div>
  )
}
