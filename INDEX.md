# eBPF Workshop — Kernel'i Yakindan Taniyin

> **Sure:** ~90 dakika (1.5 saat)
> **Hedef Sistem:** RHEL 9.x (kernel 5.14+)
> **Sunan:** Dogukan
> **Katilimcilar:** Burak, Oguzhan, Yasin, Buse, Ugur, Serhat
> **Format:** Teori + Canli kodlama (SSH) + Takim yarismasi
> **Referans:** [eBPFHub](https://ebpfhub.dev/) — Tarayicida eBPF aliştirmalari

---

## Sunum Plani

> **Tur Aciklamasi:**
> - `DEMO` = Birlikte inceleriz, ekip takip eder — **puan yok**
> - `CTF` = Capture the Flag — Takimlar SSH'ta kendi baslarina cozer, ilk yapan kazanir — **puan var**
> - `SORU` = Bilgi yarismasi (en sonda) — **puan var**

| # | Bolum | Tur | Sure | Puan |
|---|-------|-----|------|------|
| 0 | [Baslangic — Takim Olusturma & SSH](sunumlar/00-baslangic.md) | Hazirlik | 5 dk | 30 |
| 1 | [eBPF Nedir? — Teori](sunumlar/01-ebpf-nedir.md) | `DEMO` | 15 dk | — |
| 2 | [Program Turleri — Tracepoint, Kprobe, XDP](sunumlar/02-program-turleri.md) | `DEMO` | 10 dk | — |
| 3 | [Verifier ve Guvenlik](sunumlar/03-verifier.md) | `DEMO` + `CTF` | 10 dk | 80 |
| 4 | [Map'ler ve State Yonetimi](sunumlar/04-mapler.md) | `DEMO` | 5 dk | — |
| 5 | [Demo 1 — Kim Ne Calistiriyor?](sunumlar/05-demo-exec.md) | `DEMO` + `CTF` | 10 dk | 150 |
| 6 | [Demo 2 — Dosya Casusu](sunumlar/06-demo-dosya.md) | `DEMO` + `CTF` | 10 dk | 150 |
| 7 | [Demo 3 — Ag Koruyucusu](sunumlar/07-demo-ag.md) | `DEMO` + `CTF` | 10 dk | 150 |
| 8 | [Bonus Challenge'lar](sunumlar/08-bonus.md) | `CTF` | 10 dk | 300 |
| 9 | [eBPFHub & Sonraki Adimlar](sunumlar/09-sonraki-adimlar.md) | `DEMO` | 5 dk | — |
| 10 | [Bilgi Yarismasi & Skor Tablosu](sunumlar/10-quiz.md) | `SORU` | 5 dk | 400 |
| | | | **~90 dk** | |

> **Akis:** Demo (1-4) → Demo+CTF (5-7) → Saf CTF (8) → Kapat (9) → Soru Yarismasi & Oduller (10)

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
