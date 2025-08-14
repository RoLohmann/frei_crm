import React from 'react'
import { Link } from '../lib/router'

export default function Landing({ loggedIn }) {
  return (
    <div className="space-y-12">
      <section className="card card-pad text-center">
        <div className="mx-auto h-16 w-16 rounded-3xl bg-gradient-to-br from-primary to-accent"></div>
        <h1 className="text-3xl font-extrabold mt-4">CRM Grátis — leve e open source</h1>
        <p className="text-gray-600 dark:text-gray-300 mt-2 max-w-2xl mx-auto">
          Cadastre clientes, gerencie negócios em pipeline e acompanhe tarefas. Sem custos de hospedagem: React + Supabase + Vercel.
        </p>
        <div className="mt-6 flex justify-center gap-3">
          {loggedIn ? <Link to="/" className="btn-primary">Ir para o app</Link> : <Link to="/" className="btn-primary">Começar grátis</Link>}
          <a href="https://github.com" target="_blank" className="btn-ghost">Ver código</a>
        </div>
      </section>

      <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {[
          ['Clientes', 'Cadastro rápido, filtros e exportação CSV.'],
          ['Negócios', 'Pipeline Kanban com drag-and-drop entre estágios.'],
          ['Tarefas', 'Pendentes e concluídas com relacionamentos.'],
        ].map(([title,desc]) => (
          <div key={title} className="card card-pad">
            <div className="badge">{title}</div>
            <p className="mt-2 text-gray-700 dark:text-gray-300">{desc}</p>
          </div>
        ))}
      </section>

      <section className="card card-pad">
        <h2 className="text-xl font-semibold">SEO “CRM grátis”</h2>
        <ul className="list-disc pl-5 text-gray-700 dark:text-gray-300 mt-2 space-y-1">
          <li>Landing otimizada com palavras-chave.</li>
          <li>Blog posts: “Como escolher um CRM grátis”, “Planilha vs CRM”.</li>
          <li>Publicar em Product Hunt, Indie Hackers e Reddit.</li>
        </ul>
      </section>
    </div>
  )
}