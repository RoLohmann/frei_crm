import React, { useState } from 'react'
import { supabase } from '../lib/supabase'

export default function Auth() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [mode, setMode] = useState('login')
  const [error, setError] = useState(null)

  const submit = async (e) => {
    e.preventDefault()
    setLoading(true); setError(null)
    try {
      if (mode === 'login') {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) throw error
      } else {
        const { error } = await supabase.auth.signUp({ email, password })
        if (error) throw error
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-4">
      <div className="w-full max-w-md bg-white shadow rounded-2xl p-6">
        <h1 className="text-2xl font-bold mb-2 text-center">CRM Grátis</h1>
        <p className="text-gray-600 text-center mb-6">Cadastre-se ou entre para começar</p>
        <form onSubmit={submit} className="space-y-3">
          <input className="w-full border rounded-lg p-2" type="email" placeholder="Seu email" value={email} onChange={e => setEmail(e.target.value)} required />
          <input className="w-full border rounded-lg p-2" type="password" placeholder="Senha" value={password} onChange={e => setPassword(e.target.value)} required />
          {error && <div className="text-sm text-red-600">{error}</div>}
          <button disabled={loading} className="w-full rounded-lg p-2 bg-black text-white">
            {loading ? 'Aguarde...' : mode === 'login' ? 'Entrar' : 'Criar conta'}
          </button>
        </form>
        <div className="text-center mt-4">
          {mode === 'login' ? (
            <button onClick={() => setMode('signup')} className="text-sm text-blue-600">Não tem conta? Criar</button>
          ) : (
            <button onClick={() => setMode('login')} className="text-sm text-blue-600">Já tem conta? Entrar</button>
          )}
        </div>
      </div>
    </div>
  )
}