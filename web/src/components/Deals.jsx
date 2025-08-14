import React, { useEffect, useMemo, useState } from 'react'
import { supabase } from '../lib/supabase'
import ExportCSVButton from './ExportCSVButton'
import { DndContext, closestCenter } from '@dnd-kit/core'
import { arrayMove, SortableContext, useSortable, verticalListSortingStrategy } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'

const STAGES = ['novo', 'negociacao', 'fechado']

export default function Deals({ session }) {
  const user_id = session.user.id
  const [items, setItems] = useState([])
  const [form, setForm] = useState({ title: '', value: 0, client_id: null })
  const [clients, setClients] = useState([])

  const columns = useMemo(() => {
    const byStage = {}
    for (const s of STAGES) byStage[s] = []
    for (const d of items) {
      byStage[d.stage]?.push(d)
    }
    for (const s of STAGES) {
      byStage[s].sort((a,b)=> (a.position ?? 0) - (b.position ?? 0))
    }
    return byStage
  }, [items])

  const load = async () => {
    const { data } = await supabase.from('deals')
      .select('*')
      .eq('user_id', user_id)
      .order('stage', { ascending: true })
      .order('position', { ascending: true })
      .order('created_at', { ascending: true })
    setItems(data || [])
  }
  const loadClients = async () => {
    const { data } = await supabase.from('clients').select('id,name').eq('user_id', user_id).order('name')
    setClients(data || [])
  }
  useEffect(() => { load(); loadClients() }, [])

  const nextPosition = (stage) => {
    const max = Math.max(-1, ...columns[stage].map(d => d.position || 0))
    return max + 1
  }

  const save = async (e) => {
    e.preventDefault()
    const position = nextPosition('novo') // novo é o default
    await supabase.from('deals').insert([{ ...form, user_id, position }])
    setForm({ title: '', value: 0, client_id: null })
    load()
  }
  const remove = async (id) => { await supabase.from('deals').delete().eq('id', id); load() }

  const onDragEnd = async ({ active, over }) => {
    if (!over) return
    const activeId = active.id
    const overId = over.id
    // determine source & target columns
    const all = [...items]
    const source = all.find(d => d.id === activeId)
    if (!source) return
    const sourceStage = source.stage

    // If over is a column container, its id will be 'col-<stage>'
    let targetStage = sourceStage
    let targetIndex = null

    if (typeof overId === 'string' && overId.startsWith('col-')) {
      targetStage = overId.replace('col-','')
      targetIndex = columns[targetStage].length // append to end
    } else {
      const targetItem = all.find(d => d.id === overId)
      if (targetItem) {
        targetStage = targetItem.stage
        // index within target column
        const list = columns[targetStage].map(d => d.id)
        targetIndex = list.indexOf(targetItem.id)
      }
    }

    // Build new state: remove from source list and insert at targetIndex
    const newColumns = Object.fromEntries(STAGES.map(s => [s, columns[s].map(d => ({...d}))]))
    // remove source
    const srcList = newColumns[sourceStage]
    const srcIdx = srcList.findIndex(d => d.id === activeId)
    const [moved] = srcList.splice(srcIdx, 1)
    moved.stage = targetStage

    const tgtList = newColumns[targetStage]
    if (targetIndex == null || targetIndex > tgtList.length) targetIndex = tgtList.length
    tgtList.splice(targetIndex, 0, moved)

    // Reindex positions
    newColumns[sourceStage] = newColumns[sourceStage].map((d, i) => ({...d, position: i}))
    newColumns[targetStage] = newColumns[targetStage].map((d, i) => ({...d, position: i}))

    // Flatten to items state
    const updated = STAGES.flatMap(s => newColumns[s])
    setItems(updated)

    // Persist only changed rows
    const changed = []
    for (const d of updated) {
      const old = items.find(x => x.id === d.id)
      if (!old || old.stage !== d.stage || old.position !== d.position) {
        changed.push({ id: d.id, stage: d.stage, position: d.position })
      }
    }
    if (changed.length) {
      await supabase.from('deals').upsert(changed) // RLS garante escopo do usuário
      load()
    }
  }

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

      <DndContext collisionDetection={closestCenter} onDragEnd={onDragEnd}>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {STAGES.map(stage => (
            <div key={stage} id={`col-${stage}`} className="card card-pad">
              <div className="font-medium capitalize mb-2">{stage}</div>
              <SortableContext items={columns[stage].map(d=>d.id)} strategy={verticalListSortingStrategy}>
                <div className="space-y-2 min-h-[100px]">
                  {columns[stage].map(d => (
                    <SortableDeal key={d.id} id={d.id} deal={d} onDelete={async()=>{ await supabase.from('deals').delete().eq('id', d.id); load() }} />
                  ))}
                  {columns[stage].length===0 && <div className="text-sm text-gray-500">Vazio</div>}
                </div>
              </SortableContext>
            </div>
          ))}
        </div>
      </DndContext>
    </div>
  )
}

function SortableDeal({ id, deal, onDelete }) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id })
  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  }
  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners}
      className={`border rounded-xl p-3 bg-white dark:bg-[#100c16] ${isDragging ? 'opacity-70 ring-1 ring-primary-400' : ''}`}>
      <div className="font-semibold">{deal.title}</div>
      <div className="text-sm text-gray-600 dark:text-gray-300">R$ {Number(deal.value || 0).toFixed(2)}</div>
      <div className="flex gap-2 mt-2">
        <button onClick={onDelete} className="text-sm text-red-500 ml-auto hover:underline">Excluir</button>
      </div>
    </div>
  )
}