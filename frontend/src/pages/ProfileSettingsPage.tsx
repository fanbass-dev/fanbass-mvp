import React, { useState } from 'react'
import { supabase } from '../supabaseClient'
import { useUserContext } from '../context/UserContext'

const ProfileSettingsPage: React.FC = () => {
  const { user, updateProfile, refresh } = useUserContext()
  const [username, setUsername] = useState('')
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setSuccess('')
    setLoading(true)

    try {
      const { error } = await supabase
        .from('profiles')
        .update({ username: username.trim() })
        .eq('id', user?.id)

      if (error) throw error

      // Immediately update the local state
      updateProfile({ username: username.trim() })
      
      // Then refresh the data from the server
      await refresh()
      setSuccess('Username updated successfully!')
    } catch (error: any) {
      setError(error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      {/* Render your form here */}
    </div>
  )
}

export default ProfileSettingsPage 