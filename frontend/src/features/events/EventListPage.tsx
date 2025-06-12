import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { supabase } from '../../supabaseClient'
import { useActivityTracking } from '../../hooks/useActivityTracking'
import type { Event } from '../../types/types'
import { Plus, MapPin, Calendar } from 'lucide-react'

export function EventListPage() {
  const [events, setEvents] = useState<Event[]>([])
  const [loading, setLoading] = useState(true)
  const navigate = useNavigate()
  const { trackActivity } = useActivityTracking()

  useEffect(() => {
    const loadEvents = async () => {
      setLoading(true)
      try {
        const { data } = await supabase
          .from('events')
          .select('id, name, date, slug, location, num_tiers, status, created_by')
          .order('date', { ascending: false })

        setEvents(data || [])
      } catch (error) {
        console.error('Error loading events:', error)
      } finally {
        setLoading(false)
      }
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

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric'
    })
  }

  return (
    <div className="max-w-3xl w-full mx-auto">
      <div className="px-4 md:px-8 py-4 border-b border-gray-800 bg-surface shadow-md">
        <div className="flex items-center justify-between">
          <h2>All Events</h2>
          <button
            onClick={handleCreateNewEvent}
            className="flex items-center gap-2 px-3 py-1.5 text-sm bg-gray-800 border border-gray-700 rounded hover:bg-gray-700 transition-colors"
          >
            <Plus className="w-4 h-4" />
            <span>New Event</span>
          </button>
        </div>
      </div>

      <div className="px-4 md:px-8 py-6">
        {loading ? (
          <div className="text-center py-8 text-gray-400">Loading events...</div>
        ) : events.length === 0 ? (
          <div className="text-center py-8 text-gray-400">No events found</div>
        ) : (
          <div className="grid gap-4">
            {events.map((event) => (
              <Link
                key={event.id}
                to={`/event/${event.slug || event.id}`}
                className="block bg-background rounded-lg p-4 hover:bg-gray-900/50 transition-colors border border-gray-800/50"
              >
                <div className="flex flex-col gap-2">
                  <div className="flex items-center justify-between">
                    <h3 className="text-lg font-medium">{event.name}</h3>
                    <div className="flex items-center gap-1.5 text-sm text-gray-400">
                      <Calendar className="w-4 h-4" />
                      <span>{formatDate(event.date)}</span>
                    </div>
                  </div>
                  <div className="flex items-center justify-between text-sm text-gray-400">
                    <div className="flex items-center gap-1.5">
                      {event.location && (
                        <>
                          <MapPin className="w-4 h-4" />
                          <span>{event.location}</span>
                        </>
                      )}
                    </div>
                    {event.status === 'draft' && (
                      <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-700 text-gray-300">
                        Draft
                      </span>
                    )}
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
