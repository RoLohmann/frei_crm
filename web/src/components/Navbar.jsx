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