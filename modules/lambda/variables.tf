variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "function_name" {
  type    = string
  default = "my-python-lambda"
}

variable "prevent_destroy" {
  description = "Impede destroy acidental dos recursos do modulo quando true"
  type        = bool
  default     = false
}