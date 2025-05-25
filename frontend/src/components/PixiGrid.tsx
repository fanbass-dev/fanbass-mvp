import { useEffect, useRef } from 'react'
import { Application, Graphics } from 'pixi.js'

export function PixiGrid() {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    console.log('🛠️ PixiGrid mounted')

    const app = new Application()

    const setup = async () => {
      await app.init({
        width: window.innerWidth,
        height: window.innerHeight,
        backgroundColor: 0xffffff,
        antialias: true,
      })

      const canvas = app.canvas
      if (canvas && containerRef.current) {
        canvas.style.width = '100%'
        canvas.style.height = '100%'
        canvas.style.display = 'block'
        containerRef.current.appendChild(canvas)
        console.log('✅ Canvas appended to container')
      } else {
        console.warn('⚠️ Could not append canvas — missing canvas or containerRef')
      }

      const rect = new Graphics()
        .rect(100, 100, 200, 100)
        .fill(0xff0000)
      app.stage.addChild(rect)
      console.log('🟥 Red rectangle added to stage')
    }

    setup()

    return () => {
      app.destroy()
      console.log('🧹 PixiGrid unmounted and app destroyed')
    }
  }, [])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
