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
    console.log('🛠️ PixiGrid useEffect fired')

    // ——— Create Pixi Application ———
    const app = new PIXI.Application({
      width: containerRef.current?.clientWidth || window.innerWidth,
      height: containerRef.current?.clientHeight || window.innerHeight,
      backgroundColor: 0xffffff,
      resolution: window.devicePixelRatio || 1,
      autoDensity: true,
      resizeTo: containerRef.current || undefined,
    })
    console.log('📦 PIXI.Application instance:', app)

    // ——— Append the Canvas ———
    const canvasEl = app.view
    if (containerRef.current) {
      containerRef.current.appendChild(canvasEl)
    }

    // ——— Setup Viewport (cast interaction plugin) ———
    const viewport = new Viewport({
      screenWidth:  app.renderer.width,
      screenHeight: app.renderer.height,
      worldWidth:   stages.length * 340 + 40,
      worldHeight:  tiers.length * 200 + 40,
      interaction:  (app.renderer.plugins as any).interaction,
    })
    app.stage.addChild(viewport)
    viewport.drag().pinch().wheel().decelerate()

    // ——— Draw Tiers × Stages & Artists ———
    const stageWidth = 300, tierHeight = 150, padding = 20
    stages.forEach((stage, si) => {
      const stageX = padding + si * (stageWidth + padding)
      const stageLabel = new PIXI.Text(stage, { fill: '#000', fontSize: 20 })
      stageLabel.x = stageX + stageWidth/2 - stageLabel.width/2
      stageLabel.y = padding
      viewport.addChild(stageLabel)

      tiers.forEach((tier, ti) => {
        const tierY = padding + 30 + ti * (tierHeight + padding)
        const tierLabel = new PIXI.Text(tier.toUpperCase(), { fill: '#555', fontSize: 14 })
        tierLabel.x = stageX
        tierLabel.y = tierY
        viewport.addChild(tierLabel)

        const border = new PIXI.Graphics()
        border.lineStyle(2, 0xaaaaaa)
        border.drawRect(stageX, tierY + 20, stageWidth, tierHeight)
        viewport.addChild(border)

        const key = `${stage}-${tier}`
        const list = placements[key] || []
        list.forEach((artist, idx) => {
          const cols = Math.floor(stageWidth / 110)
          const col = idx % cols
          const row = Math.floor(idx / cols)
          const cardW = 100, cardH = 50, gap = 10
          const x = stageX + gap + col * (cardW + gap)
          const y = tierY + 30 + row * (cardH + gap)

          const card = new PIXI.Graphics()
          card.beginFill(0xeeeeee)
          card.drawRoundedRect(0, 0, cardW, cardH, 6)
          card.endFill()
          card.x = x
          card.y = y
          viewport.addChild(card)

          const txt = new PIXI.Text(artist.name, {
            fontSize: 12,
            fill: '#000',
            wordWrap: true,
            wordWrapWidth: cardW - 10,
            align: 'center',
          })
          txt.x = x + (cardW - txt.width) / 2
          txt.y = y + (cardH - txt.height) / 2
          viewport.addChild(txt)
        })
      })
    })

    // ——— Clean up ———
    return () => {
      app.destroy(true)
    }
  }, [placements, stages, tiers])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
