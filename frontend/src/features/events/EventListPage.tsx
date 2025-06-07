import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { supabase } from '../../supabaseClient'
import { useActivityTracking } from '../../hooks/useActivityTracking'
import type { Event } from '../../types/types'

export function EventListPage() {
  const [events, setEvents] = useState<Event[]>([])
  const navigate = useNavigate()
  const { trackActivity } = useActivityTracking()

  useEffect(() => {
    const loadEvents = async () => {
      const { data } = await supabase
        .from('events')
        .select('id, name, date, slug, location, num_tiers, status, created_by')
        .order('date', { ascending: false })

      setEvents(data || [])
    }

    loadEvents()
  }, [])

  const handleCreateNewEvent = async () => {
    // Get the current user's ID
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      console.error('No authenticated user found')
      return
    }

    const { data, error } = await supabase
      .from('events')
      .insert([
        {
          name: 'Untitled Event',
          date: new Date().toISOString().split('T')[0],
          location: '',
          num_tiers: 3,
          status: 'draft',
          created_by: user.id,
        },
      ])
      .select('id')
      .single()

    if (error || !data) {
      console.error('Failed to create event:', error)
      return
    }

    // Track the activity
    await trackActivity('create_event', { event_id: data.id })

    navigate(`/event/${data.id}`)
  }

  return (
    <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6 text-white">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-semibold">All Events</h2>
        <button
          onClick={handleCreateNewEvent}
          className="bg-gray-800 hover:bg-gray-700 text-white px-4 py-2 rounded text-sm"
        >
          + New Event
        </button>
      </div>

      <ul className="space-y-2">
        {events.map((event) => (
          <li key={event.id}>
            <Link
              to={`/event/${event.slug || event.id}`}
              className="text-blue-400 hover:underline"
            >
              {event.name} {new Date(event.date).getFullYear()}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  )
}
