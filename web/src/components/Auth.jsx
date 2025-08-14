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