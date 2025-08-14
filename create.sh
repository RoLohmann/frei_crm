# Build the "max" package with blog (Markdown), position ordering, OG tags, microdata, and improved DnD reorder.
import os, textwrap, json, zipfile, re, datetime

root = "/mnt/data/gratis-crm-max"
paths = [
    root,
    f"{root}/web",
    f"{root}/web/public",
    f"{root}/web/src",
    f"{root}/web/src/components",
    f"{root}/web/src/lib",
    f"{root}/web/src/styles",
    f"{root}/web/src/blog",
    f"{root}/web/src/blog/posts",
    f"{root}/supabase",
]
for p in paths:
    os.makedirs(p, exist_ok=True)

# README
open(f"{root}/README.md","w").write(textwrap.dedent("""
# CRM Grátis — Max (Blog + OG/Microdata + Drag-Reorder + Position)

Inclui:
- **/blog** estático com Markdown (Vite `import.meta.glob`) e rota `/blog/:slug`.
- **Open Graph / Twitter Cards** no `index.html` e título dinâmico nas páginas.
- **Microdados (JSON-LD)** de `SoftwareApplication` na landing `/sobre`.
- **Drag-and-drop com reordenação por coluna** (campo `position` em `deals`).
- **Migration SQL** para adicionar `position` e índice.

## Como aplicar
1) Substitua sua pasta `web/` por esta.
2) Rode a migration no Supabase: arquivo `supabase/migrations_add_position.sql`.
3) Commit & push → Vercel faz deploy.

## Observações
- DnD agora reordena dentro da coluna e move entre colunas; ao soltar, persiste `stage` e `position` do item arrastado e reindexa as colunas afetadas.
- Blog usa Markdown simples (sem parser extra). O renderer cobre títulos, negrito, itálico, listas e parágrafos.
""").strip())

# Supabase migration for position
open(f"{root}/supabase/migrations_add_position.sql","w").write(textwrap.dedent("""
-- Migration: add position ordering to deals
alter table if exists public.deals
  add column if not exists position int not null default 0;

-- optional: create an index to help ordering/lookups by user+stage+position
create index if not exists idx_deals_user_stage_position
  on public.deals(user_id, stage, position);

-- backfill example (set deterministic order by created_at for existing rows)
-- update public.deals d set position = sub.rn - 1
-- from (
--   select id, row_number() over (partition by user_id, stage order by created_at asc) as rn
--   from public.deals
-- ) sub
-- where sub.id = d.id;
""").strip())

# vercel.json for SPA rewrites
open(f"{root}/web/vercel.json","w").write(json.dumps({"rewrites":[{"source":"/(.*)","destination":"/"}]}, indent=2))

# package.json
package_json = {
  "name": "crm-gratis",
  "private": True,
  "version": "0.3.0",
  "type": "module",
  "scripts": {"dev":"vite","build":"vite build","preview":"vite preview"},
  "dependencies": {
    "@supabase/supabase-js":"^2.45.4",
    "@dnd-kit/core":"^6.1.0",
    "@dnd-kit/sortable":"^7.0.2",
    "@dnd-kit/modifiers":"^6.0.1",
    "react":"^18.2.0",
    "react-dom":"^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react":"^4.2.0",
    "autoprefixer":"^10.4.16",
    "postcss":"^8.4.35",
    "tailwindcss":"^3.4.4",
    "vite":"^5.0.8"
  }
}
open(f"{root}/web/package.json","w").write(json.dumps(package_json, indent=2))

# .gitignore
open(f"{root}/web/.gitignore","w").write("node_modules\ndist\n.env\n.DS_Store\n.vercel\n.netlify\n")

# Tailwind config with dark mode
open(f"{root}/web/tailwind.config.js","w").write(textwrap.dedent("""
/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{js,jsx,md}'],
  theme: {
    extend: {
      fontFamily: { sans: ['Inter','ui-sans-serif','system-ui','Apple Color Emoji','Segoe UI Emoji'] },
      colors: {
        primary: {
          DEFAULT: '#8A05BE',
          50: '#F8ECFF',100:'#F0D9FF',200:'#DFB5FF',300:'#C88CFA',
          400:'#AB5DEB',500:'#8A05BE',600:'#7303A0',700:'#5B0283',800:'#430162',900:'#2E0A40',
        },
        accent: '#B517F4',
      },
      boxShadow: { card: '0 10px 20px rgba(138,5,190,0.08)' },
    },
  },
  plugins: [],
}
""").strip())

