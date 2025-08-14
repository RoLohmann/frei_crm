import React from 'react'

export default function Navbar({ onLogout }) {
  return (
    <header className="bg-white border-b">
      <div className="max-w-6xl mx-auto p-4 flex items-center justify-between">
        <div className="font-bold">CRM Grátis</div>
        <div className="flex items-center gap-4">
          <a href="https://github.com" target="_blank" className="text-sm text-gray-600">GitHub</a>
          <button onClick={onLogout} className="text-sm bg-black text-white px-3 py-1 rounded-lg">Sair</button>
        </div>
      </div>
    </header>
  )
}