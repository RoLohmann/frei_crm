# CRM Grátis — React + Supabase (0 custo)

Um CRM leve 100% gratuito, com **login**, **clientes**, **negócios (pipeline)** e **tarefas**. Sem backend próprio: usa **Supabase** (PostgreSQL + Auth) no free tier e deploy do front no **Vercel** (também free).

## ✨ Funcionalidades
- Autenticação (email/senha) via Supabase Auth
- CRUD de **Clientes**
- CRUD de **Negócios** com **pipeline** (Novo → Em negociação → Fechado)
- CRUD de **Tarefas** (pendente/concluída), vinculadas a clientes/negócios
- Busca e filtros básicos
- Exportação CSV (Clientes e Negócios)
- UI responsiva com Tailwind

## 🧰 Stack
- **Frontend**: React + Vite + Tailwind
- **Banco/Autenticação**: Supabase
- **Hospedagem**: Vercel (front)

> Tudo pensado para **zero custo** no início (free tiers).

---

## 🚀 Deploy em 10 passos (grátis)

### 1) Criar projeto no Supabase (free)
- Acesse https://supabase.com/ e crie uma conta.
- Crie um **novo projeto**. Anote o **Project URL** e a **anon public key** (Config → API).

### 2) Executar o SQL de schema e políticas
- No painel do Supabase, vá em **SQL Editor**.
- Copie o conteúdo de `supabase/schema_and_policies.sql` deste repo e **execute**.

### 3) Configurar variáveis do ambiente (frontend)
No Vercel ou local (arquivo `.env` na pasta `web`), defina:
```
VITE_SUPABASE_URL=coloque_aqui_o_project_url
VITE_SUPABASE_ANON_KEY=cole_aqui_a_anon_public_key
```

### 4) Rodar localmente
```bash
cd web
npm install
npm run dev
```
Abrir o endereço indicado (ex.: `http://localhost:5173`).

### 5) Deploy no Vercel (free)
- Faça login em https://vercel.com/ e **Importe o repositório do GitHub**.
- Em **Environment Variables** do projeto Vercel, cadastre:
  - `VITE_SUPABASE_URL`
  - `VITE_SUPABASE_ANON_KEY`
- Deploy.

> Dica: cada conta Vercel tem build/time quotas no free tier. Para um MVP, sobra.

---

## 🗃️ Estrutura do projeto

```
gratis-crm/
├─ LICENSE
├─ README.md
├─ supabase/
│  └─ schema_and_policies.sql
└─ web/
   ├─ index.html
   ├─ package.json
   ├─ postcss.config.js
   ├─ tailwind.config.js
   ├─ vite.config.js
   ├─ .gitignore
   └─ src/
      ├─ main.jsx
      ├─ App.jsx
      ├─ styles/index.css
      ├─ lib/supabase.js
      └─ components/
         ├─ Auth.jsx
         ├─ Navbar.jsx
         ├─ Dashboard.jsx
         ├─ Clients.jsx
         ├─ Deals.jsx
         ├─ Tasks.jsx
         ├─ ExportCSVButton.jsx
         └─ Kanban.jsx
```

---

## 🔐 Segurança & RLS
As **Row Level Policies** garantem que cada usuário só veja os próprios dados (`user_id = auth.uid()`). Não há backend custom — menos custo e menos superfície de ataque.

---

## 💡 Roadmap (extras)
- Convidar membros da mesma organização (multi-user por org)
- Webhooks/Edge Functions para automações
- Integração com email/WhatsApp (opcional e pago)
- Relatórios / dashboards
- Plano pago hospedado por você (multi-tenant)

---

## 📣 SEO “CRM grátis”
- Landing page com termos “CRM grátis”, “CRM open source”, “CRM leve”
- Escrever posts “Como escolher um CRM grátis”, “Planilha vs CRM”, etc.
- Publicar no Product Hunt/Indie Hackers/Reddit

---

## 📝 Licença
MIT — use, modifique e distribua livremente.