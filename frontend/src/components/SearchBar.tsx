import { useRef, useLayoutEffect, useState, useEffect } from 'react'
import { createPortal } from 'react-dom'
import './SearchBar.css'
import type { Artist } from '../types'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onChange: (term: string) => void
  onAdd: (artist: Artist) => void
  queue: Artist[]
}

export function SearchBar({
  searchTerm,
  searchResults,
  searching,
  onChange,
  onAdd,
  queue,
}: Props) {
  const isInQueue = (artistId: string) =>
    queue.some((a) => a.id === artistId)

  const filteredResults = searchResults.filter(
    (artist) => !isInQueue(artist.id)
  )

  const inputRef = useRef<HTMLInputElement>(null)
  const dropdownRef = useRef<HTMLDivElement>(null)

  const [position, setPosition] = useState<{ top: number; left: number; width: number } | null>(null)
  const [isOpen, setIsOpen] = useState(false)

  // Reposition dropdown
  useLayoutEffect(() => {
    if (!inputRef.current) return

    if (filteredResults.length > 0) {
      const rect = inputRef.current.getBoundingClientRect()
      setPosition({
        top: rect.bottom + window.scrollY,
        left: rect.left + window.scrollX,
        width: rect.width,
      })
      setIsOpen(true)
    } else {
      if (position !== null) setPosition(null)
      setIsOpen(false)
    }
  }, [searchResults.length])

  // Close on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node) &&
        !inputRef.current?.contains(event.target as Node)
      ) {
        setIsOpen(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  return (
    <div className="searchContainer">
      <h2>Search Artists</h2>
      <input
        ref={inputRef}
        type="text"
        placeholder="Search artists"
        className="searchInput"
        value={searchTerm}
        onChange={(e) => onChange(e.target.value)}
        onFocus={() => {
          if (filteredResults.length > 0) {
            setIsOpen(true)
          }
        }}
      />

      <div style={{ minHeight: '1.5rem' }}>
        {searching && <p>Searching...</p>}
      </div>


      {position && isOpen &&
        createPortal(
          <div
            ref={dropdownRef}
            style={{
              position: 'absolute',
              top: position.top,
              left: position.left,
              width: position.width,
              background: 'white',
              border: '1px solid #ccc',
              maxHeight: '300px',
              overflowY: 'auto',
              boxShadow: '0 4px 8px rgba(0, 0, 0, 0.1)',
              padding: '0.5rem',
              zIndex: 1000,
            }}
          >
            {filteredResults.map((artist) => (
              <div key={artist.id} className="searchResultItem">
                <span>{artist.name}</span>
                <button onClick={() => onAdd(artist)}>+ Add</button>
              </div>
            ))}
          </div>,
          document.getElementById('dropdown-root')!
        )}
    </div>
  )
}
