data "aws_ami" "aws_ami" {
  most_recent = true
  owners      = ["amazon"] # Or the specific owner ID

  filter {
    name   = "image-id"
    values = ["ami-075b5421f670d735c"] # Replace with the other ID if needed
  }
}


resource "aws_instance" "webapp" {
  ami           = data.aws_ami.aws_ami.id
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.my-ec2-instance-profile
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Welcome to Terraform EC2 Inline</h1>" | tee /var/www/html/index.html
  EOF

  tags = {
    Name = "Webapp_terraform"
  }
}
