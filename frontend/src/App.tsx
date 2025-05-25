import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'
import PixiGrid from './components/PixiGrid'
import type { Artist, Tier } from './types'

const tiers: Tier[] = ['headliner', 'support', 'opener']
const stages = ['Dreamy', 'Heavy', 'Groovy']

function App() {
  const [user, setUser] = useState<any>(null)
  const [artists, setArtists] = useState<Artist[]>([])

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setUser(data?.session?.user ?? null)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    // Fetch artists from Supabase
    supabase
      .from('artists')
      .select('id, name')
      .then(({ data, error }) => {
        if (error) {
          console.error('Failed to fetch artists:', error)
        } else {
          setArtists(data || [])
        }
      })

    return () => subscription.unsubscribe()
  }, [])

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
          <PixiGrid artists={artists} tiers={tiers} stages={stages} />
        </>
      ) : (
        <button onClick={signInWithGoogle}>Log in with Google</button>
      )}
    </div>
  )
}

export default App