# PostCSS
open(f"{root}/web/postcss.config.js","w").write("export default { plugins: { tailwindcss: {}, autoprefixer: {} } }")

# index.html with OG/Twitter tags
open(f"{root}/web/index.html","w").write(textwrap.dedent("""
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CRM Grátis — leve, moderno e open source</title>
    <meta name="description" content="CRM grátis com clientes, negócios e tarefas. Visual moderno em roxo, dark mode e landing SEO." />

    <!-- Open Graph -->
    <meta property="og:type" content="website">
    <meta property="og:title" content="CRM Grátis — leve, moderno e open source">
    <meta property="og:description" content="CRM grátis com clientes, negócios e tarefas. Visual moderno em roxo, dark mode e landing SEO.">
    <meta property="og:image" content="/logo.svg">
    <meta property="og:url" content="https://seu-dominio.vercel.app/">

    <!-- Twitter -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="CRM Grátis — leve, moderno e open source">
    <meta name="twitter:description" content="CRM grátis com clientes, negócios e tarefas. Visual moderno em roxo, dark mode e landing SEO.">
    <meta name="twitter:image" content="/logo.svg">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="/logo.svg">
  </head>
  <body class="min-h-screen bg-gradient-to-b from-primary-50 to-white dark:from-[#0b0612] dark:to-[#0b0612]">
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
""").strip())

# logo.svg
open(f"{root}/web/public/logo.svg","w").write(textwrap.dedent("""
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="g" x1="0" x2="1" y1="0" y2="1">
      <stop offset="0%" stop-color="#8A05BE"/>
      <stop offset="100%" stop-color="#B517F4"/>
    </linearGradient>
  </defs>
  <rect rx="14" ry="14" x="4" y="4" width="56" height="56" fill="url(#g)" />
  <path d="M20 40c6-8 18-8 24 0" stroke="white" stroke-width="4" fill="none" stroke-linecap="round"/>
  <circle cx="24" cy="26" r="3" fill="white"/>
  <circle cx="40" cy="26" r="3" fill="white"/>
</svg>
""").strip())

# styles
open(f"{root}/web/src/styles/index.css","w").write(textwrap.dedent("""
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html, body { @apply font-sans text-gray-900 dark:text-gray-100; }
  article h1 { @apply text-3xl font-extrabold mt-6 mb-2; }
  article h2 { @apply text-2xl font-bold mt-5 mb-2; }
  article p  { @apply leading-7 my-3; }
  article ul { @apply list-disc pl-6 my-3; }
  article li { @apply my-1; }
  article a  { @apply text-primary-600 hover:underline; }
  article code { @apply bg-gray-100 dark:bg-[#100c16] rounded px-1; }
}

@layer components {
  .card { @apply bg-white dark:bg-[#14101b] rounded-2xl shadow-card border border-gray-100 dark:border-gray-800; }
  .card-pad { @apply p-5 md:p-6; }
  .input { @apply w-full border border-gray-300 dark:border-gray-700 bg-white dark:bg-[#100c16] text-gray-900 dark:text-gray-100 focus:border-primary-500 focus:ring-2 focus:ring-primary-200 dark:focus:ring-primary-700 rounded-xl px-3 py-2 outline-none transition; }
  .textarea { @apply input h-28; }
  .btn { @apply inline-flex items-center justify-center rounded-xl px-4 py-2 font-medium transition; }
  .btn-primary { @apply btn bg-primary text-white hover:bg-primary-600 shadow-sm; }
  .btn-ghost { @apply btn bg-white dark:bg-[#100c16] border border-gray-300 dark:border-gray-700 hover:border-primary-300 dark:hover:border-primary-700; }
  .badge { @apply inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium bg-primary-50 text-primary-700 dark:bg-[#1f1530] dark:text-primary-200; }
  .tab { @apply px-3 py-1 rounded-xl border border-gray-200 dark:border-gray-700; }
  .tab-active { @apply bg-primary text-white border-primary; }
}
""").strip())

# lib: supabase, theme, router
open(f"{root}/web/src/lib/supabase.js","w").write(textwrap.dedent("""
import { createClient } from '@supabase/supabase-js'
export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)
""").strip())

