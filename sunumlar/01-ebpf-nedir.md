# Bolum 1 — eBPF Nedir?

[← Baslangic](00-baslangic.md) | [INDEX](../INDEX.md) | [Sonraki: Program Turleri →](02-program-turleri.md)

---

> *Referans: [eBPFHub — eBPF'e Giris](https://ebpfhub.dev/tr/exercises/chapter-0/1_theory/)*

## Tek Cumlede eBPF

> **eBPF, ozel kodunuzu dogrudan kernel event'lerine hook etmenize olanak taniyan bir Linux mekanizmasidir — kernel kaynak kodunu degistirmeden veya kernel module yuklemeden.**

Bir event tetiklendiginde (bir process calistirilir, bir dosya acilir, bir network paketi gelir), kernel normal yurutmeyi duraklattir, sizin eBPF programinizi calistirir ve ardindan devam eder.

Bu islem **kernel seviyesinde** gerceklesir ve size user space'den tek basina elde edilmesi imkansiz olan sistem davranisi gorunurlugu saglar.

[REVIEW: burada biraz daha detay ver, ebpf bunu nasil yapiyor: yapilma methodlari neler? bu metodlar arasinda nasil farkliliklar var]

---

## Neden Onemli? — Gercek Hayat Senaryosu

[REVIEW: Neden ebpf gibi birseye ihtiyac duyuldu? Gunluk hayatimizda kullanidigimiz araclar var mi ebpf ile calisan? bpf ile ebpf arasinda fark nedir?]

Diyelim ki sunucuda bir problem var:

**eBPF oncesi — geleneksel yaklasim:**

```
Problem raporlandi
    → strace -p <pid>           (tek process'e attach, yuksek overhead)
    → tcpdump -i eth0           (paket seli, process context yok)
    → /var/log/messages oku     (olay bittikten sonra, eksik bilgi)
    → kernel module'e printk ekle (recompile, reboot)
    → tahmin et ve dua et
```

**eBPF ile — cerrahi hassasiyet:**

```
Problem raporlandi
    → tam event'e eBPF probe attach et
    → gercek zamanli cevap al, process context ile
    → sifir reboot, sifir kernel degisikligi
    → guvenerek fix'le
```

---

## Browser Benzetmesi

eBPF'i anlamanin en kolay yolu: **kernel icin JavaScript** gibi dusunun.

| Web Dunyasi | Kernel Dunyasi |
|-------------|---------------|
| Browser engine | Linux kernel |
| JavaScript kaynak kodu | eBPF C kodu / bpftrace script |
| V8 / SpiderMonkey | eBPF virtual machine + JIT compiler |
| Content Security Policy | **eBPF Verifier** |
| DOM event'leri (click, load, scroll) | Kernel event'leri (syscall, packet, sched) |
| localStorage / cookie | **BPF Map'ler** (hash, array, ringbuf) |
| Browser sandbox | eBPF sandbox (crash yok, hang yok) |

Nasil bir web sitesi browser'inizi cokertemezse (sandbox sayesinde), bir eBPF programi da **kernel'inizi cokertmez** (verifier sayesinde).

---

## eBPF Nasil Calisiyor? — Tam Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SPACE                               │
│                                                                 │
│  1. YAZ                 2. COMPILE ET            3. YUKLE       │
│  ┌─────────────┐       ┌─────────────┐       ┌──────────────┐  │
│  │ Siz         │       │ Compiler    │       │ Loader,      │  │
│  │ yazarsiniz: │──────>│ (clang/LLVM │──────>│ bytecode'u   │  │
│  │ • C kodu    │       │  veya       │       │ bpf() syscall│  │
│  │ • bpftrace  │       │  bpftrace   │       │ ile gonderir │  │
│  │   script    │       │  dahili)    │       └──────┬───────┘  │
│  └─────────────┘       └─────────────┘              │          │
│                                                      │          │
│  7. SONUCLARI OKU       6. DATA AKISI               │          │
│  ┌─────────────┐       ┌─────────────┐              │          │
│  │ Arac veriyi │<──────│ Map'ler /   │              │          │
│  │ gosterir    │       │ Ring Buffer │              │          │
│  └─────────────┘       └──────▲──────┘              │          │
├──────────────────────────────┼──────────────────────┼──────────┤
│                   KERNEL SPACE                       │          │
│                              │                       │          │
│                    ┌─────────┴───────┐     ┌────────▼────────┐ │
│                    │ 5. ATTACH       │     │ 4. VERIFIER     │ │
│                    │ eBPF programi   │     │ Guvenlik:       │ │
│                    │ event'e         │     │ • Sonlaniyor mu?│ │
│                    │ baglanir:       │<────│ • Memory safe?  │ │
│                    │ • tracepoint    │ OK  │ • Bounded mi?   │ │
│                    │ • kprobe        │     │ • NULL check?   │ │
│                    │ • XDP           │     └─────────────────┘ │
│                    │ • uprobe        │                         │
│                    └─────────────────┘                         │
│                          │                                     │
│                   JIT ile native                               │
│                   machine code'a                               │
│                   derlenir                                     │
└─────────────────────────────────────────────────────────────────┘
```

**Adim adim:**

1. **Yaz** — Kucuk bir program yazarsiniz (C veya bpftrace ile)
[REVIEW:  bftrace ile yaparsak ne oluyor c ile yazip derleyince ne oluyor]

2. **Compile et** — Clang/LLVM bunu eBPF bytecode'a derler (bpftrace bunu dahili yapar)
3. **Yukle** — Loader, bytecode'u `bpf()` system call'i ile kernel'a gonderir
[REVIEW: bpf() fonksiyonu burada tam ne yapiyor biraz daha teknik detay?]

4. **Dogrula** — Kernel verifier her instruction path'i statik olarak analiz eder
5. **Bagla** — Dogrulanan program JIT-compile edilir ve bir kernel event hook'una attach olur
6. **Calistir** — Event her tetiklendiginde programiniz calisir ve map'lere yazar
7. **Oku** — User-space araclar map'lerden okur ve sonuclari gosterir

---

## eBPF Kullanan Gercek Dunya Araclari

Bu araclarin hepsinin altinda eBPF calisir:

| Arac | Ne Yapar | eBPF Kullanimi |
|------|----------|---------------|
| **Cilium** | Kubernetes networking & security | XDP + TC ile packet filtering |
| **Falco** | Runtime security / threat detection | Tracepoint + kprobe ile syscall izleme |
| **bcc-tools** | 100+ hazir performance araci | Tracepoint, kprobe, uprobe |
| **Pixie** | Otomatik K8s observability | Uprobe ile app-level tracing |
| **Calico eBPF** | K8s dataplane | XDP + socket-level hook'lar |
| **Katran** | Facebook'un L4 load balancer'i | XDP ile packet-level LB |
| **Tetragon** | Cilium runtime security | LSM hook'lar + tracepoint'ler |

> *Referans: [eBPFHub — Kaynaklar ve On Kosullar](https://ebpfhub.dev/tr/exercises/chapter-0/3_kaynaklar/)*

---

## eBPFHub Ogrenme Yolu

[eBPFHub](https://ebpfhub.dev/), eBPF'i ilerlemeli chapter'lar halinde ogretir:

| Chapter | Konu | Ne Ogrenirsiniz |
|---------|------|----------------|
| 0 | Baslangic | Teori, setup, kaynaklar |
| 1 | C Temelleri | Program yapisi, pointer'lar, struct'lar, BPF C ozellikleri |
| 2 | Ilk eBPF Programi | Event data okuma, syscall tracing, array okuma |
| 3 | BPF Map'ler | Map'ler, birden fazla program, cross-syscall state tracking |
| 4 | Araclar & Kavramlar | bpftool, verifier, BTF/CO-RE |
| 5 | Network Tracing | Socket connect, kprobe, TCP/HTTP, DNS parsing |
| 6 | XDP Packet Processing | Packet parsing, rate limiting, load balancing |
| 7 | Ileri Konular | Tracing mekanizmalari, XDP root pattern, Go entegrasyonu |

---

## Quiz 1 — SSH ile Cevaplayin!

> Her dogru cevap: **+20 puan** (takim) + **+10 puan** (bireysel)
>
> Takimlar tartissin, bir kisi cevap versin.

**S1:** eBPF'i tek cumleyle aciklayin.

**S2:** eBPF kullanan 3 gercek dunyadan arac sayabilir misiniz?

**S3:** eBPF programini kernel'a yukleyen system call hangisi?

**S4:** Guvenlik kontrolunu kim yapar — compiler mi, verifier mi, yoksa JIT mi?

---

[← Baslangic](00-baslangic.md) | [INDEX](../INDEX.md) | [Sonraki: Program Turleri →](02-program-turleri.md)
