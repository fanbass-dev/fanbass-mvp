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

type Profile = {
  username: string | null
  displayName: string
}

type UserContextType = {
  user: User | null
  roles: Role[]
  profile: Profile | null
  hasRole: (role: Role) => boolean
  isAdmin: boolean
  isFan: boolean
  isArtist: boolean
  isPromoter: boolean
  loading: boolean
  refresh: () => Promise<void>
  updateProfile: (newProfile: Partial<Profile>) => void
}

const UserContext = createContext<UserContextType | undefined>(undefined)

export function UserProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [roles, setRoles] = useState<Role[]>([])
  const [profile, setProfile] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(true)

  const fetchUserAndData = async () => {
    setLoading(true)
    try {
      // Get user
      const { data: userData } = await supabase.auth.getUser()
      const currentUser = userData?.user ?? null
      setUser(currentUser)

      if (currentUser) {
        // Get roles
        const { data: roleData } = await supabase
          .from('roles')
          .select('role')
          .eq('user_id', currentUser.id)

        const roleList = (roleData || []).map((r) => r.role as Role)
        setRoles(roleList)

        // Get profile and display name
        const { data: displayNameData } = await supabase
          .rpc('get_display_name', { user_id: currentUser.id })
        
        const { data: profileData } = await supabase
          .from('profiles')
          .select('username')
          .eq('id', currentUser.id)
          .single()

        setProfile({
          username: profileData?.username ?? null,
          displayName: displayNameData
        })
      } else {
        setRoles([])
        setProfile(null)
      }
    } catch (error) {
      console.error('Error fetching user data:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchUserAndData()
  }, [])

  const hasRole = (role: Role) => roles.includes(role)

  const updateProfile = (newProfile: Partial<Profile>) => {
    if (!profile) return
    
    const updatedProfile = {
      ...profile,
      ...newProfile,
      // If username is being updated, also update displayName
      displayName: newProfile.username || profile.displayName
    }
    setProfile(updatedProfile)
  }

  return (
    <UserContext.Provider
      value={{
        user,
        roles,
        profile,
        hasRole,
        isAdmin: hasRole('admin'),
        isFan: hasRole('fan'),
        isArtist: hasRole('artist'),
        isPromoter: hasRole('promoter'),
        loading,
        refresh: fetchUserAndData,
        updateProfile
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
