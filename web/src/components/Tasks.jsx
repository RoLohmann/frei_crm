import React, { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'

export default function Tasks({ session }) {
  const user_id = session.user.id
  const [items, setItems] = useState([])
  const [form, setForm] = useState({ title: '', due_date: '', client_id: null, deal_id: null })
  const [clients, setClients] = useState([])
  const [deals, setDeals] = useState([])

  const load = async () => {
    const { data } = await supabase.from('tasks').select('*').eq('user_id', user_id).order('created_at', { ascending: false })
    setItems(data || [])
  }
  const loadRefs = async () => {
    const [{ data: c }, { data: d }] = await Promise.all([
      supabase.from('clients').select('id,name').eq('user_id', user_id),
      supabase.from('deals').select('id,title').eq('user_id', user_id),
    ])
    setClients(c || [])
    setDeals(d || [])
  }

  useEffect(() => { load(); loadRefs() }, [])

  const toggle = async (id, status) => {
    await supabase.from('tasks').update({ status }).eq('id', id)
    load()
  }
  const remove = async (id) => {
    await supabase.from('tasks').delete().eq('id', id)
    load()
  }
  const save = async (e) => {
    e.preventDefault()
    await supabase.from('tasks').insert([{ ...form, user_id }])
    setForm({ title: '', due_date: '', client_id: null, deal_id: null })
    load()
  }

  return (
    <div className="space-y-4">
      <div className="bg-white p-4 rounded-2xl border shadow">
        <h3 className="font-semibold mb-2">Nova tarefa</h3>
        <form onSubmit={save} className="grid grid-cols-1 md:grid-cols-5 gap-2">
          <input className="border rounded p-2 md:col-span-2" placeholder="Título" value={form.title} onChange={e=>setForm({...form, title:e.target.value})} required />
          <input className="border rounded p-2" type="date" value={form.due_date} onChange={e=>setForm({...form, due_date:e.target.value})} />
          <select className="border rounded p-2" value={form.client_id || ''} onChange={e=>setForm({...form, client_id:e.target.value || null})}>
            <option value="">Cliente</option>
            {clients.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
          <select className="border rounded p-2" value={form.deal_id || ''} onChange={e=>setForm({...form, deal_id:e.target.value || null})}>
            <option value="">Negócio</option>
            {deals.map(d => <option key={d.id} value={d.id}>{d.title}</option>)}
          </select>
          <button className="bg-black text-white rounded p-2">Salvar</button>
        </form>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-white p-3 rounded-2xl border shadow">
          <div className="font-medium mb-2">Pendentes</div>
          <ul className="space-y-2">
            {items.filter(i=>i.status==='pendente').map(it => (
              <li key={it.id} className="border rounded p-2">
                <div className="font-semibold">{it.title}</div>
                <div className="text-xs text-gray-600">Vencimento: {it.due_date || '-'}</div>
                <div className="flex gap-2 mt-2">
                  <button onClick={()=>toggle(it.id,'concluida')} className="text-sm border rounded px-2 py-1">Concluir</button>
                  <button onClick={()=>remove(it.id)} className="text-sm text-red-600 ml-auto">Excluir</button>
                </div>
              </li>
            ))}
            {items.filter(i=>i.status==='pendente').length===0 && <div className="text-sm text-gray-500">Sem tarefas pendentes</div>}
          </ul>
        </div>
        <div className="bg-white p-3 rounded-2xl border shadow">
          <div className="font-medium mb-2">Concluídas</div>
          <ul className="space-y-2">
            {items.filter(i=>i.status==='concluida').map(it => (
              <li key={it.id} className="border rounded p-2">
                <div className="font-semibold">{it.title}</div>
                <div className="text-xs text-gray-600">Vencimento: {it.due_date || '-'}</div>
                <div className="flex gap-2 mt-2">
                  <button onClick={()=>toggle(it.id,'pendente')} className="text-sm border rounded px-2 py-1">Reabrir</button>
                  <button onClick={()=>remove(it.id)} className="text-sm text-red-600 ml-auto">Excluir</button>
                </div>
              </li>
            ))}
            {items.filter(i=>i.status==='concluida').length===0 && <div className="text-sm text-gray-500">Sem tarefas concluídas</div>}
          </ul>
        </div>
      </div>
    </div>
  )
}