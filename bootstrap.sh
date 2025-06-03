#!/bin/bash
set -e

# Cria estrutura de diretórios
mkdir -p iac/providers
mkdir -p iac/modules/network/hetzner
mkdir -p iac/modules/compute/hetzner
mkdir -p iac/clients/clienteA
mkdir -p apps
mkdir -p ci/workflows

# Gera README.md com a árvore de diretórios corretamente escapada em Markdown
cat << 'EOF' > README.md
# Infrastructure as Code Monorepo

Este repositório contém a estrutura de IaC (Infraestrutura como Código) usando Terraform para a cloud Hetzner, com possibilidade de expansão para outras clouds no futuro.

## Estrutura de Diretórios

```
project/
├── README.md
├── iac/
│   ├── providers/
│   │   └── hetzner.tf
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
│   └── clients/
│       └── clienteA/
│           ├── main.tf
│           ├── variables.tf
│           ├── terraform.tfvars.example
│           └── backend.tf
├── apps/
│   └── README.md
└── ci/
    └── workflows/
        ├── terraform.yml
        └── build-apps.yml
```

## README de cada pasta

- **iac/providers/hetzner.tf**: Configuração do provider Terraform para Hetzner.
- **iac/modules/network/hetzner/**: Módulo Terraform para configurar rede em Hetzner (VPC, subnet).
- **iac/modules/compute/hetzner/**: Módulo Terraform para configurar instâncias em Hetzner.
- **iac/clients/clienteA/**: Exemplo de configuração de cliente específico, chamando módulos de rede e compute.
- **apps/**: Pasta para códigos/fonte das aplicações a serem deployadas.
- **ci/workflows/**: GitHub Actions para CI/CD (plan/apply de Terraform e build/push de Docker).

## Instruções iniciais

1. Copie a pasta \`clienteA\` e renomeie para o novo cliente.
2. Atualize \`terraform.tfvars.example\` (renomeie para \`terraform.tfvars\`) com as variáveis específicas.
3. Adicione o token do Hetzner no GitHub Secrets (\`HCLOUD_TOKEN_NOVOCLIENTE\`).
4. Faça \`terraform init\`, \`plan\` e \`apply\` no diretório do cliente após configurar o backend.
EOF

# Cria iac/providers/hetzner.tf
cat << 'EOF' > iac/providers/hetzner.tf
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.40"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
  alias = "hetzner"
}
EOF

# Cria iac/modules/network/hetzner/main.tf
cat << 'EOF' > iac/modules/network/hetzner/main.tf
variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "location" {
  type = string
}

resource "hcloud_network" "main" {
  name = var.name
}

resource "hcloud_subnet" "main" {
  network_id    = hcloud_network.main.id
  type          = "cloud"
  network_zone  = var.location
  ip_range      = var.cidr
}

output "network_id" {
  value = hcloud_network.main.id
}

output "subnet_id" {
  value = hcloud_subnet.main.id
}

output "network_cidr" {
  value = hcloud_subnet.main.ip_range
}
EOF

# Cria iac/modules/network/hetzner/variables.tf
cat << 'EOF' > iac/modules/network/hetzner/variables.tf
variable "name" {
  description = "Nome da rede"
  type        = string
}

variable "cidr" {
  description = "Faixa de IPs CIDR"
  type        = string
}

variable "location" {
  description = "Datacenter (ex: fsn1)"
  type        = string
}
EOF

# Cria iac/modules/network/hetzner/outputs.tf
cat << 'EOF' > iac/modules/network/hetzner/outputs.tf
output "network_id" {
  description = "ID da rede criada"
  value       = hcloud_network.main.id
}

output "subnet_id" {
  description = "ID da sub-rede criada"
  value       = hcloud_subnet.main.id
}

output "network_cidr" {
  description = "CIDR da sub-rede"
  value       = hcloud_subnet.main.ip_range
}
EOF

# Cria iac/modules/compute/hetzner/main.tf
cat << 'EOF' > iac/modules/compute/hetzner/main.tf
variable "network_id" {
  type = string
}

variable "image" {
  type = string
}

variable "server_type" {
  type = string
}

variable "count" {
  type = number
}

variable "ssh_key_fingerprint" {
  type = string
}

resource "hcloud_server" "main" {
  count             = var.count
  name              = "\${var.server_type}-\${count.index}"
  image             = var.image
  server_type       = var.server_type
  location          = "fsn1"
  networks          = [var.network_id]
  ssh_keys          = [var.ssh_key_fingerprint]
}

resource "hcloud_floating_ip" "main" {
  count          = var.count
  type           = "ipv4"
  home_location  = "fsn1"
}

resource "hcloud_floating_ip_assignment" "main" {
  count           = var.count
  server_id       = hcloud_server.main[count.index].id
  floating_ip_id  = hcloud_floating_ip.main[count.index].id
}

output "server_ips" {
  value = hcloud_floating_ip.main[*].ip
}
EOF

# Cria iac/modules/compute/hetzner/variables.tf
cat << 'EOF' > iac/modules/compute/hetzner/variables.tf
variable "network_id" {
  description = "ID da rede onde serão criadas as instâncias"
  type        = string
}

variable "image" {
  description = "Imagem do sistema (ex: ubuntu-22.04)"
  type        = string
}

variable "server_type" {
  description = "Tipo de servidor (ex: cx31)"
  type        = string
}

variable "count" {
  description = "Quantidade de servidores"
  type        = number
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint da chave SSH cadastrada no Hetzner"
  type        = string
}
EOF

# Cria iac/modules/compute/hetzner/outputs.tf
cat << 'EOF' > iac/modules/compute/hetzner/outputs.tf
output "server_ips" {
  description = "Lista de IPs públicos atribuídos às instâncias"
  value       = hcloud_floating_ip.main[*].ip
}
EOF

# Cria iac/clients/clienteA/main.tf
cat << 'EOF' > iac/clients/clienteA/main.tf
provider "hcloud" {
  token = var.hetzner_token
  alias = "hetzner"
}

module "network" {
  source = "../../modules/network/hetzner"
  providers = {
    hcloud = hcloud.hetzner
  }
  name     = var.network_name
  cidr     = var.network_cidr
  location = var.location
}

module "compute" {
  source = "../../modules/compute/hetzner"
  providers = {
    hcloud = hcloud.hetzner
  }
  network_id          = module.network.network_id
  image               = var.server_image
  server_type         = var.server_type
  count               = var.server_count
  ssh_key_fingerprint = var.ssh_key_fingerprint
}
EOF

# Cria iac/clients/clienteA/variables.tf
cat << 'EOF' > iac/clients/clienteA/variables.tf
variable "hetzner_token" {
  type      = string
  sensitive = true
}

variable "network_name" {
  type = string
}

variable "network_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "location" {
  type    = string
  default = "fsn1"
}

variable "server_type" {
  type    = string
  default = "cx31"
}

variable "server_image" {
  type    = string
  default = "ubuntu-22.04"
}

variable "server_count" {
  type    = number
  default = 2
}

variable "ssh_key_fingerprint" {
  type = string
}
EOF

# Cria iac/clients/clienteA/terraform.tfvars.example
cat << 'EOF' > iac/clients/clienteA/terraform.tfvars.example
hetzner_token        = "<COLE_AQUI_SEU_TOKEN>"
network_name         = "rede-clienteA"
network_cidr         = "10.1.0.0/16"
location             = "fsn1"
server_type          = "cx31"
server_image         = "ubuntu-22.04"
server_count         = 2
ssh_key_fingerprint  = "<FINGERPRINT_DA_CHAVE_SSH>"
EOF

# Cria iac/clients/clienteA/backend.tf
cat << 'EOF' > iac/clients/clienteA/backend.tf
terraform {
  backend "s3" {
    bucket = "meu-tfstate"
    key    = "clienteA/terraform.tfstate"
    region = "us-east-1"
  }
}
EOF

# Cria apps/README.md
cat << 'EOF' > apps/README.md
# Aplicações

Coloque aqui o código-fonte ou artefatos das aplicações que serão deployadas via Terraform.

Exemplo:
```
apps/
└── nomeApp1/
    ├── Dockerfile
    ├── config/
    └── scripts/
```
EOF

# Cria ci/workflows/terraform.yml
cat << 'EOF' > ci/workflows/terraform.yml
name: Terraform CI/CD (Hetzner)

on:
  push:
    paths:
      - 'iac/**.tf'
      - 'iac/clients/**'
      - 'iac/modules/**'
  workflow_dispatch:

jobs:
  plan:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        client: [clienteA]
    steps:
      - uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Terraform Init
        run: |
          cd iac/clients/\${{ matrix.client }}
          terraform init -backend-config="key=\${{ matrix.client }}/terraform.tfstate"
        env:
          HCLOUD_TOKEN: \${{ secrets.HCLOUD_TOKEN_\${{ matrix.client | upper }} }}

      - name: Terraform Fmt
        run: cd iac && terraform fmt -check

      - name: Terraform Validate
        run: cd iac/clients/\${{ matrix.client }} && terraform validate

      - name: Terraform Plan
        run: |
          cd iac/clients/\${{ matrix.client }}
          terraform plan -var-file=terraform.tfvars -out=tfplan
        env:
          HCLOUD_TOKEN: \${{ secrets.HCLOUD_TOKEN_\${{ matrix.client | upper }} }}

  apply:
    needs: plan
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        client: [clienteA]
    steps:
      - uses: actions/checkout@v3

      - name: Download Plan
        uses: actions/download-artifact@v3
        with:
          name: "\${{ matrix.client }}-tfplan"
          path: ./plans

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Terraform Apply
        run: |
          cd iac/clients/\${{ matrix.client }}
          terraform apply -auto-approve "tfplan"
        env:
          HCLOUD_TOKEN: \${{ secrets.HCLOUD_TOKEN_\${{ matrix.client | upper }} }}
EOF

# Cria ci/workflows/build-apps.yml
cat << 'EOF' > ci/workflows/build-apps.yml
name: Build & Push Docker Apps

on:
  push:
    paths:
      - 'apps/**'
  workflow_dispatch:

jobs:
  build-push:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        app: [nomeApp1]
    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Registry
        run: echo \${{ secrets.DOCKER_PASSWORD }} | docker login registry.exemplo.com -u \${{ secrets.DOCKER_USER }} --password-stdin

      - name: Build & Push
        run: |
          cd apps/\${{ matrix.app }}
          IMAGE_TAG=registry.exemplo.com/\${{ matrix.app }}:\${{ github.sha }}
          docker build -t \$IMAGE_TAG .
          docker push \$IMAGE_TAG
      - name: Set Output Tag
        id: tag
        run: echo "::set-output name=tag::\${{ github.sha }}"
EOF

echo "Bootstrap completo!"

