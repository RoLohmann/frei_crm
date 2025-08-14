import React, { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import ExportCSVButton from './ExportCSVButton'

export default function Clients({ session }) {
  const user_id = session.user.id
  const [items, setItems] = useState([])
  const [q, setQ] = useState('')
  const [form, setForm] = useState({ name: '', email: '', phone: '', notes: '' })
  const [loading, setLoading] = useState(false)

  const load = async () => {
    let query = supabase.from('clients').select('*').eq('user_id', user_id).order('created_at', { ascending: false })
    if (q) query = query.ilike('name', `%${q}%`)
    const { data } = await query
    setItems(data || [])
  }
  useEffect(() => { load() }, [q])

  const save = async (e) => {
    e.preventDefault(); setLoading(true)
    await supabase.from('clients').insert([{ ...form, user_id }])
    setForm({ name: '', email: '', phone: '', notes: '' })
    setLoading(false); load()
  }
  const remove = async (id) => { await supabase.from('clients').delete().eq('id', id); load() }

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div className="card card-pad">
        <h3 className="font-semibold mb-3">Novo cliente</h3>
        <form onSubmit={save} className="space-y-2">
          <input className="input" placeholder="Nome" value={form.name} onChange={e=>setForm({...form, name:e.target.value})} required />
          <input className="input" placeholder="Email" value={form.email} onChange={e=>setForm({...form, email:e.target.value})} />
          <input className="input" placeholder="Telefone" value={form.phone} onChange={e=>setForm({...form, phone:e.target.value})} />
          <textarea className="textarea" placeholder="Notas" value={form.notes} onChange={e=>setForm({...form, notes:e.target.value})} />
          <button disabled={loading} className="btn-primary w-full">{loading ? 'Salvando...' : 'Salvar'}</button>
        </form>
      </div>

      <div className="md:col-span-2 card card-pad">
        <div className="flex items-center justify-between mb-3">
          <input className="input w-1/2" placeholder="Buscar por nome..." value={q} onChange={e=>setQ(e.target.value)} />
          <ExportCSVButton data={items} filename="clientes.csv" />
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-500 dark:text-gray-400">
                <th className="p-2">Nome</th>
                <th className="p-2">Email</th>
                <th className="p-2">Telefone</th>
                <th className="p-2">Ações</th>
              </tr>
            </thead>
            <tbody>
              {items.map(it => (
                <tr key={it.id} className="border-t border-gray-100 dark:border-gray-800">
                  <td className="p-2">{it.name}</td>
                  <td className="p-2">{it.email}</td>
                  <td className="p-2">{it.phone}</td>
                  <td className="p-2">
                    <button onClick={()=>remove(it.id)} className="text-red-500 hover:underline">Excluir</button>
                  </td>
                </tr>
              ))}
              {items.length===0 && (<tr><td className="p-2 text-gray-500" colSpan={4}>Sem clientes</td></tr>)}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}