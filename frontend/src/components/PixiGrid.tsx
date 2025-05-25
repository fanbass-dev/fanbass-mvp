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

    // workaround TS missing init()
    const ApplicationAny = (PIXI.Application as any)
    const app: PIXI.Application = ApplicationAny.init({
      width: window.innerWidth,
      height: window.innerHeight,
      backgroundColor: 0xffffff,
      resolution: window.devicePixelRatio || 1,
      autoDensity: true,
    })

    console.log('PIXI.Application instance:', app)
    console.log(' renderer exists?', app.renderer)
    console.log(' renderer.view exists?', (app.renderer as any)?.view)

    // append the real <canvas>
    const canvasEl = (app.renderer.view as unknown) as HTMLCanvasElement
    canvasEl.style.display = 'block'
    canvasEl.style.width   = '100%'
    canvasEl.style.height  = '100%'
    containerRef.current?.appendChild(canvasEl)
    console.log('✅ Appended canvas')

    // set up pan/zoom
    const viewport = new Viewport({
      screenWidth:  window.innerWidth,
      screenHeight: window.innerHeight,
      worldWidth:   5000,
      worldHeight:  2000,
      events:       app.renderer.events,
    })
    app.stage.addChild(viewport)
    viewport.drag().pinch().wheel().decelerate()

    // draw grid & artists
    const stageW = 300, tierH = 150, pad = 20
    stages.forEach((stage, si) => {
      const x = si * (stageW + pad)
      const sLabel = new PIXI.Text(stage, { fill: '#000', fontSize: 20 })
      sLabel.position.set(x + stageW/2 - sLabel.width/2, 10)
      viewport.addChild(sLabel)

      tiers.forEach((tier, ti) => {
        const y = 50 + ti * (tierH + pad)
        const tLabel = new PIXI.Text(tier.toUpperCase(), { fill: '#555', fontSize: 14 })
        tLabel.position.set(x, y)
        viewport.addChild(tLabel)

        const border = new PIXI.Graphics()
        border.lineStyle(2, 0xaaaaaa)
        border.beginFill(0xffffff)
        border.drawRect(x, y + 20, stageW, tierH)
        border.endFill()
        viewport.addChild(border)

        const key = `${stage}-${tier}`
        const list = placements[key] || []
        list.forEach((artist, i) => {
          const col = i % 3, row = Math.floor(i/3)
          const cw = 90, ch = 40, gap = 10
          const ax = x + gap + col*(cw+gap)
          const ay = y + 30 + row*(ch+gap)

          const card = new PIXI.Graphics()
          card.beginFill(0xeeeeee)
          card.drawRoundedRect(0, 0, cw, ch, 6)
          card.endFill()
          card.position.set(ax, ay)
          viewport.addChild(card)

          const txt = new PIXI.Text(artist.name, {
            fontSize: 12,
            fill: 0x000000,
            wordWrap: true,
            wordWrapWidth: cw - 10,
            align: 'center',
          })
          txt.position.set(
            ax + (cw - txt.width) / 2,
            ay + (ch - txt.height) / 2
          )
          viewport.addChild(txt)
        })
      })
    })

    return () => {
      console.log('🧹 Destroying PIXI.Application')
      app.destroy(true, { children: true, texture: true })
    }
  }, [tiers, stages, placements])

  return <div ref={containerRef} style={{ width: '100%', height: '100vh' }} />
}