open(f"{root}/web/src/lib/theme.js","w").write(textwrap.dedent("""
const KEY = 'theme'
export function getTheme() {
  const pref = localStorage.getItem(KEY)
  if (pref === 'light' || pref === 'dark') return pref
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}
export function applyTheme(t) {
  const el = document.documentElement
  if (t === 'dark') el.classList.add('dark'); else el.classList.remove('dark')
  localStorage.setItem(KEY, t)
}
export function toggleTheme() {
  const next = (getTheme() === 'dark') ? 'light' : 'dark'
  applyTheme(next)
  return next
}
""").strip())

open(f"{root}/web/src/lib/router.js","w").write(textwrap.dedent("""
import { useEffect, useState } from 'react'
export function usePathname() {
  const [path, setPath] = useState(window.location.pathname)
  useEffect(() => {
    const onPop = () => setPath(window.location.pathname)
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [])
  return [path, setPath]
}
export function Link({ to, children, className }) {
  const onClick = (e) => { e.preventDefault(); window.history.pushState({}, '', to); window.dispatchEvent(new PopStateEvent('popstate')) }
  return <a href={to} onClick={onClick} className={className}>{children}</a>
}
""").strip())

# main.jsx
open(f"{root}/web/src/main.jsx","w").write(textwrap.dedent("""
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import './styles/index.css'
import { applyTheme, getTheme } from './lib/theme'
applyTheme(getTheme())
createRoot(document.getElementById('root')).render(<React.StrictMode><App /></React.StrictMode>)
""").strip())

# App.jsx includes routes for /sobre, /blog, /blog/:slug
open(f"{root}/web/src/App.jsx","w").write(textwrap.dedent("""
import React, { useEffect, useState } from 'react'
import { supabase } from './lib/supabase'
import { usePathname } from './lib/router'
import Auth from './components/Auth'
import Navbar from './components/Navbar'
import Dashboard from './components/Dashboard'
import Landing from './components/Landing'
import BlogList from './components/BlogList'
import BlogPost from './components/BlogPost'

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

  if (path === '/blog') {
    return (
      <div className="min-h-screen">
        <Navbar session={session} />
        <div className="max-w-4xl mx-auto p-4 md:p-6">
          <BlogList />
        </div>
      </div>
    )
  }

  if (path.startsWith('/blog/')) {
    const slug = decodeURIComponent(path.replace('/blog/',''))
    return (
      <div className="min-h-screen">
        <Navbar session={session} />
        <div className="max-w-3xl mx-auto p-4 md:p-6">
          <BlogPost slug={slug} />
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
""").strip())

# Navbar
open(f"{root}/web/src/components/Navbar.jsx","w").write(textwrap.dedent("""
import React, { useState } from 'react'
import { Link } from '../lib/router'
import { getTheme, toggleTheme } from '../lib/theme'

export default function Navbar({ onLogout, session }) {
  const [theme, setTheme] = useState(getTheme())
  const flip = () => setTheme(toggleTheme())
  return (
    <header className="sticky top-0 z-10 backdrop-blur bg-white/70 dark:bg-[#0e0a14]/70 border-b border-gray-100 dark:border-gray-800">
      <div className="max-w-6xl mx-auto p-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <img src="/logo.svg" className="h-8 w-8 rounded-xl" alt="logo" />
          <Link to="/" className="font-bold tracking-tight">CRM Grátis</Link>
          <Link to="/sobre" className="ml-3 text-sm text-gray-600 dark:text-gray-300 hover:text-primary-700">Sobre</Link>
          <Link to="/blog" className="ml-3 text-sm text-gray-600 dark:text-gray-300 hover:text-primary-700">Blog</Link>
        </div>
        <div className="flex items-center gap-3">
          <button onClick={flip} className="btn-ghost" title="Alternar tema">{theme==='dark'?'🌙':'☀️'}</button>
          {session ? (
            <button onClick={onLogout} className="btn-ghost">Sair</button>
          ) : (
            <Link to="/" className="btn-ghost">Entrar</Link>
          )}
        </div>
      </div>
    </header>
  )
}
""").strip())

