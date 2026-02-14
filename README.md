# Task Manager API

API REST para gerenciamento de tarefas (tasks) construída com **Ruby on Rails 7.1**.

Uma aplicação backend robusta que demonstra as melhores práticas de desenvolvimento com Rails, incluindo validações, testes automatizados, paginação, filtros avançados e dockerização completa.

## 📋 Objetivo

Desenvolver uma API RESTful para gerenciamento de tarefas com:

- ✅ CRUD completo de tarefas
- 🔍 Filtros por status e data de vencimento
- 📄 Paginação de resultados
- ✔️ Validações rigorosas de dados
- 🧪 Suite completa de testes automatizados (RSpec)
- 🐳 Suporte a Docker para containerização
- ⚡ Ordenação automática por due_date

## 🛠️ Stack de Tecnologias

### Backend

- **Ruby** 3.3.0
- **Rails** 7.1.3 (API-only mode)
- **PostgreSQL** 12+ (banco de dados)
- **Puma** (servidor web)

### Testes

- **RSpec** (framework de testes)
- **FactoryBot** (fixtures de dados)

### DevOps

- **Docker** & **Docker Compose**
- **Bundler** (gerenciador de gems)

## ✅ Conformidade com Requisitos

### Requisitos Obrigatórios

| Funcionalidade | Status | Detalhe |
|---|---|---|
| POST /tasks | ✅ | Criar tarefa com validações |
| GET /tasks | ✅ | Listar com filtros e paginação |
| GET /tasks/:id | ✅ | Detalhar tarefa específica |
| PATCH /tasks/:id | ✅ | Atualizar com validações |
| DELETE /tasks/:id | ✅ | Remover tarefa |
| Validar title (3+ chars) | ✅ | `length: { minimum: 3 }` |
| Validar status (pending/doing/done) | ✅ | `inclusion: { in: STATUSES }` |
| Filtro por status | ✅ | `?status=pending` |
| Filtro por due_date | ✅ | `?due_date=2026-02-20` |
| HTTP 422 com errors | ✅ | `{ "errors": [...] }` |

### Diferenciais Implementados

| Funcionalidade | Status | Detalhe |
|---|---|---|
| Paginação | ✅ | `page` e `per_page` |
| Ordenação | ✅ | Ordem ascendente por due_date |
| Testes RSpec | ✅ | 16+ casos cobrindo CRUD + validações |

## 📦 Instalação e Configuração

### Pré-requisitos

