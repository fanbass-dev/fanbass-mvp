import './LoginScreen.css'

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
      backgroundColor: '#03050c',
      color: 'white',
    }}>
      <img
        src="/logo.png"
        alt="FanBass Logo"
        style={{ width: '150px', marginBottom: '1rem' }}
      />
      <div className="shiny-text-wrapper">
        <h1 className="metallic-text">FanBass</h1>
        <span className="shiny-text-glow" />
      </div>
      <p style={{ fontSize: '1.2rem', marginTop: '0.5rem', marginBottom: '2rem' }}>
        A Feedback Resonator for Music Culture
      </p>
      <button className="login-button" onClick={onLogin}>
        Google Login
      </button>
    </div>
  )
}
