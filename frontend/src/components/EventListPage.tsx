import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { supabase } from '../supabaseClient'

type Event = {
  id: string
  name: string
  date: string
  slug: string
}

export function EventListPage() {
  const [events, setEvents] = useState<Event[]>([])

  useEffect(() => {
    const loadEvents = async () => {
      const { data } = await supabase
        .from('events')
        .select('id, name, date, slug')
        .order('date', { ascending: false })

      setEvents(data || [])
    }

    loadEvents()
  }, [])

  return (
    <div style={{ padding: '1rem' }}>
      <h2>All Events</h2>
      <ul>
        {events.map(event => (
          <li key={event.id}>
            <Link to={`/event/${event.slug}`}>
              {event.name} ({event.date})
            </Link>
          </li>
        ))}
      </ul>
    </div>
  )
}
