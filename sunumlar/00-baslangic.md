# Bolum 0 — Baslangic: Takim Olusturma & SSH Baglantisi

[← INDEX](../INDEX.md) | [Sonraki: eBPF Nedir? →](01-ebpf-nedir.md)

---

## Hosgeldiniz!

Bugun kernel'in icine dalacagiz. eBPF sayesinde process'leri, dosya erisimlerini ve network paketlerini **gercek zamanli** izleyeceksiniz — hicbir kernel module yuklemeden, hicbir servis restart etmeden.

Herkes SSH ile sunucuya baglanacak ve **canli** kod yazacak.

---

## Takimlar

6 katilimci, 3 takim, takim basina 2 kisi.

**Asagidaki 5 isimden birini secin (ilk secen alir!):**

| # | Takim Adi | Maskot |
|---|-----------|--------|
| 1 | **Kernel Pandas** | `(◕ᴥ◕)` |
| 2 | **Packet Pirates** | `☠` |
| 3 | **Trace Wolves** | `🐺` |
| 4 | **Root Causes** | `#` |
| 5 | **Seg Faulters** | `💀` |

### Takim Dagilimi

| Takim | Uyeler | Secilen Isim |
|-------|--------|-------------|
| **Takim 1** | Burak & Oguzhan | _______________ |
| **Takim 2** | Yasin & Buse | _______________ |
| **Takim 3** | Ugur & Serhat | _______________ |

> Dogukan sunumu yapiyor, takimlara destek veriyor.

---

## SSH Baglantisi

Herkes ayni sunucuya SSH ile baglanacak. Dogukan size IP ve kullanici bilgilerini verecek.

```bash
ssh <kullanici>@<sunucu-ip>
```

Baglantidan sonra workshop dizinine gidin:

```bash
cd /opt/ebpf-demo
```

### Kontrol Listesi

Baglandiktan sonra su komutlari calistirin:

```bash
# 1. bpftrace yuklumu?
bpftrace --version

# 2. Kernel versiyonu (5.14+ olmali)
uname -r

# 3. eBPF destegi acik mi?
cat /boot/config-$(uname -r) | grep CONFIG_BPF=

# 4. BTF destegi var mi? (CO-RE icin gerekli)
cat /boot/config-$(uname -r) | grep CONFIG_DEBUG_INFO_BTF=

# 5. Smoke test — eBPF calisiyor mu?
sudo bpftrace -e 'BEGIN { printf("eBPF calisiyor!\n"); exit(); }'
```

Tum ciktilar basariliysa devam edebilirsiniz.

> **BASARIM:** *"Pre-flight Tamam"* — Her kisi kontrol listesini tamamladiginda **+10 puan** (bireysel)
>
> | Kisi | Tamamlandi |
> |------|-----------|
> | Burak | [ ] |
> | Oguzhan | [ ] |
> | Yasin | [ ] |
> | Buse | [ ] |
> | Ugur | [ ] |
> | Serhat | [ ] |

---

## SSH Ipuclari

Workshop boyunca **2 terminal penceresi** acmaniz gerekecek:

- **Terminal 1:** bpftrace programini calistirmak icin
- **Terminal 2:** test komutlari calistirmak icin (ls, curl, cat vs.)

Bunu yapmanin yollari:

```bash
# Yol 1: tmux kullanin (sunucuda yuklu)
tmux
# Ctrl+B sonra % ile ekrani bolin
# Ctrl+B sonra ok tuslari ile pencereler arasi gecis

# Yol 2: Ikinci bir SSH baglantisi acin
ssh <kullanici>@<sunucu-ip>
```

---

[← INDEX](../INDEX.md) | [Sonraki: eBPF Nedir? →](01-ebpf-nedir.md)
