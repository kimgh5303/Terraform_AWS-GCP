# Google Cloud Provider 설정
provider "google" {
  credentials = file("/home/vagrant/gcp_terraform/terraformtest-5303-a32d67784edb.json")  # 서비스 계정 키 파일 경로
  project     = "terraformtest-5303"  # 프로젝트 ID
  region      = "asia-northeast3"     # 기본 리전 설정
  zone         = "asia-northeast3-a"
}

# 기본 VPC 네트워크 정보 조회
resource "google_compute_network" "main" {
  name = "terraform-network"    # 네트워크 이름
}

# HTTP 트래픽을 허용하는 방화벽 규칙 생성
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  target_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}

# 가상 머신 인스턴스 생성
resource "google_compute_instance" "instance" {
  name         = "my-instance"
  machine_type = "n2-standard-2"
  tags         = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.main.self_link
    access_config {}
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      sudo apt update -y
      sudo apt install -y apache2
      sudo systemctl start apache2
      sudo systemctl enable apache2

      # HTML 페이지에 이미지 삽입
      echo '<img src="https://i.namu.wiki/i/lVX-N10dzyEF_B76STHoR9SpkwVgcMU5h0n-hWLI-qq1ly3IpK_tTTvg3zod9dQFqn8xxvlAJW9dPl3yn6kF7L5i7lRTzN07K-UlceBSj7XmWCl0IlOTMB_csiAHGjzWW6YX99Q8KplYzbVoaKjVnA.webp">' > /var/www/html/index.html
      sudo systemctl restart apache2
    EOT
  }
}


# 출력 변수 설정
output "public_ip" {
  value = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip  # 인스턴스의 공개 IP 주소 출력
}