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