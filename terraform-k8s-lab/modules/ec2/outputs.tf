output "instance_id" {
  value = aws_instance.master.id
}

output "instance_public_ip" {
  value = aws_instance.master.public_ip
}

output "volume_id" {
  description = "ID of the additional EBS volume"
  value       = aws_ebs_volume.data.id
}

output "volume_device" {
  description = "Device name the volume is attached as on the instance"
  value       = aws_volume_attachment.data_attach.device_name
}
