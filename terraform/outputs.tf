output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}