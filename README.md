# Linux Automation Scripts

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Bash](https://img.shields.io/badge/bash-4.0+-green.svg)
![Linux](https://img.shields.io/badge/platform-linux-lightgrey.svg)

## 📋 Descrição

Coleção de scripts Bash para automação e administração de servidores Linux. Este repositório contém ferramentas essenciais para tarefas rotineiras de sysadmin, focando em eficiência, segurança e facilidade de uso.

## 🚀 Scripts Disponíveis

### 🔄 backup.sh
Script completo para backup automático com as seguintes funcionalidades:
- Backup incremental e completo
- Compressão automática
- Rotação de backups antigos
- Notificação por email
- Logs detalhados

### 🧹 log_cleaner.sh
Ferramenta para limpeza inteligente de logs:
- Remove logs baseado em idade e tamanho
- Preserva logs críticos
- Compressão de logs antigos
- Configuração flexível por diretório
- Relatório de espaço liberado

### 👥 user_manager.sh
Gerenciador completo de usuários do sistema:
- Criação de usuários com templates
- Configuração automática de permissões
- Geração de senhas seguras
- Configuração de grupos e sudo
- Remoção segura de usuários

## 📁 Estrutura do Projeto

```
linux-automation-scripts/
├── scripts/
│   ├── backup.sh
│   ├── log_cleaner.sh
│   └── user_manager.sh
├── config/
│   ├── backup.conf
│   ├── log_cleaner.conf
│   └── user_templates/
├── logs/
├── docs/
│   ├── backup-guide.md
│   ├── log-management.md
│   └── user-management.md
└── README.md
```

## ⚡ Instalação e Configuração

### Pré-requisitos
```bash
# Dependências necessárias
sudo apt-get update
sudo apt-get install rsync tar gzip mail-utils
```

### Instalação
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/linux-automation-scripts.git
cd linux-automation-scripts

# Torne os scripts executáveis
chmod +x scripts/*.sh

# Configure os arquivos de configuração
cp config/backup.conf.example config/backup.conf
# Edite as configurações conforme necessário
```

## 🔧 Uso dos Scripts

### Backup Script
```bash
# Backup completo
./scripts/backup.sh --full

# Backup incremental
./scripts/backup.sh --incremental

# Backup de diretório específico
./scripts/backup.sh --directory /home/user --destination /backup

# Configurar backup automático (crontab)
crontab -e
# Adicione: 0 2 * * * /path/to/backup.sh --incremental
```

### Log Cleaner
```bash
# Limpeza padrão (configuração do arquivo)
./scripts/log_cleaner.sh

# Limpeza personalizada
./scripts/log_cleaner.sh --days 30 --size 100M --path /var/log

# Modo dry-run (apenas mostra o que seria removido)
./scripts/log_cleaner.sh --dry-run
```

### User Manager
```bash
# Criar usuário com template padrão
./scripts/user_manager.sh --create username

# Criar usuário com template específico
./scripts/user_manager.sh --create username --template developer

# Remover usuário
./scripts/user_manager.sh --remove username

# Listar usuários criados pelo script
./scripts/user_manager.sh --list
```

## ⚙️ Configuração

### backup.conf
```bash
# Configurações de backup
BACKUP_SOURCE="/home /etc /var/www"
BACKUP_DESTINATION="/backup"
RETENTION_DAYS=30
EMAIL_NOTIFICATION="admin@empresa.com"
COMPRESSION_LEVEL=6
```

### log_cleaner.conf
```bash
# Configurações de limpeza
LOG_DIRECTORIES="/var/log /home/*/logs"
MAX_AGE_DAYS=15
MAX_SIZE_MB=500
COMPRESS_OLD_LOGS=true
```

## 📊 Monitoramento e Logs

Todos os scripts geram logs detalhados em `/var/log/automation/`:
- `backup.log` - Logs de backup
- `log_cleaner.log` - Logs de limpeza
- `user_manager.log` - Logs de gerenciamento de usuários

### Visualização de logs
```bash
# Últimas execuções de backup
tail -f /var/log/automation/backup.log

# Resumo de limpeza de logs
grep "SUMMARY" /var/log/automation/log_cleaner.log
```

## 🔐 Segurança

- Scripts executam com privilégios mínimos necessários
- Validação de entrada em todos os parâmetros
- Backup de configurações antes de alterações
- Logs auditáveis de todas as operações
- Senhas geradas com alta entropia

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📝 Changelog

### v1.2.0 (2025-07-19)
- Adicionado suporte a backup incremental
- Melhorada validação de parâmetros
- Corrigido bug na rotação de logs

### v1.1.0 (2025-06-15)
- Adicionado template system para usuários
- Implementado dry-run no log cleaner
- Adicionadas notificações por email

### v1.0.0 (2025-05-01)
- Release inicial
- Scripts básicos de backup, limpeza e usuários

## 🐛 Troubleshooting

### Problemas Comuns

**Erro de permissão**
```bash
# Solução: Execute com sudo ou ajuste permissões
sudo ./scripts/backup.sh
```

**Backup falha por falta de espaço**
```bash
# Solução: Configure limpeza automática
./scripts/log_cleaner.sh --emergency-clean
```

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Seu Nome**
- GitHub: [@seu-usuario](https://github.com/Viniciuss-Moreira)
- LinkedIn: [Seu Perfil](https://linkedin.com/in/viniciusmoreira-)
- Email: vinnismoreira@gmail.com

## 🌟 Agradecimentos

- Comunidade Linux pela inspiração
- Contribuidores do projeto
- Ferramentas open source utilizadas

---

⭐ Se este projeto foi útil, considere dar uma estrela no repositório!
