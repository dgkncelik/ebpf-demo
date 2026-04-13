# Bolum 2 — Program Turleri: Tracepoint, Kprobe, XDP, Uprobe

[← eBPF Nedir?](01-ebpf-nedir.md) | [INDEX](../INDEX.md) | [Sonraki: Verifier →](03-verifier.md)

---

> *Referans: [eBPFHub — eBPF'e Giris](https://ebpfhub.dev/tr/exercises/chapter-0/1_theory/)*

eBPF programlari, **kernel'de nereye attach olduklarina** gore kategorize edilir. Her tur farkli bir context alir ve farkli yeteneklere sahiptir.

---

## 1. Tracepoint'ler — Stabil Kernel Event Hook'lari

Tracepoint'ler, kernel kodu boyunca tanimlanmis **onceden belirlenmis** hook noktalaridir. Kernel'in **stable ABI**'sinin bir parcasidir — minor versiyonlar arasinda degismezler.

### Pratikte Gorelim (SSH ile sunucuda calistirin)

```bash
# Sistemdeki tum tracepoint'leri listeleyin:
sudo bpftrace -l 'tracepoint:*' | wc -l          # genellikle 1000+

# Syscall tracepoint'lerini listeleyin:
sudo bpftrace -l 'tracepoint:syscalls:*' | head -20

# Belirli bir tracepoint'in field'larini gorun:
sudo bpftrace -lv 'tracepoint:syscalls:sys_enter_openat'
```

### Tracepoint Context Nasil Calisiyor?

> *Referans: [eBPFHub — Reading event data](https://ebpfhub.dev/tr/exercises/chapter-1/2-reading-data/)*

Her tracepoint, event'e ozel field'lar iceren bir **context struct** saglar. Bunu inceleyebilirsiniz:

```bash
# Kernel'in sagladigi struct layout'u gorun:
cat /sys/kernel/tracing/events/sched/sched_process_exec/format
```

Cikti:
```
format:
  unsigned short common_type;           offset:0;   size:2;
  unsigned char common_flags;           offset:2;   size:1;
  unsigned char common_preempt_count;   offset:3;   size:1;
  int common_pid;                       offset:4;   size:4;
  __data_loc char[] filename;           offset:8;   size:4;
  pid_t pid;                            offset:12;  size:4;
  pid_t old_pid;                        offset:16;  size:4;
```

Bu, event tetiklendiginde kernel'in size **tam olarak hangi verileri** verdigini gosterir.

### `__data_loc` Nedir?

> *Referans: [eBPFHub — Reading event data](https://ebpfhub.dev/tr/exercises/chapter-1/2-reading-data/)*

Yukaridaki `filename` field'ina dikkat edin — tipi `__data_loc char[]`. Bu normal bir pointer degildir.

`__data_loc` on eki, field'in string'in kendisini degil, **kodlanmis konumunu** icerdigini belirtir:

- **Alt 16 bit:** Offset (string'in struct basindan ne kadar uzakta oldugu)
- **Ust 16 bit:** Length (string'in uzunlugu)

bpftrace bunu sizin icin otomatik handle eder (`str(args.filename)`), ama C ile yazarken bu ayrimi bilmeniz gerekir.

### SysAdmin'ler icin Onemli Tracepoint Kategorileri

| Kategori | Ornek Tracepoint'ler | Kullanim Alani |
|----------|---------------------|---------------|
| **syscalls** | `sys_enter_openat`, `sys_enter_execve`, `sys_enter_connect` | Herhangi bir system call'i trace edin |
| **sched** | `sched_process_exec`, `sched_process_exit`, `sched_switch` | Process yasam dongusu |
| **block** | `block_rq_issue`, `block_rq_complete` | Disk I/O tracing |
| **net** | `net_dev_xmit`, `netif_receive_skb` | Network paket akisi |
| **sock** | `inet_sock_set_state` | TCP baglanti durumu degisiklikleri |

### Entry/Exit Pattern'i

> *Referans: [eBPFHub — Tracing a system call](https://ebpfhub.dev/tr/exercises/chapter-1/3-reading-syscalls/)*

System call'larin iki tracepoint'i vardir — **entry** (cagri basladiginda) ve **exit** (dondugunde):

```
sys_enter_openat    →    kernel is yapar    →    sys_exit_openat
   (filename,               ...                     (return value:
    flags, mode var)                                  fd veya error code)
```

Ikisini birlestirerek:
- **Latency** olcebilirsiniz (syscall ne kadar surdu)
- **Girdi/cikti iliskilendirebilirsiniz** (hangi dosya acma basarili, hangi basarisiz)

### Syscall Argument'leri Nasil Okunuyor?

> *Referans: [eBPFHub — Tracing a system call](https://ebpfhub.dev/tr/exercises/chapter-1/3-reading-syscalls/)*

Syscall tracepoint'leri **genel** bir struct kullanir:

```c
struct trace_event_raw_sys_enter {
    long int id;               // Syscall numarasi
    long unsigned int args[6]; // Argument'ler (maksimum 6)
};
```

Neden 6? Cunku syscall'larin alabilecegi **maksimum argument sayisi** budur. Tum argument'ler `unsigned long` tipindedir — dogru tipe cast etmek size kalmis.

`execve` ornegi:

```c
int execve(const char *filename, char *const argv[], char *const envp[]);
//          args[0]                args[1]               args[2]
```

**Onemli:** `args[0]` user space bellegine isaret eder. Guvenle okumak icin `bpf_probe_read_user_str()` kullanmaniz gerekir (bpftrace bunu `str()` ile otomatik yapar).

---

## 2. Kprobe'lar — Herhangi Bir Kernel Fonksiyonuna Hook

Kprobe'lar, **herhangi bir kernel fonksiyonuna ismiyle** attach olur. Tracepoint'lerin aksine, stable API'nin parcasi **degildir** — fonksiyon isimleri kernel versiyonlari arasinda degisebilir.

[REVIEW: burada trace pointler ve kproble'larin farki hakkinda biraz daha detay ver. Implementasyon ve uygulamada ne gibi farklari var? nerede hangisi kullanilmali? ]

```bash
# Mevcut kernel fonksiyonlarini listeleyin:
sudo bpftrace -l 'kprobe:*' | wc -l          # genellikle 50.000+

# TCP baglantilari geldiginde trace edin:
sudo bpftrace -e 'kprobe:tcp_v4_rcv { @[comm] = count(); }'
```

### Tracepoint mi Kprobe mu?

| | Tracepoint | Kprobe |
|---|-----------|--------|
| Stabilite | Versiyonlar arasi stabil | Kernel update'inde bozulabilir |
| Kapsam | Secilmis event seti | HERHANGi bir kernel fonksiyonu |
| Performans | Biraz daha hizli | Biraz daha yavas |
| Kullanim | Production monitoring | Derin debugging |

**Kural:** Tracepoint varsa tracepoint kullanin. Yoksa kprobe'a basvurun.

---

## 3. XDP — eXpress Data Path

> *Referans: [eBPFHub — XDP Temelleri ve Packet Parsing](https://ebpfhub.dev/tr/exercises/xdp/xdp-temelleri/)*

XDP programlari **network driver seviyesinde** hook olur — paketleri kernel'in network stack'ine **ulasmadan once** isler. Linux'ta mumkun olan en hizli paket isleme yoludur.

### XDP Action'lari

```
                    Paket NIC'e gelir
                           │
                           ▼
                    ┌──────────────┐
                    │  XDP Programi│
                    │  BURADA      │
                    │  calisir     │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┬──────────────┐
              ▼            ▼            ▼              ▼
         XDP_DROP     XDP_PASS     XDP_TX       XDP_REDIRECT
         Sessizce     Kernel       Ayni         Baska bir
         at           network      interface'den interface'e
         (en hizli!)  stack'e      geri gonder  yonlendir
                      ilet
```

| Action | Ne Yapar | Kullanim Alani |
|--------|----------|---------------|
| `XDP_PASS` | Paketi kernel stack'e ilet | Normal isleme |
| `XDP_DROP` | Paketi aninda at | DDoS engelleme, firewall |
| `XDP_TX` | Paketi ayni NIC'den geri gonder | Test, reflection |
| `XDP_REDIRECT` | Baska bir interface'e yonlendir | Load balancing |
| `XDP_ABORTED` | At + trace event uret | Hata yonetimi |

### Packet Parsing Pattern'i

> *Referans: [eBPFHub — XDP Temelleri](https://ebpfhub.dev/tr/exercises/xdp/xdp-temelleri/)*

Her XDP programi bu pattern'i izler — katman katman parse et, **her zaman bounds check yap:**

```c
SEC("xdp")
int xdp_parser(struct xdp_md *ctx) {
    void *data     = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;

    // L2: Ethernet header
    struct ethhdr *eth = data;
    if (data + sizeof(*eth) > data_end)     // BOUNDS CHECK (verifier bunu zorlar!)
        return XDP_PASS;

    // L3: IP header (sadece IPv4 ise)
    if (eth->h_proto == bpf_htons(ETH_P_IP)) {
        struct iphdr *ip = data + sizeof(*eth);
        if ((void *)(ip + 1) > data_end)    // BOUNDS CHECK yine
            return XDP_PASS;

        // Artik ip->saddr, ip->protocol vs. guvenle okunabilir
    }
    return XDP_PASS;
}
```

**Tam parse chain ornegi (Ethernet → IP → TCP/UDP):**

```c
SEC("xdp")
int xdp_full_parse(struct xdp_md *ctx) {
    void *data = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;

    // L2: Ethernet
    struct ethhdr *eth = data;
    if (data + sizeof(*eth) > data_end)
        return XDP_PASS;

    if (eth->h_proto != bpf_htons(ETH_P_IP))
        return XDP_PASS;

    // L3: IPv4
    struct iphdr *ip = data + sizeof(*eth);
    if ((void *)(ip + 1) > data_end)
        return XDP_PASS;

    // L4: TCP veya UDP
    void *l4 = (void *)ip + (ip->ihl * 4);

    if (ip->protocol == IPPROTO_TCP) {
        struct tcphdr *tcp = l4;
        if ((void *)(tcp + 1) > data_end)
            return XDP_PASS;
        if (tcp->dest == bpf_htons(80))
            return XDP_DROP;      // HTTP trafigini dusur
    } else if (ip->protocol == IPPROTO_UDP) {
        struct udphdr *udp = l4;
        if ((void *)(udp + 1) > data_end)
            return XDP_PASS;
        if (udp->dest == bpf_htons(53))
            return XDP_DROP;      // DNS trafigini dusur
    }

    return XDP_PASS;
}
```

> Verifier her bounds check'i **zorlar**. Birini atlarsiniz, programiniz yuklenmez.

---

## 4. Uprobe'lar — User-Space Fonksiyonlarina Hook

Uprobe'lar **user-space binary'lerdeki** fonksiyonlara attach olur. Uygulamayi degistirmeden uygulama davranisini trace etmek icin kullanilir.

[REVIEW: kprobe ve tracepoint ile farki nedir, gunluk hayatimizda kullanimini orneklendir. Bunun icinde demoya bir ornek eklenebilir]

```bash
# libc'deki her malloc cagrisini trace edin:
sudo bpftrace -e 'uprobe:/lib64/libc.so.6:malloc { @[comm] = count(); }'

# SSL_read'i trace edin (sifrelenmis icerik cozulurken):
sudo bpftrace -e 'uprobe:/usr/lib64/libssl.so:SSL_read { printf("%s\n", comm); }'
```

---

## Ozet Tablosu

| Tur | Nereye Hook Olur | Stabilite | Kullanim |
|-----|-----------------|-----------|----------|
| **Tracepoint** | Onceden tanimli kernel event'leri | Stabil | Production monitoring |
| **Kprobe** | Herhangi bir kernel fonksiyonu | Degisebilir | Derin debugging |
| **XDP** | Network driver (pre-stack) | Stabil | Hizli paket filtreleme |
| **Uprobe** | User-space binary fonksiyonlari | Binary'ye bagli | Uygulama tracing |

---

## Quiz 2 — Takim Yarismasil

> Her dogru cevap: **+20 puan** (takim) + **+10 puan** (bireysel)

**S1:** Tracepoint ile kprobe arasindaki temel fark nedir?

**S2:** Paketleri kernel network stack'inden once islyen eBPF program turu hangisi?

**S3:** Bir tracepoint'in field'larini gormek icin hangi komutu kullaniriz?

---

[← eBPF Nedir?](01-ebpf-nedir.md) | [INDEX](../INDEX.md) | [Sonraki: Verifier →](03-verifier.md)
