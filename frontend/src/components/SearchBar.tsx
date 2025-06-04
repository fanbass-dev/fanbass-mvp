// src/components/SearchBar.tsx
import { useRef, useLayoutEffect, useState, useEffect, useMemo } from 'react'
import { createPortal } from 'react-dom'
import clsx from 'clsx'
import './SearchBar.css'
import type { Artist } from '../types/types'
import { supabase } from '../supabaseClient'

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

  // Filter out B2B artists in B2B mode and add status flags
  const searchResultsWithStatus = useMemo(
    () => searchResults
      .filter(artist => !b2bMode || artist.type !== 'b2b')
      .map((artist) => ({
        ...artist,
        isInQueue: queue.some((a) => a.id === artist.id),
        isInB2bQueue: b2bQueue.some((a) => a.id === artist.id)
      })),
    [searchResults, queue, b2bQueue, b2bMode]
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

    const shouldOpenDropdown = searchResultsWithStatus.length > 0 || (inputValue.trim().length > 0 && !searching)

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
  }, [searchResultsWithStatus.length, inputValue, searching])

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

  const handleCreateB2B = async () => {
    if (b2bQueue.length < 2) return

    const sortedIds = b2bQueue.map(a => a.id).sort()
    // Sort names alphabetically to ensure consistent ordering
    const name = b2bQueue
      .map(a => a.name.toUpperCase())
      .sort()
      .join(' B2B ')
    const fingerprint = sortedIds.join('_')

    try {
      // First try to find by member IDs instead of fingerprint
      const { data: memberMatches } = await supabase
        .from('artist_members')
        .select('parent_artist_id')
        .in('member_artist_id', sortedIds)

      if (memberMatches?.length) {
        // Get all parent IDs that have these members
        const parentIds = Array.from(new Set(memberMatches.map(m => m.parent_artist_id)))
        
        // Check which parents have exactly these members
        const { data: existingB2Bs } = await supabase
          .from('artists')
          .select('id, name, type, fingerprint')
          .eq('type', 'b2b')
          .in('id', parentIds)

        if (existingB2Bs?.length) {
          // Find the B2B that has exactly these members
          for (const b2b of existingB2Bs) {
            const { data: members } = await supabase
              .from('artist_members')
              .select('member_artist_id')
              .eq('parent_artist_id', b2b.id)

            const memberIds = members?.map(m => m.member_artist_id).sort() || []
            if (JSON.stringify(memberIds) === JSON.stringify(sortedIds)) {
              // Found exact match
              onAdd({
                ...b2b,
                member_ids: memberIds
              })
              setB2bQueue([])
              setInputValue('')
              setIsOpen(false)
              return
            }
          }
        }
      }

      // No existing B2B found, create new one
      const { data: newB2B, error: createError } = await supabase
        .from('artists')
        .insert({
          name,
          type: 'b2b',
          fingerprint
        })
        .select()
        .single()

      if (createError) {
        console.error('Failed to create B2B artist:', createError)
        return
      }

      // Create member relationships
      const { error: memberError } = await supabase
        .from('artist_members')
        .insert(
          sortedIds.map(memberId => ({
            parent_artist_id: newB2B.id,
            member_artist_id: memberId
          }))
        )

      if (memberError) {
        console.error('Failed to create B2B member relationships:', memberError)
        // Clean up the artist if member creation fails
        await supabase.from('artists').delete().eq('id', newB2B.id)
        return
      }

      onAdd({
        ...newB2B,
        member_ids: sortedIds
      })
      setB2bQueue([])
      setInputValue('')
      setIsOpen(false)

    } catch (error) {
      console.error('Error in B2B creation:', error)
    }
  }

  const handleCancelB2B = () => {
    setB2bQueue([])
  }

  return (
    <div className="searchContainer">
      <div style={{ marginBottom: '0.5rem' }}>
        <input
          ref={inputRef}
          type="text"
          placeholder="Search artists"
          className="searchInput"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onFocus={() => {
            if (searchResultsWithStatus.length > 0) {
              setIsOpen(true)
            }
          }}
        />
      </div>

      {/* B2B Toggle */}
      <div className="mb-3 flex items-center gap-3">
        <div
          className={clsx(
            'w-11 h-6 rounded-full relative cursor-pointer transition-colors',
            b2bMode ? 'bg-blue-600' : 'bg-gray-600'
          )}
          onClick={() => {
            setB2bMode((prev) => !prev)
            setB2bQueue([])
          }}
        >
          <div
            className={clsx(
              'absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition-transform duration-200 transform',
              b2bMode && 'translate-x-5'
            )}
          />
        </div>
        <span className="text-sm text-white">B2B</span>
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
            {searchResultsWithStatus.map((result) => {
              const { isInQueue, isInB2bQueue } = result
              return (
                <div
                  key={result.id}
                  className={clsx("searchResultItem", {
                    "bg-gray-700": isInB2bQueue,
                    "opacity-75": isInQueue && !b2bMode
                  })}
                >
                  <span>{result.name}</span>
                  {b2bMode ? (
                    <button 
                      onClick={() => toggleB2BArtist(result)}
                      className={clsx({
                        "text-blue-400": isInB2bQueue
                      })}
                    >
                      {isInB2bQueue ? '− Remove' : '+ Select'}
                    </button>
                  ) : (
                    isInQueue ? (
                      <span className="text-gray-400 text-sm">Added</span>
                    ) : (
                      <button onClick={() => onAdd(result)}>+ Add</button>
                    )
                  )}
                </div>
              )
            })}
            {inputValue.trim().length > 0 &&
              searchResultsWithStatus.length === 0 &&
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
