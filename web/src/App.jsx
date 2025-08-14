import React, { useEffect, useState } from 'react'
import { supabase } from './lib/supabase'
import { usePathname } from './lib/router'
import Auth from './components/Auth'
import Navbar from './components/Navbar'
import Dashboard from './components/Dashboard'
import Landing from './components/Landing'

export default function App() {
  const [session, setSession] = useState(null)
  const [path] = usePathname()
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => setSession(session))
    const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => setSession(session))
    return () => listener.subscription.unsubscribe()
  }, [])
  if (path === '/sobre') {
    return (
      <div className="min-h-screen">
        <Navbar session={session} />
        <div className="max-w-6xl mx-auto p-4 md:p-6">
          <Landing loggedIn={!!session} />
        </div>
      </div>
    )
  }
  if (!session) return <Auth />
  return (
    <div className="min-h-screen">
      <Navbar session={session} />
      <div className="max-w-6xl mx-auto p-4 md:p-6">
        <Dashboard session={session} />
      </div>
    </div>
  )
}