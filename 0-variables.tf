variable "vpc_cidr" {
  default     = "10.0.0.0/24"
  type        = string
}

variable "public-web-subnet-1-cidr" {
  default     = "10.0.0.0/27"
  type        = string
}

variable "public-web-subnet-2-cidr" {
  default     = "10.0.0.32/27"
  type        = string
}

variable "private-app-subnet-1-cidr" {
  default     = "10.0.0.64/27"
  type        = string
}

variable "private-app-subnet-2-cidr" {
  default     = "10.0.0.96/27"
  type        = string
}

variable "private-db-subnet-1-cidr" {
  default     = "10.0.0.128/27"
  description = "private_db_subnet1"
  type        = string
}

variable "private-db-subnet-2-cidr" {
  default     = "10.0.0.160/27"
  description = "private_db_subnet2"
  type        = string
}

variable "ssh-locate" {
  default     = "10.0.0.0/24"
  type        = string
}

variable "database-instance-class" {
  default     = "db.t3.micro"
  type        = string
}
