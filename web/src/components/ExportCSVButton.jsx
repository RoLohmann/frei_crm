import React from 'react'
function toCSV(rows){ if(!rows||rows.length===0) return ''; const headers=Object.keys(rows[0]); const lines=[headers.join(',')]; for(const row of rows){ const vals=headers.map(h=>{ const v=row[h]??''; const s=String(v).replace(/"/g,'""'); return `"${s}"`;}); lines.push(vals.join(','))} return lines.join('\n') }
export default function ExportCSVButton({ data, filename='export.csv' }){
  const handle=()=>{ if(!data||data.length===0) return; const csv=toCSV(data); const blob=new Blob([csv],{type:'text/csv;charset=utf-8;'}); const url=URL.createObjectURL(blob); const a=document.createElement('a'); a.href=url;a.download=filename;a.click();URL.revokeObjectURL(url) }
  return <button onClick={handle} className="btn-ghost">Exportar CSV</button>
}