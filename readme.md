# Terraform Settings

O bloco `terraform {}` configura o comportamento global do Terraform, como a versão mínima exigida e os providers necessários.

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend remoto para armazenar o state
  backend "s3" {
    bucket = "meu-bucket-terraform"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

- `required_version` — garante que todos usem uma versão compatível do Terraform.
- `required_providers` — declara os providers e suas versões.
- `backend` — define onde o arquivo de estado (`.tfstate`) será armazenado.

---

# Resource

O bloco `resource` é usado para **criar, atualizar e destruir** infraestrutura. É o bloco principal do Terraform.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name = "web-server"
  }
}
```

- Sintaxe: `resource "<tipo>" "<nome_local>" {}`
- O tipo é composto por `<provider>_<recurso>` (ex: `aws_instance`, `azurerm_virtual_machine`).
- O nome local é usado para referenciar o recurso internamente: `aws_instance.web.id`.
- Terraform gerencia o ciclo de vida completo: **create → update → destroy**.

---

# Data Source

O bloco `data` permite **consultar informações de recursos já existentes** sem gerenciá-los. É somente leitura.

```hcl
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]
  }
}

resource "aws_subnet" "example" {
  vpc_id     = data.aws_vpc.existing.id
  cidr_block = "10.0.1.0/24"
}
```

- Sintaxe: `data "<tipo>" "<nome_local>" {}`
- Referenciado como `data.<tipo>.<nome>.<atributo>`.
- Útil para referenciar recursos criados manualmente, por outro time ou outro workspace.
- **Não cria nem modifica** recursos, apenas lê dados do provider.

| | `resource` | `data` |
|---|---|---|
| Gerencia ciclo de vida | Sim | Não |
| Cria / altera / destrói | Sim | Não |
| Apenas lê | Não | Sim |

---

# Variables

Variáveis permitem **parametrizar** configurações, tornando o código reutilizável e flexível.

```hcl
variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  # sem default: será solicitado na execução
}

variable "allowed_ports" {
  description = "Lista de portas liberadas"
  type        = list(number)
  default     = [80, 443]
}
```

Referenciando uma variável:

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type
}
```

Formas de passar valores:
- Arquivo `terraform.tfvars` ou `*.auto.tfvars`
- Flag `-var="chave=valor"` na linha de comando
- Variáveis de ambiente: `TF_VAR_<nome>`
- Interativamente no terminal (quando sem `default`)

Tipos suportados: `string`, `number`, `bool`, `list()`, `map()`, `set()`, `object()`, `tuple()`.

---

# Outputs

O bloco `output` **expõe valores** do estado do Terraform, útil para exibir informações após o apply ou para compartilhar dados entre módulos.

```hcl
output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.web.public_ip
}

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
  sensitive   = false
}

output "db_password" {
  description = "Senha do banco de dados"
  value       = aws_db_instance.main.password
  sensitive   = true  # oculta o valor no terminal
}
```

- Exibidos ao final do `terraform apply`.
- Consultados com `terraform output <nome>`.
- `sensitive = true` oculta o valor nos logs (mas ainda armazena no state).
- Em módulos, outputs são referenciados como `module.<nome_modulo>.<output>`.

