import React, { useEffect } from 'react'
import { Link } from '../lib/router'

export default function Landing({ loggedIn }) {
  useEffect(() => { document.title = 'CRM Grátis — Sobre' }, [])
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'CRM Grátis',
    applicationCategory: 'BusinessApplication',
    operatingSystem: 'Web',
    offers: { '@type':'Offer', price:'0', priceCurrency:'BRL' },
    description: 'CRM grátis e open source: clientes, negócios e tarefas.',
    url: typeof window !== 'undefined' ? window.location.origin : 'https://example.com',
    creator: { '@type':'Organization', name: 'CRM Grátis' }
  }
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
        <script type="application/ld+json" dangerouslySetInnerHTML={{__html: JSON.stringify(jsonLd)}} />
      </section>

      <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {[
          ['Clientes', 'Cadastro rápido, filtros e exportação CSV.'],
          ['Negócios', 'Pipeline Kanban com drag-and-drop e reordenação.'],
          ['Tarefas', 'Pendentes e concluídas com relacionamentos.'],
        ].map(([title,desc]) => (
          <div key={title} className="card card-pad">
            <div className="badge">{title}</div>
            <p className="mt-2 text-gray-700 dark:text-gray-300">{desc}</p>
          </div>
        ))}
      </section>
    </div>
  )
}