import { useState, useRef, useEffect, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { useUserContext } from '../context/UserContext'
import { Menu, X, User, LogOut } from 'lucide-react'
import { FaDiscord as RawFaDiscord } from 'react-icons/fa'

const FaDiscord = RawFaDiscord as unknown as React.FC<React.SVGProps<SVGSVGElement>>

type Props = {
  onSignOut: () => void
  useFormUI: boolean
  onToggleView: () => void
}

export function Header({ onSignOut, useFormUI, onToggleView }: Props) {
  const navigate = useNavigate()
  const [isOpen, setIsOpen] = useState(false)
  const [isProfileOpen, setIsProfileOpen] = useState(false)
  const { profile, loading, isAdmin } = useUserContext()
  const profileMenuRef = useRef<HTMLDivElement>(null)
  
  const displayText = useMemo(() => {
    return loading ? 'Loading...' : profile?.displayName || 'Unknown User'
  }, [loading, profile?.displayName])

  // Close profile menu when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (profileMenuRef.current && !profileMenuRef.current.contains(event.target as Node)) {
        setIsProfileOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  const handleProfileClick = (action: 'profile' | 'logout') => {
    setIsProfileOpen(false)
    if (action === 'profile') {
      navigate('/settings/profile')
    } else {
      onSignOut()
    }
  }

  return (
    <header className="w-full px-4 py-3 z-20 relative bg-surface text-white border-b border-gray-800 shadow-sm">
      <div className="max-w-3xl w-full mx-auto">
        {/* Top Row: mobile menu toggle */}
        <div className="flex items-center justify-between md:hidden">
          <button
            onClick={() => setIsOpen(!isOpen)}
            className="text-white focus:outline-none"
          >
            {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
          <div className="relative" ref={profileMenuRef}>
            <button 
              onClick={() => setIsProfileOpen(!isProfileOpen)}
              className="flex items-center gap-2 text-sm hover:text-brand transition"
            >
              <strong>{displayText}</strong>
              <div className="w-8 h-8 rounded-full bg-gray-700 flex items-center justify-center">
                <User className="w-4 h-4" />
              </div>
            </button>
            {isProfileOpen && (
              <div className="absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-gray-800 ring-1 ring-black ring-opacity-5">
                <div className="py-1" role="menu" aria-orientation="vertical">
                  <button
                    onClick={() => handleProfileClick('profile')}
                    className="w-full text-left px-4 py-2 text-sm text-white hover:bg-gray-700 flex items-center gap-2"
                  >
                    <User className="w-4 h-4" />
                    Profile
                  </button>
                  <button
                    onClick={() => handleProfileClick('logout')}
                    className="w-full text-left px-4 py-2 text-sm text-white hover:bg-gray-700 flex items-center gap-2"
                  >
                    <LogOut className="w-4 h-4" />
                    Log out
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Desktop View */}
        <div className="hidden md:flex justify-between items-center gap-4 mt-0">
          <nav className="flex flex-wrap items-center gap-2 relative">
            <button onClick={() => navigate('/')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Artists</button>
            <button onClick={() => navigate('/events')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Events</button>
            <div className="w-px h-6 bg-gray-700 mx-1" />
            <button onClick={() => navigate('/feature-voting')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Feature Voting</button>

            {isAdmin && (
              <>
                <div className="w-px h-6 bg-gray-700 mx-1" />
                <button onClick={() => navigate('/admin/artist-rankings')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Artist Rankings</button>
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

          <div className="flex items-center gap-4">
            <div className="relative" ref={profileMenuRef}>
              <button 
                onClick={() => setIsProfileOpen(!isProfileOpen)}
                className="flex items-center gap-2 text-sm hover:text-brand transition group"
              >
                <strong>{displayText}</strong>
                <div className="w-8 h-8 rounded-full bg-gray-700 flex items-center justify-center group-hover:bg-gray-600">
                  <User className="w-4 h-4" />
                </div>
              </button>
              {isProfileOpen && (
                <div className="absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-gray-800 ring-1 ring-black ring-opacity-5">
                  <div className="py-1" role="menu" aria-orientation="vertical">
                    <button
                      onClick={() => handleProfileClick('profile')}
                      className="w-full text-left px-4 py-2 text-sm text-white hover:bg-gray-700 flex items-center gap-2"
                    >
                      <User className="w-4 h-4" />
                      Profile
                    </button>
                    <button
                      onClick={() => handleProfileClick('logout')}
                      className="w-full text-left px-4 py-2 text-sm text-white hover:bg-gray-700 flex items-center gap-2"
                    >
                      <LogOut className="w-4 h-4" />
                      Log out
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Mobile Nav Dropdown */}
        <nav className={`flex flex-col gap-2 mt-4 ${isOpen ? 'block' : 'hidden'} md:hidden`}>
          <button onClick={() => navigate('/')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Artists</button>
          <button onClick={() => navigate('/events')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Events</button>
          <div className="w-full h-px bg-gray-700 my-1" />
          <button onClick={() => navigate('/feature-voting')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Feature Voting</button>
          
          {isAdmin && (
            <>
              <div className="w-full h-px bg-gray-700 my-1" />
              <button onClick={() => navigate('/admin/artist-rankings')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base text-center">Artist Rankings</button>
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
        </nav>
      </div>
    </header>
  )
}
