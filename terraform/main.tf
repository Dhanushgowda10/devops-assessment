resource "aws_security_group" "app_sg" {
  name        = "devops-assessment-sg1"
  description = "Allow HTTP, HTTPS, SSH, and Django API"

  # Frontend Port
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Django Backend Port - MANDATORY for the "Connection Failed" fix
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "web_server" {
  ami                    = "ami-0b6c6ebed2801a5cb" 
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  # Add this line below:
  key_name               = "project" 

  user_data = <<-EOF
            #!/bin/bash
            sudo apt update
            # Install Docker and the Docker Compose Plugin
            sudo apt install -y docker.io docker-compose-v2
            sudo systemctl start docker
            sudo systemctl enable docker
            # Allow the ubuntu user to run docker commands
            sudo usermod -aG docker ubuntu
            EOF
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}
