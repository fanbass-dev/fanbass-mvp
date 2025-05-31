import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://vkvhrearjmmwiuvvmcib.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrdmhyZWFyam1td2l1dnZtY2liIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgwNTE3NjMsImV4cCI6MjA2MzYyNzc2M30.yjGv1br6hEnuvkTUEH7S8PidI5dly9Q5rvfcdfehpYo'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
