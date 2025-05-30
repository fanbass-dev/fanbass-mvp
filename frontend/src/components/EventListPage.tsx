import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { supabase } from '../supabaseClient'

type Event = {
  id: string
  name: string
  date: string
  slug: string
}

export function EventListPage() {
  const [events, setEvents] = useState<Event[]>([])
  const navigate = useNavigate()

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
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2>All Events</h2>
        <button
          onClick={() => navigate('/event/new')}
          style={{
            padding: '6px 12px',
            fontSize: '0.9rem',
            border: '1px solid #000',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
        >
          + New Event
        </button>
      </div>

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
