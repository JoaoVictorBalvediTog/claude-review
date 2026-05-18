# PR Reviewer com Claude

Runner local para revisar pull requests no GitHub usando contexto da PR, Jira, arquivos alterados, diff e arquivos opcionais de contexto da aplicação.

## Comandos

```bash
./review-pr.sh review owner/repo 123
./review-pr.sh comment review owner/repo 123
./review-pr.sh owner/repo 123
```

Atalhos opcionais:

```bash
ln -sf "$PWD/review-pr.sh" /usr/local/bin/review
ln -sf "$PWD/review-pr.sh" /usr/local/bin/comment
```

Com atalhos:

```bash
review owner/repo 123
comment review owner/repo 123
```

## Modos

- `review`: gera preview local e não posta nada no GitHub.
- `comment review`: gera a review e posta no GitHub.
- modo legado `./review-pr.sh owner/repo 123`: mantém compatibilidade e não posta por padrão.

## Estrutura

```text
review-pr.sh
prompts/review_system_prompt.md
py/parse_review_result.py
.env.example
outputs/
```

Jira é opcional. Quando `JIRA_BASE_URL`, `JIRA_EMAIL` e `JIRA_API_TOKEN` existem, o script tenta buscar a issue detectada na PR. Caso contrário, inclui no contexto que Jira não foi buscado.

## Outputs

Os arquivos ficam em:

```text
outputs/<owner__repo>/
```

Principais arquivos:

- `pr-<n>-review.md`: preview humano.
- `pr-<n>-review-input.md`: contexto completo enviado ao Claude.
- `pr-<n>-inline-comments.json`: comentários normalizados.
- `pr-<n>-inline-review-payload.json`: payload enviado ao GitHub.
- `pr-<n>-inline-review-response.json`: resposta do GitHub quando houver postagem.
- `pr-<n>-usage.txt`: uso e diagnóstico.
- `pr-<n>-review-status.txt`: `accepted` ou `comments`.

## Validações locais

```bash
bash -n review-pr.sh
python3 -m py_compile py/parse_review_result.py
```
