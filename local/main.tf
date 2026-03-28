resource "local_file" "foo" {
  content  = var.conteudo
  filename = "${path.module}/hello.txt"
}


variable "conteudo"{
    type = string
    default = "Variavel Conteudo"
    description = "Conteudo de uma variavel"
}

variable "conteudo_bool" {
    type = bool
    default = true
    description = "Conteudo de uma variavel do tipo booleano"
  
}

variable "conteudo_number" {
    type = number
    default = 42
    description = "Conteudo de uma variavel do tipo numero"
  
}

variable "conteudo_lista" {
    type = list(string)
    default = ["item1", "item2", "item3"]
    description = "Conteudo de uma variavel do tipo lista" 
}

variable "conteudo_mapa" {
    type = map(string)
    default = {
        chave1 = "valor1"
        chave2 = "valor2"
        chave3 = "valor3"
    }
    description = "Conteudo de uma variavel do tipo mapa"
}

variable "conteudo_set" {
    type = set(string)
    default = ["itemA", "itemB", "itemC"]
    description = "Conteudo de uma variavel do tipo set"
  
}