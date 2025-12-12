# Azure Hub-Spoke Infrastructure with Terraform

Azure 기반 Hub-Spoke 아키텍처 인프라를 Terraform으로 구성하는 프로젝트입니다.

## ✨ 주요 특징

- 🔧 **프로젝트 Prefix 변수화**: 하나의 변수로 모든 리소스 이름 자동 생성
- 🏗️ **Hub-Spoke 아키텍처**: 네트워크와 워크로드를 두 개의 리소스 그룹으로 분리
- 📝 **명확한 네이밍 규칙**: 상위 리소스(대문자), 하위 리소스(소문자)로 일관성 유지
- 🚀 **최소 설정으로 실행**: `project_prefix`와 `postgresql_admin_password`만 설정하면 배포 가능

## 📁 프로젝트 구조

```
terraform-azure-vpa/
├── main.tf                      # 메인 Terraform 구성
├── variables.tf                 # 변수 정의
├── outputs.tf                   # 출력 정의
├── terraform.tfvars.example     # 변수 값 예제
├── .gitignore                   # Git 제외 파일
├── modules/
│   ├── network/                 # VNet, Subnet, Gateway
│   ├── compute/                 # Virtual Machines
│   ├── container/               # AKS, ACR
│   ├── database/                # PostgreSQL, Redis, MongoDB
│   └── security/                # Network Security Groups
└── CHANGELOG.md                 # 변경 이력 (Git에 포함 안 됨)
```

## 🏗️ 아키텍처 구성

### Hub-Spoke 네트워크 토폴로지

이 프로젝트는 **두 개의 리소스 그룹**으로 Hub와 Spoke를 분리합니다:

#### Hub Resource Group (`{PREFIX}-HUB-RG`)
중앙 네트워크 인프라
- **Hub VNet** (10.220.0.0/16)
  - GatewaySubnet: VPN Gateway용
  - jumpbox-subnet: 관리용 Jumpbox
- **NAT Gateway**: 아웃바운드 연결
- **VPN Gateway**: 온프레미스 연결

#### Spoke Resource Group (`{PREFIX}-SPOKE-RG`)
애플리케이션 워크로드
- **Spoke VNet** (10.221.0.0/16)
  - app-subnet: 애플리케이션 VM
  - aks-subnet: AKS 클러스터
  - private-endpoint-subnet: Private Endpoint
  - database-subnet: PostgreSQL
- **리소스**
  - Network Security Groups
  - Virtual Machines
  - AKS Cluster
  - Container Registry
  - PostgreSQL Flexible Server
  - Redis Cache

### 네이밍 규칙

**상위 리소스 (대문자):**
- Resource Group: `MYPROJECT-HUB-RG`, `MYPROJECT-SPOKE-RG`
- VNet: `MYPROJECT-HUB-VNET`, `MYPROJECT-SPOKE-VNET`

**하위 리소스 (소문자):**
- Gateway: `myproject-hub-nat`, `myproject-hub-vgw`
- AKS: `myproject-spoke-aks`
- ACR: `myprojectspokeacr`
- Database: `myproject-spoke-postgresql`, `myproject-spoke-redis`

## 🚀 빠른 시작

### 1. 사전 요구사항
- Terraform >= 1.5.0
- Azure CLI
- Azure 구독 및 적절한 권한

### 2. Azure 인증
```bash
az login
az account set --subscription "<your-subscription-id>"
```

### 3. 변수 설정

**terraform.tfvars 파일 생성 (권장)**
```bash
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
```

**최소 설정:**
```hcl
# terraform.tfvars
project_prefix = "myproject"
postgresql_admin_password = "YourSecurePassword123!"
```

**또는 환경 변수 사용:**
```bash
export TF_VAR_project_prefix="myproject"
export TF_VAR_postgresql_admin_password="YourSecurePassword123!"
```

### 4. 배포

```bash
# 초기화
terraform init

# 실행 계획 확인
terraform plan

# 인프라 배포
terraform apply

# 인프라 삭제
terraform destroy
```

## 📝 주요 변수

### 필수 변수

| 변수명 | 설명 | 예시 |
|--------|------|------|
| `project_prefix` | 모든 리소스 이름의 prefix | `myproject` |
| `postgresql_admin_password` | PostgreSQL 관리자 비밀번호 | `Secure123!@#` |

### 선택 변수 (자동 생성)

`project_prefix`를 기반으로 자동 생성되는 리소스 이름:

| 변수명 | 자동 생성 규칙 | 예시 (prefix=myproject) |
|--------|----------------|-------------------------|
| `hub_resource_group_name` | `{PREFIX}-HUB-RG` | `MYPROJECT-HUB-RG` |
| `spoke_resource_group_name` | `{PREFIX}-SPOKE-RG` | `MYPROJECT-SPOKE-RG` |
| `aks_cluster_name` | `{prefix}-spoke-aks` | `myproject-spoke-aks` |
| `acr_name` | `{prefix}spokeacr` | `myprojectspokeacr` |
| `postgresql_server_name` | `{prefix}-spoke-postgresql` | `myproject-spoke-postgresql` |

전체 변수 목록은 `terraform.tfvars.example` 파일을 참조하세요.

## 🔐 보안 고려사항

1. **비밀번호 관리**
   - `terraform.tfvars` 파일은 Git에 커밋되지 않습니다 (.gitignore)
   - 환경 변수 또는 CLI 인자 사용 권장

2. **네트워크 보안**
   - Private Endpoint를 통한 PaaS 서비스 접근
   - NSG를 통한 트래픽 제어

3. **접근 제어**
   - RBAC를 통한 리소스 접근 관리
   - Managed Identity 사용 권장

## 🔄 백업 및 복구

- **PostgreSQL**: 자동 백업 (기본 7일 보관)
- **AKS**: Velero를 통한 클러스터 백업 권장

## 📚 추가 리소스

- [Azure Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🤝 기여 방법

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📌 주의사항

- **Backend 설정**: Remote state 사용 시 `main.tf`의 backend 블록 주석 해제 및 설정 필요
- **PostgreSQL 비밀번호**: 반드시 안전한 방법으로 관리
- **검증**: 변경사항 적용 전 `terraform init` → `terraform plan` → `terraform apply` 순서로 진행

## 📄 라이센스

이 프로젝트는 내부 사용 목적으로 작성되었습니다.

## 📞 문의

프로젝트 관련 문의사항은 Platform Team에 연락주세요.

---

**변경 이력은 `CHANGELOG.md`를 참조하세요.**
