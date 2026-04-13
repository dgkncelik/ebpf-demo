# eBPF Workshop — Kernel'i Yakindan Taniyin

> **Sure:** ~90 dakika (1.5 saat)
> **Hedef Sistem:** RHEL 9.x (kernel 5.14+)
> **Sunan:** Dogukan
> **Katilimcilar:** Burak, Oguzhan, Yasin, Buse, Ugur, Serhat
> **Format:** Teori + Canli kodlama (SSH) + Takim yarismasi
> **Referans:** [eBPFHub](https://ebpfhub.dev/) — Tarayicida eBPF aliştirmalari

---

## Sunum Plani

| # | Bolum | Dosya | Sure | Puan |
|---|-------|-------|------|------|
| 0 | [Baslangic — Takim Olusturma & SSH](sunumlar/00-baslangic.md) | `00-baslangic.md` | 5 dk | 30 |
| 1 | [eBPF Nedir? — Teori](sunumlar/01-ebpf-nedir.md) | `01-ebpf-nedir.md` | 15 dk | — |
| 2 | [Program Turleri — Tracepoint, Kprobe, XDP](sunumlar/02-program-turleri.md) | `02-program-turleri.md` | 10 dk | — |
| 3 | [Verifier ve Guvenlik](sunumlar/03-verifier.md) | `03-verifier.md` | 10 dk | 80 |
| 4 | [Map'ler ve State Yonetimi](sunumlar/04-mapler.md) | `04-mapler.md` | 5 dk | — |
| 5 | [Demo 1 — Kim Ne Calistiriyor?](sunumlar/05-demo-exec.md) | `05-demo-exec.md` | 10 dk | 200 |
| 6 | [Demo 2 — Dosya Casusu](sunumlar/06-demo-dosya.md) | `06-demo-dosya.md` | 10 dk | 200 |
| 7 | [Demo 3 — Ag Koruyucusu](sunumlar/07-demo-ag.md) | `07-demo-ag.md` | 10 dk | 200 |
| 8 | [Bonus Challenge'lar](sunumlar/08-bonus.md) | `08-bonus.md` | 10 dk | 300 |
| 9 | [eBPFHub & Sonraki Adimlar](sunumlar/09-sonraki-adimlar.md) | `09-sonraki-adimlar.md` | 5 dk | — |
| 10 | [Bilgi Yarismasi & Skor Tablosu](sunumlar/10-quiz.md) | `10-quiz.md` | 5 dk | 400 |
| | | | **~90 dk** | |

> **Akis:** Teori (1-4) → Pratik demolar ve challenge'lar (5-8) → Sonraki adimlar (9) → Quiz & oduller (10)
>
> Quiz en sonda — bugun ogrendiklerinizi test eder.

---

## Diger Dosyalar

| Dosya | Aciklama |
|-------|----------|
| [README.md](README.md) | Genel bilgi ve kurulum talimatlari |
| [setup.sh](setup.sh) | RHEL 9.x sunucu hazirlik script'i (multi-user SSH) |
| [SCORECARD.md](SCORECARD.md) | Canli skor tablosu |
| `demos/` | Tum demo ve challenge dosyalari |

---

## Hizli Referans

| Ihtiyac | Komut |
|---------|-------|
| Tum tracepoint'leri listele | `sudo bpftrace -l 'tracepoint:*'` |
| Syscall tracepoint'leri | `sudo bpftrace -l 'tracepoint:syscalls:*'` |
| Tracepoint field'larini gor | `sudo bpftrace -lv 'tracepoint:syscalls:sys_enter_openat'` |
| Syscall sayisi (one-liner) | `sudo bpftrace -e 'tracepoint:syscalls:sys_enter_* { @[probe] = count(); }'` |
| bpftrace versiyonu | `bpftrace --version` |
| Kernel versiyonu | `uname -r` |
