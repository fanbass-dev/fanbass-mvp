import { BrowserRouter } from 'react-router-dom'
import { useState } from 'react'
import { useAuth } from './hooks/useAuth'
import { useArtistSearch } from './features/artists/useArtistSearch'
import { Header } from './components/Header'
import { LoginScreen } from './components/LoginScreen'
import { AppRoutes } from './routes/AppRoutes'
import { UserProvider } from './context/UserContext'

function App() {
  const { user, signIn, signOut } = useAuth()
  const [searchTerm, setSearchTerm] = useState('')
  const { searchResults, searching } = useArtistSearch(searchTerm)
  const [useFormUI, setUseFormUI] = useState(true)

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
          <AppRoutes
            searchTerm={searchTerm}
            searchResults={searchResults}
            searching={searching}
            onSearchChange={setSearchTerm}
            onAddToQueue={() => { }} // you can remove this too if it's unused
            useFormUI={useFormUI}
            currentUser={user}
          />
        </div>
      </UserProvider>
    </BrowserRouter>
  )
}

export default App
