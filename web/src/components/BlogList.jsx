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