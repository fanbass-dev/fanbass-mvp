// src/features/featureVoting/FeatureForm.tsx

import { useState } from 'react'

type Props = {
  onSubmit: (title: string, description: string) => Promise<void>
}

export function FeatureForm({ onSubmit }: Props) {
  const [titleInput, setTitleInput] = useState('')
  const [descInput, setDescInput] = useState('')
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!titleInput) return
    setSubmitting(true)
    await onSubmit(titleInput, descInput)
    setTitleInput('')
    setDescInput('')
    setSubmitting(false)
  }

  return (
    <form onSubmit={handleSubmit} style={{ marginBottom: '24px' }}>
      <h4>Suggest a Feature</h4>
      <input
        type="text"
        value={titleInput}
        onChange={(e) => setTitleInput(e.target.value)}
        placeholder="Title"
        required
        style={{
          display: 'block',
          width: '100%',
          marginBottom: '8px',
          padding: '6px',
        }}
      />
      <textarea
        value={descInput}
        onChange={(e) => setDescInput(e.target.value)}
        placeholder="Optional description"
        rows={3}
        style={{
          display: 'block',
          width: '100%',
          marginBottom: '8px',
          padding: '6px',
        }}
      />
      <button type="submit" disabled={submitting}>
        {submitting ? 'Submitting...' : 'Submit Feature'}
      </button>
    </form>
  )
}
