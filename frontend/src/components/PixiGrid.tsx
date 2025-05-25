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
    // ✨ Use the constructor so app.view is defined
    const app = new PIXI.Application({
      width: window.innerWidth,
      height: window.innerHeight,
      backgroundColor: 0xffffff,
      resolution: window.devicePixelRatio || 1,
      autoDensity: true,
    })

    // Append the <canvas> element
    containerRef.current?.appendChild(app.view)

    // Set up panning/zooming
    const viewport = new Viewport({
      screenWidth: window.innerWidth,
      screenHeight: window.innerHeight,
      worldWidth: 5000,
      worldHeight: 2000,
      events: app.renderer.events,
    })
    app.stage.addChild(viewport)
    viewport.drag().pinch().wheel().decelerate()

    // Layout constants
    const stageWidth = 300
    const tierHeight = 150
    const padding = 20

    stages.forEach((stage, si) => {
      const x = si * (stageWidth + padding)
      // Stage label
      const stageLabel = new PIXI.Text(stage, { fill: '#000', fontSize: 20 })
      stageLabel.position.set(x + stageWidth / 2 - stageLabel.width / 2, 10)
      viewport.addChild(stageLabel)

      tiers.forEach((tier, ti) => {
        const y = 50 + ti * (tierHeight + padding)
        // Tier label
        const tierLabel = new PIXI.Text(tier.toUpperCase(), { fill: '#555', fontSize: 14 })
        tierLabel.position.set(x, y)
        viewport.addChild(tierLabel)

        // Cell border
        const border = new PIXI.Graphics()
        border.lineStyle(2, 0xaaaaaa)
        border.beginFill(0xffffff)
        border.drawRect(x, y + 20, stageWidth, tierHeight)
        border.endFill()
        viewport.addChild(border)

        // Place artists
        const key = `${stage}-${tier}`
        const artists = placements[key] || []
        artists.forEach((artist, i) => {
          const col = i % 3
          const row = Math.floor(i / 3)
          const cw = 90, ch = 40, gap = 10
          const ax = x + gap + col * (cw + gap)
          const ay = y + 30 + row * (ch + gap)

          const card = new PIXI.Graphics()
          card.beginFill(0xeeeeee)
          card.drawRoundedRect(0, 0, cw, ch, 6)
          card.endFill()
          card.position.set(ax, ay)
          viewport.addChild(card)

          const text = new PIXI.Text(artist.name, {
            fontSize: 12,
            fill: 0x000000,
            wordWrap: true,
            wordWrapWidth: cw - 10,
            align: 'center',
          })
          text.position.set(
            ax + (cw - text.width) / 2,
            ay + (ch - text.height) / 2
          )
          viewport.addChild(text)
        })
      })
    })

    // Cleanup
    return () => {
      app.destroy(true, { children: true, texture: true })
    }
  }, [tiers, stages, placements])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
