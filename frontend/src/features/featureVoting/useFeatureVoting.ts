// src/features/featureVoting/useFeatureVoting.ts

import { useCallback, useEffect, useState } from 'react'
import { supabase } from '../../supabaseClient'
import { Feature } from './types'

export function useFeatureVoting() {
  const [features, setFeatures] = useState<Feature[]>([])
  const [user, setUser] = useState<any>(null)
  const [sortBy, setSortBy] = useState<'top' | 'newest'>('top')

  const sortFeatures = useCallback((data: Feature[]) => {
    return sortBy === 'top'
      ? [...data].sort((a, b) => b.vote_count - a.vote_count)
      : [...data].sort((a, b) =>
          new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        )
  }, [sortBy])

  const fetchFeatures = useCallback(async () => {
    const { data, error } = await supabase
      .from('features')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Plain fetch failed:', error)
    } else {
      console.log('Plain fetch succeeded:', data)
      setFeatures(sortFeatures(data))
    }
  }, [sortFeatures])

  const handleVote = useCallback(async (featureId: string) => {
    if (!user) return

    const { error } = await supabase.from('feature_votes').insert({
      feature_id: featureId,
      user_id: user.id,
    })

    if (!error) {
      setFeatures((prev) =>
        sortFeatures(
          prev.map((f) =>
            f.id === featureId
              ? { ...f, vote_count: f.vote_count + 1, user_voted: true }
              : f
          )
        )
      )
    } else {
      console.error(error)
    }
  }, [user, sortFeatures])

  const handleSuggest = useCallback(async (title: string, description: string) => {
    if (!user) return

    const { error } = await supabase.from('features').insert({
      title,
      description,
      created_by: user.id,
    })

    if (error) {
      console.error(error)
    } else {
      await fetchFeatures()
    }
  }, [user, fetchFeatures])

  useEffect(() => {
    const { data: listener } = supabase.auth.onAuthStateChange((event, session) => {
      if (session?.user) {
        setUser(session.user)
      }
    })

    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        setUser(session.user)
      }
    })

    return () => {
      listener?.subscription.unsubscribe()
    }
  }, [])

  useEffect(() => {
    fetchFeatures()
  }, [sortBy, fetchFeatures])

  return {
    user,
    features,
    sortBy,
    setSortBy,
    handleVote,
    handleSuggest,
  }
}
