locals {
  private_subnet_1a_id = one([for subnet in aws_subnet.privates : subnet.id if subnet.availability_zone == "us-east-1a"])
  private_subnet_1b_id = one([for subnet in aws_subnet.privates : subnet.id if subnet.availability_zone == "us-east-1b"])

  public_subnet_1a_id = one([for subnet in aws_subnet.publics : subnet.id if subnet.availability_zone == "us-east-1a"])
  public_subnet_1b_id = one([for subnet in aws_subnet.publics : subnet.id if subnet.availability_zone == "us-east-1b"])
}