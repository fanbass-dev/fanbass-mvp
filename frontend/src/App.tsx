import { useState } from 'react'
import { useAuth } from './hooks/useAuth'
import { useArtistSearch } from './hooks/useArtistSearch'
import type { Artist } from './types'
import { Header } from './components/Header'
import { MainLayout } from './components/MainLayout'
import { LoginScreen } from './components/LoginScreen'

function App() {
  const { user, signIn, signOut } = useAuth()
  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)
  const [queue, setQueue] = useState<Artist[]>([])

  const handleAddToQueue = (artist: Artist) => {
    setQueue((prev) => [...prev, artist])
  }

if (!user) return <LoginScreen onLogin={signIn} />

  return (
    <div style={{ fontFamily: 'sans-serif', height: '100vh', display: 'flex', flexDirection: 'column' }}>
      <Header userEmail={user.email} onSignOut={signOut} />
      <MainLayout
        searchTerm={searchTerm}
        searchResults={searchResults}
        searching={searching}
        onSearchChange={setSearchTerm}
        onAddToQueue={handleAddToQueue}
        queue={queue}
      />
    </div>
  )
}

export default App
