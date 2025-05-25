import { useEffect, useRef } from 'react'
import * as PIXI from 'pixi.js'
import { Viewport } from 'pixi-viewport'
import type { Artist, Tier } from '../types'

type Props = {
  artists: Artist[]
  tiers: Tier[]
  stages: string[]
}

export default function PixiGrid({ artists, tiers, stages }: Props) {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const app = new PIXI.Application({
      resizeTo: window,
      backgroundColor: 0xffffff,
      antialias: true,
    })

    containerRef.current?.appendChild(app.view as HTMLCanvasElement)

    const viewport = new Viewport({
      screenWidth: window.innerWidth,
      screenHeight: window.innerHeight,
      worldWidth: 5000,
      worldHeight: 2000,
    })

    viewport.interaction = app.renderer.plugins.interaction

    app.stage.addChild(viewport)

    viewport
      .drag()
      .pinch()
      .wheel()
      .decelerate()

    const cellWidth = 120
    const cellHeight = 160

    // Draw grid background
    tiers.forEach((tier, row) => {
      stages.forEach((stage, col) => {
        const box = new PIXI.Graphics()
        box.lineStyle(1, 0xcccccc)
        box.beginFill(0xfafafa)
        box.drawRect(col * cellWidth, row * cellHeight, cellWidth, cellHeight)
        box.endFill()
        viewport.addChild(box)
      })
    })

    // Text style for artist names
    const style = new PIXI.TextStyle({
      fontSize: 12,
      fill: '#000',
      wordWrap: true,
      wordWrapWidth: cellWidth - 16,
      align: 'center',
    })

    // Add draggable artist cards
    artists.forEach((artist, i) => {
      const card = new PIXI.Container()
      const background = new PIXI.Graphics()
      background.beginFill(0xeeeeee)
      background.drawRoundedRect(0, 0, 100, 48, 6)
      background.endFill()
      card.addChild(background)

      const label = new PIXI.Text(artist.name, style)
      label.x = 50 - label.width / 2
      label.y = 24 - label.height / 2
      card.addChild(label)

      card.x = 50 + (i * 110)
      card.y = 20

      card.eventMode = 'static'
      card.cursor = 'grab'

      card.on('pointerdown', (event: PIXI.FederatedPointerEvent) => {
        card.cursor = 'grabbing'
        card.alpha = 0.6
        card.dragData = event.data
        card.dragOffset = event.data.getLocalPosition(card)
        card.dragging = true
      })

      card.on('pointerup', () => {
        card.dragging = false
        card.cursor = 'grab'
        card.alpha = 1

        const global = card.dragData.getLocalPosition(viewport)
        const col = Math.floor(global.x / cellWidth)
        const row = Math.floor(global.y / cellHeight)

        card.x = col * cellWidth + 10
        card.y = row * cellHeight + 10
      })

      card.on('pointermove', () => {
        if (card.dragging) {
          const pos = card.dragData.getLocalPosition(viewport)
          card.x = pos.x - card.dragOffset.x
          card.y = pos.y - card.dragOffset.y
        }
      })

      viewport.addChild(card)
    })

    return () => {
      app.destroy(true, true)
    }
  }, [artists, tiers, stages])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
