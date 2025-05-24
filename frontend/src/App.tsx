import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'
import { DndContext, closestCenter, DragEndEvent } from '@dnd-kit/core'

import { SearchBar } from './components/SearchBar'
import { Queue } from './components/Queue'
import { StageGrid } from './components/StageGrid'
import type { Artist, Tier } from './types'

const tiers: Tier[] = ['headliner', 'support', 'opener']
const stages = ['Dreamy', 'Heavy', 'Groovy']

function App() {
  const [user, setUser] = useState<any>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [searchResults, setSearchResults] = useState<Artist[]>([])
  const [searching, setSearching] = useState(false)
  const [queue, setQueue] = useState<Artist[]>([])
  const [placements, setPlacements] = useState<Record<string, Artist[]>>({})

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setUser(data?.session?.user ?? null)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
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

  const handleSearchChange = async (term: string) => {
    setSearchTerm(term)
    setSearching(true)

    if (term.length < 2) {
      setSearchResults([])
      setSearching(false)
      return
    }

    const { data, error } = await supabase
      .from('artists')
      .select('id, name')
      .ilike('name', `%${term}%`)
      .limit(10)

    if (error) {
      console.error('Search error:', error)
    } else {
      setSearchResults(data ?? [])
    }

    setSearching(false)
  }

  const addToQueue = (artist: Artist) => {
    setQueue((prev) => {
      if (prev.some((a) => a.id === artist.id)) return prev
      return [...prev, artist]
    })
  }

  const dropKey = (stage: string, tier: Tier) => `${stage}-${tier}`

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event
    if (!over) return

    const artist = queue.find((a) => a.id === active.id)
    if (!artist) return

    const targetKey = over.id.toString()
    setPlacements((prev) => {
      const updated = { ...prev }
      updated[targetKey] = [...(updated[targetKey] ?? []), artist]
      return updated
    })

    setQueue((prev) => prev.filter((a) => a.id !== artist.id))
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>FanBass MVP</h1>

      {user ? (
        <>
          <p>Logged in as: <strong>{user.email}</strong></p>
          <button onClick={signOut}>Log out</button>

          <SearchBar
            searchTerm={searchTerm}
            searchResults={searchResults}
            searching={searching}
            onChange={handleSearchChange}
            onAdd={addToQueue}
            queue={queue}
          />

          <DndContext collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
            <Queue queue={queue} />

            <h2 style={{ marginTop: '2rem' }}>Lineup Grid</h2>
            <StageGrid
              stages={stages}
              tiers={tiers}
              placements={placements}
              dropKey={dropKey}
            />
          </DndContext>
        </>
      ) : (
        <button onClick={signInWithGoogle}>Log in with Google</button>
      )}
    </div>
  )
}

export default App
