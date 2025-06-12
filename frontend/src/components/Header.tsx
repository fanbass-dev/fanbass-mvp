import { useState, useRef, useEffect, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { useUserContext } from '../context/UserContext'
import { Menu, X, User, LogOut, BarChart2, ChevronDown } from 'lucide-react'
import { FaDiscord as RawFaDiscord } from 'react-icons/fa'
import { GamificationService } from '../services/gamification'
import { UserLevel, UserTitle } from '../config/gamification'

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
  const [isAdminOpen, setIsAdminOpen] = useState(false)
  const { profile, loading, isAdmin, user } = useUserContext()
  const [userLevel, setUserLevel] = useState<UserLevel | null>(null)
  const [userTitle, setUserTitle] = useState<UserTitle | null>(null)
  const profileMenuRef = useRef<HTMLDivElement>(null)
  const mobileProfileMenuRef = useRef<HTMLDivElement>(null)
  const adminMenuRef = useRef<HTMLDivElement>(null)
  const mobileMenuRef = useRef<HTMLDivElement>(null)
  
  const displayText = useMemo(() => {
    return loading ? 'Loading...' : profile?.displayName || 'Unknown User'
  }, [loading, profile?.displayName])

  // Load user level and title
  useEffect(() => {
    async function loadUserLevel() {
      if (!user?.id) return
      try {
        const { level, title } = await GamificationService.getUserLevel(user.id)
        setUserLevel(level)
        setUserTitle(title)
      } catch (err) {
        console.error('Error loading user level:', err)
      }
    }
    loadUserLevel()
  }, [user?.id])

  // Close menus when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      const target = event.target as Node
      const clickedInMobileMenu = mobileProfileMenuRef.current?.contains(target)
      const clickedInDesktopMenu = profileMenuRef.current?.contains(target)
      const clickedInAdminMenu = adminMenuRef.current?.contains(target)
      const clickedInBurgerMenu = mobileMenuRef.current?.contains(target)
      const clickedInBurgerButton = target.parentElement?.classList.contains('burger-button')
      
      if (!clickedInMobileMenu && !clickedInDesktopMenu) {
        setIsProfileOpen(false)
      }
      if (!clickedInAdminMenu) {
        setIsAdminOpen(false)
      }
      if (!clickedInBurgerMenu && !clickedInBurgerButton) {
        setIsOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  const handleProfileClick = (action: 'profile' | 'stats' | 'logout') => {
    setIsProfileOpen(false)
    if (action === 'profile') {
      navigate('/settings/profile')
    } else if (action === 'stats') {
      navigate('/settings/stats')
    } else {
      onSignOut()
    }
  }

  return (
    <header className="fixed top-0 left-0 w-full px-4 py-3 z-50 bg-surface text-white border-b border-gray-800 shadow-sm">
      <div className="max-w-3xl w-full mx-auto">
        {/* Mobile View */}
        <div className="flex items-center justify-between md:hidden">
          <button
            onClick={() => setIsOpen(!isOpen)}
            className="text-white focus:outline-none burger-button"
          >
            {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
          <div className="relative" ref={mobileProfileMenuRef}>
            <button 
              onClick={() => setIsProfileOpen(!isProfileOpen)}
              className="flex items-center gap-2 text-sm hover:text-brand transition"
            >
              <div className="text-right">
                <strong>{displayText}</strong>
                {userLevel && userTitle && (
                  <div className="text-xs">
                    <span className={userTitle.color}>{userTitle.name}</span>
                    <span className="text-gray-400 ml-1">Lvl {userLevel.currentLevel.toString()}</span>
                  </div>
                )}
              </div>
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
                    onClick={() => handleProfileClick('stats')}
                    className="w-full text-left px-4 py-2 text-sm text-white hover:bg-gray-700 flex items-center gap-2"
                  >
                    <BarChart2 className="w-4 h-4" />
                    My Stats
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
        <div className="hidden md:flex items-center justify-between">
          <nav className="flex flex-wrap items-center gap-2 relative">
            <button onClick={() => navigate('/')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Artists</button>
            <button onClick={() => navigate('/events')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Events</button>
            <div className="w-px h-6 bg-gray-700 mx-1" />
            <button onClick={() => navigate('/feature-voting')} className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base">Feature Voting</button>

            {isAdmin && (
              <>
                <div className="w-px h-6 bg-gray-700 mx-1" />
                <div className="relative" ref={adminMenuRef}>
                  <button
                    onClick={() => setIsAdminOpen(!isAdminOpen)}
                    className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition text-base flex items-center gap-1"
                  >
                    Admin
                    <ChevronDown className={`w-4 h-4 transition-transform ${isAdminOpen ? 'rotate-180' : ''}`} />
                  </button>
                  {isAdminOpen && (
                    <div className="absolute left-0 mt-2 w-48 rounded-md shadow-lg bg-gray-800 ring-1 ring-black ring-opacity-5">
                      <div className="py-1" role="menu" aria-orientation="vertical">
                        <button
                          onClick={() => {
                            navigate('/admin/artist-rankings')
                            setIsAdminOpen(false)
                          }}
                          className="w-full text-left px-4 py-2 text-sm text-white hover:bg-gray-700"
                        >
                          Artist Rankings
                        </button>
                        <button
                          onClick={() => {
                            navigate('/admin/lineup-uploader')
                            setIsAdminOpen(false)
                          }}
                          className="w-full text-left px-4 py-2 text-sm text-white hover:bg-gray-700"
                        >
                          Lineup Uploader
                        </button>
                      </div>
                    </div>
                  )}
                </div>
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

          <div className="relative" ref={profileMenuRef}>
            <button 
              onClick={() => setIsProfileOpen(!isProfileOpen)}
              className="flex items-center gap-2 text-sm hover:text-brand transition group"
            >
              <div className="text-right">
                <strong>{displayText}</strong>
                {userLevel && userTitle && (
                  <div className="text-xs">
                    <span className={userTitle.color}>{userTitle.name}</span>
                    <span className="text-gray-400 ml-1">Lvl {userLevel.currentLevel.toString()}</span>
                  </div>
                )}
              </div>
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
                    onClick={() => handleProfileClick('stats')}
                    className="w-full text-left px-4 py-2 text-sm text-white hover:bg-gray-700 flex items-center gap-2"
                  >
                    <BarChart2 className="w-4 h-4" />
                    My Stats
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

        {/* Mobile Nav Dropdown */}
        <nav ref={mobileMenuRef} className={`flex flex-col gap-2 mt-4 ${isOpen ? 'block' : 'hidden'} md:hidden`}>
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
