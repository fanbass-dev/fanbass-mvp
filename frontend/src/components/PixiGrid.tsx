// frontend/src/components/PixiGrid.tsx
import { useEffect, useRef } from 'react'
import * as PIXI from 'pixi.js'

export function PixiGrid() {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    async function initPixi() {
      const app = await PIXI.Application.init({
        width: 500,
        height: 300,
        backgroundColor: 0x1099bb,
        antialias: true,
      })

      const text = new PIXI.Text('Pixi is working!', {
        fill: '#fff',
        fontSize: 24,
      })
      text.x = 50
      text.y = 120

      app.stage.addChild(text)
      containerRef.current?.appendChild(app.canvas)
    }

    initPixi()
  }, [])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
