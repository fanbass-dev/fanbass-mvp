type Props = {
  onLogin: () => void
}

export function LoginScreen({ onLogin }: Props) {
  return (
    <div style={{
      height: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      fontFamily: 'sans-serif',
      textAlign: 'center',
      padding: '2rem',
    }}>
      <img
        src="/logo.png"
        alt="FanBass Logo"
        style={{ width: '150px', marginBottom: '1rem' }}
      />
      <h1 style={{ fontSize: '2.5rem', margin: 0 }}>FanBass</h1>
      <p style={{ fontSize: '1.2rem', marginTop: '0.5rem', marginBottom: '2rem' }}>
        A Feedback Resonator for Music Culture
      </p>
      <button
        onClick={onLogin}
        style={{
          padding: '0.75rem 1.5rem',
          fontSize: '1rem',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer',
        }}
      >
        Log in with Google
      </button>
    </div>
  )
}
