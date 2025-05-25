// frontend/src/components/PixiGrid.tsx
import { useEffect, useRef } from 'react'
import * as PIXI from 'pixi.js'
import { Viewport } from 'pixi-viewport'
import { Artist, Tier } from '../types'

type PixiGridProps = {
  tiers: Tier[]
  stages: string[]
  placements: Record<string, Artist[]>
}

export function PixiGrid({ tiers, stages, placements }: PixiGridProps) {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    console.log('🛠️ PixiGrid useEffect fired')
    console.log('PIXI.Application constructor:', PIXI.Application)

    const app = new PIXI.Application({
      width: window.innerWidth,
      height: window.innerHeight,
      backgroundColor: 0xffffff,
      resolution: window.devicePixelRatio || 1,
      autoDensity: true,
    })

    console.log('Created PIXI.Application instance:', app)
    console.log(' app.renderer exists?', (app as any).renderer)
    console.log(' app.renderer.view exists?', (app as any).renderer?.view)

    // — Attempt to grab the canvas —
    let canvasEl: HTMLCanvasElement | undefined
    try {
      canvasEl = (app.renderer.view as unknown) as HTMLCanvasElement
      console.log(' canvasEl is:', canvasEl)
    } catch (err) {
      console.error('❌ Failed to cast app.renderer.view to canvas:', err)
    }

    console.log(' containerRef.current is:', containerRef.current)
    if (canvasEl && containerRef.current) {
      canvasEl.style.display = 'block'
      canvasEl.style.width   = '100%'
      canvasEl.style.height  = '100%'
      containerRef.current.appendChild(canvasEl)
      console.log('✅ Appended canvas to container')
    } else {
      console.warn('⚠️ Skipping append—canvasEl or containerRef is missing')
    }

    // Rest of our drawing logic…
    const viewport = new Viewport({
      screenWidth:  window.innerWidth,
      screenHeight: window.innerHeight,
      worldWidth:   5000,
      worldHeight:  2000,
      events:       app.renderer.events,
    })
    app.stage.addChild(viewport)
    viewport.drag().pinch().wheel().decelerate()

    // (…draw stages/tiers/artists, same as before…)

    return () => {
      console.log('🧹 Destroying PIXI.Application')
      app.destroy(true, { children: true, texture: true })
    }
  }, [tiers, stages, placements])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
