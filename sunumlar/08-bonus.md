# Bolum 8 — Bonus Challenge'lar

[← Demo 3](07-demo-ag.md) | [INDEX](../INDEX.md) | [Sonraki: Sonraki Adimlar →](09-sonraki-adimlar.md)

---

> Takimlar bagimsiz calisir. Ilk tamamlayan takim temel puanin ustune **+50 bonus puan** alir!
>
> Tum dosyalar sunucuda: `/opt/ebpf-demo/demos/challenges/`

---

## Bonus 1: Process Yasam Dongusu Takipcisi (+100 puan)

### Gorev

Process **olusturma** ve **cikis** event'lerini zaman damgasiyla takip edin.

### Tracepoint'ler

- `tracepoint:sched:sched_process_exec` — process baslar
- `tracepoint:sched:sched_process_exit` — process cikar

### Beklenen Cikti Formati

```
[EXEC] 123456789  pid=1234   bash
[EXIT] 234567890  pid=1234   bash
```

### Baslangic

```bash
cd /opt/ebpf-demo/demos/challenges
vim lifecycle.bt
sudo bpftrace lifecycle.bt
```

Test icin diger terminalde:
```bash
ls /tmp
sleep 1
echo "test"
```

### Ipuclari

- `elapsed` = bpftrace baslangicina gore nanosaniye
- `pid` = process ID
- `comm` = process adi

<details>
<summary>Cozum</summary>

```
BEGIN
{
    printf("Process yasam dongusu izleniyor... Ctrl+C ile durdurun.\n\n");
}

tracepoint:sched:sched_process_exec
{
    printf("[EXEC] %-12lld  pid=%-6d  %s\n", elapsed, pid, comm);
}

tracepoint:sched:sched_process_exit
{
    printf("[EXIT] %-12lld  pid=%-6d  %s\n", elapsed, pid, comm);
}
```

</details>

---

## Bonus 2: Yavas Syscall Bulucu (+100 puan)

### Gorev

**1ms'den uzun** suren `read()` syscall'larini bulun — klasik I/O darboğaz avciligil

### Pattern

Bolum 4'te ogrendigimiz **entry/exit map pattern**'ini kullanin:

1. `sys_enter_read`'de timestamp'i map'e kaydedin (`@start[tid] = nsecs`)
2. `sys_exit_read`'de delta hesaplayin
3. Delta > 1.000.000 ns (1ms) ise yazdirinl
4. Map entry'sini temizleyin

### Beklenen Cikti

```
PID    COMM             LATENCY(ms)
1234   sshd             2.345 ms
5678   systemd-journal  15.678 ms
```

### Baslangic

```bash
cd /opt/ebpf-demo/demos/challenges
vim slow_reads.bt
sudo bpftrace slow_reads.bt
```

Test icin:
```bash
dd if=/dev/urandom of=/tmp/bigfile bs=1M count=100
cat /tmp/bigfile > /dev/null
find / -name "*.log" 2>/dev/null
```

<details>
<summary>Cozum</summary>

```
BEGIN
{
    printf("Yavas read() call'lari araniyor (>1ms)... Ctrl+C ile durdurun.\n");
    printf("%-6s %-16s %-12s\n", "PID", "COMM", "LATENCY(ms)");
}

tracepoint:syscalls:sys_enter_read
{
    @start[tid] = nsecs;
}

tracepoint:syscalls:sys_exit_read
/@start[tid]/
{
    $delta = nsecs - @start[tid];
    if ($delta > 1000000) {
        printf("%-6d %-16s %d.%03d ms\n",
            pid, comm,
            $delta / 1000000, ($delta % 1000000) / 1000);
    }
    delete(@start[tid]);
}
```

</details>

---

## Bonus 3: Yasakli Komut Dedektoru (+100 puan)

### Gorev

Birisi `rm` calistirdiginda **buyuk bir uyari** yazdirinl

### Strateji

1. `tracepoint:syscalls:sys_enter_execve`'e hook yapin
2. `filename`'in `rm` icerip icermedigini kontrol edin
3. UID, PID ve komutu iceren gosterisli bir uyari kutusu yazdirinl

### Beklenen Cikti

```
*********************************************
*** UYARI: rm TESPIT EDILDI!             ***
*** uid=1000  pid=12345                  ***
*** cmd: /usr/bin/rm                     ***
*********************************************
```

### Baslangic

```bash
cd /opt/ebpf-demo/demos/challenges
vim forbidden.bt
sudo bpftrace forbidden.bt
```

Test icin (zararsiz):
```bash
rm /tmp/testfile 2>/dev/null
touch /tmp/dummy && rm /tmp/dummy
```

**Ipucu:** `strncmp(str(args.filename), "/usr/bin/rm", 11) == 0`

<details>
<summary>Cozum</summary>

```
BEGIN
{
    printf("Tehlikeli rm komutlari izleniyor... Ctrl+C ile durdurun.\n\n");
}

tracepoint:syscalls:sys_enter_execve
/strncmp(str(args.filename), "/usr/bin/rm", 11) == 0/
{
    printf("\n");
    printf("*********************************************\n");
    printf("*** UYARI: rm TESPIT EDILDI!             ***\n");
    printf("*** uid=%-6d pid=%-6d                  ***\n", uid, pid);
    printf("*** cmd: %-35s***\n", str(args.filename));
    printf("*********************************************\n\n");
}
```

</details>

---

## One-Liner Yarismasi

Her takimdan bir kisi, en iyi **bpftrace one-liner**'ini yazar. Workshop sonunda herkes oy verir.

Ornekler:
```bash
# Saniyede en cok syscall yapan process
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); } interval:s:1 { print(@, 5); clear(@); }'

# En cok dosya acan 5 process
sudo bpftrace -e 't:syscalls:sys_enter_openat { @[comm] = count(); } END { print(@, 5); }'

# TCP baglanti sayisi port bazinda
sudo bpftrace -e 't:sock:inet_sock_set_state /args.newstate == 1/ { @[args.dport] = count(); }'
```

---

[← Demo 3](07-demo-ag.md) | [INDEX](../INDEX.md) | [Sonraki: Sonraki Adimlar →](09-sonraki-adimlar.md)
