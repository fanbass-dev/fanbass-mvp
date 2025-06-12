import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'
import { useActivityTracking } from '../hooks/useActivityTracking'

type Props = {
  isOpen: boolean
  onClose: () => void
  suggestedName: string
  onSuccess: () => void
  currentUser: any
}

export function CreateArtistModal({ isOpen, onClose, suggestedName, onSuccess, currentUser }: Props) {
  const [name, setName] = useState(suggestedName)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const { trackActivity } = useActivityTracking()

  // Update name whenever modal opens with a new suggested name
  useEffect(() => {
    if (isOpen) {
      setName(suggestedName)
    }
  }, [isOpen, suggestedName])

  if (!isOpen) return null

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const upperName = name.trim().toUpperCase()

    if (!upperName) {
      setError('Name is required.')
      setLoading(false)
      return
    }

    try {
      const { data, error } = await supabase.from('artists').insert({
        name: upperName,
        created_by: currentUser.id,
      }).select().single()
      
      if (error) throw error
      
      // Track the activity
      await trackActivity('create_artist', { artist_id: data.id })
      onSuccess()
      onClose()
    } catch (err: any) {
      setError(err.message || 'Something went wrong.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-gray-900 rounded-lg p-6 max-w-md w-full mx-4">
        <h2 className="text-xl font-semibold mb-4">Create New Artist</h2>
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label className="block text-sm font-medium mb-1">Name (ALL CAPS)</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value.toUpperCase())}
              className="w-full px-3 py-2 bg-gray-800 border border-gray-700 rounded focus:outline-none focus:border-blue-500"
            />
          </div>
          {error && <div className="text-red-500 text-sm mb-4">{error}</div>}
          <div className="flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-sm bg-gray-800 hover:bg-gray-700 rounded"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 text-sm bg-blue-600 hover:bg-blue-500 rounded disabled:opacity-50"
            >
              {loading ? 'Creating...' : 'Create Artist'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
} 