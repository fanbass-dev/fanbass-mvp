type Props = {
  userEmail: string
  onSignOut: () => void
  useFormUI: boolean
  onToggleView: () => void
}

import { useNavigate } from 'react-router-dom' // Add this line at the top

export function Header({ userEmail, onSignOut, useFormUI, onToggleView }: Props) {
  const navigate = useNavigate() // Add this line inside the component

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
        <button style={{ marginLeft: '1rem' }} onClick={onSignOut}>
          Log out
        </button>
      </div>

      <div>
        <button
          onClick={onToggleView}
          style={{
            marginLeft: '1rem',
            padding: '4px 10px',
            background: 'transparent',
            border: '1px solid #000',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
        >
          Switch to {useFormUI ? 'Canvas' : 'Form'} View
        </button>

        <button
          onClick={() => navigate('/feature-voting')}
          style={{
            marginLeft: '1rem',
            padding: '4px 10px',
            background: '#03050e',
            color: '#fff',
            border: '1px solid #000',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
        >
          Feature Voting
        </button>
      </div>
    </div>
  )
}