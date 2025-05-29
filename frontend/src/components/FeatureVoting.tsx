// components/FeatureVoting.tsx
import { useEffect, useState } from 'react'
import { supabase } from '../supabaseClient'
import { getCurrentUser } from '../services/authService'

type Feature = {
  id: string
  title: string
  description: string | null
  status: string
  vote_count: number
  user_voted: boolean
}

export function FeatureVoting() {
  const [features, setFeatures] = useState<Feature[]>([])
  const [user, setUser] = useState<any>(null)

  useEffect(() => {
    const fetchData = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      const currentUser = session?.user
      if (!currentUser) return

      setUser(currentUser)

      const { data, error } = await supabase.rpc('get_feature_votes', {
        uid: currentUser.id
      })

      if (error) {
        console.error(error)
      } else {
        setFeatures(data)
      }
    }

    fetchData()
  }, [])

  const handleVote = async (featureId: string) => {
    if (!user) return

    const { error } = await supabase.from('feature_votes').insert({
      feature_id: featureId,
      user_id: user.id
    })

    if (!error) {
      setFeatures(prev =>
        prev.map(f =>
          f.id === featureId
            ? { ...f, vote_count: f.vote_count + 1, user_voted: true }
            : f
        )
      )
    } else {
      console.error(error)
    }
  }

  return (
    <div>
      <h2>🗳 Feature Voting</h2>
      {features.map((f) => (
        <div key={f.id} style={{ border: '1px solid #ccc', margin: '8px 0', padding: '12px' }}>
          <h3>{f.title}</h3>
          <p>{f.description}</p>
          <p>Status: <strong>{f.status}</strong></p>
          <button
            onClick={() => handleVote(f.id)}
            disabled={f.user_voted}
          >
            {f.user_voted ? 'Voted ✅' : `Upvote (${f.vote_count})`}
          </button>
        </div>
      ))}
    </div>
  )
}
