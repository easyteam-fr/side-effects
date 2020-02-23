data google_compute_image ovirt {
  name  = "ovirt-host"
  project = var.projectid
}

data google_compute_network default {
   name = "default"
}

data google_compute_subnetwork subnetwork {
  name   = "default"
  region = "us-central1"
}

resource google_compute_address ovirt_host1_internal {
  name = "ovirt-host1-internal"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnetwork.self_link
  address      = "10.128.0.11"
  region       = "us-central1"
}

resource google_compute_address engine_internal {
  name = "ovirt-engine-internal"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnetwork.self_link
  address      = "10.128.0.10"
  region       = "us-central1"
}

resource google_compute_firewall internal {
  name    = "internal"
  network = data.google_compute_network.default.name
  source_ranges = ["10.128.0.0/20"]
  direction = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }
}

resource google_compute_firewall remote {
  name    = "remote"
  network = data.google_compute_network.default.name
  source_ranges = ["0.0.0.0/0"]
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["54323", "5900-6300"]
  }
  target_tags = ["web"]
}

resource google_compute_instance ovirt_host1 {
  count        = 1
  name         = "ovirt-host1"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["app", "ovirt"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ovirt.self_link
      size  = 50
    }
  }

  network_interface {
    network = "default"
    network_ip = google_compute_address.ovirt_host1_internal.address
    access_config {
    }
  }

  metadata = {
    app      = "ovirt"
    ssh-keys = "oracle:${var.ssh_key}"
    startup-script = file("host-init.script")
  }
}

resource google_compute_instance engine {
  count        = 1
  name         = "engine"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"

  tags = ["app", "ovirt", "https-server", "web"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ovirt.self_link
      size  = 50
    }
  }

  network_interface {
    network = "default"
    network_ip = google_compute_address.engine_internal.address
    access_config {
    }
  }

  metadata = {
    app      = "ovirt"
    ssh-keys = "oracle:${var.ssh_key}"
    startup-script = file("engine-init.script")
  }
}

