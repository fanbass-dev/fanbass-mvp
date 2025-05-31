import { useEffect, useRef } from 'react'
import { Application, Container, Graphics, Text, TextStyle } from 'pixi.js'
import type { Artist } from '../../../types/types'

// Extend Container with a dragging flag
interface DraggableNode extends Container {
  dragging?: boolean
}

type Props = {
  artists: Artist[]
}

const ArtistCanvas = ({ artists }: Props) => {
  const canvasRef = useRef<HTMLDivElement>(null)
  const appRef = useRef<Application | null>(null)

  useEffect(() => {
    let app: Application

    const init = async () => {
      app = new Application()
      await app.init({
        resizeTo: window,
        background: '#0d0d0d',
        antialias: true,
      })

      appRef.current = app

      if (canvasRef.current) {
        canvasRef.current.appendChild(app.canvas)
      }

      const padding = 20
      const nodeHeight = 40
      const nodeWidth = 200

      artists.forEach((artist, index) => {
        const y = padding + index * (nodeHeight + padding)
        const x = padding

        const node = new Container() as DraggableNode
        node.x = x
        node.y = y
        node.eventMode = 'static'
        node.cursor = 'pointer'

        // background box
        const box = new Graphics()
        box.beginFill(0x1e1e1e)
        box.lineStyle(1, 0xffffff, 0.2)
        box.drawRoundedRect(0, 0, nodeWidth, nodeHeight, 8)
        box.endFill()

        // text
        const text = new Text(artist.name, new TextStyle({
          fill: '#ffffff',
          fontSize: 12,
          fontFamily: 'sans-serif',
        }))
        text.x = 10
        text.y = nodeHeight / 2 - text.height / 2

        node.addChild(box)
        node.addChild(text)
        app.stage.addChild(node)

        // Drag behavior
        node.on('pointerdown', (e) => {
          node.dragging = true
          node.zIndex = 999 // bring to front while dragging
        })

        node.on('pointermove', (e) => {
          if (node.dragging) {
            node.position.set(e.global.x - node.width / 2, e.global.y - node.height / 2)
          }
        })

        node.on('pointerup', () => {
          node.dragging = false
          node.zIndex = 0
        })

        node.on('pointerupoutside', () => {
          node.dragging = false
          node.zIndex = 0
        })
      })
    }

    init()

    return () => {
      appRef.current?.destroy(true, { children: true })
    }
  }, [artists])

  return (
    <div
      ref={canvasRef}
      style={{
        width: '100%',
        height: '100%',
        position: 'relative',
        zIndex: 0,
      }}
    />
  )
}

export default ArtistCanvas
