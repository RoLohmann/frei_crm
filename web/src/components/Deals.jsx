import React, { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import ExportCSVButton from './ExportCSVButton'

const STAGES = ['novo', 'negociacao', 'fechado']

export default function Deals({ session }) {
  const user_id = session.user.id
  const [items, setItems] = useState([])
  const [form, setForm] = useState({ title: '', value: 0, client_id: null })
  const [clients, setClients] = useState([])

  const load = async () => {
    const { data } = await supabase.from('deals').select('*').eq('user_id', user_id).order('created_at', { ascending: false })
    setItems(data || [])
  }

  const loadClients = async () => {
    const { data } = await supabase.from('clients').select('id,name').eq('user_id', user_id).order('name')
    setClients(data || [])
  }

  useEffect(() => { load(); loadClients() }, [])

  const save = async (e) => {
    e.preventDefault()
    await supabase.from('deals').insert([{ ...form, user_id }])
    setForm({ title: '', value: 0, client_id: null })
    load()
  }

  const move = async (id, dir) => {
    const d = items.find(x => x.id === id)
    const idx = STAGES.indexOf(d.stage)
    const next = STAGES[Math.min(STAGES.length-1, Math.max(0, idx + dir))]
    if (next !== d.stage) {
      await supabase.from('deals').update({ stage: next }).eq('id', id)
      load()
    }
  }

  const remove = async (id) => {
    await supabase.from('deals').delete().eq('id', id)
    load()
  }

  const columns = STAGES.map(stage => ({
    stage,
    data: items.filter(i => i.stage === stage)
  }))

  return (
    <div className="space-y-4">
      <div className="bg-white p-4 rounded-2xl border shadow">
        <h3 className="font-semibold mb-2">Novo negócio</h3>
        <form onSubmit={save} className="grid grid-cols-1 md:grid-cols-4 gap-2">
          <input className="border rounded p-2" placeholder="Título" value={form.title} onChange={e=>setForm({...form, title:e.target.value})} required />
          <input className="border rounded p-2" placeholder="Valor (R$)" type="number" value={form.value} onChange={e=>setForm({...form, value:Number(e.target.value)})} />
          <select className="border rounded p-2" value={form.client_id || ''} onChange={e=>setForm({...form, client_id:e.target.value || null})}>
            <option value="">(opcional) Cliente</option>
            {clients.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
          <button className="bg-black text-white rounded p-2">Salvar</button>
        </form>
      </div>

      <div className="flex items-center justify-between">
        <h3 className="font-semibold">Pipeline</h3>
        <ExportCSVButton data={items} filename="negocios.csv" />
      </div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {columns.map(col => (
          <div key={col.stage} className="bg-white p-3 rounded-2xl border shadow">
            <div className="font-medium capitalize mb-2">{col.stage}</div>
            <div className="space-y-2">
              {col.data.map(d => (
                <div key={d.id} className="border rounded-lg p-2">
                  <div className="font-semibold">{d.title}</div>
                  <div className="text-sm text-gray-600">R$ {Number(d.value || 0).toFixed(2)}</div>
                  <div className="flex gap-2 mt-2">
                    <button onClick={()=>move(d.id, -1)} className="text-sm border rounded px-2 py-1">←</button>
                    <button onClick={()=>move(d.id, +1)} className="text-sm border rounded px-2 py-1">→</button>
                    <button onClick={()=>remove(d.id)} className="text-sm text-red-600 ml-auto">Excluir</button>
                  </div>
                </div>
              ))}
              {col.data.length===0 && <div className="text-sm text-gray-500">Vazio</div>}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}