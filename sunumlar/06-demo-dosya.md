# Bolum 6 — Demo 2: Dosya Casusu

[← Demo 1](05-demo-exec.md) | [INDEX](../INDEX.md) | [Sonraki: Demo 3 →](07-demo-ag.md)

---

## Hedef

Hangi dosyalarin acildigini, kim tarafindan acildigini izleyin ve hassas dizinlere filtreleyin.

**SysAdmin senaryosu:** *"Oguzhan, bir seyler surekli /etc/resolv.conf'u degistiriyor — kim yapıyor?"*

---

## openat() Syscall'i

Modern Linux tum dosya islemleri icin `openat()` kullanir (eski `open()` degil):

```c
int openat(int dirfd, const char *pathname, int flags, mode_t mode);
```

### Field'lari Kesfetme (SSH ile deneyin)

```bash
sudo bpftrace -lv 'tracepoint:syscalls:sys_enter_openat'
```

Bu komut size tracepoint'in tum field'larini gosterir: `filename`, `flags`, `mode` vs.

---

## Canli Kodlama — SSH ile Birlikte

### Adim 1: Script'i inceleyin

```bash
cd /opt/ebpf-demo/demos/02-file-spy
cat file_spy.bt
```

Icerik:

```
tracepoint:syscalls:sys_enter_openat
{
    printf("%-6d %-16s %s\n", pid, comm, str(args.filename));
}
```

### Adim 2: Calistirin (Terminal 1)

```bash
sudo bpftrace file_spy.bt
```

### Adim 3: Diger terminalde dosya islemleri yapin (Terminal 2)

```bash
cat /etc/hostname
cat /etc/passwd
vim /tmp/testfile           # :wq ile kaydet ve cik
ls /var/log/
systemctl status sshd
```

`systemctl` bile icerde onlarca dosya acar — library'ler, D-Bus socket'leri vs. Hepsini goreceksiniz!

Diger takimlarin dosya erisimlerini de goreceksiniz cunku herkes ayni sunucuda.

> **PUAN:** Base demo'yu calistirdiniz → **+100 puan** (takim)

---

## Challenge 2A — Hedefli Gozlem: Sadece /etc/ (+50 puan)

`file_spy.bt`'yi sadece `/etc/` altindaki dosya acma islemlerini gosterecek sekilde degistirin.

**Ipucu:** `strncmp(str(args.filename), "/etc/", 5) == 0`

SSH ile:
```bash
cp file_spy.bt file_spy_v2.bt
vim file_spy_v2.bt
sudo bpftrace file_spy_v2.bt
```

Test:
```bash
# Bu gorunmeli:
cat /etc/hostname

# Bu gorunMEmeli:
cat /tmp/testfile
```

<details>
<summary>Cozum</summary>

```
tracepoint:syscalls:sys_enter_openat
/strncmp(str(args.filename), "/etc/", 5) == 0/
{
    printf("%-6d %-16s %s\n", pid, comm, str(args.filename));
}
```

</details>

---

## Challenge 2B — Process Basina Dosya Acma Sayisi (+50 puan)

Her acma islemini yazdirmak yerine, her process'in kac dosya actigini **sayin**. Ctrl+C'de ozet yazsin.

**Ipucu:** bpftrace map'i `@opens[comm]` ve `count()` kullanin.

<details>
<summary>Cozum</summary>

```
tracepoint:syscalls:sys_enter_openat
{
    @opens[comm] = count();
}
```

Ctrl+C yaptiginizda bpftrace map icerigini sirali olarak yazdirir. Muhtemelen `systemd-journal`, `tuned` veya `sssd` en ustte olacak!

</details>

---

> **BASARIM:** *"Dosya Dedektifi"* — Dosya erisimlerini basariyla trace ettiniz!
>
> Ilk tamamlayan takim **+50 bonus puan** alir.

---

[← Demo 1](05-demo-exec.md) | [INDEX](../INDEX.md) | [Sonraki: Demo 3 →](07-demo-ag.md)
