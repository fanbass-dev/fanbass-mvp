import { useState } from 'react'
import { useUserContext } from '../../context/UserContext'
import { supabase } from '../../supabaseClient'

export function ProfileSettingsPage() {
  const { user, profile, loading, refresh } = useUserContext()
  const [username, setUsername] = useState(profile?.username || '')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  const validateUsername = (value: string) => {
    const trimmedValue = value.trim()
    if (trimmedValue.length < 3) return 'Username must be at least 3 characters'
    if (trimmedValue.length > 30) return 'Username must be less than 30 characters'
    if (trimmedValue.length === 0) return 'Username cannot be only spaces'
    if (!/^[a-zA-Z0-9 _-]+$/.test(value)) {
      return 'Username can only contain letters, numbers, spaces, underscores, and hyphens'
    }
    return null
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    setSuccess(false)

    // Validate
    const validationError = validateUsername(username)
    if (validationError) {
      setError(validationError)
      return
    }

    setIsSubmitting(true)
    try {
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ username: username.trim() }) // Trim spaces from start/end before saving
        .eq('id', user?.id)
        .select()

      if (updateError) {
        if (updateError.code === '23505') { // Unique violation
          setError('This username is already taken')
        } else {
          setError(updateError.message)
        }
      } else {
        await refresh()
        setSuccess(true)
      }
    } catch (err) {
      setError('An unexpected error occurred')
    } finally {
      setIsSubmitting(false)
    }
  }

  if (loading) {
    return <div className="p-4">Loading...</div>
  }

  return (
    <div className="max-w-2xl mx-auto p-4">
      <h1 className="text-2xl font-bold mb-6">Profile</h1>
      
      <div className="bg-gray-800 rounded-lg p-6 mb-6">
        <h2 className="text-xl font-semibold mb-4">Username</h2>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="username" className="block text-sm font-medium mb-2">
              Choose your username
            </label>
            <input
              type="text"
              id="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full px-3 py-2 bg-gray-700 rounded border border-gray-600 focus:border-brand focus:ring-1 focus:ring-brand"
              placeholder="Enter username"
              disabled={isSubmitting}
            />
            <p className="mt-2 text-sm text-gray-400">
              This will be your public display name. You can use letters, numbers, spaces, underscores, and hyphens.
            </p>
          </div>

          {error && (
            <div className="text-red-400 text-sm">{error}</div>
          )}
          
          {success && (
            <div className="text-green-400 text-sm">Username updated successfully!</div>
          )}

          <button
            type="submit"
            disabled={isSubmitting}
            className="px-4 py-2 bg-brand text-white rounded hover:bg-opacity-90 disabled:opacity-50"
          >
            {isSubmitting ? 'Saving...' : 'Save Username'}
          </button>
        </form>
      </div>

      {/* Future sections can be added here */}
      <div className="bg-gray-800 rounded-lg p-6 opacity-50">
        <h2 className="text-xl font-semibold mb-2">More Settings Coming Soon</h2>
        <p className="text-gray-400">Additional profile customization options will be available here.</p>
      </div>
    </div>
  )
} 