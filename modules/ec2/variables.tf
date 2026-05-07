variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_name" {
  type    = string
  default = "example-dev"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "prevent_destroy" {
  description = "Impede destroy acidental dos recursos do modulo quando true"
  type        = bool
  default     = false
}
