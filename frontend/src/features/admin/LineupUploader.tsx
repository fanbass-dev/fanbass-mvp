// src/features/admin/LineupUploader.tsx

import { useState, useEffect } from 'react'
import Papa from 'papaparse'
import { supabase } from '../../supabaseClient'
import type { Event } from '../../types/types'

type Row = {
    name: string
    tier: string
    set_note: string
    artistNames: string[]
}

type EventPreview = Pick<Event, 'id' | 'name' | 'date'>

export function LineupUploader() {
    const [eventId, setEventId] = useState('')
    const [events, setEvents] = useState<EventPreview[]>([])
    const [rows, setRows] = useState<Row[]>([])
    const [csvError, setCsvError] = useState<string | null>(null)
    const [uploading, setUploading] = useState(false)

    useEffect(() => {
        const loadEvents = async () => {
            const { data } = await supabase
                .from('events')
                .select('id, name, date')
            if (data) setEvents(data as EventPreview[])
        }
        loadEvents()
    }, [])

    const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0]
        if (!file) return

        Papa.parse(file, {
            header: true,
            skipEmptyLines: true,
            complete: (results) => {
                try {
                    const parsedRows = results.data.map((row: any) => {
                        const name = row.name?.trim() || ''
                        const artistNames = name
                            .split(/ B2B |,|&/i)
                            .map((n: string) => n.trim().toUpperCase())
                        return {
                            name,
                            tier: row.tier?.trim() || '',
                            set_note: row.set_note?.trim() || '',
                            artistNames,
                        }
                    })
                    setRows(parsedRows)
                    setCsvError(null)
                } catch (err) {
                    console.error('CSV Parse Error', err)
                    setCsvError('Failed to parse CSV')
                }
            },
            error: (err) => {
                console.error('CSV Upload Error', err)
                setCsvError('Failed to upload CSV')
            },
        })
    }

    const createB2BArtist = async (artistNames: string[]) => {
        const { data: existingArtists } = await supabase
            .from('artists')
            .select('id, name')
            .in('name', artistNames)

        if (!existingArtists || existingArtists.length !== artistNames.length) {
            throw new Error('All artists must exist before creating B2B')
        }

        const sortedIds = existingArtists.map(a => a.id).sort()
        const name = artistNames.join(' B2B ')

        // Check if B2B already exists
        const { data: existingB2B } = await supabase
            .from('artists')
            .select('*')
            .eq('type', 'b2b')
            .eq('fingerprint', sortedIds.join(','))
            .single()

        if (existingB2B) {
            return existingB2B
        }

        const { data: newB2B, error } = await supabase
            .from('artists')
            .insert({
                name,
                type: 'b2b',
                member_ids: sortedIds,
                fingerprint: sortedIds.join(',')
            })
            .select()
            .single()

        if (error) throw error
        return newB2B
    }

    const handleUpload = async () => {
        if (!eventId || rows.length === 0) return
        setUploading(true)

        try {
            for (const row of rows) {
                const artistNames = row.artistNames.map(name => name.trim().toUpperCase())
                
                let artist
                if (artistNames.length > 1) {
                    // This is a B2B set
                    artist = await createB2BArtist(artistNames)
                } else {
                    // Single artist
                    const { data } = await supabase
                        .from('artists')
                        .select('*')
                        .eq('name', artistNames[0])
                        .single()
                    
                    if (!data) {
                        throw new Error(`Artist not found: ${artistNames[0]}`)
                    }
                    artist = data
                }

                // Create event set
                const { data: setData, error: setError } = await supabase
                    .from('event_sets')
                    .insert({
                        event_id: eventId,
                        tier: parseInt(row.tier) || 1,
                        display_name: artist.type === 'b2b' ? artist.name : null,
                        set_note: row.set_note
                    })
                    .select()
                    .single()

                if (setError || !setData) {
                    throw new Error(`Failed to create event set: ${setError?.message}`)
                }

                // Add artists to set
                const artistIds = artist.type === 'b2b' && artist.member_ids 
                    ? artist.member_ids 
                    : [artist.id]

                const joins = artistIds.map((id: string) => ({
                    set_id: setData.id,
                    artist_id: id,
                    event_id: eventId
                }))

                const { error: joinError } = await supabase
                    .from('event_set_artists')
                    .insert(joins)

                if (joinError) {
                    throw new Error(`Failed to add artists to set: ${joinError.message}`)
                }
            }

            // Clear form after successful upload
            setRows([])
            setCsvError(null)
        } catch (error) {
            console.error('Upload error:', error)
            setCsvError(error instanceof Error ? error.message : 'Upload failed')
        } finally {
            setUploading(false)
        }
    }

    return (
        <div className="p-4 max-w-3xl mx-auto">
            <h2 className="text-xl font-semibold mb-4">Lineup Uploader</h2>

            <div className="mb-4">
                <label className="block mb-1 font-medium text-sm">Select Event</label>
                <select
                    value={eventId}
                    onChange={(e) => setEventId(e.target.value)}
                    className="w-full p-2 rounded bg-black border border-gray-600 text-white"
                >
                    <option value="">-- Select an event --</option>
                    {events.map((event) => {
                        const year = new Date(event.date).getFullYear()
                        return (
                            <option key={event.id} value={event.id}>
                                {event.name} ({year})
                            </option>
                        )
                    })}
                </select>
            </div>

            <div className="mb-4">
                <input type="file" accept=".csv" onChange={handleFileUpload} />
                {csvError && <p className="text-red-500 text-sm mt-2">{csvError}</p>}
            </div>

            {rows.length > 0 && (
                <div className="mb-4">
                    <h3 className="font-medium mb-2">Preview</h3>
                    <table className="w-full text-sm">
                        <thead>
                            <tr>
                                <th className="text-left">Artists</th>
                                <th className="text-left">Tier</th>
                                <th className="text-left">Note</th>
                            </tr>
                        </thead>
                        <tbody>
                            {rows.map((row, i) => (
                                <tr key={i}>
                                    <td>{row.name}</td>
                                    <td>{row.tier}</td>
                                    <td>{row.set_note}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}

            <button
                onClick={handleUpload}
                disabled={uploading || !eventId || rows.length === 0}
                className="bg-blue-600 text-white px-4 py-2 rounded disabled:opacity-50"
            >
                {uploading ? 'Uploading...' : 'Upload Lineup'}
            </button>
        </div>
    )
}
