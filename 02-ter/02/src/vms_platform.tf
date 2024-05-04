###### COMMON ####

variable "vms_resources" {
  description = "Default VM resources"
  type        = map(any)
}



###### VM WEB ####

### Image vars

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
}

### VM vars

variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v3"
}

variable "vm_web_preemptible" {
  type        = bool
  default     = true
}

variable "vm_web_nat" {
  type        = bool
  default     = true
}




###### VM DB ####

### Image vars

variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
}

### VM vars

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = ""
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v3"
  description = ""
}

variable "vm_db_zone" {
  type        = string
  default     = "ru-central1-b"
  description = ""
}

variable "vm_db_preemptible" {
  type        = bool
  default     = true
  description = ""
}

variable "vm_db_nat" {
  type        = bool
  default     = true
  description = ""
}
