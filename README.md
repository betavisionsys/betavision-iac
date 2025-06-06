# Infrastructure as Code Monorepo

Este repositório contém a estrutura de IaC (Infraestrutura como Código) usando Terraform para a cloud Hetzner, com possibilidade de expansão para outras clouds no futuro.

## Estrutura de Diretórios

```
project/
├── README.md
├── .gitignore
├── bootstrap.sh
├── iac/
│   ├── providers/
│   ├── clients/
│   │   └── clienteA/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── terraform.tfvars.example
│   │       ├── tfplan
│   │       ├── .terraform/
│   │       └── .terraform.lock.hcl
│   ├── modules/
│   │   ├── network/
│   │   │   └── hetzner/
│   │   │       ├── main.tf
│   │   │       ├── variables.tf
│   │   │       └── outputs.tf
│   │   └── compute/
│   │       └── hetzner/
│   │           ├── main.tf
│   │           ├── variables.tf
│   │           └── outputs.tf
├── apps/
│   └── README.md
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       └── build-apps.yml
```

## README de cada pasta

- **iac/providers/**: Configuração do provider Terraform para Hetzner.
- **iac/modules/network/hetzner/**: Módulo Terraform para configurar rede em Hetzner (VPC, subnet).
- **iac/modules/compute/hetzner/**: Módulo Terraform para configurar instâncias em Hetzner.
- **iac/clients/clienteA/**: Exemplo de configuração de cliente específico, chamando módulos de rede e compute.
- **apps/**: Pasta para códigos/fonte das aplicações a serem deployadas.
- **.github/workflows/**: GitHub Actions para CI/CD (plan/apply de Terraform e build/push de Docker).

## Instruções iniciais

1. Copie a pasta `clienteA` e renomeie para o novo cliente.
2. Atualize `terraform.tfvars.example` (renomeie para `terraform.tfvars`) com as variáveis específicas.
3. Adicione o token do Hetzner no GitHub Secrets (`HCLOUD_TOKEN_NOVOCLIENTE`).
4. Faça `terraform init`, `plan` e `apply` no diretório do cliente após configurar o backend.
