import { useEffect, useState } from 'react'
import { supabase } from '../supabaseClient'

type Role = 'admin' | 'fan' | 'artist' | 'promoter'

type UseUserRolesResult = {
  roles: Role[]
  hasRole: (r: Role) => boolean
  isAdmin: boolean
  isFan: boolean
  isArtist: boolean
  isPromoter: boolean
  loading: boolean
  error: string | null
}

export function useUserRoles(userId?: string): UseUserRolesResult {
  const [roles, setRoles] = useState<Role[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!userId) {
      setLoading(false)
      return
    }

    const fetchRoles = async () => {
      setLoading(true)
      const { data, error } = await supabase
        .from('roles')
        .select('role')
        .eq('user_id', userId)

      if (error) {
        setError(error.message)
        setRoles([])
      } else {
        const roleList = (data || []).map((r) => r.role as Role)
        setRoles(roleList)
      }

      setLoading(false)
    }

    fetchRoles()
  }, [userId])

  const hasRole = (role: Role) => roles.includes(role)

  return {
    roles,
    hasRole,
    isAdmin: hasRole('admin'),
    isFan: hasRole('fan'),
    isArtist: hasRole('artist'),
    isPromoter: hasRole('promoter'),
    loading,
    error,
  }
}
