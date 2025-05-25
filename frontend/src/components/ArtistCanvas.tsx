import { useEffect, useRef } from 'react'
import {
  Application,
  Container,
  Graphics,
  Text,
  TextStyle,
} from 'pixi.js'

type Artist = {
  id: string
  name: string
}

type Props = {
  artists: Artist[]
}

const ArtistCanvas = ({ artists }: Props) => {
  const canvasRef = useRef<HTMLDivElement>(null)
  const appRef = useRef<Application | null>(null)

  useEffect(() => {
    if (!canvasRef.current) return

    const app = new Application({
      resizeTo: window,
      backgroundColor: 0x0d0d0d,
      antialias: true,
    })

    appRef.current = app
    canvasRef.current.appendChild(app.view)

    const padding = 20
    const nodeHeight = 60
    const nodeWidth = 300

    artists.forEach((artist, index) => {
      const y = padding + index * (nodeHeight + padding)

      const node = new Container()
      node.x = padding
      node.y = y

      const box = new Graphics()
      box.beginFill(0x1e1e1e)
      box.lineStyle(2, 0xffffff, 0.2)
      box.drawRoundedRect(0, 0, nodeWidth, nodeHeight, 10)
      box.endFill()

      const text = new Text(artist.name, new TextStyle({
        fill: '#ffffff',
        fontSize: 20,
        fontFamily: 'sans-serif',
      }))
      text.x = 20
      text.y = nodeHeight / 2 - text.height / 2

      node.addChild(box)
      node.addChild(text)

      app.stage.addChild(node)
    })

    return () => {
      app.destroy(true, true)
    }
  }, [artists])

  return <div ref={canvasRef} style={{ width: '100%', height: '100vh' }} />
}

export default ArtistCanvas
