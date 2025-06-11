import { ReactNode } from 'react'
import { Header } from './Header'

type LayoutProps = {
  children: ReactNode
  onSignOut: () => void
  useFormUI?: boolean
  onToggleView?: () => void
}

export function Layout({ children, onSignOut, useFormUI = false, onToggleView = () => {} }: LayoutProps) {
  return (
    <div className="min-h-screen bg-background">
      <Header onSignOut={onSignOut} useFormUI={useFormUI} onToggleView={onToggleView} />
      <main className="pt-[72px]"> {/* 72px accounts for header height (48px) + padding (24px) */}
        {children}
      </main>
    </div>
  )
} 