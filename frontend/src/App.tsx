import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { useState } from 'react'
import { useAuth } from './hooks/useAuth'
import { useArtistSearch } from './hooks/useArtistSearch'
import { useArtistRankings } from './hooks/useArtistRankings'
import type { Artist } from './types'
import { Header } from './components/Header'
import { MainLayout } from './components/MainLayout'
import { LoginScreen } from './components/LoginScreen'
import { ArtistPage } from './components/ArtistPage' // this file is coming next

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

  if (!user) return <LoginScreen onLogin={signIn} />

  return (
    <BrowserRouter>
      <div style={{ fontFamily: 'sans-serif', height: '100vh', display: 'flex', flexDirection: 'column' }}>
        <Header
          userEmail={user.email}
          onSignOut={signOut}
          useFormUI={useFormUI}
          onToggleView={() => setUseFormUI((prev) => !prev)}
        />
        <Routes>
          <Route
            path="/"
            element={
              <MainLayout
                searchTerm={searchTerm}
                searchResults={searchResults}
                searching={searching}
                onSearchChange={setSearchTerm}
                onAddToQueue={addArtistToQueue}
                queue={myArtists}
                useFormUI={useFormUI}
                rankings={rankings}
                updateTier={updateTier}
              />
            }
          />
          <Route path="/artist/:id" element={<ArtistPage currentUser={user} />} />
        </Routes>
      </div>
    </BrowserRouter>
  )
}

export default App
