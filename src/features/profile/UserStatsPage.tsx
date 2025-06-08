import { useState, useEffect } from 'react'
import { supabase } from '../../supabaseClient'
import { useUserContext } from '../../context/UserContext'

type UserStats = {
  events_created: number
  artists_created: number
  artists_added_to_lineup: number
}

export function UserStatsPage() {
  const { user } = useUserContext()
  const [stats, setStats] = useState<UserStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function fetchStats() {
      try {
        const { data, error } = await supabase
          .from('user_activities')
          .select('activity_type')
          .eq('user_id', user?.id)

        if (error) throw error

        const stats: UserStats = {
          events_created: data.filter(a => a.activity_type === 'event_created').length,
          artists_created: data.filter(a => a.activity_type === 'artist_created').length,
          artists_added_to_lineup: data.filter(a => a.activity_type === 'artist_added_to_lineup').length
        }

        setStats(stats)
      } catch (err) {
        console.error('Error fetching user stats:', err)
        setError('Failed to load stats')
      } finally {
        setLoading(false)
      }
    }

    if (user) {
      fetchStats()
    }
  }, [user])

  if (loading) {
    return <div className="p-4">Loading stats...</div>
  }

  if (error) {
    return <div className="p-4 text-red-500">{error}</div>
  }

  if (!stats) {
    return <div className="p-4">No stats available</div>
  }

  return (
    <div className="max-w-2xl mx-auto p-4">
      <h1 className="text-2xl font-bold mb-6">My Stats</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-2">Events Created</h2>
          <p className="text-4xl font-bold text-brand">{stats.events_created}</p>
        </div>

        <div className="bg-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-2">Artists Created</h2>
          <p className="text-4xl font-bold text-brand">{stats.artists_created}</p>
        </div>

        <div className="bg-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-2">Artists Added to Lineup</h2>
          <p className="text-4xl font-bold text-brand">{stats.artists_added_to_lineup}</p>
        </div>
      </div>
    </div>
  )
} 