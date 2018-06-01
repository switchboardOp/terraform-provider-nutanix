provider "nutanix" {
  username = "admin"
  password = "Nutanix/1234"
  endpoint = "10.5.81.134"
  insecure = true
  port     = 9440
}

resource "nutanix_image" "test" {
  name        = "Ubuntu"
  description = "Ubuntu Server Mini ISO"
  source_uri  = "http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/current/images/netboot/mini.iso"
}

data "nutanix_clusters" "clusters" {
  metadata = {
    length = 2
  }
}

resource "nutanix_virtual_machine" "vm1" {
  name = "test-dou-update-12"

  description = "test update"

  cluster_reference = {
    kind = "cluster"
    uuid = "${data.nutanix_clusters.clusters.entities.0.metadata.uuid}"
  }

  num_vcpus_per_socket = 1
  num_sockets          = 1
  memory_size_mib      = 1024
  power_state          = "ON"

  nic_list = [
    {
      subnet_reference = {
        kind = "subnet"
        uuid = "${nutanix_subnet.next-iac-managed2.id}"
      }

      ip_endpoint_list = {
        ip   = "10.5.80.11"
        type = "ASSIGNED"
      }
    },
    {
      subnet_reference = {
        kind = "subnet"
        uuid = "${nutanix_subnet.next-iac-managed2.id}"
      }

      ip_endpoint_list = {
        ip   = "10.5.80.10"
        type = "ASSIGNED"
      }
    },
  ]

  disk_list = [{
    data_source_reference = [{
      kind = "image"
      name = "ubuntu"
      uuid = "${nutanix_image.test.id}"
    }]

    device_properties = [{
      device_type = "DISK"
    }]

    disk_size_mib = 10000
  }]

  guest_customization_cloud_init {
    user_data = "I2Nsb3VkLWNvbmZpZwpib290Y21kOgotIHRlc3QgLWYgL2V0Yy9kZWZhdWx0L3BvbGxpbmF0ZSAmJiBzZWQgLWkgLS0gcyxlbnRyb3B5LnVidW50dS5jb20scmFuZG9tLm5vcmR1Lm5ldCwgL2V0Yy9kZWZhdWx0L3BvbGxpbmF0ZSAmJiBzZWQgLWkgLS0gcyxeQ1VSTF9PUFRTLCNDVVJMX09QVFMsIC9ldGMvZGVmYXVsdC9wb2xsaW5hdGUgfHwgdHJ1ZQotICdlY2hvICJXZWxjb21lIHRvIHlvdXIgYnJhbmQgbmV3IFZNIQoKCiAgSWYgeW91IHNlZSB0aGlzIG1lc3NhZ2UsIHRoZW4gaXQgcHJvYmFibHkgbWVhbnMgdGhhdCBpcyBzdGlsbCBiZWluZyBjb25maWd1cmVkCgogIGJ5IENsb3VkLUluaXQgdG8gcnVuIENvc21vcyBhbmQgUHVwcGV0LgoKCiAgVG8gZm9sbG93IHRoZSBwcm9ncmVzcyBydW46CgogICQgdGFpbCAtZiAvdmFyL2xvZy9jbG91ZC1pbml0LW91dHB1dC5sb2cKCgogICIgPiAvZXRjL21vdGQnCmZpbmFsX21lc3NhZ2U6IGNsb3VkLWluaXQgY29tcGxldGVkICgkVVBUSU1FIHNlY29uZHMpCmZxZG46IHNlLXR1Zy1udHAwMS5ub3JkdS5uZXQKaG9zdG5hbWU6IHNlLXR1Zy1udHAwMQptYW5hZ2VfZXRjX2hvc3RzOiB0cnVlCnBhY2thZ2VfdXBncmFkZTogdHJ1ZQpyYW5kb21fc2VlZDoKICBkYXRhOiBmOTc1ODc2ZmIyMzg4MTg1MTBkYWFiNzM0MDkyOWQ0NjY2Y2Q5YTgyOThmNWM5NWE5MjZjZmNkZWU4NGZjZjdlMGMwMzRhM2FkMzA1OWM3MTkxM2VhMzRjMmE4N2Q2MmY1MDNmNmRmODJmMzRiMGNlNDA4ZWQyMDkwNTdjODUxNwogIGZpbGU6IC9kZXYvdXJhbmRvbQpyc3lzbG9nOgogIGNvbmZpZ19maWxlbmFtZTogMjAtbm9yZHVuZXQuY29uZgogIHJlbW90ZXM6CiAgICBzeXNsb2cxLm5vcmR1Lm5ldDogJyouKiBAc3lzbG9nMS5ub3JkdS5uZXQnCiAgICBzeXNsb2cyLm5vcmR1Lm5ldDogJyouKiBAc3lzbG9nMi5ub3JkdS5uZXQnCnJ1bmNtZDoKLSBjaG1vZCB1K3ggL3Zhci9vcHQvY29zbW9zLWJvb3RzdHJhcAotICcvdmFyL29wdC9jb3Ntb3MtYm9vdHN0cmFwIGh0dHA6Ly9naXRwcm94eS5ub3JkdS5uZXQvbmRuLXN5c2NvbmYuZ2l0IDJmMTVlMWVkYjAyZjE0NjA3MDg0ZjE2NzkyOWJjMTQ1ZWQ0Nzk1NGQgJwp1c2VyczoKLSBnZWNvczogTlVOT0MgVXNlcgogIGxvY2tfcGFzc3dkOiBmYWxzZQogIG5hbWU6IG51bm9jCiAgcGFzc3dkOiAkNiRiSGtycGJ1OVdLJE04WDVmVmFDM0RQMGVQSnU4SFpWUXFzUXR5NzRiTjlIeGNWdjl6SDFCSGxzMUdydThNYVZyL1E1cTdpd3FZUFk3Z2FISFZjcE9MdlJZWE1XaEtYN2guCiAgc2hlbGw6IC9iaW4vYmFzaAogIHNzaC1hdXRob3JpemVkLWtleXM6CiAgLSBzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFBQkFBQUJBUURlTUU2THVJUlp6SGg4Zjd3VEJFMVJSWDhmWDREZnRuWmFtYlZPb0dPemc1dWp0Vm5td0JaaUZGY3VtcVJHczdvL2lyYWRVWTBJQjVLMnRib29ISmtUWWgrQjBzSVIvNWpPUEpKWitiUzQ1Ym5nY0dxMXZ6Kyt6MVZTWGxUR0gxM0g4T0ZYSFpQbmp3dkZ6TzVlYXVIbmVuNHVLVktyTjlBL2xOaFRmYmpwaUhSTjF5Zlh1dW5sdmFyNEdvNk9MQW02dGdXZTkzc2NkWGlBZHhkM0xvWi9JOTF3N2RqZkFpMFNwTWlURGJZY2hydHQ5d0MzbDRVNDJ3ZWhjQU5VNEVoRUpmTXJ3Y01jUlhSU1ovM0llalhwMkkxUHVlUWhpSGprbkFrVlgvcjRZMjNSS1Q3N0IxT0ViVlhnOFZpekZWbkhyaGtHV1cxSlp6UVdydmIvTXJ1VCAvVXNlcnMvaHRqLy5zc2gvaWRfcnNhCiAgLSBzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFBQkFBQUJBUURlTUU2THVJUlp6SGg4Zjd3VEJFMVJSWDhmWDREZnRuWmFtYlZPb0dPemc1dWp0Vm5td0JaaUZGY3VtcVJHczdvL2lyYWRVWTBJQjVLMnRib29ISmtUWWgrQjBzSVIvNWpPUEpKWitiUzQ1Ym5nY0dxMXZ6Kyt6MVZTWGxUR0gxM0g4T0ZYSFpQbmp3dkZ6TzVlYXVIbmVuNHVLVktyTjlBL2xOaFRmYmpwaUhSTjF5Zlh1dW5sdmFyNEdvNk9MQW02dGdXZTkzc2NkWGlBZHhkM0xvWi9JOTF3N2RqZkFpMFNwTWlURGJZY2hydHQ5d0MzbDRVNDJ3ZWhjQU5VNEVoRUpmTXJ3Y01jUlhSU1ovM0llalhwMkkxUHVlUWhpSGprbkFrVlgvcjRZMjNSS1Q3N0IxT0ViVlhnOFZpekZWbkhyaGtHV1cxSlp6UVdydmIvTXJ1VCBodGpAcHlyaXRlCiAgc3VkbzogJ0FMTD0oQUxMKSBOT1BBU1NXRDogQUxMJwp3cml0ZV9maWxlczoKLSBjb250ZW50OiAnJwogIGVuY29kaW5nOiBiNjQKICBvd25lcjogcm9vdDpyb290CiAgcGF0aDogL3Zhci9vcHQvbmlhYgogIHBlcm1pc3Npb25zOiAnNjAwJwotIGNvbnRlbnQ6IEl5RXZZbWx1TDNOb0Nnb2pJRlJvYVhNZ2MyTnlhWEIwSUdsdWMzUmhiR3h6SUdOdmMyMXZjeUJoYm1RZ2MyVjBjeUIxY0NCcGJtbDBhV0ZzSUdOdmMyMXZjeUJwYm5OMFlXeHNZWFJwYjI0S0l5QlVhR1VnYzJOeWFYQjBJSFJoYTJWeklIUjNieUJoY21kMWJXVnVkSE02SUR4eVpYQnZjMmwwYjNKNVBpQThhR0Z6YUQ0S0l5QXRJSEpsY0c5emFYUnZjbms2SUdkcGRDQnlaWEJ2YVhOMGIzSjVJSFZ5YkN3Z1pTNW5MaUFnWjJsMExtNXZjbVIxTG01bGREcHVaRzR0YzNselkyOXVaaTVuYVhRS0l5QXRJR2hoYzJnNklDQWdJQ0FnSUd0dWIzZHVJR2R2YjJRZ2FHRnphQ3dnZFhObFpDQjBieUJpYjI5MGMzUnlZWEFnWTI5emJXOXpJR3RsZVhNS0l3b2pJRlJvYVhNZ2MyTnlhWEIwSUdseklHRWdZbWxuSUdKaFp5QnZaaUJ1WVhOMGVTNHVMaUFvZDJsMGFDQmxlSFJ5WVNCMGFXNW1iMmxzS1FvakNpTWdRWFYwYUc5eU9pQm9kR292YW1KeUNnb2pJRVJ2YmlkMElISmxiVzkyWlNCMGFHbHpMQ0J2ZEdobGQybHpaU0JnWm1Gc2MyVWdmSHdnS0dWamFHOGdUV1Z6YzJGblpUc2daWGhwZENBNU9TbGdJSGRwYkd3S0l5QnpkRzl3SUhkdmNtdHBibWNnWVhNZ2FXNTBaVzUwWldRS2MyVjBJQzFsQ2dvS0l5QkRhR1ZqYXlCcGJuQjFkQXBwWmlCYklDSWtJeUlnTFd4MElESWdYU0I4ZkNCYklDSWtJeUlnTFdkMElETWdYVHNnZEdobGJnb2dJQ0FnWldOb2J5QWlWWE5oWjJVNklDUXdJSEpsY0c5emFYUnZjbmtnYUdGemFDQmJkR0ZuWFNJZ1BpWXlDaUFnSUNCbGVHbDBJREVLWm1rS2NtVndiejBrTVFwcGJuUnBZV3gwY25WemREMGtNZ3AwWVdjOUpETUtDbVZqYUc4Z0lrbHVjM1JoYkd4cGJtY2dRMjl6Ylc5eklHUmxjR1Z1WkdWdVkybGxjeUlLQ2lNZ1NXNXpkR0ZzYkNCamIzTnRiM01nWkdWd1pXNWtaVzVqYVdWekNpTWdUbTkwWlRvZ1ZHaGxJRlZpZFc1MGRTQmpiRzkxWkMxcGJtbDBJR2x0WVdkbElHbHVZMngxWkdWeklHZHBkQ0JoYm1RZ1kzVnliQ3dnWW5WMElFbFRUeUJwYm5OMFlXeHNaV1FnYVcxaFoyVWdaRzlsY3lCdWIzUXVDbWxtSUdOdmJXMWhibVFnTFhZZ1pIQnJaeUFtSmlCamIyMXRZVzVrSUMxMklHRndkQzFuWlhRN0lIUm9aVzRLSUNCaGNIUXRaMlYwSUhWd1pHRjBaU0F0ZVFvZ0lHRndkQzFuWlhRZ2FXNXpkR0ZzYkNBdGVTQm5hWFFnWTNWeWJDQnlibWN0ZEc5dmJITUtaV3hwWmlCamIyMXRZVzVrSUMxMklISndiU0FtSmlCamIyMXRZVzVrSUMxMklIbDFiVHNnZEdobGJnb2dJSGwxYlNCcGJuTjBZV3hzSUMxNUlHZHBkQ0J5Ym1jdGRHOXZiSE1LWld4elpRb2dJR1ZqYUc4Z0lrNXZJSE4xY0hCdmNuUmxaQ0J3WVdOcllXZGxJRzFoYm1GblpYSWdabTkxYm1RaElnb2dJR1Y0YVhRZ01ncG1hUW9LQ2lNZ1EyOXVabWxuZFhKbElIUmhaeXdnYzJodmRXeGtJR0psSUhObGRDQmlaV1p2Y21VZ2QyVWdjbVZoWkNCamIzTnRiM011WTI5dVpncHBaaUJiSUMxNklDSWtkR0ZuSWlCZE95QjBhR1Z1Q2lBZ2RHRm5QU1FvWW1GelpXNWhiV1VnSWlSeVpYQnZJaUF1WjJsMEtRcGxiSE5sQ2lBZ0l5QnpaWFFnYVc1cGRHbGhiQ0IwY25WemRDQjBieUIwWVdjZ1ptOXlJR1JsZG1Wc2IzQnRaVzUwQ2lBZ2FXNTBhV0ZzZEhKMWMzUTlJaVIwWVdjaUNtWnBDZ29qSUdkbGRDQnJibTkzYmlCbmIyOWtJR2RwZENCeVpYQnZJR0Z1WkNCcGJuTjBZV3hzSUdOdmMyMXZjd29vQ2lBZ2RHMXdaR2x5UFNRb2JXdDBaVzF3SUMxa0tRb2dJR05rSUNJa2RHMXdaR2x5SWdvZ0lHZHBkQ0JwYm1sMENpQWdaMmwwSUhKbGJXOTBaU0JoWkdRZ0xXWWdiM0pwWjJsdUlDSWtjbVZ3YnlJS0lDQm5hWFFnWTI5dVptbG5JR052Y21VdWMzQmhjbk5sUTJobFkydHZkWFFnZEhKMVpRb2dJR2RwZENCamIyNW1hV2NnY0dGamF5NTBhSEpsWVdSeklERUtJQ0JuYVhRZ1kyOXVabWxuSUhCaFkyc3VaR1ZzZEdGRFlXTm9aVk5wZW1VZ01Rb2dJR2RwZENCamIyNW1hV2NnWTI5eVpTNXdZV05yWldSSGFYUlhhVzVrYjNkVGFYcGxJREUyYlFvZ0lHZHBkQ0JqYjI1bWFXY2dZMjl5WlM1d1lXTnJaV1JIYVhSTWFXMXBkQ0F4TWpodENpQWdaMmwwSUdOdmJtWnBaeUJ3WVdOckxuZHBibVJ2ZDAxbGJXOXllU0F4TWpodENpQWdaMmwwSUdOdmJtWnBaeUJqYjNKbExtSnBaMFpwYkdWVWFISmxjMmh2YkdRZ05XMEtJQ0I3Q2lBZ0lDQmxZMmh2SUNKbmJHOWlZV3d2YTJWNWN5OGlDaUFnSUNCbFkyaHZJQ0puYkc5aVlXd3ZaR2x6ZEM5amIzTnRiM010Y0dGamEyRm5aWE12SWdvZ0lIMGdQajRnTG1kcGRDOXBibVp2TDNOd1lYSnpaUzFqYUdWamEyOTFkQW9nSUdkcGRDQmphR1ZqYTI5MWRDQWlKR2x1ZEdsaGJIUnlkWE4wSWlCOGZDQW9JR1ZqYUc4Z0lrVnljbTl5SUdOb1pXTnJhVzVuSUc5MWNpQnpjR1ZqYVdacFl5Qm9ZWE5vSWlBN0lHVjRhWFFnTkNrS0NpQWdJeUJKYm5OMFlXeHNJR052YzIxdmN3b2dJR2xtSUdOdmJXMWhibVFnTFhZZ1pIQnJaeUFtSmlCamIyMXRZVzVrSUMxMklHRndkQzFuWlhRN0lIUm9aVzRLSUNBZ0lDQWdaSEJyWnlBdGFTQm5iRzlpWVd3dlpHbHpkQzlqYjNOdGIzTXRjR0ZqYTJGblpYTXZZMjl6Ylc5ektpNWtaV0lLSUNCbGJHbG1JR052YlcxaGJtUWdMWFlnY25CdElDWW1JR052YlcxaGJtUWdMWFlnZVhWdE95QjBhR1Z1Q2lBZ0lDQWdJSEp3YlNBdFZYWm9JQzB0Wm05eVkyVWdaMnh2WW1Gc0wyUnBjM1F2WTI5emJXOXpMWEJoWTJ0aFoyVnpMMk52YzIxdmN5b3VjbkJ0Q2lBZ1pXeHpaUW9nSUNBZ0lDQmxZMmh2SUNKT2J5QnpkWEJ3YjNKMFpXUWdjR0ZqYTJGblpTQnRZVzVoWjJWeUlHWnZkVzVrSVNJS0lDQWdJQ0FnWlhocGRDQXlDaUFnWm1rS0NpQWdaV05vYnlBaVEyOXpiVzl6SUhCaFkydGhaMlVnYVc1emRHRnNiR1ZrSWdvS0lDQWpJRWx0Y0c5eWRDQjBjblZ6ZEdWa0lHZHdaeUJyWlhseklHbHVkRzhnWTI5emJXOXpJR3RsZVhOMGIzSmxDaUFnWTI5emJXOXpJR2R3WnlBdExXbHRjRzl5ZENCbmJHOWlZV3d2YTJWNWN5OHFMbkIxWWdvS0lDQmpaQ0F0Q2lBZ2NtMGdMWEptSUNJa2RHMXdaR2x5SWdvcENncG9iM04wYm1GdFpUMGtLR2h2YzNSdVlXMWxJQzFtS1FvS0l5QkpiWEJ2Y25RZ1kyeHZkV1F0YVc1cGRDQm5aVzVsY21GMFpXUWdjSEpwZG1GMFpTQnJaWGtzSUdsbUlIQnlaWE5sYm5RZ2IzUm9aWEozYVhObElHZGxibVZ5WVhSbElHdGxlWE1LY0hKcGRtRjBaVXRsZVQwaUwzWmhjaTl2Y0hRdkpIdG9iM04wYm1GdFpYMHVjMlZqSWdwcFppQmJJQzFtSUNJa2NISnBkbUYwWlV0bGVTSWdYVHNnZEdobGJnb2dJR052YzIxdmN5Qm5jR2NnTFMxcGJYQnZjblFnSWlSd2NtbDJZWFJsUzJWNUlnb2dJSEp0SUMxbUlDSWtjSEpwZG1GMFpVdGxlU0lLWld4elpRb2dJR1Z0WVdsc1BTSjJZMEFrYUc5emRHNWhiV1VpQ2lBZ1pXTm9ieUFpQ2lBZ0pXNXZMWEJ5YjNSbFkzUnBiMjRLSUNCTFpYa3RWSGx3WlRvZ2NuTmhDaUFnVTNWaWEyVjVMVlI1Y0dVNklISnpZUW9nSUV0bGVTMU1aVzVuZEdnNklHUmxabUYxYkhRS0lDQk9ZVzFsTFZKbFlXdzZJQ1JvYjNOMGJtRnRaUW9nSUU1aGJXVXRSVzFoYVd3NklDUmxiV0ZwYkFvZ0lFVjRjR2x5WlMxRVlYUmxPaUF3Q2lBZ0pXTnZiVzFwZENJZ2ZGd0tJQ0FnSUdOdmMyMXZjeUJuY0djZ0xTMWlZWFJqYUNBdExXZGxiaTFyWlhrS1pta0tDaU1nVTJWMGRYQWdZMjl6Ylc5eklIUnZJSFZ6WlNCamIzSnlaV04wSUhSaFp3cHpaV1FnTFdrZ0xTMGdJbk1zSTBOUFUwMVBVMTlWVUVSQlZFVmZWa1ZTU1VaWlgwZEpWRjlVUVVkZlVFRlVWRVZTVGowdUtpeERUMU5OVDFOZlZWQkVRVlJGWDFaRlVrbEdXVjlIU1ZSZlZFRkhYMUJCVkZSRlVrNDlYQ0lrZEdGbkxTcGNJaXdpSUM5bGRHTXZZMjl6Ylc5ekwyTnZjMjF2Y3k1amIyNW1DZ29qSUdkbGRDQkRUMU5OVDFOZlVrVlFUeUJsYm5Zc0lHVjRjRzl5ZENCMGFHVWdkbUZ5YVdGaWJHVnpJSFJ2SUhOMVluTm9aV3hzSUNndFlTa0tjMlYwSUMxaENpNGdMMlYwWXk5amIzTnRiM012WTI5emJXOXpMbU52Ym1ZZ2ZId2dLR1ZqYUc4Z0lrTnZkV3hrSUc1dmRDQnpiM1Z5WTJVZ1kyOXpiVzl6TG1OdmJtWWlJRHNnWlhocGRDQTFLUXB6WlhRZ0syRUtDaU1nVG1WbFpHVmtJR0o1SURJMWRtVnlhV1o1TFdkcGRDQW9hWE1nYm05MElITmxkQ0JwYmlBdlpYUmpMMk52YzIxdmN5OWpiM050YjNNdVkyOXVaaWtLWlhod2IzSjBJRU5QVTAxUFUxOURUMDVHWDBSSlVqMHZaWFJqTDJOdmMyMXZjd29LSXlCVGNHRnljMlVnWTJobFkydHZkWFFnWTI5emJXOXpJSEpsY0c4S0tBb2dJRzFyWkdseUlDMXdJQ0lrUTA5VFRVOVRYMUpGVUU4aUNpQWdZMlFnSWlSRFQxTk5UMU5mVWtWUVR5SWdmSHdnS0NCbFkyaHZJQ0pGY25KdmNpQmphR0Z1WjJsdVp5QnBiblJ2SUNSRFQxTk5UMU5mVWtWUVR5SWdPeUJsZUdsMElERXhJQ2tLSUNCbmFYUWdhVzVwZEFvZ0lHZHBkQ0J5WlcxdmRHVWdZV1JrSUMxbUlHOXlhV2RwYmlBaUpISmxjRzhpQ2lBZ1oybDBJR052Ym1acFp5QmpiM0psTG5Od1lYSnpaVU5vWldOcmIzVjBJSFJ5ZFdVS0lDQm5hWFFnWTI5dVptbG5JSEJoWTJzdWRHaHlaV0ZrY3lBeENpQWdaMmwwSUdOdmJtWnBaeUJ3WVdOckxtUmxiSFJoUTJGamFHVlRhWHBsSURFS0lDQm5hWFFnWTI5dVptbG5JR052Y21VdWNHRmphMlZrUjJsMFYybHVaRzkzVTJsNlpTQXhObTBLSUNCbmFYUWdZMjl1Wm1sbklHTnZjbVV1Y0dGamEyVmtSMmwwVEdsdGFYUWdNVEk0YlFvZ0lHZHBkQ0JqYjI1bWFXY2djR0ZqYXk1M2FXNWtiM2ROWlcxdmNua2dNVEk0YlFvZ0lHZHBkQ0JqYjI1bWFXY2dZMjl5WlM1aWFXZEdhV3hsVkdoeVpYTm9iMnhrSURWdENpQWdld29nSUNBZ1pXTm9ieUFpWjJ4dlltRnNMeUlLSUNBZ0lHVmphRzhnSWlGbmJHOWlZV3d2WkdsemRDOWpiM050YjNNdGNHRmphMkZuWlhNdklnb2dJQ0FnWldOb2J5QWlhRzl6ZEhNdkpHaHZjM1J1WVcxbEx5SUtJQ0I5SUQ0K0lDNW5hWFF2YVc1bWJ5OXpjR0Z5YzJVdFkyaGxZMnR2ZFhRS0tRb2pJRlpsY21sbWVTQnlaWEJ2Q2k5bGRHTXZZMjl6Ylc5ekwzVndaR0YwWlM1a0x6STFkbVZ5YVdaNUxXZHBkQ0I4ZkNBb0lHVmphRzhnSWtaaGFXeGxaQ0IwYnlCMlpYSnBabmtnWTI5emJXOXpJSEpsY0c5emFYUnZjbmtpSURzZ1pYaHBkQ0EySUNrS1pXTm9ieUFuTFMwdExTMHRMUzB0TFMwdExTMHRMUzB0TFMwdExTMHRMUzBuQ21WamFHOGdKME52YzIxdmN5QnlaWEJ2YzJsMGIzSjVJSFpsY21sbWFXVmtKd3BsWTJodklDY3RMUzB0TFMwdExTMHRMUzB0TFMwdExTMHRMUzB0TFMwdExTY0tDbTFoYm1sbVpYTjBYM0JoZEdnOUlpOTJZWEl2WTJGamFHVXZZMjl6Ylc5ekwzSmxjRzh2YUc5emRITXZKR2h2YzNSdVlXMWxMMjFoYm1sbVpYTjBMbXB6YjI0aUNuUmxjM1FnTFdZZ0lpUnRZVzVwWm1WemRGOXdZWFJvSWlCOGZDQW9aV05vYnlBaVNHOXpkQ0J0WVc1cFptVnpkQ0J1YjNRZ1ptOTFibVFnWm05eUlDUm9iM04wYm1GdFpTSWdKaVlnWlhocGRDQTNLUXBsWTJodklDSlZjMmx1WnlCdFlXNXBabVZ6ZERvZ0pHMWhibWxtWlhOMFgzQmhkR2dpQ2dwblpYUmZiV0Z1YVdabGMzUmZhMlY1S0NrZ2V3b2dJR050WkQwaWFXMXdiM0owSUdwemIyNDdJSEJ5YVc1MEtHcHpiMjR1Ykc5aFpDaHZjR1Z1S0Nja2JXRnVhV1psYzNSZmNHRjBhQ2NwS1M1blpYUW9KeVF4SnlrZ2IzSWdKeWNwSWdvZ0lIQjVkR2h2YmlBdFl5QWlKR050WkNJZ2ZId2djSGwwYUc5dU1pQXRZeUFpSkdOdFpDSWdmSHdnY0hsMGFHOXVNeUF0WXlBaUpHTnRaQ0lnZkh3Z0tHVmphRzhnSWs1dklIQjVkR2h2YmlCaGRtRnBiR0ZpYkdVaUlEc2daWGhwZENBNEtRcDlDZ29qSUVOb1pXTnJJR1p2Y2lCb2IzTjBibUZ0WlFwbWNXUnVQU0lrS0dkbGRGOXRZVzVwWm1WemRGOXJaWGtnYUc5emRHNWhiV1VwSWdwcFppQmJJQzE2SUNJa1puRmtiaUlnWFRzZ2RHaGxiZ29nSUdWamFHOGdUbThnYUc5emRHNWhiV1VnWjJsMlpXNGdhVzRnYldGdWFXWmxjM1F1YW5OdmJnb2dJR1Y0YVhRZ01ncGxiSE5sQ2lBZ1kyOXpiVzl6WDNKbGNHOWZhRzl6ZEc1aGJXVTlJbHdrUTA5VFRVOVRYMUpGVUU4dmFHOXpkSE12SkdaeFpHNHZJZ3BtYVFvS0l5QkRhR1ZqYXlCbWIzSWdiM01LYjNNOUlpUW9aMlYwWDIxaGJtbG1aWE4wWDJ0bGVTQnZjeWtpQ21sbUlGc2dMWG9nSWlSdmN5SWdYVHNnZEdobGJnb2dJR1ZqYUc4Z1RtOGdUMU1nWjJsMlpXNGdhVzRnYldGdWFXWmxjM1F1YW5OdmJnb2dJR1Y0YVhRZ01ncGxiSE5sQ2lBZ1kyOXpiVzl6WDNKbGNHOWZiM005SWx3a1EwOVRUVTlUWDFKRlVFOHZiM012Skc5ekx5SUtabWtLQ2lNZ1FXUmtJRzl6SUhCaGRHZ2dkRzhnYzNCaGNuTmxJR05vWldOcmIzVjBDbVZqYUc4Z0ltOXpMeVJ2Y3k4aUlENCtJQ0lrUTA5VFRVOVRYMUpGVUU4dkxtZHBkQzlwYm1adkwzTndZWEp6WlMxamFHVmphMjkxZENJS0NpTWdVMlYwSUdOdmMyMXZjeUJ5WlhCdmN5QmhibVFnZEdGbklIQnlaV1pwZUFwamIzTnRiM05mY21Wd2IxOW5iRzlpWVd3OUlsd2tRMDlUVFU5VFgxSkZVRTh2WjJ4dlltRnNMeUlLQ21OdmMyMXZjMTl5WlhCdlgyMXZaR1ZzY3owaUpHTnZjMjF2YzE5eVpYQnZYMmh2YzNSdVlXMWxPaVJqYjNOdGIzTmZjbVZ3YjE5dmN6b2tZMjl6Ylc5elgzSmxjRzlmWjJ4dlltRnNJZ29LSXlCRGIyNW1hV2QxY21VZ2JXOWtaV3dLYzJWa0lDMXBJQzB0SUNKekxDTkRUMU5OVDFOZlVrVlFUMTlOVDBSRlRGTTlMaW9zUTA5VFRVOVRYMUpGVUU5ZlRVOUVSVXhUUFZ3aUpHTnZjMjF2YzE5eVpYQnZYMjF2WkdWc2Mxd2lMQ0lnTDJWMFl5OWpiM050YjNNdlkyOXpiVzl6TG1OdmJtWUtDaU1nVW5WdUlHTnZjMjF2Y3l3Z2FYUWdhVzV6ZEdGc2JITWdhWFJ6Wld4bUlHbHVJR055YjI1MFlXSUtJeUJqYjNOdGIzTWdMWFlnZFhCa1lYUmxDaU1nWm14dlkyc2dMM1J0Y0M5amIzTnRiM010Wm14dlkyc2dZMjl6Ylc5eklDMTJJR0Z3Y0d4NUNnbz0KICBlbmNvZGluZzogYjY0CiAgb3duZXI6IHJvb3Q6cm9vdAogIHBhdGg6IC92YXIvb3B0L2Nvc21vcy1ib290c3RyYXAKICBwZXJtaXNzaW9uczogJzYwMCcK"
  }
}

resource "nutanix_subnet" "next-iac-managed2" {
  cluster_reference = {
    kind = "cluster"
    uuid = "${data.nutanix_clusters.clusters.entities.0.metadata.uuid}"
  }

  name        = "next-iac-managed-tes2"
  vlan_id     = 40
  subnet_type = "VLAN"

  prefix_length = 20

  default_gateway_ip = "10.5.80.1"
  subnet_ip          = "10.5.80.0"

  dhcp_domain_name_server_list = ["8.8.8.8", "4.2.2.2"]
  dhcp_domain_search_list      = ["nutanix.com", "eng.nutanix.com"]
}
