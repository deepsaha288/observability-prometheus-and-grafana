resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  user_data              = var.user_data

  tags = {
    Name = var.instance_name
  }
}

# Create a 20GB EBS volume and attach it to the EC2 instance
resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.master.availability_zone
  size              = var.volume_size
  type              = var.volume_type

  tags = {
    Name = "${var.instance_name}-data"
  }
}

resource "aws_volume_attachment" "data_attach" {
  device_name = var.device_name
  instance_id = aws_instance.master.id
  volume_id   = aws_ebs_volume.data.id
}
