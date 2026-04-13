# Bolum 9 — eBPFHub & Sonraki Adimlar

[← Bonus](08-bonus.md) | [INDEX](../INDEX.md) | [Skor Tablosu →](../SCORECARD.md)

---

## eBPFHub ile Devam Edin

[eBPFHub](https://ebpfhub.dev/), eBPF programlarini dogrudan **tarayicinizda** yazmaniza, compile etmenize ve calistirmaniza olanak tanir — sunucu kurulumu gerekmez.

> *Referans: [eBPFHub — Ana Sayfa](https://ebpfhub.dev/tr/)*

---

## Haftalik Ogrenme Plani

Bu workshop'tan sonra takip etmeniz gereken yol:

| Hafta | Konu | eBPFHub Linki |
|-------|------|--------------|
| 1 | BPF icin C Temelleri | [Program Yapisi & Type'lar](https://ebpfhub.dev/tr/exercises/c-temelleri/program-yapisi-tipler/) |
| 1 | Pointer'lar & String'ler | [Pointers & Strings](https://ebpfhub.dev/tr/exercises/c-temelleri/pointers-strings/) |
| 1 | BPF C Ozellikleri | [BPF C Pitfalls](https://ebpfhub.dev/tr/exercises/c-temelleri/bpf-c-pitfalls/) |
| 2 | Event data okuma | [Reading Event Data](https://ebpfhub.dev/tr/exercises/chapter-1/2-reading-data/) |
| 2 | Syscall tracing | [Tracing a System Call](https://ebpfhub.dev/tr/exercises/chapter-1/3-reading-syscalls/) |
| 2 | Syscall array'leri | [Reading Syscall Arrays](https://ebpfhub.dev/tr/exercises/chapter-1/4-reading-syscall-arrays/) |
| 3 | Map'ler & state | [Maps and Multiple Programs](https://ebpfhub.dev/tr/exercises/chapter-2/intro-maps-and-programs/) |
| 3 | Buffer okuma | [Reading Syscall Buffers](https://ebpfhub.dev/tr/exercises/chapter-2/read-buffer-contents/) |
| 3 | Cross-syscall tracking | [Cross-syscall State](https://ebpfhub.dev/tr/exercises/chapter-2/read-file-password/) |
| 4 | bpftool & dev ortami | [Dev Environment](https://ebpfhub.dev/tr/exercises/ebpf-araclar/dev-environment/) |
| 4 | Verifier derinlemesine | [Verifier & BTF/CO-RE](https://ebpfhub.dev/tr/exercises/ebpf-araclar/verifier-btf/) |
| 4 | Verifier hatalari | [Verifier Challenge](https://ebpfhub.dev/tr/exercises/ebpf-araclar/verifier-challenge/) |
| 5 | Network: connect tracing | [Tracking Connections](https://ebpfhub.dev/tr/exercises/chapter-3/socket-and-connect/) |
| 5 | Kprobe & TCP | [Kprobe Temelleri](https://ebpfhub.dev/tr/exercises/chapter-3/tcp-connect/) |
| 5 | TCP/HTTP | [TCP Packet Reading](https://ebpfhub.dev/tr/exercises/chapter-3/read-http-password/) |
| 5 | DNS parsing | [DNS Packet Parsing](https://ebpfhub.dev/tr/exercises/chapter-3/read-dns/) |
| 6 | XDP temelleri | [XDP Temelleri](https://ebpfhub.dev/tr/exercises/xdp/xdp-temelleri/) |
| 6 | Rate limiting & firewall | [Rate Limiting](https://ebpfhub.dev/tr/exercises/xdp/rate-limiting-firewall/) |
| 7 | Load balancing | [Packet Rewriting & LB](https://ebpfhub.dev/tr/exercises/xdp/packet-rewriting-lb/) |
| 7 | Program type'lar & debugging | [Deep Dive](https://ebpfhub.dev/tr/exercises/xdp/program-types-debugging/) |
| 8 | Ileri konular: Go entegrasyonu | [Tracing & XDP Root](https://ebpfhub.dev/tr/exercises/ileri-konular/tracing-xdp-root/) |

---

## Hedef Projeler

> *Referans: [eBPFHub — Kaynaklar](https://ebpfhub.dev/tr/exercises/chapter-0/3_kaynaklar/)*

Ogrenme yolunu tamamladiktan sonra bunlari insa edin:

1. **L4 Load Balancer** — XDP tabanli ([challenge](https://codingchallenges.fyi/challenges/challenge-load-balancer/))
2. **DDoS Engine** — XDP ingress filtering
3. **DNS Policy Filter** — DNS query bazli filtreleme
4. **DNS Resolver** (opsiyonel) — [challenge](https://codingchallenges.fyi/challenges/challenge-dns-resolver)

---

## Incelenecek Referans Projeler

| Proje | Aciklama |
|-------|----------|
| [Katran](https://github.com/facebookincubator/katran) | Facebook'un L4 load balancer'i (XDP) |
| [lb-from-scratch](https://github.com/lizrice/lb-from-scratch) | Liz Rice'in LB'si — iyi bir ilk proje |
| [DnsTrace](https://github.com/furkanonder/DnsTrace) | eBPF ile DNS tracing |
| [xdp-tutorial](https://github.com/xdp-project/xdp-tutorial) | Resmi XDP tutorial reposu |
| [eBPFeXPLOIT](https://github.com/bfengj/eBPFeXPLOIT) | eBPF exploit ornekleri |

---

## Sunucuda Zaten Yuklu bcc-tools

`setup.sh` ile yuklenen production-ready eBPF araclari:

```bash
# Yeni process'leri trace et (Demo 1 gibi ama production-grade)
sudo execsnoop-bpfcc

# Dosya acma islemlerini trace et (Demo 2 gibi)
sudo opensnoop-bpfcc

# TCP baglantilarini trace et
sudo tcpconnect-bpfcc

# Disk I/O latency histogram'i
sudo biolatency-bpfcc

# Yavas filesystem islemleri (>1ms olanlar)
sudo ext4slower-bpfcc 1

# DNS sorgu latency'si
sudo gethostlatency-bpfcc

# Page cache hit orani
sudo cachestat-bpfcc

# CPU stack trace profili (5 saniye boyunca)
sudo profile-bpfcc -F 99 5
```

---

## Ek Kaynaklar

- [eBPFHub — Tam Mufredat](https://ebpfhub.dev/tr/) (Turkce)
- [eBPFHub — English](https://ebpfhub.dev/)
- [eBPFHub Discord](https://discord.gg/ZahkB4F7)
- [ebpf.io — What is eBPF?](https://ebpf.io/what-is-ebpf/)
- [bpftrace Reference Guide](https://github.com/bpftrace/bpftrace/blob/master/docs/reference_guide.md)
- [BPF Performance Tools (Brendan Gregg)](https://www.brendangregg.com/bpf-performance-tools-book.html)
- [RHEL 9 eBPF Kilavuzu](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_and_managing_networking/assembly_understanding-the-ebpf-features-in-rhel_configuring-and-managing-networking)
- [xdp-tutorial](https://github.com/xdp-project/xdp-tutorial)
- [iximiuz Labs](https://labs.iximiuz.com/) — Interaktif Linux & networking kurslari

---

## Hizli Referans Karti

### bpftrace Built-in Degiskenler

| Degisken | Aciklama |
|----------|----------|
| `pid` | Process ID |
| `tid` | Thread ID |
| `uid` | User ID |
| `gid` | Group ID |
| `comm` | Process adi (maks 16 karakter) |
| `nsecs` | Nanosaniye timestamp |
| `elapsed` | bpftrace baslangicindan beri nanosaniye |
| `cpu` | CPU numarasi |
| `args` | Tracepoint argument struct'i |
| `retval` | Return value (return probe'lar icin) |
| `probe` | Tam probe ismi |

### BPF Helper Fonksiyonlari

> *Referans: [eBPFHub — Hizli Referans](https://ebpfhub.dev/tr/exercises/referans/quick-reference/)*

| Ihtiyac | Helper | Not |
|---------|--------|-----|
| Kernel memory oku | `bpf_probe_read_kernel_str()` | Kernel adres alani icin |
| User memory oku | `bpf_probe_read_user_str()` | User adres alani icin |
| Process adi al | `bpf_get_current_comm()` | comm (task adi) dondurur |
| String karsilastir | `bpf_strncmp()` | Degisken buf ile sabit karsilastir |
| Port byte order | `bpf_ntohs()` | Network → host (16-bit) |
| IP byte order | `bpf_ntohl()` | Network → host (32-bit) |
| Map'e yaz | `bpf_map_update_elem()` | Key-value store |
| Map'ten oku | `bpf_map_lookup_elem()` | Pointer dondurur (NULL olabilir!) |
| Map'ten sil | `bpf_map_delete_elem()` | Key ile entry sil |
| Debug ciktisi | `bpf_printk()` | Sadece gelistirme, trace pipe'a yazar |

---

[← Bonus](08-bonus.md) | [INDEX](../INDEX.md) | [Skor Tablosu →](../SCORECARD.md)
