# Bolum 5 — Demo 1: Kim Ne Calistiriyor?

[← Map'ler](04-mapler.md) | [INDEX](../INDEX.md) | [Sonraki: Demo 2 →](06-demo-dosya.md)

---

## Hedef

Sistemdeki her `execve()` cagrisini trace edin — her kullanicinin calistirdigi her komutu gercek zamanli gorun.

**SysAdmin senaryosu:** *"Burak, gece 3'te tum CPU'yu yiyen cron job'i kim calistiriyor?"*

---

## execve() Syscall'i Nedir?

> *Referans: [eBPFHub — Tracing a system call](https://ebpfhub.dev/tr/exercises/chapter-1/3-reading-syscalls/)*

Bir program (mesela `bash`) baska bir programi (mesela `ls`) calistirmak istediginde `execve()` system call'ini kullanir:

```c
int execve(const char *filename, char *const argv[], char *const envp[]);
//          args[0]                args[1]               args[2]
```

- `filename`: Calistirilacak binary'nin yolu (ornegin `/usr/bin/ls`)
- `argv[]`: Komut satiri argument'leri
- `envp[]`: Ortam degiskenleri

`filename` pointer'i **user space bellegine** isaret eder, bu yuzden kernel'da okumak icin `bpf_probe_read_user_str()` gerekir. bpftrace bunu `str(args.filename)` ile otomatik yapar.

---

## Canli Kodlama — Herkes SSH ile Birlikte Yazsin!

### Adim 1: Script'i inceleyin

```bash
cd /opt/ebpf-demo/demos/01-hello-exec
cat trace_exec.bt
```

Icerik:

```
tracepoint:syscalls:sys_enter_execve
{
    printf("%-6d %-16s %s\n", pid, comm, str(args.filename));
}
```

### Adim 2: Calistirin (Terminal 1)

```bash
sudo bpftrace trace_exec.bt
```

### Adim 3: Diger terminalde aktivite yaratin (Terminal 2)

```bash
ls /tmp
whoami
curl -s example.com > /dev/null
cat /etc/hostname
systemctl status sshd
```

Ciktida **her komutu** goreceksiniz — diger takimlarin komutlari dahil! (Herkes ayni sunucuda cunku.)

---

## Ne Oldu?

```
HOOK                              NE ALDIK
──────────────────                ─────────────────
tracepoint:syscalls               Kernel'in stabil syscall tracepoint'leri
  :sys_enter_execve               HER execve() cagrisinda tetiklenir

pid                               Cagiran process'in ID'si
comm                              Process adi (ornegin "bash")
str(args.filename)                Calistirilan binary (ornegin "/usr/bin/ls")
                                  (bpftrace user memory'yi bizim icin okur)
```

> **PUAN:** Base demo'yu basariyla calistirdiniz → **+100 puan** (takim)

---

## Challenge 1A — UID ve Zaman Damgasi Ekleyin (+50 puan)

`trace_exec.bt`'yi su bilgileri de gosterecek sekilde degistirin:
- **UID** — komutu kim calistiriyor
- **Elapsed time** — ne zaman oldu (baslangica gore)

**Ipucu:** `uid` ve `elapsed` bpftrace'in built-in degiskenleridir.

SSH ile sunucuda duzenleyin:

```bash
cp trace_exec.bt trace_exec_v2.bt
vim trace_exec_v2.bt
sudo bpftrace trace_exec_v2.bt
```

<details>
<summary>Cozum (once deneyin!)</summary>

```
tracepoint:syscalls:sys_enter_execve
{
    printf("%-12lld %-6d %-6d %-16s %s\n",
        elapsed, uid, pid, comm, str(args.filename));
}
```

</details>

---

## Challenge 1B — Kullaniciya Gore Filtrele (+50 puan)

Script'i sadece belirli bir UID'nin calistirdigi komutlari gosterecek sekilde degistirin.

**Ipucu:** bpftrace'de `/condition/` syntax'i filtre olarak kullanilir.

Kendi UID'nizi ogrenin:

```bash
id -u
```

<details>
<summary>Cozum</summary>

```
tracepoint:syscalls:sys_enter_execve
/uid == 1000/
{
    printf("%-6d %-16s %s\n", pid, comm, str(args.filename));
}
```

`/uid == 1000/` bir bpftrace **filtresidir** — probe body'si sadece kosul dogru oldugunda calisir. Eslesmeyen event'ler icin overhead yoktur.

</details>

---

> **BASARIM:** *"Big Brother"* — Exec call'larini basariyla trace ettiniz!
>
> Ilk tamamlayan takim **+50 bonus puan** alir.

---

[← Map'ler](04-mapler.md) | [INDEX](../INDEX.md) | [Sonraki: Demo 2 →](06-demo-dosya.md)
