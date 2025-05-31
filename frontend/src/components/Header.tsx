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

  const sharedButtonStyle = {
    marginLeft: '1rem',
    padding: '6px 12px',
    fontSize: '0.9rem',
    border: '1px solid #000',
    borderRadius: '4px',
    cursor: 'pointer',
    display: 'inline-block',
    textDecoration: 'none',
    lineHeight: 1.2,
  } as const

  return (
    <div
      style={{
        padding: '0.5rem',
        zIndex: 2,
        position: 'relative',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}
    >
      {/* Left: Navigation */}
      <div>
        <button
          onClick={() => navigate('/')}
          style={{
            ...sharedButtonStyle,
            background: '#eee',
            color: '#000',
            marginLeft: 0,
          }}
        >
          Home
        </button>

        <button
          onClick={() => navigate('/events')}
          style={{ ...sharedButtonStyle }}
        >
          Events
        </button>

        <button
          onClick={() => navigate('/feature-voting')}
          style={{
            ...sharedButtonStyle,
            background: '#03050e',
            color: '#fff',
          }}
        >
          Feature Voting
        </button>

        {isAdmin && (
          <button
            onClick={() => navigate('/admin/artist-rankings')}
            style={{
              ...sharedButtonStyle,
              background: '#111',
              color: '#fff',
            }}
          >
            Admin Rankings
          </button>
        )}

        <a
          href="https://discord.gg/HuXbDVVBjb"
          target="_blank"
          rel="noopener noreferrer"
          style={{
            ...sharedButtonStyle,
            background: '#5865F2',
            color: '#fff',
          }}
        >
          Join Discord
        </a>
      </div>

      {/* Right: Account */}
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <strong>{userEmail}</strong>
        {isAdmin && (
          <span
            style={{
              marginLeft: '0.5rem',
              padding: '2px 6px',
              backgroundColor: '#333',
              color: '#fff',
              fontSize: '0.75rem',
              borderRadius: '12px',
              lineHeight: 1,
            }}
          >
            Admin
          </span>
        )}
        <button style={{ ...sharedButtonStyle, marginLeft: '1rem' }} onClick={onSignOut}>
          Log out
        </button>
      </div>
    </div>
  )
}
