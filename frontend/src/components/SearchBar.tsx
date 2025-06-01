// src/components/SearchBar.tsx
import { useRef, useLayoutEffect, useState, useEffect, useMemo } from 'react'
import { createPortal } from 'react-dom'
import './SearchBar.css'
import type { Artist } from '../types/types'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onChange: (term: string) => void
  onAdd: (artist: Artist | Artist[]) => void
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
  const inputRef = useRef<HTMLInputElement>(null)
  const dropdownRef = useRef<HTMLDivElement>(null)

  const [inputValue, setInputValue] = useState(searchTerm)
  const [position, setPosition] = useState<{ top: number; left: number; width: number } | null>(null)
  const [isOpen, setIsOpen] = useState(false)
  const [b2bMode, setB2bMode] = useState(false)
  const [b2bQueue, setB2bQueue] = useState<Artist[]>([])

  const filteredResults = useMemo(
    () => searchResults.filter((artist) => !queue.some((a) => a.id === artist.id)),
    [searchResults, queue]
  )

  useEffect(() => {
    const timeout = setTimeout(() => {
      if (inputValue !== searchTerm) {
        onChange(inputValue)
      }
    }, 300)
    return () => clearTimeout(timeout)
  }, [inputValue, onChange, searchTerm])

  useLayoutEffect(() => {
    if (!inputRef.current) return

    const shouldOpenDropdown =
      filteredResults.length > 0 || (inputValue.trim().length > 0 && !searching)

    if (shouldOpenDropdown) {
      const rect = inputRef.current.getBoundingClientRect()
      setPosition({
        top: rect.bottom + window.scrollY,
        left: rect.left + window.scrollX,
        width: rect.width,
      })
      setIsOpen(true)
    } else {
      setPosition(null)
      setIsOpen(false)
    }
  }, [filteredResults.length, inputValue, searching])

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

  const toggleB2BArtist = (artist: Artist) => {
    if (b2bQueue.some((a) => a.id === artist.id)) {
      setB2bQueue((prev) => prev.filter((a) => a.id !== artist.id))
    } else {
      setB2bQueue((prev) => [...prev, artist])
    }
  }

  const handleCreateB2B = () => {
    if (b2bQueue.length < 2) return
    onAdd(b2bQueue)
    setB2bQueue([])
    setInputValue('')
    setIsOpen(false)
  }

  const handleCancelB2B = () => {
    setB2bQueue([])
  }

  return (
    <div className="searchContainer">
      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '0.5rem' }}>
        <input
          ref={inputRef}
          type="text"
          placeholder="Search artists"
          className="searchInput"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onFocus={() => {
            if (filteredResults.length > 0) {
              setIsOpen(true)
            }
          }}
        />
        <label style={{ marginLeft: '1rem', fontSize: '0.85rem' }}>
          <input
            type="checkbox"
            checked={b2bMode}
            onChange={(e) => {
              setB2bMode(e.target.checked)
              setB2bQueue([])
            }}
            style={{ marginRight: '0.25rem' }}
          />
          B2B mode
        </label>
      </div>

      {/* B2B Cart Display */}
      {b2bMode && b2bQueue.length > 0 && (
        <div className="text-sm text-white border border-gray-600 bg-gray-800 rounded p-2 mb-3">
          <strong>Selected for B2B:</strong>
          <ul className="list-disc list-inside mb-2">
            {b2bQueue.map((a) => (
              <li key={a.id}>{a.name}</li>
            ))}
          </ul>
          <div className="flex gap-2">
            <button
              onClick={handleCancelB2B}
              className="bg-gray-700 hover:bg-gray-600 text-white text-xs px-3 py-1 rounded"
            >
              Cancel B2B
            </button>
            <button
              onClick={handleCreateB2B}
              disabled={b2bQueue.length < 2}
              className="bg-blue-600 hover:bg-blue-500 text-white text-xs px-3 py-1 rounded disabled:opacity-40"
            >
              Create B2B Set
            </button>
          </div>
        </div>
      )}

      <div style={{ minHeight: '1.5rem' }}>
        {searching && <p>Searching...</p>}
      </div>

      {position && isOpen &&
        createPortal(
          <div
            ref={dropdownRef}
            className="dropdownMenu"
            style={{
              top: position.top,
              left: position.left,
              width: position.width,
            }}
          >
            {filteredResults.map((artist) => {
              const isQueued = b2bQueue.some((a) => a.id === artist.id)
              return (
                <div
                  key={artist.id}
                  className="searchResultItem"
                  style={{ background: isQueued ? '#1f2937' : undefined }}
                >
                  <span>{artist.name}</span>
                  {b2bMode ? (
                    <button onClick={() => toggleB2BArtist(artist)}>
                      {isQueued ? '− Remove' : '+ Select'}
                    </button>
                  ) : (
                    <button onClick={() => onAdd(artist)}>+ Add</button>
                  )}
                </div>
              )
            })}
            {inputValue.trim().length > 0 &&
              filteredResults.length === 0 &&
              !searching && (
                <div className="searchResultItem">
                  <span>No match found.</span>
                  <a
                    href={`/artist/new?name=${encodeURIComponent(inputValue.trim().toUpperCase())}`}
                    style={{
                      display: 'block',
                      marginTop: '0.5rem',
                      color: '#007bff',
                      textDecoration: 'underline',
                      cursor: 'pointer',
                    }}
                    onClick={() => setIsOpen(false)}
                  >
                    Create: {inputValue.trim().toUpperCase()}
                  </a>
                </div>
              )}
          </div>,
          document.getElementById('dropdown-root')!
        )}
    </div>
  )
}
