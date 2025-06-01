// src/features/admin/LineupUploader.tsx

import { useState, useEffect } from 'react'
import Papa from 'papaparse'
import { supabase } from '../../supabaseClient'

type Row = {
    name: string
    tier: string
    set_note?: string
    artistNames: string[]
}

type Event = {
    id: string
    name: string
    date: string
}

export function LineupUploader() {
    const [eventId, setEventId] = useState('')
    const [events, setEvents] = useState<Event[]>([])
    const [rows, setRows] = useState<Row[]>([])
    const [csvError, setCsvError] = useState<string | null>(null)
    const [uploading, setUploading] = useState(false)

    useEffect(() => {
        const loadEvents = async () => {
            const { data } = await supabase.from('events').select('id, name, date')
            if (data) setEvents(data)
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

    const handleImport = async () => {
        if (!eventId) {
            alert('Please select an event.')
            return
        }

        for (const row of rows) {
            try {
                // 1. Lookup or create artists
                const artistIds: string[] = []
                for (const name of row.artistNames) {
                    const { data: existing } = await supabase
                        .from('artists')
                        .select('id')
                        .ilike('name', name)
                        .maybeSingle()

                    let artistId = existing?.id
                    if (!artistId) {
                        const { data: inserted, error } = await supabase
                            .from('artists')
                            .insert({ name })
                            .select()
                            .single()
                        if (error) throw error
                        artistId = inserted.id
                    }

                    artistIds.push(artistId)
                }

                // 2. Sort artistIds to avoid mirrored sets
                const sortedArtistIds = [...artistIds].sort()

                // 3. Check if an identical set already exists
                const { data: existingSetLinks } = await supabase
                    .from('event_set_artists')
                    .select('set_id, artist_id')
                    .in('artist_id', sortedArtistIds)
                    .eq('event_id', eventId)  // optional if event_id in join view
                const setsById: Record<string, string[]> = {}

                for (const link of existingSetLinks || []) {
                    const setId = link.set_id
                    if (!setsById[setId]) setsById[setId] = []
                    setsById[setId].push(link.artist_id)
                }

                let duplicateSetId: string | null = null
                for (const [setId, ids] of Object.entries(setsById)) {
                    if (ids.sort().join(',') === sortedArtistIds.join(',')) {
                        duplicateSetId = setId
                        break
                    }
                }

                if (duplicateSetId) {
                    console.log(`⚠️ Skipping duplicate set: ${row.name}`)
                    continue
                }

                // 4. Insert event_set row
                const { data: setData, error: setError } = await supabase
                    .from('event_sets')
                    .insert({
                        event_id: eventId,
                        tier: row.tier,
                        set_note: row.set_note || null,
                        display_name: row.artistNames.sort().join(' B2B '),
                    })
                    .select()
                    .single()
                if (setError) throw setError

                const event_set_id = setData.id

                // 5. Link all artists to the set
                const artistLinks = artistIds.map((artistId) => ({
                    set_id: event_set_id,
                    artist_id: artistId,
                }))

                const { error: linkError } = await supabase
                    .from('event_set_artists')
                    .insert(artistLinks)

                if (linkError) throw linkError
            } catch (err: any) {
                console.error(`❌ Failed to import: ${row.name}`, err)
            }
        }
        alert('✅ Import complete!')
    setUploading(false)
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
            <div className="mt-6">
                <h3 className="text-lg font-semibold mb-2">Preview</h3>
                <table className="w-full border-collapse text-sm">
                    <thead>
                        <tr>
                            <th className="border-b border-gray-700 text-left p-1">Name</th>
                            <th className="border-b border-gray-700 text-left p-1">Tier</th>
                            <th className="border-b border-gray-700 text-left p-1">Note</th>
                            <th className="border-b border-gray-700 text-left p-1">Artists</th>
                        </tr>
                    </thead>
                    <tbody>
                        {rows.map((row, i) => (
                            <tr key={i} className="border-t border-gray-800">
                                <td className="p-1">{row.name}</td>
                                <td className="p-1">{row.tier}</td>
                                <td className="p-1">{row.set_note}</td>
                                <td className="p-1">{row.artistNames.join(', ')}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>

                <button
                    onClick={handleImport}
                    className="mt-4 bg-green-600 hover:bg-green-500 text-white px-4 py-2 rounded text-sm"
                    disabled={uploading}
                >
                    {uploading ? 'Importing...' : 'Import to Supabase'}
                </button>
            </div>
        )}
    </div>
)
}
