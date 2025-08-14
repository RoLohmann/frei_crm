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