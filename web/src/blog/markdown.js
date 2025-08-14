export function mdToHtml(md) {
  let html = md
  // escape basic
  html = html.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
  // headings
  html = html.replace(/^###\s+(.+)$/gm, '<h3>$1</h3>')
  html = html.replace(/^##\s+(.+)$/gm, '<h2>$1</h2>')
  html = html.replace(/^#\s+(.+)$/gm, '<h1>$1</h1>')
  // bold/italic
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
  html = html.replace(/\*(.+?)\*/g, '<em>$1</em>')
  // lists
  html = html.replace(/^(?:-\s+.+\n?)+/gm, (block) => {
    const items = block.trim().split(/\n/).map(l => l.replace(/^-\s+/,'')).map(i=>`<li>${i}</li>`).join('')
    return `<ul>${items}</ul>`
  })
  // paragraphs (lines that aren't tags)
  html = html.replace(/^(?!<h\d>|<ul>|<li>|<\/li>|<\/ul>)(.+)$/gm, (m, p1)=>{
    if (!p1.trim()) return ''
    return `<p>${p1}</p>`
  })
  return html
}