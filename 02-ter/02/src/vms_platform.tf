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

variable "vm_web_cores" {
  type        = number
  default     = 2
}

variable "vm_web_memory" {
  type        = number
  default     = 1
}

variable "vm_web_core_fraction" {
  type        = number
  default     = 20
}

variable "vm_web_preemptible" {
  type        = bool
  default     = true
}

variable "vm_web_nat" {
  type        = bool
  default     = true
}

variable "vm_web_serial-port-enable" {
  type        = number
  default     = 1
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

variable "vm_db_cores" {
  type        = number
  default     = 2
  description = ""
}

variable "vm_db_memory" {
  type        = number
  default     = 2
  description = ""
}

variable "vm_db_core_fraction" {
  type        = number
  default     = 20
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

variable "vm_db_serial-port-enable" {
  type        = number
  default     = 1
  description = ""
}