# Auth.jsx (same as before)
open(f"{root}/web/src/components/Auth.jsx","w").write(textwrap.dedent("""
import React, { useState } from 'react'
import { supabase } from '../lib/supabase'
import { Link } from '../lib/router'

export default function Auth() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [mode, setMode] = useState('login')
  const [error, setError] = useState(null)

  const submit = async (e) => {
    e.preventDefault(); setLoading(true); setError(null)
    try {
      if (mode === 'login') {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) throw error
      } else {
        const { error } = await supabase.auth.signUp({ email, password })
        if (error) throw error
      }
    } catch (err) {
      console.error(err); setError(err?.message || 'Erro ao autenticar (veja o console).')
    } finally { setLoading(false) }
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-gradient-to-b from-primary-50 to-white dark:from-[#0b0612] dark:to-[#0b0612]">
      <div className="card w-full max-w-md">
        <div className="card-pad">
          <div className="text-center mb-6">
            <img src="/logo.svg" className="mx-auto h-12 w-12 rounded-2xl" />
            <h1 className="text-2xl font-bold mt-3">CRM Grátis</h1>
            <p className="text-gray-600 dark:text-gray-300">Cadastre-se ou entre para começar</p>
          </div>
          <form onSubmit={submit} className="space-y-3">
            <input className="input" type="email" placeholder="Seu email" value={email} onChange={e=>setEmail(e.target.value)} required />
            <input className="input" type="password" placeholder="Senha" value={password} onChange={e=>setPassword(e.target.value)} required />
            {error && <div className="text-sm text-red-500">{error}</div>}
            <button disabled={loading} className="btn-primary w-full">
              {loading ? 'Aguarde...' : mode === 'login' ? 'Entrar' : 'Criar conta'}
            </button>
          </form>
          <div className="text-center mt-4">
            {mode === 'login' ? (
              <button onClick={() => setMode('signup')} className="text-sm text-primary-700 hover:underline">Não tem conta? Criar</button>
            ) : (
              <button onClick={() => setMode('login')} className="text-sm text-primary-700 hover:underline">Já tem conta? Entrar</button>
            )}
          </div>
          <div className="text-center mt-3">
            <Link to="/sobre" className="text-xs text-gray-500 hover:underline">Saiba mais sobre o projeto</Link>
          </div>
        </div>
      </div>
    </div>
  )
}
""").strip())

# Landing.jsx with JSON-LD microdata
open(f"{root}/web/src/components/Landing.jsx","w").write(textwrap.dedent("""
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
""").strip())

# Blog data loader using import.meta.glob
open(f"{root}/web/src/blog/data.js","w").write(textwrap.dedent("""
/* Load markdown posts at build time */
const files = import.meta.glob('./posts/*.md', { eager: true, as: 'raw' })

function parse(md, filePath) {
  const slug = filePath.replace('./posts/','').replace(/\\.md$/, '')
  const lines = md.split(/\\r?\\n/)
  const titleLine = lines.find(l => /^#\\s+/.test(l)) || lines[0] || slug
  const title = titleLine.replace(/^#\\s+/, '').trim()
  // first paragraph
  let excerpt = ''
  for (const l of lines) {
    const s = l.trim()
    if (s && !s.startsWith('#') && !s.startsWith('-')) { excerpt = s; break }
  }
  return { slug, title, excerpt, content: md }
}

export const posts = Object.entries(files).map(([path, md]) => parse(md, path))
  .sort((a,b) => a.slug < b.slug ? 1 : -1) // sort desc by filename (use date prefix)
  
export function getPost(slug) {
  return posts.find(p => p.slug === slug)
}
""").strip())

# BlogList component
open(f"{root}/web/src/components/BlogList.jsx","w").write(textwrap.dedent("""
import React, { useEffect } from 'react'
import { Link } from '../lib/router'
import { posts } from '../blog/data'

export default function BlogList() {
  useEffect(() => { document.title = 'CRM Grátis — Blog' }, [])
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-extrabold">Blog</h1>
      <div className="grid grid-cols-1 gap-4">
        {posts.map(p => (
          <article key={p.slug} className="card card-pad">
            <h2 className="text-xl font-semibold"><Link to={`/blog/${p.slug}`}>{p.title}</Link></h2>
            <p className="text-gray-600 dark:text-gray-300 mt-1">{p.excerpt}</p>
            <div className="mt-3">
              <Link to={`/blog/${p.slug}`} className="btn-ghost">Ler mais</Link>
            </div>
          </article>
        ))}
      </div>
    </div>
  )
}
""").strip())

