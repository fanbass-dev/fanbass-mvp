import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { supabase } from '../../supabaseClient'
import { useActivityTracking } from '../../hooks/useActivityTracking'

type Props = {
  currentUser: any
}

export function ArtistPage({ currentUser }: Props) {
  const { id } = useParams()
  const isNew = id === 'new'
  const navigate = useNavigate()
  const { trackActivity } = useActivityTracking()

  const [name, setName] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (isNew) {
      const queryParams = new URLSearchParams(window.location.search)
      const suggestedName = queryParams.get('name')
      if (suggestedName) setName(suggestedName)
    } else {
      supabase
        .from('artists')
        .select('id, name')
        .eq('id', id)
        .single()
        .then(({ data, error }) => {
          if (error) {
            setError('Artist not found.')
          } else {
            setName(data.name)
          }
        })
    }
  }, [id, isNew])

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
      if (isNew) {
        const { data, error } = await supabase.from('artists').insert({
          name: upperName,
          created_by: currentUser.id,
        }).select().single()
        
        if (error) throw error
        
        // Track the activity
        await trackActivity('create_artist', { artist_id: data.id })
      } else {
        const { error } = await supabase
          .from('artists')
          .update({ name: upperName })
          .eq('id', id)
        if (error) throw error
      }

      navigate('/')
    } catch (err: any) {
      setError(err.message || 'Something went wrong.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ padding: '2rem', maxWidth: 600 }}>
      <h2>{isNew ? 'Create Artist' : 'Edit Artist'}</h2>
      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: '1rem' }}>
          <label>Name (ALL CAPS)</label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value.toUpperCase())}
            style={{ width: '100%', padding: '0.5rem' }}
          />
        </div>
        {error && <div style={{ color: 'red', marginBottom: '1rem' }}>{error}</div>}
        <button type="submit" disabled={loading}>
          {loading ? 'Saving...' : isNew ? 'Create Artist' : 'Save Changes'}
        </button>
      </form>
    </div>
  )
}
