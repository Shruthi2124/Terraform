resource "local_file" "local1" {
  content  = "Hello Terraform!"
  filename ="${path.module}/local.txt"
  }


