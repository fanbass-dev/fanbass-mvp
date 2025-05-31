import { useNavigate } from 'react-router-dom'
import { useUserContext } from '../context/UserContext'

type Props = {
  userEmail: string
  onSignOut: () => void
  useFormUI: boolean
  onToggleView: () => void
}

export function Header({ userEmail, onSignOut }: Props) {
  const navigate = useNavigate()
  const { isAdmin } = useUserContext()

  return (
    <div className="w-full px-4 py-3 z-20 relative flex flex-col gap-4 md:flex-row md:items-center md:justify-between bg-[#03050e] text-white border-b border-gray-800 shadow-sm">
      {/* Navigation Buttons */}
      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => navigate('/')}
          className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition"
        >
          Home
        </button>

        <button
          onClick={() => navigate('/events')}
          className="bg-gray-800 text-white hover:bg-gray-700 px-4 py-2 rounded transition"
        >
          Events
        </button>

        <button
          onClick={() => navigate('/feature-voting')}
          className="bg-indigo-700 text-white hover:bg-indigo-600 px-4 py-2 rounded transition"
        >
          Feature Voting
        </button>

        {isAdmin && (
          <button
            onClick={() => navigate('/admin/artist-rankings')}
            className="bg-black text-white hover:bg-gray-900 px-4 py-2 rounded transition"
          >
            Admin Rankings
          </button>
        )}

        <a
          href="https://discord.gg/HuXbDVVBjb"
          target="_blank"
          rel="noopener noreferrer"
          className="bg-[#5865F2] text-white hover:bg-[#4752c4] px-4 py-2 rounded transition"
        >
          Join Discord
        </a>
      </div>

      {/* Account Info */}
      <div className="flex flex-wrap items-center justify-between md:justify-end gap-2">
        <div className="flex items-center gap-2 flex-wrap">
          <strong className="text-sm">{userEmail}</strong>
          {isAdmin && (
            <span className="px-2 py-1 text-xs rounded-full bg-gray-700 text-white uppercase tracking-wide font-medium">
              Admin
            </span>
          )}
        </div>
        <button
          onClick={onSignOut}
          className="bg-gray-700 text-white hover:bg-gray-600 px-4 py-2 rounded transition"
        >
          Log out
        </button>
      </div>
    </div>
  )
}
