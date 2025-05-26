import type { Artist } from '../types'

type Props = {
  artists: Artist[]
}

const ArtistCanvas = (_props: Props) => {
  return (
    <div
      style={{
        flex: 1,
        background: '#eaeaea',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: '#666',
        fontStyle: 'italic',
      }}
    >
      Canvas placeholder – MVP layout under construction
    </div>
  )
}

export default ArtistCanvas
