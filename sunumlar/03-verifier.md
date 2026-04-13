# Bolum 3 — Verifier ve Guvenlik

[← Program Turleri](02-program-turleri.md) | [INDEX](../INDEX.md) | [Sonraki: Map'ler →](04-mapler.md)

---

> *Referans: [eBPFHub — Verifier ve BTF/CO-RE](https://ebpfhub.dev/tr/exercises/ebpf-araclar/verifier-btf/)*

## Verifier Neden Var?

Kernel'de keyfi kod calistirabilseydiniz:
- Null pointer dereference ile **sistemi cokertebilirdiniz**
- Rastgele kernel memory okuyarak **gizli verileri sizdirabilirdiniz**
- Sonsuz dongu ile **makineyi kilitleyebilirdiniz**
- Kontrolsuz write ile **verileri bozabilirdiniz**

eBPF verifier, programinizi **calismadan once** analiz ederek tum bunlari onler.

---

## Dort Guvenlik Garantisi

```
┌─────────────────────────────────────────────────────┐
│              eBPF VERIFIER GARANTILERI               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. SONLANMA (TERMINATION)                          │
│     ✓ Loop'larin sinirli iterasyonu olmali          │
│       (compile-time'da bilinen ust sinir)           │
│     ✓ Maksimum instruction complexity limiti        │
│     ✓ Sonsuz recursion yok                          │
│                                                     │
│  2. MEMORY SAFETY                                   │
│     ✓ Rastgele pointer arithmetic yok               │
│     ✓ Kernel okuma: bpf_probe_read_kernel()         │
│     ✓ User okuma: bpf_probe_read_user()             │
│     ✓ Tum array erisimi bounds-checked              │
│                                                     │
│  3. NULL SAFETY                                     │
│     ✓ Map lookup sonucu NULL-check zorunlu          │
│     ✓ Her kod yolu (branch) analiz edilir           │
│                                                     │
│  4. TYPE SAFETY                                     │
│     ✓ Dogru helper fonksiyon signature'lari         │
│     ✓ Context erisimi program turune uygun          │
│     ✓ GPL-only helper'lar icin GPL lisansi          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Yaygin Verifier Hatalari ve Cozumleri

> *Referans: [eBPFHub — Verifier ve BTF/CO-RE](https://ebpfhub.dev/tr/exercises/ebpf-araclar/verifier-btf/)*

| Hata Mesaji | Anlami | Cozum |
|------------|--------|-------|
| `R0 invalid mem access 'map_value_or_null'` | Map lookup sonucu NULL-check yapilmamis | `if (!val) return 0;` ekleyin |
| `variable stack access var_off` | Stack buffer boyutu sabit olmali | Sabit boyutlu array kullanin |
| `back-edge from insn X to Y` | Sinirsiz dongu tespit edildi | `#pragma unroll` veya sabit ust sinir |
| `invalid access to packet` | XDP'de bounds check olmadan paket okunmus | `if ((void*)(ptr+1) > data_end)` ekleyin |
| `pointer arithmetic prohibited` | Kisitli pointer uzerinde aritmetik | Helper fonksiyonlari kullanin |

---

## Canli Ornekler — Verifier Hatalari

### Ornek 1: NULL Check Eksik (en yaygin hata!)

```c
// YANLIS — verifier reddeder
char *val = bpf_map_lookup_elem(&my_map, &key);
bpf_printk("value: %s", val);  // val NULL olabilir!

// DOGRU — her zaman NULL kontrolu yapilmali
char *val = bpf_map_lookup_elem(&my_map, &key);
if (!val) return 0;             // verifier bunu zorlar
bpf_printk("value: %s", val);  // artik guvenli
```

### Ornek 2: Sinirsiz Dongu

```c
// YANLIS — verifier reddeder: "back-edge from insn X to Y"
for (int i = 0; i < len; i++) {   // 'len' runtime degeri!
    buf[i] = 0;
}

// DOGRU — compile-time sabit sinir
#pragma unroll
for (int i = 0; i < 64; i++) {    // sabit ust sinir
    if (i >= len) break;
    buf[i] = 0;
}
```

### Ornek 3: Paket Bounds Check (XDP)

```c
// YANLIS — verifier reddeder: "invalid access to packet"
struct iphdr *ip = data + sizeof(struct ethhdr);
__u32 src = ip->saddr;            // bounds check yok!

// DOGRU — okumadan once her zaman kontrol edin
struct iphdr *ip = data + sizeof(struct ethhdr);
if ((void *)(ip + 1) > data_end)
    return XDP_PASS;              // paket cok kisaysa atla
__u32 src = ip->saddr;            // bounds check'ten sonra guvenli
```

---

## Interaktif: Verifier'i Kirin! (SSH ile)

> **Takim Challenge'i: +30 puan (takim) + ilk duzelten kisiye +30 puan (bireysel)**

### Adim 1: Bozuk script'i calistirin

```bash
cd /opt/ebpf-demo/demos/04-verifier-crash
sudo bpftrace verifier_break.bt
```

Hata mesajini **okuyun**. Ne soyluyor?

### Adim 2: Duzeltilmis versiyonu yazin

`verifier_fix.bt` dosyasini duzenleyin ve calisan bir hale getirin:

```bash
vim verifier_fix.bt
sudo bpftrace verifier_fix.bt
```

> **BASARIM:** *"Verifier Whisperer"* — Verifier hatasini ilk duzelten kisi
>
> | Kisi | Ilk Duzelten? |
> |------|--------------|
> | Burak | [ ] |
> | Oguzhan | [ ] |
> | Yasin | [ ] |
> | Buse | [ ] |
> | Ugur | [ ] |
> | Serhat | [ ] |

---

## BTF ve CO-RE (Tasinabilirlik)

> *Referans: [eBPFHub — Verifier ve BTF/CO-RE](https://ebpfhub.dev/tr/exercises/ebpf-araclar/verifier-btf/)*

### Problem: Kernel Struct'lari Degisir

Bir eBPF programi `struct task_struct` icerisindeki `comm` field'ina offset 1234'ten eriisyor diyelim. Ama yeni kernel versiyonunda bu struct'a yeni field'lar eklendi ve `comm`'un offset'i artik 1256. Eski programiniz **yanlis memory'yi** okur — ve verifier bunu yakalayamaz cunku compile-time'da dogru gorunur.

Bu, eBPF'in en buyuk tasinabilirlik sorunuydu: **her kernel versiyonu icin yeniden derleme** gerekiyordu.

### Cozum: BTF + CO-RE

**BTF (BPF Type Format)**, kernel'in kendi type bilgisini `/sys/kernel/btf/vmlinux` dosyasinda saklamasidir. Bu dosya kernel'deki **tum struct'larin** field isimlerini, tiplerini ve offset'lerini icerir.

**CO-RE (Compile Once, Run Everywhere)** ise BTF'i kullanarak compile-time offset'leri **yukleme zamaninda** hedef kernel'e gore ayarlayan bir mekanizmadir.

```
Derleme Zamani                      Yukleme Zamani
┌────────────────┐                  ┌────────────────────────┐
│ eBPF programi  │                  │ Loader BTF'i okur      │
│ "comm field'ini│     ──────>      │ "comm" offset'ini      │
│  oku" der      │                  │ hedef kernel'de bulur  │
│ (relocatable)  │                  │ ve programi patch'ler  │
└────────────────┘                  └────────────────────────┘
```

### vmlinux.h — Tek Header ile Tum Kernel Type'lari

Normalde kernel struct'larina erismek icin onlarca header dosyasi include etmeniz gerekir. `vmlinux.h` **tum** kernel type'larini tek bir dosyada toplar:

```bash
# vmlinux.h olusturma (RHEL 9.x'de BTF destegi varsayilan olarak acik):
bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h

# Dosya boyutunu kontrol edin — genellikle 5-10 MB:
ls -lh vmlinux.h

# Icinde herhangi bir struct'i arayabilirsiniz:
grep "struct task_struct {" vmlinux.h
```

Bu sayede `#include <linux/sched.h>`, `#include <linux/fs.h>` gibi onlarca header yerine tek bir `#include "vmlinux.h"` yeterlidir.

### BPF_CORE_READ — Guvenli Cross-Kernel Okuma

```c
#include "vmlinux.h"
#include <bpf/bpf_core_read.h>

SEC("kprobe/tcp_connect")
int trace(struct pt_regs *ctx) {
    struct sock *sk = (void *)PT_REGS_PARM1(ctx);

    // CO-RE OLMADAN: struct layout degisirse bozulur
    // __u16 port = sk->__sk_common.skc_dport;

    // CO-RE ILE: kernel versiyonlari arasinda calisir
    __u16 port = BPF_CORE_READ(sk, __sk_common.skc_dport);

    // Ic ice struct okuma bile guvenli:
    // task -> mm -> exe_file -> f_path.dentry -> d_name.name
    // BPF_CORE_READ her adimda dogru offset'i ayarlar
    return 0;
}
```

`BPF_CORE_READ`, **relocatable** okuma uretir. Loader, calisan kernel'in BTF bilgisine gore field offset'lerini yukleme zamaninda ayarlar. Boylece RHEL 9.0'da derlediginiz program RHEL 9.4'te de calisir.

### SysAdmin icin Bu Neden Onemli?

Production'da eBPF araci dagitacaksaniz (ornegin bir monitoring agent), CO-RE sayesinde **tek bir binary** tum kernel versiyonlarinda calisir. BTF olmadan her sunucu icin ayri derleme yapmak gerekirdi.

> **Not:** bpftrace kullanidigimiz surece BTF/CO-RE ile dogrudan ugrasmamiza gerek yok — bpftrace bunlari dahili olarak handle eder. Ama C ile eBPF yazacaksaniz CO-RE bilmek zorunludur.

---

[← Program Turleri](02-program-turleri.md) | [INDEX](../INDEX.md) | [Sonraki: Map'ler →](04-mapler.md)
