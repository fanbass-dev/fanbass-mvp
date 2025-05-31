import { useRef, useLayoutEffect, useState, useEffect, useMemo } from 'react'
import { createPortal } from 'react-dom'
import './SearchBar.css'
import type { Artist } from '../types/types'

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
  const inputRef = useRef<HTMLInputElement>(null)
  const dropdownRef = useRef<HTMLDivElement>(null)

  const [inputValue, setInputValue] = useState(searchTerm)
  const [position, setPosition] = useState<{ top: number; left: number; width: number } | null>(null)
  const [isOpen, setIsOpen] = useState(false)

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

  return (
    <div className="searchContainer">
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
            {filteredResults.map((artist) => (
              <div key={artist.id} className="searchResultItem">
                <span>{artist.name}</span>
                <button onClick={() => onAdd(artist)}>+ Add</button>
              </div>
            ))}
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
