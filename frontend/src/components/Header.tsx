type Props = {
  userEmail: string
  onSignOut: () => void
}

export function Header({ userEmail, onSignOut }: Props) {
  return (
    <div style={{
      padding: '0.5rem',
      background: '#f0f0f0',
      zIndex: 2,
      position: 'relative'
    }}>
      Logged in as: <strong>{userEmail}</strong>
      <button style={{ marginLeft: '1rem' }} onClick={onSignOut}>Log out</button>
    </div>
  )
}
