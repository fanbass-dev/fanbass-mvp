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
    created_at: string // ISO string
}

export function FeatureVoting() {
    const [features, setFeatures] = useState<Feature[]>([])
    const [user, setUser] = useState<any>(null)
    const [titleInput, setTitleInput] = useState('')
    const [descInput, setDescInput] = useState('')
    const [submitting, setSubmitting] = useState(false)
    const [sortBy, setSortBy] = useState<'top' | 'newest'>('top')

    const sortFeatures = (data: Feature[]) => {
        if (sortBy === 'top') {
            return data.sort((a, b) => b.vote_count - a.vote_count)
        } else {
            return data.sort(
                (a, b) =>
                    new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
            )
        }
    }

    const fetchFeatures = async (uid: string) => {
        const { data, error } = await supabase.rpc('get_feature_votes', { uid })
        if (error) console.error(error)
        else setFeatures(sortFeatures(data))
    }

    useEffect(() => {
        const fetchData = async () => {
            const { data: { session } } = await supabase.auth.getSession()
            const currentUser = session?.user
            if (!currentUser) return

            setUser(currentUser)
            await fetchFeatures(currentUser.id)
        }

        fetchData()
    }, [])

    useEffect(() => {
        if (user) fetchFeatures(user.id)
    }, [sortBy])

    const handleVote = async (featureId: string) => {
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
    }

    const handleSuggest = async (e: React.FormEvent) => {
        e.preventDefault()
        if (!titleInput || !user) return
        setSubmitting(true)

        const { error } = await supabase.from('features').insert({
            title: titleInput,
            description: descInput,
            created_by: user.id,
        })

        if (error) {
            console.error(error)
        } else {
            setTitleInput('')
            setDescInput('')
            await fetchFeatures(user.id)
        }

        setSubmitting(false)
    }

    return (
        <div>
            <h2>🧠 Feature Voting</h2>

            <form onSubmit={handleSuggest} style={{ marginBottom: '24px' }}>
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

            <div style={{ marginBottom: '12px' }}>
                <label htmlFor="sort">Sort by:</label>
                <select
                    id="sort"
                    value={sortBy}
                    onChange={(e) => setSortBy(e.target.value as 'top' | 'newest')}
                    style={{ marginLeft: '8px' }}
                >
                    <option value="top">Top</option>
                    <option value="newest">Newest</option>
                </select>
            </div>

            {features.map((f) => (
                <div
                    key={f.id}
                    style={{
                        border: '1px solid #ccc',
                        borderRadius: '8px',
                        margin: '8px 0',
                        padding: '12px',
                        display: 'flex',
                        flexDirection: 'column',
                        gap: '6px',
                    }}
                >
                    {/* Title and Submitted Date in one row */}
                    <div
                        style={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            flexWrap: 'wrap',
                            gap: '8px',
                        }}
                    >
                        <h3 style={{ margin: 0 }}>{f.title}</h3>
                        <span style={{ fontSize: '0.85rem', color: '#555' }}>
                            Submitted: {new Date(f.created_at).toLocaleDateString()}
                        </span>
                    </div>

                    {/* Description */}
                    {f.description && (
                        <p style={{ margin: 0, fontSize: '0.95rem' }}>{f.description}</p>
                    )}

                    {/* Status + Votes + Button in one row */}
                    <div
                        style={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            flexWrap: 'wrap',
                            fontSize: '0.9rem',
                            gap: '8px',
                        }}
                    >
                        <span>Status: <strong>{f.status}</strong></span>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                            <span>Votes: <strong>{f.vote_count}</strong></span>
                            <button onClick={() => handleVote(f.id)} disabled={f.user_voted}>
                                {f.user_voted ? 'Voted ✅' : 'Upvote'}
                            </button>
                        </div>
                    </div>
                </div>


            ))}
        </div>
    )
}
