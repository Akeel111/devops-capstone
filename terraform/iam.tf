# -------------------------
# IAM Role for EC2
# -------------------------

resource "aws_iam_role" "ec2_role" {
  name = "devops-capstone-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "devops-capstone-ec2-role"
  }
}

# -------------------------
# Allow EC2 to use Systems Manager
# -------------------------

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -------------------------
# Allow EC2 to pull images from ECR
# -------------------------

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# -------------------------
# EC2 Instance Profile
# -------------------------

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "devops-capstone-ec2-profile"
  role = aws_iam_role.ec2_role.name
}