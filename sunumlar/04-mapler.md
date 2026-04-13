# Bolum 4 — Map'ler ve State Yonetimi

[← Verifier](03-verifier.md) | [INDEX](../INDEX.md) | [Sonraki: Demo 1 →](05-demo-exec.md)

---

> *Referans: [eBPFHub — Maps and multiple programs](https://ebpfhub.dev/tr/exercises/chapter-2/intro-maps-and-programs/)*

## Problem: eBPF Programlari Stateless'tir

Her event tetiklendiginde eBPF programiniz calisir ve cikar. Onceki calismalarin **hicbir hafizasi yoktur**.

Peki su durumlarda ne yapacaksiniz?
- Bir seyin kac kez oldugunu **saymak** istiyorsaniz?
- Event A'dan veri saklayip Event B'de **okumak** istiyorsaniz?
- Veriyi user space'e **gondermek** istiyorsaniz?

## Cozum: BPF Map'ler

Map'ler, **kernel tarafinda kalici veri yapilaridir**. Sunlar arasinda paylasimlidirlar:

- Birden fazla eBPF program cagrisi
- Birden fazla eBPF programi (ornegin entry + exit cifti)
- eBPF programlari ve user-space araclari

```
  Program Calisma #1       Program Calisma #2       User-space Araci
  ┌────────────┐          ┌────────────┐          ┌────────────┐
  │ event       │          │ event       │          │ map'i okur │
  │ tetiklenir │          │ tetiklenir │          │ veriyi     │
  │ map'e yaz  │── MAP ──>│ map'ten oku│── MAP ──>│ gosterir   │
  └────────────┘          └────────────┘          └────────────┘
```

---

## Map Turleri

| Tur | Aciklama | Kullanim Alani |
|-----|----------|---------------|
| `BPF_MAP_TYPE_HASH` | Key-value hash tablosu | PID bazli veri, counter'lar |
| `BPF_MAP_TYPE_ARRAY` | Sabit boyutlu indeksli array | Konfigürasyon, global counter |
| `BPF_MAP_TYPE_RINGBUF` | Lock-free ring buffer | Event'leri user space'e stream etme |
| `BPF_MAP_TYPE_PERCPU_HASH` | CPU basina hash tablosu | Yuksek performansli counter (lock contention yok) |
| `BPF_MAP_TYPE_LPM_TRIE` | Longest prefix match | CIDR bazli IP engelleme |
| `BPF_MAP_TYPE_PROG_ARRAY` | Program FD array'i | Tail call (program zincirleme) |

> *Referans: [eBPFHub — Hizli Referans](https://ebpfhub.dev/tr/exercises/referans/quick-reference/)*

---

## C'de Map Kullanimi

> *Referans: [eBPFHub — Maps and multiple programs](https://ebpfhub.dev/tr/exercises/chapter-2/intro-maps-and-programs/)*

### Map Tanimlama

```c
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 1024);
    __type(key, u64);
    __type(value, char[16]);
} my_map SEC(".maps");
```

### Veri Yazma

```c
u64 key = 12345;
char value[16] = "hello";
bpf_map_update_elem(&my_map, &key, value, BPF_ANY);
```

### Veri Okuma (NULL check zorunlu!)

```c
char *stored = bpf_map_lookup_elem(&my_map, &key);
if (!stored) {        // Key bulunamadi — NULL check ZORUNLU
    return 0;
}
// 'stored' artik char[16] array'ine pointer
```

### Veri Silme

```c
bpf_map_delete_elem(&my_map, &key);
```

---

## bpftrace'de Map Kullanimi (bugun kullanacagimiz)

bpftrace, map'leri `@` syntax'i ile kolaylastirir:

```
@mymap[key] = value;         // deger ata
@mymap[key] = count();       // olusum say
@mymap[key] = sum(val);      // topla
@mymap[key] = hist(val);     // histogram olustur
@mymap[key] = avg(val);      // ortalama hesapla
@mymap[key] = min(val);      // minimum
@mymap[key] = max(val);      // maksimum
```

Ctrl+C yaptiginizda bpftrace tum map'leri otomatik olarak yazdirir.

---

## Entry/Exit Pattern'i — Cross-Event State

> *Referans: [eBPFHub — Maps and multiple programs](https://ebpfhub.dev/tr/exercises/chapter-2/intro-maps-and-programs/)*

En guclu pattern: **entry**'de veri sakla, **exit**'te geri al, farki hesapla.

```
tracepoint:syscalls:sys_enter_read
{
    @start[tid] = nsecs;         // entry'de timestamp sakla, thread ID ile key'le
}

tracepoint:syscalls:sys_exit_read
/@start[tid]/                    // sadece entry gordugumuzde calistir
{
    $delta = nsecs - @start[tid];
    @latency = hist($delta);     // latency histogram'i olustur
    delete(@start[tid]);         // temizle
}
```

Bu pattern her yerde kullanilir:
- Syscall latency olcme
- `connect()` sonucunu iliskilendirme
- Dosya acma/kapama eslestirme
- Process baslama/bitme suresi

### eBPFHub'dan Gercek Ornek

> *Referans: [eBPFHub — Cross-syscall state tracking](https://ebpfhub.dev/tr/exercises/chapter-2/read-file-password/)*

eBPFHub'daki bir alistirmada, process baslangicinda ismi saklayip, exit'te exit code ile eslestirme yapiliyor:

```c
// Program 1: Process baslangicinda ismi map'e yaz
SEC("tracepoint/sched/sched_process_exec")
int on_process_start(struct trace_event_raw_sched_process_exec *ctx) {
    u64 pid = bpf_get_current_pid_tgid() >> 32;
    bpf_get_current_comm(&name, sizeof(name));
    bpf_map_update_elem(&names, &pid, &name, BPF_ANY);
    return 0;
}

// Program 2: Process exit'inde ismi geri al ve exit code ile birlikte raporla
SEC("tracepoint/syscalls/sys_enter_exit")
int on_process_exit(struct trace_event_raw_sys_enter *ctx) {
    u64 pid = bpf_get_current_pid_tgid() >> 32;
    char *name = bpf_map_lookup_elem(&names, &pid);
    if (!name) return 0;
    int exit_code = (int)ctx->args[0];
    // name ve exit_code artik eslesmis durumda
    return 0;
}
```

---

## Pratikte Gorelim (SSH ile)

Hazir bir ornek calistiralim:

```bash
cd /opt/ebpf-demo/demos/05-map-state
sudo bpftrace latency_hist.bt
```

Baska bir terminalde:
```bash
cat /etc/hostname
dd if=/dev/zero of=/tmp/testfile bs=1M count=10
find / -name "*.conf" 2>/dev/null | head -5
```

Ctrl+C yaptiginda read() latency histogram'ini goreceksiniz.

---

[← Verifier](03-verifier.md) | [INDEX](../INDEX.md) | [Sonraki: Demo 1 →](05-demo-exec.md)