# Simple markdown to HTML converter
open(f"{root}/web/src/blog/markdown.js","w").write(textwrap.dedent("""
export function mdToHtml(md) {
  let html = md
  // escape basic
  html = html.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
  // headings
  html = html.replace(/^###\\s+(.+)$/gm, '<h3>$1</h3>')
  html = html.replace(/^##\\s+(.+)$/gm, '<h2>$1</h2>')
  html = html.replace(/^#\\s+(.+)$/gm, '<h1>$1</h1>')
  // bold/italic
  html = html.replace(/\\*\\*(.+?)\\*\\*/g, '<strong>$1</strong>')
  html = html.replace(/\\*(.+?)\\*/g, '<em>$1</em>')
  // lists
  html = html.replace(/^(?:-\\s+.+\\n?)+/gm, (block) => {
    const items = block.trim().split(/\\n/).map(l => l.replace(/^-\\s+/,'')).map(i=>`<li>${i}</li>`).join('')
    return `<ul>${items}</ul>`
  })
  // paragraphs (lines that aren't tags)
  html = html.replace(/^(?!<h\\d>|<ul>|<li>|<\\/li>|<\\/ul>)(.+)$/gm, (m, p1)=>{
    if (!p1.trim()) return ''
    return `<p>${p1}</p>`
  })
  return html
}
""").strip())

# BlogPost component
open(f"{root}/web/src/components/BlogPost.jsx","w").write(textwrap.dedent("""
import React, { useEffect } from 'react'
import { getPost } from '../blog/data'
import { mdToHtml } from '../blog/markdown'

export default function BlogPost({ slug }) {
  const post = getPost(slug)
  useEffect(() => { document.title = post ? `${post.title} — CRM Grátis` : 'Post não encontrado' }, [slug])
  if (!post) return <div className="card card-pad">Post não encontrado.</div>
  const html = mdToHtml(post.content)
  return (
    <article className="card card-pad">
      <div dangerouslySetInnerHTML={{__html: html}} />
    </article>
  )
}
""").strip())

# Dashboard, Clients, Deals, Tasks with position changes
open(f"{root}/web/src/components/Dashboard.jsx","w").write(textwrap.dedent("""
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
    <div className="card card-pad">
      <div className="text-sm text-gray-500 dark:text-gray-400">{title}</div>
      <div className="text-3xl font-bold mt-1">{value}</div>
    </div>
  )
}
function TabButton({ active, children, ...props }) {
  return <button {...props} className={`tab ${active ? 'tab-active' : 'bg-white dark:bg-[#100c16]'}`}>{children}</button>
}
""").strip())

# Clients JSX similar to previous (unchanged except classes)
open(f"{root}/web/src/components/Clients.jsx","w").write(textwrap.dedent("""
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
""").strip())

# Export CSV
open(f"{root}/web/src/components/ExportCSVButton.jsx","w").write(textwrap.dedent("""
import React from 'react'
function toCSV(rows){ if(!rows||rows.length===0) return ''; const headers=Object.keys(rows[0]); const lines=[headers.join(',')]; for(const row of rows){ const vals=headers.map(h=>{ const v=row[h]??''; const s=String(v).replace(/"/g,'""'); return `"${s}"`;}); lines.push(vals.join(','))} return lines.join('\\n') }
export default function ExportCSVButton({ data, filename='export.csv' }){
  const handle=()=>{ if(!data||data.length===0) return; const csv=toCSV(data); const blob=new Blob([csv],{type:'text/csv;charset=utf-8;'}); const url=URL.createObjectURL(blob); const a=document.createElement('a'); a.href=url;a.download=filename;a.click();URL.revokeObjectURL(url) }
  return <button onClick={handle} className="btn-ghost">Exportar CSV</button>
}
""").strip())

# Deals with DnD reordering and persistence (position)
open(f"{root}/web/src/components/Deals.jsx","w").write(textwrap.dedent("""
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
""").strip())

