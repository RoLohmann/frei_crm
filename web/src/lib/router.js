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