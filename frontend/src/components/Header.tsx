import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useUserContext } from '../context/UserContext'
import { Menu, X } from 'lucide-react'
import { FaDiscord as RawFaDiscord } from 'react-icons/fa'

const FaDiscord = RawFaDiscord as unknown as React.FC<React.SVGProps<SVGSVGElement>>

type Props = {
  userEmail: string
  onSignOut: () => void
  useFormUI: boolean
  onToggleView: () => void
}

export function Header({ userEmail, onSignOut }: Props) {
  const navigate = useNavigate()
  const { isAdmin } = useUserContext()
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <header className="w-full px-4 py-3 z-20 relative bg-surface text-white border-b border-gray-800 shadow-sm">
      {/* Top Row: mobile menu toggle */}
      <div className="flex items-center justify-between md:hidden">
        <button
          onClick={() => setMenuOpen(!menuOpen)}
          className="text-white focus:outline-none"
        >
          {menuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
        <div className="text-sm">
          <strong>{userEmail}</strong>
        </div>
      </div>

      {/* Desktop View: Nav + Account */}
      <div className="hidden md:flex justify-between items-center gap-4 mt-0">
        <nav className="flex flex-wrap items-center gap-2">
          <button onClick={() => navigate('/')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Artists</button>
          <button onClick={() => navigate('/events')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Events</button>
          <div className="w-px h-6 bg-gray-700 mx-1" />
          <button onClick={() => navigate('/feature-voting')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Feature Voting</button>
          {isAdmin && (
            <>
              <button onClick={() => navigate('/admin/artist-rankings')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Admin Rankings</button>
              <button onClick={() => navigate('/admin/lineup-uploader')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Lineup Uploader</button>
            </>
          )}
          <a
            href="https://discord.gg/HuXbDVVBjb"
            target="_blank"
            rel="noopener noreferrer"
            className="bg-brand text-white hover:bg-[#7289da] px-4 py-2 rounded transition flex items-center gap-2 text-sm justify-center"
          >
            <FaDiscord className="w-4 h-4" />
            <span>Discord</span>
          </a>
        </nav>

        <div className="flex items-center gap-2">
          <div className="text-sm">
            <strong>{userEmail}</strong>
          </div>
          {isAdmin && (
            <span className="px-2 py-1 text-xs rounded-full bg-gray-700 text-white uppercase tracking-wide font-medium">
              Admin
            </span>
          )}
          <button
            onClick={onSignOut}
            className="bg-gray-800 hover:bg-gray-700 text-white px-4 py-2 rounded transition text-base"
          >
            Log out
          </button>
        </div>
      </div>

      {/* Mobile Nav Dropdown */}
      <nav className={`flex flex-col gap-2 mt-4 ${menuOpen ? 'block' : 'hidden'} md:hidden`}>
        <button onClick={() => navigate('/')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Artists</button>
        <button onClick={() => navigate('/events')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Events</button>
        <div className="w-full h-px bg-gray-700 my-1" />
        <button onClick={() => navigate('/feature-voting')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Feature Voting</button>
        {isAdmin && (
          <>
            <button onClick={() => navigate('/admin/artist-rankings')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Admin Rankings</button>
            <button onClick={() => navigate('/admin/lineup-uploader')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Lineup Uploader</button>
          </>
        )}
        <a
          href="https://discord.gg/HuXbDVVBjb"
          target="_blank"
          rel="noopener noreferrer"
          className="bg-brand text-white hover:bg-[#7289da] px-4 py-2 rounded transition flex items-center gap-2 text-sm justify-center"
        >
          <FaDiscord className="w-4 h-4" />
          <span>Discord</span>
        </a>
        <button
          onClick={onSignOut}
          className="bg-gray-800 hover:bg-gray-700 text-white px-4 py-2 rounded transition text-base text-center"
        >
          Log out
        </button>
      </nav>
    </header>
  )
}
