### Project vars

variable "project_name" {
  type    = string
  default = "netology"
}

variable "environment" {
  type    = string
  default = "develop-platform"
}


### Cloud vars

variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "default_subnet_name" {
  type        = string
  default     = "develop"
  description = "VPC default subnet name"
}

variable "develop-2_zone" {
  type        = string
  default     = "ru-central1-b"
}
variable "develop-2_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
}
variable "develop-2_subnet_name" {
  type        = string
  default     = "develop-2"
  description = "VPC develop-2 subnet name"
}


### SSH vars

variable "vms_metadata" {
  description = "Metadata of VM"
  type        = map
}
