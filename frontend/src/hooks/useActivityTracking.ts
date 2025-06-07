import { supabase } from '../supabaseClient'

export function useActivityTracking() {
  const trackActivity = async (
    activity_type: 'create_artist' | 'create_event' | 'add_artist_to_lineup',
    metadata: {
      artist_id?: string
      event_id?: string
      set_id?: string
    }
  ) => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return

      const { error } = await supabase
        .from('user_activities')
        .insert({
          user_id: user.id,
          activity_type,
          artist_id: metadata.artist_id,
          event_id: metadata.event_id,
          set_id: metadata.set_id
        })

      if (error) {
        console.error('Failed to track activity:', error)
      }
    } catch (error) {
      console.error('Error tracking activity:', error)
    }
  }

  return { trackActivity }
} 