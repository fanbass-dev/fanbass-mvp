import {
  createContext,
  useContext,
  useEffect,
  useState,
  ReactNode,
} from 'react'
import { supabase } from '../supabaseClient'
import type { User } from '@supabase/supabase-js'
import type { Role } from '../types/roles'

type UserContextType = {
  user: User | null
  roles: Role[]
  hasRole: (role: Role) => boolean
  isAdmin: boolean
  isFan: boolean
  isArtist: boolean
  isPromoter: boolean
  loading: boolean
}

const UserContext = createContext<UserContextType | undefined>(undefined)

export function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [roles, setRoles] = useState<Role[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchUserAndRoles = async () => {
      setLoading(true)
      const { data: userData } = await supabase.auth.getUser()
      const currentUser = userData?.user ?? null
      setUser(currentUser)

      if (currentUser) {
        const { data: roleData } = await supabase
          .from('roles')
          .select('role')
          .eq('user_id', currentUser.id)

        const roleList = (roleData || []).map((r) => r.role as Role)
        setRoles(roleList)
      }

      setLoading(false)
    }

    fetchUserAndRoles()
  }, [])

  const hasRole = (role: Role) => roles.includes(role)

  return (
    <UserContext.Provider
      value={{
        user,
        roles,
        hasRole,
        isAdmin: hasRole('admin'),
        isFan: hasRole('fan'),
        isArtist: hasRole('artist'),
        isPromoter: hasRole('promoter'),
        loading,
      }}
    >
      {children}
    </UserContext.Provider>
  )
}

export function useUserContext() {
  const context = useContext(UserContext)
  if (!context) {
    throw new Error('useUserContext must be used within a UserProvider')
  }
  return context
}
