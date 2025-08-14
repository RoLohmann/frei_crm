import React, { useEffect, useState } from 'react'
import Clients from './Clients'
import Deals from './Deals'
import Tasks from './Tasks'
import { supabase } from '../lib/supabase'

export default function Dashboard({ session }) {
  const [tab, setTab] = useState('clients')
  const [stats, setStats] = useState({ clients: 0, deals: 0, tasks: 0 })

  useEffect(() => {
    const load = async () => {
      const user_id = session.user.id
      const [{ count: c1 }, { count: c2 }, { count: c3 }] = await Promise.all([
        supabase.from('clients').select('*', { count: 'exact', head: true }).eq('user_id', user_id),
        supabase.from('deals').select('*', { count: 'exact', head: true }).eq('user_id', user_id),
        supabase.from('tasks').select('*', { count: 'exact', head: true }).eq('user_id', user_id),
      ])
      setStats({ clients: c1 ?? 0, deals: c2 ?? 0, tasks: c3 ?? 0 })
    }
    load()
  }, [session])

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        <Card title="Clientes" value={stats.clients} />
        <Card title="Negócios" value={stats.deals} />
        <Card title="Tarefas" value={stats.tasks} />
      </div>
      <div className="flex gap-2">
        <TabButton active={tab==='clients'} onClick={() => setTab('clients')}>Clientes</TabButton>
        <TabButton active={tab==='deals'} onClick={() => setTab('deals')}>Negócios</TabButton>
        <TabButton active={tab==='tasks'} onClick={() => setTab('tasks')}>Tarefas</TabButton>
      </div>
      {tab === 'clients' && <Clients session={session} />}
      {tab === 'deals' && <Deals session={session} />}
      {tab === 'tasks' && <Tasks session={session} />}
    </div>
  )
}

function Card({ title, value }) {
  return (
    <div className="bg-white rounded-2xl p-4 shadow border">
      <div className="text-sm text-gray-500">{title}</div>
      <div className="text-2xl font-bold">{value}</div>
    </div>
  )
}

function TabButton({ active, children, ...props }) {
  return (
    <button {...props}
      className={`px-3 py-1 rounded-lg border ${active ? 'bg-black text-white' : 'bg-white'}`}>
      {children}
    </button>
  )
}