- **Ruby 3.3.0** (usar [rbenv](https://github.com/rbenv/rbenv) ou [rvm](https://rvm.io/))
- **PostgreSQL 12+**
- **Bundle**
- **Docker** (opcional, para containerização)

### 1. Clonar o repositório

```bash
git clone <repository-url>
cd task_manager_api
```

### 2. Instalar dependências

```bash
bundle install
```

### 3. Configurar banco de dados

```bash
# Criar banco de dados
rails db:create

# Executar migrations
rails db:migrate

# (Opcional) Carregar seeds
rails db:seed
```

### 4. Iniciar o servidor

```bash
bin/rails server
```

A API estará disponível em **http://localhost:3000**

### Setup Automático (Recomendado)

```bash
bin/setup
```

Este script irá:

1. Instalar dependências (gems)
2. Preparar o banco de dados
3. Limpar logs e temp files
4. Reiniciar o servidor

## 🐳 Rodando com Docker

### Build da imagem

```bash
docker build -t task_manager_api .
```

### Executar container

```bash
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://postgres:postgres@host.docker.internal:5432/task_manager_api_development" \
  task_manager_api
```

## 🧪 Testes

### Executar toda suite de testes

```bash
bundle exec rspec
```

### Executar testes de um arquivo específico

```bash
bundle exec rspec spec/requests/api/tasks_spec.rb
```

### Executar testes com output detalhado

```bash
bundle exec rspec --format documentation
```

### Executar testes com verbose (mais detalhado)

```bash
bundle exec rspec --format documentation --color
```

### Cobertura de Testes

**16+ casos de teste implementados:**

- ✅ GET /tasks (listar, filtros, paginação, ordenação)
- ✅ GET /tasks/:id (sucesso e erro)
- ✅ POST /tasks (criação, validações específicas)
- ✅ PATCH /tasks/:id (atualização, validações)
- ✅ DELETE /tasks/:id (deleção, erro)

## 📚 Endpoints da API

### 1. Listar Tarefas

**Requisição:**

```bash
GET /api/tasks
```

**Parâmetros de query (todos opcionais):**

- `status` - Filtrar por status (pending, doing, done)
- `due_date` - Filtrar por data (YYYY-MM-DD)
- `page` - Número da página (padrão: 1)
- `per_page` - Itens por página (padrão: 10)

**Exemplo com filtros:**

```bash
curl "http://localhost:3000/api/tasks?status=pending&page=1&per_page=5"
```

**Resposta de Sucesso (200 OK):**

```json
{
  "data": [
    {
      "id": 1,
      "title": "Implementar autenticação",
      "description": "Adicionar JWT authentication",
      "status": "pending",
      "due_date": "2026-02-28",
      "created_at": "2026-02-14T10:30:00.000Z",
      "updated_at": "2026-02-14T10:30:00.000Z"
    }
  ],
  "status": 200,
  "total_records": 1,
  "per_page": 10,
  "page": 1
}
```

---

### 2. Obter Tarefa Específica

**Requisição:**

```bash
GET /api/tasks/:id
```

**Resposta de Sucesso (200 OK):**

```json
{
  "data": {
    "id": 1,
    "title": "Implementar autenticação",
    "description": "Adicionar JWT authentication",
    "status": "pending",
    "due_date": "2026-02-28",
    "created_at": "2026-02-14T10:30:00.000Z",
    "updated_at": "2026-02-14T10:30:00.000Z"
  },
  "status": 200
}
```

**Resposta de Erro (404 Not Found):**

```json
{
  "errors": ["Task not found"]
}
```

---

### 3. Criar Tarefa

**Requisição:**

```bash
POST /api/tasks
Content-Type: application/json

{
  "task": {
    "title": "Implementar autenticação",
    "description": "Adicionar JWT authentication",
    "status": "pending",
    "due_date": "2026-02-28"
  }
}
```

**Resposta de Sucesso (201 Created):**

```json
{
  "data": {
    "id": 1,
    "title": "Implementar autenticação",
    "status": "pending",
    "created_at": "2026-02-14T10:30:00.000Z",
    "updated_at": "2026-02-14T10:30:00.000Z"
  },
  "status": 201
}
```

**Resposta de Erro - Título muito curto (422):**

```json
{
  "errors": ["Title is too short (minimum is 3 characters)"]
}
```

**Resposta de Erro - Status inválido (422):**

```json
{
  "errors": ["Status is not included in the list"]
}
```

---

### 4. Atualizar Tarefa

**Requisição:**

```bash
PATCH /api/tasks/:id

{
  "task": {
    "status": "done"
  }
}
```

**Resposta de Sucesso (200 OK):**

```json
{
  "data": {
    "id": 1,
    "status": "done",
    "updated_at": "2026-02-14T12:00:00.000Z"
  },
  "status": 200
}
```

---

### 5. Deletar Tarefa

**Requisição:**

```bash
DELETE /api/tasks/:id
```

**Resposta de Sucesso (200 OK):**

```json
{
  "message": "Task deleted",
  "status": 200
}
```

---

## 📊 Modelo de Dados

### Task

| Campo | Tipo | Validações |
|-------|------|-----------|
| `id` | Integer | PK |
| `title` | String | Obrigatório, min 3 caracteres |
| `description` | Text | Opcional |
| `status` | String | Obrigatório, valores: pending, doing, done |
| `due_date` | Date | Opcional |
| `created_at` | DateTime | Auto |
| `updated_at` | DateTime | Auto |

---

## 🚀 Desenvolvimento

### Estrutura de Diretórios

```
app/
├── controllers/
│   └── api/tasks_controller.rb      # Lógica dos endpoints
├── models/
│   └── task.rb                      # Modelo + Validações
config/
├── routes.rb                         # Rotas da API
db/
├── migrate/
│   └── 20260213200508_create_tasks.rb
spec/
├── factories/tasks.rb                # Factory para testes
└── requests/api/tasks_spec.rb       # Testes
```

---

## 📄 Licença

MIT
