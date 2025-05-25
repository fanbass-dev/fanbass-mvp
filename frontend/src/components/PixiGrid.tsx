// frontend/src/components/PixiGrid.tsx
import { useEffect, useRef } from 'react'
import * as PIXI from 'pixi.js'
import { Viewport } from 'pixi-viewport'
import { Artist, Tier } from '../types'

type PixiGridProps = {
  placements: Record<string, Artist[]>
  tiers: Tier[]
  stages: string[]
}

export function PixiGrid({ placements, tiers, stages }: PixiGridProps) {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    // Create the PIXI application
    const app = new PIXI.Application({
      width: containerRef.current?.clientWidth || window.innerWidth,
      height: containerRef.current?.clientHeight || window.innerHeight,
      backgroundColor: 0xffffff,
      resolution: window.devicePixelRatio || 1,
      autoDensity: true,
      resizeTo: containerRef.current || undefined,
    })

    // Append its canvas to our div
    if (containerRef.current) {
      containerRef.current.appendChild(app.view)
    }

    // Build the viewport options and cast to any so TS won’t complain
    const vpOpts = {
      screenWidth: app.renderer.width,
      screenHeight: app.renderer.height,
      worldWidth: stages.length * 340 + 40,
      worldHeight: tiers.length * 200 + 40,
      events: app.renderer.events, // ✅ required in pixi-viewport@6
    }


    const viewport = new Viewport(vpOpts)
    app.stage.addChild(viewport)
    viewport.drag().pinch().wheel().decelerate()

    // Constants for layout
    const stageW = 300, tierH = 150, pad = 20

    // Draw all stages × tiers
    stages.forEach((stage, si) => {
      const x0 = pad + si * (stageW + pad)
      // Stage header
      const sLab = new PIXI.Text(stage, { fill: '#000', fontSize: 20 })
      sLab.x = x0 + stageW / 2 - sLab.width / 2
      sLab.y = pad
      viewport.addChild(sLab)

      tiers.forEach((tier, ti) => {
        const y0 = pad + 30 + ti * (tierH + pad)
        // Tier label
        const tLab = new PIXI.Text(tier.toUpperCase(), { fill: '#555', fontSize: 14 })
        tLab.x = x0
        tLab.y = y0
        viewport.addChild(tLab)

        // Border box
        const box = new PIXI.Graphics()
        box.lineStyle(2, 0xaaaaaa)
        box.drawRect(x0, y0 + 20, stageW, tierH)
        viewport.addChild(box)

        // Put artists in here
        const key = `${stage}-${tier}`
        const list = placements[key] || []
        list.forEach((artist, idx) => {
          const cols = Math.floor(stageW / 110)
          const col = idx % cols
          const row = Math.floor(idx / cols)
          const w = 100, h = 50, g = 10
          const ax = x0 + g + col * (w + g)
          const ay = y0 + 30 + row * (h + g)

          const card = new PIXI.Graphics()
          card.beginFill(0xeeeeee)
          card.drawRoundedRect(0, 0, w, h, 6)
          card.endFill()
          card.x = ax
          card.y = ay
          viewport.addChild(card)

          const txt = new PIXI.Text(artist.name, {
            fontSize: 12,
            fill: '#000',
            wordWrap: true,
            wordWrapWidth: w - 10,
            align: 'center',
          })
          txt.x = ax + (w - txt.width) / 2
          txt.y = ay + (h - txt.height) / 2
          viewport.addChild(txt)
        })
      })
    })

    // Clean up on unmount
    return () => {
      app.destroy(true)
    }
  }, [placements, stages, tiers])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
