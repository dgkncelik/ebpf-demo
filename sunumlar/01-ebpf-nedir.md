# Bolum 1 — eBPF Nedir?

[← Baslangic](00-baslangic.md) | [INDEX](../INDEX.md) | [Sonraki: Program Turleri →](02-program-turleri.md)

---

> *Referans: [eBPFHub — eBPF'e Giris](https://ebpfhub.dev/tr/exercises/chapter-0/1_theory/)*

## Tek Cumlede eBPF

> **eBPF, ozel kodunuzu dogrudan kernel event'lerine hook etmenize olanak taniyan bir Linux mekanizmasidir — kernel kaynak kodunu degistirmeden veya kernel module yuklemeden.**

Bir event tetiklendiginde (bir process calistirilir, bir dosya acilir, bir network paketi gelir), kernel normal yurutmeyi duraklattir, sizin eBPF programinizi calistirir ve ardindan devam eder.

Bu islem **kernel seviyesinde** gerceklesir ve size user space'den tek basina elde edilmesi imkansiz olan sistem davranisi gorunurlugu saglar.

### eBPF Bunu Nasil Yapiyor?

eBPF programlari kernel'e yuklenmenin **birden fazla yolu** vardir. Her yontemin kendine ozgu avantajlari ve kullanim alanlari bulunur:

| Yontem | Nasil Calisir | Avantaji | Dezavantaji |
|--------|-------------|----------|-------------|
| **bpftrace** | Tek satirlik veya kisa script'ler yazar, bpftrace dahili olarak compile + load yapar | Hizli prototipleme, ogrenme icin ideal | Karmasik programlar icin sinirli |
| **libbpf + C** | C'de eBPF programi yazarsiniz, clang ile compile edersiniz, libbpf ile yuklersiniz | Tam kontrol, production-grade | Daha fazla kod, derleme adimi gerekli |
| **BCC (Python)** | Python'da eBPF C kodu gomulu yazarsiniz, BCC runtime'da compile eder | Python rahatligi, hizli gelistirme | Runtime'da LLVM gerektirir, yavas baslangic |
| **Go (cilium/ebpf, bpf2go)** | Go'da eBPF programi yazarsiniz, tek binary olarak dagitirsiniz | Tek binary, kolay dagitim | Go bilgisi gerekir |

**bpftrace** bugun kullanacagimiz yontem — ogrenme icin en uygun. Production'da genellikle **libbpf + C** veya **Go** tercih edilir.

---

## BPF'ten eBPF'e: Tarihce

| Yil | Olay |
|-----|------|
| 1992 | **BPF (Berkeley Packet Filter)** — Sadece paket filtreleme icin tasarlandi. `tcpdump` bunun uzerine calısır. Basit bir sanal makine: paketleri filtreler, gecer/atar. |
| 2014 | **eBPF (extended BPF)** — Alexei Starovoitov, BPF'i Linux kernel'a genisleterek yeniden yazdı. Artik sadece paket degil, **herhangi bir kernel event'ine** hook olabilir. Map'ler, helper fonksiyonlar, JIT compiler eklendi. |
| 2016+ | eBPF program turleri hizla artti: XDP, tracepoint, kprobe, uprobe, cgroup, LSM... |
| Bugun | eBPF, modern Linux observability ve security altyapisinin temelidir. |

**Temel fark:** BPF sadece "paket filtrele, gec ya da at" yapabilirken, eBPF **herhangi bir kernel event'inde** ozel kod calistirmaniza, veri toplamaniza, kararlar almaniza olanak tanir.

## Neden eBPF'e Ihtiyac Duyuldu?

Linux kernel'i izlemek ve debug etmek icin geleneksel yontemler **ya cok yavas, ya cok riskli, ya da cok sinirlidir:**

| Geleneksel Yontem | Problem |
|-------------------|---------|
| `strace` | Tek process'e attach olur, **~%50 overhead** yaratir, production'da kullanilamaz |
| `tcpdump` | Sadece network paketleri, process context yok — "bu paketi kim gonderdi?" bilinmez |
| Kernel module yazmak | Root gerekir, hata yaparsanız **kernel panic**, her kernel versiyonunda yeniden derleme |
| `/proc` & `/sys` okumak | Anlik snapshot, gercek zamanli degil, sinirli bilgi |
| Log dosyalari | Olay olduktan **sonra**, kayip olabilir, ilgisiz bilgi seli |

eBPF bunlarin **hepsini** tek bir mekanizmayla cozer: guvenli, hizli, gercek zamanli, process context'li kernel izleme.

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

1. **Yaz** — Kucuk bir program yazarsiniz. Iki yol var:
   - **bpftrace ile:** Yuksek seviyeli script dili. `tracepoint:syscalls:sys_enter_openat { printf("%s\n", comm); }` gibi tek satirda is yapabilirsiniz. bpftrace arka planda bu script'i C'ye cevirir, compile eder ve yukler — siz sadece script yazarsiniz.
   - **C ile:** `SEC("tracepoint/syscalls/sys_enter_openat")` gibi annotation'larla tam eBPF programi yazarsiniz. `clang -target bpf` ile compile edersiniz. Daha fazla kontrol, daha fazla kod.

2. **Compile et** — Clang/LLVM, C kodunuzu **eBPF bytecode**'a derler. Bu bytecode x86 veya ARM degil, eBPF sanal makinesinin anlayacagi ozel bir instruction set'tir (11 register, 64-bit). bpftrace kullaniyorsaniz bu adimi bpftrace otomatik yapar.

3. **Yukle** — Loader, bytecode'u `bpf()` system call'i ile kernel'a gonderir. `bpf()` syscall'i cok yonlu bir arayuzdur:

   ```c
   int bpf(int cmd, union bpf_attr *attr, unsigned int size);
   ```

   | `cmd` degeri | Ne yapar |
   |-------------|----------|
   | `BPF_PROG_LOAD` | eBPF programini kernel'a yukler |
   | `BPF_MAP_CREATE` | Yeni bir BPF map olusturur |
   | `BPF_MAP_LOOKUP_ELEM` | Map'ten veri okur |
   | `BPF_MAP_UPDATE_ELEM` | Map'e veri yazar |
   | `BPF_PROG_ATTACH` | Programi bir event'e baglar |

   Yani `bpf()` tek bir syscall icinde program yukleme, map yonetimi ve program baglama islemlerini yapar. Her islem icin farkli bir `cmd` degeri kullanilir.

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

[← Baslangic](00-baslangic.md) | [INDEX](../INDEX.md) | [Sonraki: Program Turleri →](02-program-turleri.md)
