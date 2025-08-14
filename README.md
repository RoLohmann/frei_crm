# CRM Grátis — Max (Blog + OG/Microdata + Drag-Reorder + Position)

Inclui:
- **/blog** estático com Markdown (Vite `import.meta.glob`) e rota `/blog/:slug`.
- **Open Graph / Twitter Cards** no `index.html` e título dinâmico nas páginas.
- **Microdados (JSON-LD)** de `SoftwareApplication` na landing `/sobre`.
- **Drag-and-drop com reordenação por coluna** (campo `position` em `deals`).
- **Migration SQL** para adicionar `position` e índice.

## Como aplicar
1) Substitua sua pasta `web/` por esta.
2) Rode a migration no Supabase: arquivo `supabase/migrations_add_position.sql`.
3) Commit & push → Vercel faz deploy.

## Observações
- DnD agora reordena dentro da coluna e move entre colunas; ao soltar, persiste `stage` e `position` do item arrastado e reindexa as colunas afetadas.
- Blog usa Markdown simples (sem parser extra). O renderer cobre títulos, negrito, itálico, listas e parágrafos.