# Tasks.jsx (unchanged from previous nuplus)
open(f"{root}/web/src/components/Tasks.jsx","w").write(textwrap.dedent("""
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
    setClients(c || []); setDeals(d || [])
  }
  useEffect(() => { load(); loadRefs() }, [])

  const toggle = async (id, status) => { await supabase.from('tasks').update({ status }).eq('id', id); load() }
  const remove = async (id) => { await supabase.from('tasks').delete().eq('id', id); load() }
  const save = async (e) => {
    e.preventDefault()
    await supabase.from('tasks').insert([{ ...form, user_id }])
    setForm({ title: '', due_date: '', client_id: null, deal_id: null }); load()
  }

  return (
    <div className="space-y-4">
      <div className="card card-pad">
        <h3 className="font-semibold mb-2">Nova tarefa</h3>
        <form onSubmit={save} className="grid grid-cols-1 md:grid-cols-5 gap-2">
          <input className="input md:col-span-2" placeholder="Título" value={form.title} onChange={e=>setForm({...form, title:e.target.value})} required />
          <input className="input" type="date" value={form.due_date} onChange={e=>setForm({...form, due_date:e.target.value})} />
          <select className="input" value={form.client_id || ''} onChange={e=>setForm({...form, client_id:e.target.value || null})}>
            <option value="">Cliente</option>
            {clients.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
          <select className="input" value={form.deal_id || ''} onChange={e=>setForm({...form, deal_id:e.target.value || null})}>
            <option value="">Negócio</option>
            {deals.map(d => <option key={d.id} value={d.id}>{d.title}</option>)}
          </select>
          <button className="btn-primary">Salvar</button>
        </form>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="card card-pad">
          <div className="font-medium mb-2">Pendentes</div>
          <ul className="space-y-2">
            {items.filter(i=>i.status==='pendente').map(it => (
              <li key={it.id} className="border rounded-xl p-3 bg-white dark:bg-[#100c16]">
                <div className="font-semibold">{it.title}</div>
                <div className="text-xs text-gray-600 dark:text-gray-300">Vencimento: {it.due_date || '-'}</div>
                <div className="flex gap-2 mt-2">
                  <button onClick={()=>toggle(it.id,'concluida')} className="btn-ghost">Concluir</button>
                  <button onClick={()=>remove(it.id)} className="text-sm text-red-500 ml-auto hover:underline">Excluir</button>
                </div>
              </li>
            ))}
            {items.filter(i=>i.status==='pendente').length===0 && <div className="text-sm text-gray-500">Sem tarefas pendentes</div>}
          </ul>
        </div>
        <div className="card card-pad">
          <div className="font-medium mb-2">Concluídas</div>
          <ul className="space-y-2">
            {items.filter(i=>i.status==='concluida').map(it => (
              <li key={it.id} className="border rounded-xl p-3 bg-white dark:bg-[#100c16]">
                <div className="font-semibold">{it.title}</div>
                <div className="text-xs text-gray-600 dark:text-gray-300">Vencimento: {it.due_date || '-'}</div>
                <div className="flex gap-2 mt-2">
                  <button onClick={()=>toggle(it.id,'pendente')} className="btn-ghost">Reabrir</button>
                  <button onClick={()=>remove(it.id)} className="text-sm text-red-500 ml-auto hover:underline">Excluir</button>
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
""").strip())

# Sample blog posts
open(f"{root}/web/src/blog/posts/2025-08-01-crm-gratis.md","w").write(textwrap.dedent("""
# CRM grátis: como lançar seu primeiro CRM sem gastar

Montar um CRM do zero é possível usando camadas **grátis** de serviços como Vercel (front) e Supabase (banco + auth).
- Foque no valor: clientes, negócios, tarefas.
- Garanta segurança com *Row Level Security*.
- Priorize SEO: tenha uma landing e blog.

Para monetizar, ofereça hospedagem gerenciada por um valor baixo e funcionalidades premium sob demanda.
""").strip())

open(f"{root}/web/src/blog/posts/2025-08-02-planilha-vs-crm.md","w").write(textwrap.dedent("""
# Planilha vs CRM: quando migrar?

Planilhas são ótimas para começar, mas escalam mal quando existe **time**, **pipeline** e **processo**.
- Histórico e atividades ficam espalhados.
- Falta controle de acesso.
- Relatórios exigem manutenção manual.

Um CRM simples resolve esses pontos com pouco esforço e melhora a taxa de conversão do funil.
""").strip())

# Zip
zip_path = "/mnt/data/gratis-crm-max.zip"
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as z:
    for folder_path, dirs, files in os.walk(root):
        for file in files:
            full = os.path.join(folder_path, file)
            rel = os.path.relpath(full, "/mnt/data")
            z.write(full, rel)

zip_path
