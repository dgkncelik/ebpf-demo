# Bolum 7 — Demo 3: Ag Koruyucusu

[← Demo 2](06-demo-dosya.md) | [INDEX](../INDEX.md) | [Sonraki: Bonus →](08-bonus.md)

---

## Hedef

Kernel seviyesinde network paketlerini ve TCP baglanitilarini izleyin — hangi protokollerin aktif oldugunu ve kimin baglandigini gorun.

**SysAdmin senaryosu:** *"Serhat, biri bizi flood mu ediyor? Hangi protokol tum bant genisligimizi yiyor?"*

---

## eBPF ile Network Tracing

> *Referans: [eBPFHub — Tracking network connections](https://ebpfhub.dev/tr/exercises/chapter-3/socket-and-connect/)*

eBPF, network aktivitesini birden fazla katmanda trace edebilir:

```
Uygulama (curl, nginx)
    │  uprobe
    ▼
System Call'lar (connect, send, recv)
    │  tracepoint:syscalls:sys_enter_connect
    ▼
Socket Katmani
    │  tracepoint:sock:inet_sock_set_state
    ▼
TCP/UDP Implementasyonu
    │  kprobe:tcp_v4_rcv, kprobe:udp_rcv
    ▼
IP Katmani
    │  kprobe:ip_rcv
    ▼
Network Driver
    │  XDP (en hizli!)
    ▼
NIC Donanimi
```

Her seviyede farkli bilgiler mevcuttur. Daha yukarida → daha fazla context (process bilgisi). Daha asagida → daha hizli, daha az overhead.

---

## connect() Syscall'i

> *Referans: [eBPFHub — Tracking network connections](https://ebpfhub.dev/tr/exercises/chapter-3/socket-and-connect/)*

```c
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

Entry noktasinda (`sys_enter_connect`):
- `ctx->args[0]` = socket file descriptor
- `ctx->args[1]` = `sockaddr` struct'ina pointer (user space)

Exit noktasinda (`sys_exit_connect`):
- `ctx->ret == 0` → Baglanti basarili
- `ctx->ret < 0` → Baglanti basarisiz (errno)

### sockaddr Struct'i

```c
struct sockaddr_in {
    u16 sin_family;  // AF_INET = 2
    u16 sin_port;    // Port (network byte order!)
    u32 sin_addr;    // IP adresi
    char __pad[8];
};
```

> **Onemli:** Port ve IP degerleri **network byte order** (big-endian) formatindadir. Host order'a donusturmek icin `bpf_ntohs()` kullanin.

---

---

# `DEMO` — Birlikte Inceleyelim

> Birlikte kodu inceleriz ve calistiririz. Puan **yoktur**.

## Canli Kodlama — Paket Sayici

### Adim 1: Script'i inceleyin

```bash
cd /opt/ebpf-demo/demos/03-net-guard
cat net_counter.bt
```

Icerik:
```
kprobe:ip_rcv
{
    @packets[comm] = count();
}

interval:s:5
{
    printf("\n--- Paket sayilari (son 5sn) ---\n");
    print(@packets);
    clear(@packets);
}
```

### Adim 2: Calistirin (Terminal 1)

```bash
sudo bpftrace net_counter.bt
```

### Adim 3: Trafik olusturun (Terminal 2)

```bash
ping -c 10 127.0.0.1
curl -s example.com > /dev/null
ssh localhost echo test 2>/dev/null
```

Her 5 saniyede bir process bazinda paket sayisini goreceksiniz. Diger takimlarin trafigini de goreceksiniz!

> **Not:** Bu gosterimdi — puan yok. Simdi asil challenge'lar basliyor!

---

---

# `CTF` — Takimlar SSH'ta Cozer, Puan Kazanir!

> Takimlar kendi basina calisir. Ilk tamamlayan takim **+50 bonus puan** alir.

## Challenge 3A — TCP Baglanti Takipcisi (+50 puan)

`sock:inet_sock_set_state` tracepoint'ini kullanarak yeni TCP baglantilarini hedef port'a gore sayan bir bpftrace one-liner yazin.

Once mevcut field'lari inceleyin:

```bash
sudo bpftrace -lv 'tracepoint:sock:inet_sock_set_state'
```

**Ipucu:** `newstate == 1` TCP_ESTABLISHED anlamina gelir.

<details>
<summary>Cozum</summary>

```bash
sudo bpftrace -e '
tracepoint:sock:inet_sock_set_state
/args.newstate == 1/
{
    @connections[args.dport] = count();
}'
```

</details>

---

## Challenge 3B — Protokol Dagilimi (+50 puan)

Paketleri TCP, UDP ve ICMP olarak ayri ayri sayin.

Ayri kprobe'lar kullanin: `tcp_v4_rcv`, `udp_rcv`, `icmp_rcv`.

<details>
<summary>Cozum</summary>

```
kprobe:tcp_v4_rcv  { @proto["TCP"]  = count(); }
kprobe:udp_rcv     { @proto["UDP"]  = count(); }
kprobe:icmp_rcv    { @proto["ICMP"] = count(); }

interval:s:5
{
    print(@proto);
    clear(@proto);
}
```

</details>

---

## Ekstra: TCP Baglanti Tracer'i

Daha detayli bir ornek calistirin:

```bash
cd /opt/ebpf-demo/demos/06-net-trace
sudo bpftrace tcp_connect.bt
```

Bu, TCP state degisikliklerini (ESTABLISHED, CLOSE) process, port ve zaman bilgisiyle gosterir.

---

> **BASARIM:** *"Paket Fisildayicisi"* — Network'u kernel seviyesinde izlediniz!
>
> Ilk tamamlayan takim **+50 bonus puan** alir.

---

[← Demo 2](06-demo-dosya.md) | [INDEX](../INDEX.md) | [Sonraki: Bonus →](08-bonus.md)
