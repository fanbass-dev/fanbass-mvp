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
      events: app.renderer.events, // ✅ This is the key fix for your TS error
    })

    app.stage.addChild(viewport)

    const stageWidth = 300
    const tierHeight = 150
    const padding = 20

    stages.forEach((stage, stageIndex) => {
      const stageX = stageIndex * (stageWidth + padding)

      // Stage label
      const stageLabel = new PIXI.Text(stage, { fill: '#000', fontSize: 20 })
      stageLabel.position.set(stageX + stageWidth / 2 - stageLabel.width / 2, 10)
      viewport.addChild(stageLabel)

      tiers.forEach((tier, tierIndex) => {
        const tierY = 50 + tierIndex * (tierHeight + padding)

        // Tier label
        const tierLabel = new PIXI.Text(tier.toUpperCase(), { fill: '#555', fontSize: 14 })
        tierLabel.position.set(stageX, tierY)
        viewport.addChild(tierLabel)

        // Border
        const border = new PIXI.Graphics()
        border.lineStyle(2, 0xaaaaaa, 1)
        border.beginFill(0xffffff)
        border.drawRect(stageX, tierY + 20, stageWidth, tierHeight)
        border.endFill()
        viewport.addChild(border)

        // Artists
        const key = `${stage}-${tier}`
        const artists = placements[key] || []
        artists.forEach((artist, i) => {
          const col = i % 3
          const row = Math.floor(i / 3)
          const cardWidth = 90
          const cardHeight = 40
          const spacing = 10
          const artistX = stageX + spacing + col * (cardWidth + spacing)
          const artistY = tierY + 30 + row * (cardHeight + spacing)

          const card = new PIXI.Graphics()
          card.beginFill(0xeeeeee)
          card.drawRoundedRect(0, 0, cardWidth, cardHeight, 6)
          card.endFill()
          card.x = artistX
          card.y = artistY
          viewport.addChild(card)

          const text = new PIXI.Text(artist.name, {
            fontSize: 12,
            fill: 0x000000,
            wordWrap: true,
            wordWrapWidth: cardWidth - 10,
            align: 'center',
          })
          text.x = artistX + (cardWidth - text.width) / 2
          text.y = artistY + (cardHeight - text.height) / 2
          viewport.addChild(text)
        })
      })
    })

    return () => {
      app.destroy(true, { children: true, texture: true, baseTexture: true })
    }
  }, [tiers, stages, placements])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
