import { useNavigate } from 'react-router-dom'

type Props = {
  userEmail: string
  onSignOut: () => void
  useFormUI: boolean
  onToggleView: () => void
}

export function Header({ userEmail, onSignOut, useFormUI, onToggleView }: Props) {
  const navigate = useNavigate()

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
      <div>
        Logged in as: <strong>{userEmail}</strong>
        <button style={{ ...sharedButtonStyle }} onClick={onSignOut}>
          Log out
        </button>
      </div>

      <div>
        {false && (
          <button
            onClick={onToggleView}
            style={{
              ...sharedButtonStyle,
              background: 'transparent',
            }}
          >
            Switch to {useFormUI ? 'Canvas' : 'Form'} View
          </button>
        )}

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
    </div>
  )
}
