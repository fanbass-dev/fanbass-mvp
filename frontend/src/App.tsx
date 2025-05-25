import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'
import { PixiGrid } from './components/PixiGrid'
import type { Artist, Tier } from './types'

const tiers: Tier[] = ['headliner', 'support', 'opener']
const stages = ['Dreamy', 'Heavy', 'Groovy']

type Placement = {
  stage: string
  tier: Tier
  artist: Artist
}

function App() {
  const [user, setUser] = useState<any>(null)
  const [placements, setPlacements] = useState<Record<string, Artist[]>>({})

  useEffect(() => {
    // Get current session
    supabase.auth.getSession().then(({ data }) => {
      setUser(data?.session?.user ?? null)
    })

    // Subscribe to auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    return () => subscription.unsubscribe()
  }, [])

  useEffect(() => {
    if (!user) return

    supabase
      .from('artist_placements')
      .select('stage, tier, artist:artist_id(id, name)')
      .eq('user_id', user.id)
      .then(({ data, error }) => {
        if (error) {
          console.error('Failed to fetch placements:', error)
          return
        }

        const grouped: Record<string, Artist[]> = {}
          ; (data || []).forEach((row: any) => {
            const { stage, tier, artist } = row
            const key = `${stage}-${tier}`

            // Create the flattened Artist object
            const a: Artist = {
              id: artist.id,
              name: artist.name,
              stage,
              tier,
            }

            if (!grouped[key]) grouped[key] = []
            grouped[key].push(a)
          })

        setPlacements(grouped)
      })
  }, [user])


  const signInWithGoogle = async () => {
    await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: window.location.origin,
      },
    })
  }

  const signOut = async () => {
    await supabase.auth.signOut()
    setUser(null)
  }

  return (
    <div style={{ fontFamily: 'sans-serif', height: '100vh', overflow: 'hidden' }}>
      {user ? (
        <>
          <div style={{ padding: '0.5rem', background: '#f0f0f0' }}>
            Logged in as: <strong>{user.email}</strong>
            <button style={{ marginLeft: '1rem' }} onClick={signOut}>Log out</button>
          </div>
          <PixiGrid placements={placements} tiers={tiers} stages={stages} />
        </>
      ) : (
        <button onClick={signInWithGoogle}>Log in with Google</button>
      )}
    </div>
  )
}

export default App
