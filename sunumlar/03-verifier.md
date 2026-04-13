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

[REVIEW: bu basligi biraz daha genislet cok az bilgi ve ornek var]

> *Referans: [eBPFHub — Verifier ve BTF/CO-RE](https://ebpfhub.dev/tr/exercises/ebpf-araclar/verifier-btf/)*

Farkli kernel versiyonlarinda struct layout'lari degisebilir. **BTF (BPF Type Format)** ve **CO-RE (Compile Once, Run Everywhere)** bu sorunu cozer.

[REVIEW: nasil cozer? biraz daha teknik detay]

### vmlinux.h

Tum kernel type'larina tek bir header dosyasindan erisim:

```bash
bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h
```

### BPF_CORE_READ

Farkli kernel versiyonlarinda guvenle struct field okuma:

```c
// CO-RE OLMADAN: struct layout degisirse bozulur
__u16 port = sk->__sk_common.skc_dport;

// CO-RE ILE: kernel versiyonlari arasinda calisir
__u16 port = BPF_CORE_READ(sk, __sk_common.skc_dport);
```

`BPF_CORE_READ`, relocatable okuma uretir. Loader, calisan kernel'in BTF bilgisine gore field offset'lerini yukleme zamaninda ayarlar.

---

[← Program Turleri](02-program-turleri.md) | [INDEX](../INDEX.md) | [Sonraki: Map'ler →](04-mapler.md)
