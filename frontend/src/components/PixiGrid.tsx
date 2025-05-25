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
    const app = new PIXI.Application({
      width: window.innerWidth,
      height: window.innerHeight,
      backgroundColor: 0xffffff,
      resolution: window.devicePixelRatio || 1,
      autoDensity: true,
    })

    containerRef.current?.appendChild(app.view as HTMLCanvasElement)

    const viewport = new Viewport({
      screenWidth: window.innerWidth,
      screenHeight: window.innerHeight,
      worldWidth: 5000,
      worldHeight: 2000,
      events: app.renderer.events,
    })

    app.stage.addChild(viewport)

    const stageWidth = 300
    const tierHeight = 150
    const padding = 20

    // Draw stages and tiers
    stages.forEach((stage, si) => {
      const x = si * (stageWidth + padding)
      const label = new PIXI.Text(stage, { fill: '#000', fontSize: 20 })
      label.position.set(x + stageWidth / 2 - label.width / 2, 10)
      viewport.addChild(label)

      tiers.forEach((tier, ti) => {
        const y = 50 + ti * (tierHeight + padding)
        const tierLabel = new PIXI.Text(tier.toUpperCase(), { fill: '#555', fontSize: 14 })
        tierLabel.position.set(x, y)
        viewport.addChild(tierLabel)

        const border = new PIXI.Graphics()
        border.lineStyle(2, 0xaaaaaa)
        border.beginFill(0xffffff)
        border.drawRect(x, y + 20, stageWidth, tierHeight)
        border.endFill()
        viewport.addChild(border)

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
          card.x = ax; card.y = ay
          viewport.addChild(card)

          const text = new PIXI.Text(artist.name, {
            fontSize: 12,
            fill: 0x000000,
            wordWrap: true,
            wordWrapWidth: cw - 10,
            align: 'center',
          })
          text.x = ax + (cw - text.width) / 2
          text.y = ay + (ch - text.height) / 2
          viewport.addChild(text)
        })
      })
    })

    return () => {
      // DROP baseTexture option — only children & texture are supported now
      app.destroy(true, { children: true, texture: true })
    }
  }, [tiers, stages, placements])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
