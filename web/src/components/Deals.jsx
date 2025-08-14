import React, { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import ExportCSVButton from './ExportCSVButton'
import { DndContext, useDraggable, useDroppable } from '@dnd-kit/core'

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
  const remove = async (id) => { await supabase.from('deals').delete().eq('id', id); load() }

  const onDragEnd = async (event) => {
    const { active, over } = event
    if (!over) return
    const overId = over.id
    const col = typeof overId === 'string' && overId.startsWith('col-') ? overId.replace('col-','') : null
    if (!col) return
    const d = items.find(x => x.id === active.id)
    if (d && d.stage !== col) {
      await supabase.from('deals').update({ stage: col }).eq('id', d.id)
      load()
    }
  }

  const columns = STAGES.map(stage => ({ stage, data: items.filter(i => i.stage === stage) }))

  return (
    <div className="space-y-4">
      <div className="card card-pad">
        <h3 className="font-semibold mb-2">Novo negócio</h3>
        <form onSubmit={save} className="grid grid-cols-1 md:grid-cols-4 gap-2">
          <input className="input" placeholder="Título" value={form.title} onChange={e=>setForm({...form, title:e.target.value})} required />
          <input className="input" placeholder="Valor (R$)" type="number" value={form.value} onChange={e=>setForm({...form, value:Number(e.target.value)})} />
          <select className="input" value={form.client_id || ''} onChange={e=>setForm({...form, client_id:e.target.value || null})}>
            <option value="">(opcional) Cliente</option>
            {clients.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
          <button className="btn-primary">Salvar</button>
        </form>
      </div>

      <div className="flex items-center justify-between">
        <h3 className="font-semibold">Pipeline</h3>
        <ExportCSVButton data={items} filename="negocios.csv" />
      </div>

      <DndContext onDragEnd={onDragEnd}>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {columns.map(col => (
            <Column key={col.stage} id={`col-${col.stage}`} title={col.stage}>
              {col.data.map(d => (<CardDeal key={d.id} id={d.id} deal={d} onDelete={() => remove(d.id)} />))}
              {col.data.length===0 && <div className="text-sm text-gray-500">Vazio</div>}
            </Column>
          ))}
        </div>
      </DndContext>
    </div>
  )
}

function Column({ id, title, children }) {
  const { setNodeRef, isOver } = useDroppable({ id })
  return (
    <div ref={setNodeRef} className={`card card-pad ${isOver ? 'ring-2 ring-primary-400' : ''}`}>
      <div className="font-medium capitalize mb-2">{title}</div>
      <div className="space-y-2 min-h-[100px]">{children}</div>
    </div>
  )
}

function CardDeal({ id, deal, onDelete }) {
  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({ id })
  const style = transform ? { transform: `translate3d(${transform.x}px, ${transform.y}px, 0)` } : undefined
  return (
    <div ref={setNodeRef} {...listeners} {...attributes} style={style}
      className={`border rounded-xl p-3 bg-white dark:bg-[#100c16] ${isDragging ? 'opacity-70 ring-1 ring-primary-400' : ''}`}>
      <div className="font-semibold">{deal.title}</div>
      <div className="text-sm text-gray-600 dark:text-gray-300">R$ {Number(deal.value || 0).toFixed(2)}</div>
      <div className="flex gap-2 mt-2">
        <button onClick={onDelete} className="text-sm text-red-500 ml-auto hover:underline">Excluir</button>
      </div>
    </div>
  )
}