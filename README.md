# ITF-Project

An AWS-based tennis tournament management system designed for ITF Masters Tour competitions. Built with Flask, MySQL, and deployed in a secure, multi-subnet VPC with failover readiness.

---

## 🎯 Project Scope

- Display and manage official-style ITF tournament draws
- Track players, age/gender categories, results, and status
- Enforce ITF ranking logic based on the best 4 results over 52 weeks
- Allow secure manual match result entry with set-by-set validation
- Deploy resilient, private infrastructure with SSM-only access and Route 53 routing
- Prepare for future multi-region failover architecture (currently single region)

---

## 🧱 Architecture Overview

### Region A – us-east-1 (Active)
- **VPC:** `VPC_DR_WebAccess`
- **Subnets:** Public and private subnets in AZ1 and AZ2
- **ALB:** `ALB-Primary-RegionA` (public-facing, HTTPS enabled)
- **EC2:** AppTier instance in private subnet with SSM agent (no NAT GW)
- **RDS:** Single-AZ MySQL (no Multi-AZ, no read replica yet)
- **VPC Interface Endpoints:**  
  - `com.amazonaws.us-east-1.ssm`  
  - `com.amazonaws.us-east-1.ec2messages`  
  - `com.amazonaws.us-east-1.ssmmessages`
- **Security Groups:** Strictly defined for ALB, EC2, and RDS access
- **Route 53:** Hosted zone for `awscloudcase.com` with alias to ALB
- **IAM Roles:** SSM, S3 full access, CloudWatch, custom inline policies

---

## 💡 Planned (Failover – Region B)
- Additional ALB and EC2 deployment in a second region
- Read replica of RDS MySQL for DR
- Route 53 failover routing with health checks
- Identical subnet, security group, and endpoint layout

---

## 📁 Folder Structure

```plaintext
html/         → Static HTML views (draws, rankings)
terraform/    → IaC definitions for VPC Endpoints, EC2, etc.
scripts/      → Deployment scripts, user-data
=======
# ITF-Project

An AWS-based tennis tournament management system designed for ITF Masters Tour competitions. Built with Flask, MySQL, and deployed in a secure, multi-subnet VPC with failover readiness.

---

## 🎯 Project Scope

- Display and manage official-style ITF tournament draws
- Track players, age/gender categories, results, and status
- Enforce ITF ranking logic based on the best 4 results over 52 weeks
- Allow secure manual match result entry with set-by-set validation
- Deploy resilient, private infrastructure with SSM-only access and Route 53 routing
- Prepare for future multi-region failover architecture (currently single region)

---

## 🧱 Architecture Overview

### Region A – us-east-1 (Active)
- **VPC:** `VPC_DR_WebAccess`
- **Subnets:** Public and private subnets in AZ1 and AZ2
- **ALB:** `ALB-Primary-RegionA` (public-facing, HTTPS enabled)
- **EC2:** AppTier instance in private subnet with SSM agent (no NAT GW)
- **RDS:** Single-AZ MySQL (no Multi-AZ, no read replica yet)
- **VPC Interface Endpoints:**  
  - `com.amazonaws.us-east-1.ssm`  
  - `com.amazonaws.us-east-1.ec2messages`  
  - `com.amazonaws.us-east-1.ssmmessages`
- **Security Groups:** Strictly defined for ALB, EC2, and RDS access
- **Route 53:** Hosted zone for `awscloudcase.com` with alias to ALB
- **IAM Roles:** SSM, S3 full access, CloudWatch, custom inline policies

---

## 💡 Planned (Failover – Region B)
- Additional ALB and EC2 deployment in a second region
- Read replica of RDS MySQL for DR
- Route 53 failover routing with health checks
- Identical subnet, security group, and endpoint layout

---

## 📁 Folder Structure

```plaintext
html/         → Static HTML views (draws, rankings)
terraform/    → IaC definitions for VPC Endpoints, EC2, etc.
scripts/      → Deployment scripts, user-data
>>>>>>> ded5e6d (Add .gitignore and README.md at root level)
sql/          → Schema and inserts for ITF tournaments
