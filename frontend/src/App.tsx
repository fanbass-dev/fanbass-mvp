import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { useState } from 'react'
import { useAuth } from './hooks/useAuth'
import { useArtistSearch } from './features/artists/useArtistSearch'
import { useArtistRankings } from './features/artists/useArtistRankings'
import { Header } from './components/Header'
import { LoginScreen } from './components/LoginScreen'
import { AppRoutes } from './routes/AppRoutes'
import { UserProvider } from './context/UserContext'
import { LineupUploader } from './features/admin/LineupUploader'

function App() {
  const { user, signIn, signOut } = useAuth()
  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)
  const [useFormUI, setUseFormUI] = useState(true)
  const { addArtistToQueue, myArtists } = useArtistRankings()

  if (!user) return <LoginScreen onLogin={signIn} />

  return (
    <BrowserRouter>
      <UserProvider>
        <div style={{ fontFamily: 'sans-serif', height: '100vh', display: 'flex', flexDirection: 'column' }}>
          <Header
            userEmail={user.email}
            onSignOut={signOut}
            useFormUI={useFormUI}
            onToggleView={() => setUseFormUI((prev) => !prev)}
          />
          <Routes>
            {/* Main App Route Tree */}
            <Route
              path="/*"
              element={
                <AppRoutes
                  searchTerm={searchTerm}
                  searchResults={searchResults}
                  searching={searching}
                  onSearchChange={setSearchTerm}
                  onAddToQueue={addArtistToQueue}
                  useFormUI={useFormUI}
                  currentUser={user}
                  myArtists={myArtists}
                />
              }
            />
            {/* Admin Lineup Uploader */}
            <Route path="/admin/lineup-uploader" element={<LineupUploader />} />
          </Routes>
        </div>
      </UserProvider>
    </BrowserRouter>
  )
}

export default App
