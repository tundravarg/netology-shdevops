terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
  required_version = ">=0.13"
}

provider "docker" {
  host     = "ssh://admin@51.250.107.19:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}


resource "random_password" "root_pwd" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "random_password" "user_pwd" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}


resource "docker_image" "db" {
  name         = "mysql:8"
  keep_locally = true
}

resource "docker_container" "db" {
  image = docker_image.db.image_id
  name  = "test_db"

  env = [
    "MYSQL_ROOT_HOST=%",
    "MYSQL_ROOT_PASSWORD=${random_password.root_pwd.result}",
    "MYSQL_DATABASE=test_db",
    "MYSQL_USER=db-user",
    "MYSQL_PASSWORD=${random_password.user_pwd.result}",
  ]

  ports {
    internal = 3306
    external = 3306
  }
}
