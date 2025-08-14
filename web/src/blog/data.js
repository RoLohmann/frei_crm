/* Load markdown posts at build time */
const files = import.meta.glob('./posts/*.md', { eager: true, as: 'raw' })

function parse(md, filePath) {
  const slug = filePath.replace('./posts/','').replace(/\.md$/, '')
  const lines = md.split(/\r?\n/)
  const titleLine = lines.find(l => /^#\s+/.test(l)) || lines[0] || slug
  const title = titleLine.replace(/^#\s+/, '').trim()
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