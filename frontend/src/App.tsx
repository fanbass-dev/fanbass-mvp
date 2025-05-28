import { useState } from 'react'
import { useAuth } from './hooks/useAuth'
import { useArtistSearch } from './hooks/useArtistSearch'
import { useArtistRankings } from './hooks/useArtistRankings'
import type { Artist } from './types'
import { Header } from './components/Header'
import { MainLayout } from './components/MainLayout'
import { LoginScreen } from './components/LoginScreen'

function App() {
  const { user, signIn, signOut } = useAuth()
  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)
  const [useFormUI, setUseFormUI] = useState(true)

  const {
    user: rankingsUser,
    myArtists,
    rankings,
    updateTier,
    addArtistToQueue,
  } = useArtistRankings()

  const handleAddToQueue = (artist: Artist) => {
    addArtistToQueue(artist)
  }

  if (!user) return <LoginScreen onLogin={signIn} />

  return (
    <div style={{ fontFamily: 'sans-serif', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      <Header
        userEmail={user.email}
        onSignOut={signOut}
        useFormUI={useFormUI}
        onToggleView={() => setUseFormUI((prev) => !prev)}
      />
      <MainLayout
        searchTerm={searchTerm}
        searchResults={searchResults}
        searching={searching}
        onSearchChange={setSearchTerm}
        onAddToQueue={handleAddToQueue}
        queue={myArtists}
        useFormUI={useFormUI}
        rankings={rankings}            // ✅ Added
        updateTier={updateTier}        // ✅ Added
      />
    </div>
  )
}

export default App
