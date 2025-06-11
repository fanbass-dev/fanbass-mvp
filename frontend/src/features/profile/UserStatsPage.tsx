import { useState, useEffect } from 'react'
import { supabase } from '../../supabaseClient'
import { useUserContext } from '../../context/UserContext'
import { UserStats as GamificationStats } from '../../components/UserStats'
import { GamificationGuide } from '../../components/GamificationGuide'

type ActivityStats = {
  events_created: number
  artists_created: number
  artists_added_to_lineup: number
}

export function UserStatsPage() {
  const { user } = useUserContext()
  const [stats, setStats] = useState<ActivityStats | null>(null)
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

        const stats: ActivityStats = {
          events_created: data.filter(a => a.activity_type === 'create_event').length,
          artists_created: data.filter(a => a.activity_type === 'create_artist').length,
          artists_added_to_lineup: data.filter(a => a.activity_type === 'add_artist_to_lineup').length
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
    return <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6">Loading stats...</div>
  }

  if (error) {
    return <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6 text-red-500">{error}</div>
  }

  if (!stats) {
    return <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6">No stats available</div>
  }

  return (
    <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6">
      <h1 className="text-xl font-semibold mb-4">My Stats</h1>
      
      {/* Activity Stats */}
      <div className="grid grid-cols-3 gap-2 mb-8">
        <div className="bg-gray-800 rounded-lg px-1.5 flex flex-col items-center justify-center text-center">
          <div className="py-2 space-y-0.5">
            <p className="text-2xl font-bold text-brand">{stats.events_created}</p>
            <h2 className="text-base text-gray-300">Events Added</h2>
          </div>
        </div>

        <div className="bg-gray-800 rounded-lg px-1.5 flex flex-col items-center justify-center text-center">
          <div className="py-2 space-y-0.5">
            <p className="text-2xl font-bold text-brand">{stats.artists_created}</p>
            <h2 className="text-base text-gray-300">Artists Added</h2>
          </div>
        </div>

        <div className="bg-gray-800 rounded-lg px-1.5 flex flex-col items-center justify-center text-center">
          <div className="py-2 space-y-0.5">
            <p className="text-2xl font-bold text-brand">{stats.artists_added_to_lineup}</p>
            <h2 className="text-base text-gray-300">Sets Added</h2>
          </div>
        </div>
      </div>

      {/* Gamification Stats */}
      <div className="mt-8 pt-8 border-t border-gray-700">
        <h2 className="text-lg font-semibold mb-6">Progress & Achievements</h2>
        <GamificationStats />
      </div>

      {/* Gamification Guide */}
      <div className="mt-8 pt-8 border-t border-gray-700">
        <GamificationGuide />
      </div>
    </div>
  )
} 