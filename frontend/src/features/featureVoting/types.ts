export type Feature = {
  id: string
  title: string
  description: string | null
  status: string
  vote_count: number
  user_voted: boolean
  created_at: string // ISO string
  submitter_id: string
  submitter_username: string | null
}