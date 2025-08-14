import React, { useEffect, useState } from 'react'
import { supabase } from './lib/supabase'
import Auth from './components/Auth'
import Navbar from './components/Navbar'
import Dashboard from './components/Dashboard'

export default function App() {
  const [session, setSession] = useState(null)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => setSession(session))
    const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
    })
    return () => listener.subscription.unsubscribe()
  }, [])

  if (!session) return <Auth />

  return (
    <div className="min-h-screen">
      <Navbar onLogout={() => supabase.auth.signOut()} />
      <div className="max-w-6xl mx-auto p-4">
        <Dashboard session={session} />
      </div>
    </div>
  )
}