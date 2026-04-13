# eBPF Workshop — SysAdmin Takimi icin

Sistem yonetici takimi icin tasarlanmis, oyunlastirilmis, SSH tabanli eBPF workshop'u. RHEL 9.x uzerinde calisir.

**Sunan:** Dogukan
**Katilimcilar:** Burak, Oguzhan, Yasin, Buse, Ugur, Serhat
**Referans:** [eBPFHub](https://ebpfhub.dev/) — Tarayicida eBPF aliştirmalari

---

## Dosya Yapisi

```
ebpf-demo/
├── INDEX.md                           # Ana navigasyon dosyasi (BURADAN BASLAYIN)
├── SCORECARD.md                       # Canli skor tablosu
├── setup.sh                           # Sunucu kurulum script'i (multi-user)
├── README.md                          # Bu dosya
├── sunumlar/
│   ├── 00-baslangic.md                # Takim olusturma & SSH baglantisi
│   ├── 01-ebpf-nedir.md               # eBPF nedir? Teori
│   ├── 02-program-turleri.md          # Tracepoint, Kprobe, XDP, Uprobe
│   ├── 03-verifier.md                 # Verifier ve guvenlik
│   ├── 04-mapler.md                   # Map'ler ve state yonetimi
│   ├── 05-demo-exec.md               # Demo 1: execve tracing
│   ├── 06-demo-dosya.md              # Demo 2: openat tracing
│   ├── 07-demo-ag.md                 # Demo 3: Network tracing
│   ├── 08-bonus.md                   # Bonus challenge'lar
│   └── 09-sonraki-adimlar.md         # eBPFHub yolu & kaynaklar
└── demos/
    ├── 01-hello-exec/
    │   └── trace_exec.bt              # Demo 1: Komut calistirma tracing
    ├── 02-file-spy/
    │   └── file_spy.bt                # Demo 2: Dosya acma izleme
    ├── 03-net-guard/
    │   └── net_counter.bt             # Demo 3: Paket sayma
    ├── 04-verifier-crash/
    │   ├── verifier_break.bt          # Kasitli bozuk script
    │   └── verifier_fix.bt            # Duzeltme sablonu
    ├── 05-map-state/
    │   └── latency_hist.bt            # Entry/exit map pattern ornegi
    ├── 06-net-trace/
    │   └── tcp_connect.bt             # TCP baglanti tracer
    └── challenges/
        ├── lifecycle.bt               # Bonus 1: Process yasam dongusu (sablon)
        ├── slow_reads.bt              # Bonus 2: Yavas syscall bulucu (sablon)
        └── forbidden.bt               # Bonus 3: Yasakli komut dedektoru (sablon)
```

---

## On Kosullar

- RHEL 9.x sunucu (kernel 5.14+)
- Root / sudo erisimi (kurulum icin)
- Katilimcilar icin SSH erisimi

---

## Sunucu Kurulumu (Dogukan icin)

### 1. Repo'yu sunucuya klonlayin

```bash
git clone <repo-url> /opt/ebpf-demo
cd /opt/ebpf-demo
```

### 2. Setup script'ini calistirin

```bash
sudo bash setup.sh
```

Bu script:
- `bpftrace`, `bcc-tools`, `tmux`, kernel header'larini yukler
- Workshop dosyalarini `/opt/ebpf-demo`'ya kopyalar
- 6 katilimci kullanicisi olusturur (burak, oguzhan, yasin, buse, ugur, serhat)
- Her kullaniciya bpftrace icin sudo yetkisi verir
- Smoke test calistirir

### 3. Katilimcilara SSH bilgilerini verin

```
ssh burak@<sunucu-ip>
ssh oguzhan@<sunucu-ip>
ssh yasin@<sunucu-ip>
ssh buse@<sunucu-ip>
ssh ugur@<sunucu-ip>
ssh serhat@<sunucu-ip>
```

Varsayilan sifre: `ebpf2026` (setup.sh'dan degistirilebilir)

---

## Workshop Akisi (90 dakika)

| Sure | Bolum | Dosya |
|------|-------|-------|
| 5 dk | Takim olusturma & SSH | `sunumlar/00-baslangic.md` |
| 15 dk | eBPF teori | `sunumlar/01-ebpf-nedir.md` |
| 10 dk | Program turleri | `sunumlar/02-program-turleri.md` |
| 10 dk | Verifier & guvenlik | `sunumlar/03-verifier.md` |
| 5 dk | Map'ler & state | `sunumlar/04-mapler.md` |
| 10 dk | Demo 1 — Exec tracing | `sunumlar/05-demo-exec.md` |
| 10 dk | Demo 2 — Dosya tracing | `sunumlar/06-demo-dosya.md` |
| 10 dk | Demo 3 — Network tracing | `sunumlar/07-demo-ag.md` |
| 10 dk | Bonus challenge'lar | `sunumlar/08-bonus.md` |
| 5 dk | Sonraki adimlar | `sunumlar/09-sonraki-adimlar.md` |
| 5 dk | Skorlar & oduller | `SCORECARD.md` |

---

## Takimlar

| Takim | Uyeler |
|-------|--------|
| Takim 1 | Burak & Oguzhan |
| Takim 2 | Yasin & Buse |
| Takim 3 | Ugur & Serhat |

Takimlar 5 isimden birini secer: **Kernel Pandas**, **Packet Pirates**, **Trace Wolves**, **Root Causes**, **Seg Faulters**

---

## Oyunlastirma

- **Takim puanlari**: Demo ve challenge tamamlama (maks ~1150 puan)
- **Bireysel puanlar**: Quiz cevaplari ve kisisel basarimlar
- **Rank kademeleri**: Kernel Turisti'nden Kernel Overlord'a
- **6 kupa**: eBPF MVP, Hiz Seytani, Verifier Whisperer, One-Liner Krali, Yaraticilik Odulu, First Blood
- **Oylama turu**: Workshop sonunda One-Liner Krali ve Yaraticilik Odulu icin

---

## Sunucu Ipuclari (Dogukan icin)

- `INDEX.md`'yi ana ekrandan takip edin, bolum bolum ilerleyin
- `SCORECARD.md`'yi ekrana yansıtın — rekabet katilimi arttirir
- Her demoda **satir satir** aciklama yapin — kavramlar burada oturur
- Denemeyi tesvik edin — verifier tehlikeli programlari yakalar
- Bonus challenge'larda sablonlari dagitip takimlari bagimsiz calistirin
- Herkes ayni sunucuda oldugu icin birbirlerinin trace ciktilarini gorurler — bu eglenceli!
- tmux kullanmalarini onerin (cift terminal icin)

---

## Referanslar

- [eBPFHub](https://ebpfhub.dev/) — Tam mufredat (TR + EN)
- [eBPFHub Discord](https://discord.gg/ZahkB4F7)
- [ebpf.io — What is eBPF?](https://ebpf.io/what-is-ebpf/)
- [bpftrace Reference](https://github.com/bpftrace/bpftrace/blob/master/docs/reference_guide.md)
- [xdp-tutorial](https://github.com/xdp-project/xdp-tutorial)
- [RHEL 9 eBPF Docs](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_and_managing_networking/assembly_understanding-the-ebpf-features-in-rhel_configuring-and-managing-networking)
- [iximiuz Labs](https://labs.iximiuz.com/)
