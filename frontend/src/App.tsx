import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { useState } from 'react'
import { useAuth } from './hooks/useAuth'
import { useArtistSearch } from './features/artists/useArtistSearch'
import { useArtistRankings } from './features/artists/useArtistRankings'
import { Layout } from './components/Layout'
import { LoginScreen } from './components/LoginScreen'
import { AppRoutes } from './routes/AppRoutes'
import { UserProvider } from './context/UserContext'
import { LineupUploader } from './features/admin/LineupUploader'

function App() {
  const { user, signIn, signOut } = useAuth()
  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)
  const [useFormUI, setUseFormUI] = useState(true)
  const { addArtistToQueue, myArtists, rankings, updateTier, removeArtistFromQueue } = useArtistRankings()

  if (!user) return <LoginScreen onLogin={signIn} />

  return (
    <BrowserRouter>
      <UserProvider>
        <Layout onSignOut={signOut} useFormUI={useFormUI} onToggleView={() => setUseFormUI((prev) => !prev)}>
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
                  rankings={rankings}
                  updateTier={updateTier}
                  removeArtistFromQueue={removeArtistFromQueue}
                />
              }
            />
            {/* Admin Lineup Uploader */}
            <Route path="/admin/lineup-uploader" element={<LineupUploader />} />
          </Routes>
        </Layout>
      </UserProvider>
    </BrowserRouter>
  )
}

export default App
