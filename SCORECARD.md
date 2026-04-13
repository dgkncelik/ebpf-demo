# eBPF Workshop — Canli Skor Tablosu

> **Sunan:** Dogukan
> **Tarih:** _______________
> **Sure:** 90 dakika

---

## Takimlar

*Her takim asagidaki 5 isimden birini secer (ilk secen alir!):*
**Kernel Pandas** · **Packet Pirates** · **Trace Wolves** · **Root Causes** · **Seg Faulters**

| Takim | Uyeler | Secilen Isim | Toplam Puan | Sira |
|-------|--------|-------------|-------------|------|
| **Takim 1** | Burak & Oguzhan | | | |
| **Takim 2** | Yasin & Buse | | | |
| **Takim 3** | Ugur & Serhat | | | |

---

## Bireysel Skor Tablosu

| Kisi | Takim | Pre-flight | Verifier | Soru Yarismasi | Toplam |
|------|-------|-----------|----------|---------------|--------|
| Burak | 1 | /10 | | | |
| Oguzhan | 1 | /10 | | | |
| Yasin | 2 | /10 | | | |
| Buse | 2 | /10 | | | |
| Ugur | 3 | /10 | | | |
| Serhat | 3 | /10 | | | |

---

## Bolum 0 — Pre-flight Check (SSH ile)

| Kisi | SSH Baglandi | bpftrace OK | Smoke Test OK | Puan |
|------|-------------|-------------|---------------|------|
| Burak | [ ] | [ ] | [ ] | /10 |
| Oguzhan | [ ] | [ ] | [ ] | /10 |
| Yasin | [ ] | [ ] | [ ] | /10 |
| Buse | [ ] | [ ] | [ ] | /10 |
| Ugur | [ ] | [ ] | [ ] | /10 |
| Serhat | [ ] | [ ] | [ ] | /10 |

---

## Bolum 3 — `CTF`: Verifier Challenge (SSH ile)

| Aktivite | Puan | Takim 1 | Takim 2 | Takim 3 |
|----------|------|---------|---------|---------|
| Verifier hatasini duzelt | 30 | | | |

**Verifier Whisperer (ilk duzelten):**

| Kisi | Ilk Duzelten? | Bireysel Bonus |
|------|--------------|---------------|
| Burak | [ ] | /30 |
| Oguzhan | [ ] | /30 |
| Yasin | [ ] | /30 |
| Buse | [ ] | /30 |
| Ugur | [ ] | /30 |
| Serhat | [ ] | /30 |

---

## Bolum 5 — `DEMO` + `CTF`: Kim Ne Calistiriyor? (SSH ile)

| Tur | Aktivite | Puan | Takim 1 | Takim 2 | Takim 3 |
|-----|----------|------|---------|---------|---------|
| `DEMO` | Base demo — Birlikte inceleyelim | — | — | — | — |
| `CTF` | Challenge 1A: UID + timestamp | 50 | | | |
| `CTF` | Challenge 1B: Kullaniciya gore filtre | 50 | | | |
| `CTF` | **Ilk tamamlayan bonus** | 50 | | | |

---

## Bolum 6 — `DEMO` + `CTF`: Dosya Casusu (SSH ile)

| Tur | Aktivite | Puan | Takim 1 | Takim 2 | Takim 3 |
|-----|----------|------|---------|---------|---------|
| `DEMO` | Base demo — Birlikte inceleyelim | — | — | — | — |
| `CTF` | Challenge 2A: /etc/ filtresi | 50 | | | |
| `CTF` | Challenge 2B: Process basina sayim | 50 | | | |
| `CTF` | **Ilk tamamlayan bonus** | 50 | | | |

---

## Bolum 7 — `DEMO` + `CTF`: Ag Koruyucusu (SSH ile)

| Tur | Aktivite | Puan | Takim 1 | Takim 2 | Takim 3 |
|-----|----------|------|---------|---------|---------|
| `DEMO` | Base demo — Birlikte inceleyelim | — | — | — | — |
| `CTF` | Challenge 3A: TCP baglanti takibi | 50 | | | |
| `CTF` | Challenge 3B: Protokol dagilimi | 50 | | | |
| `CTF` | **Ilk tamamlayan bonus** | 50 | | | |

---

## Bolum 8 — `CTF`: Bonus Challenge'lar (SSH ile)

*Ilk tamamlayan takim temel puanin ustune +50 bonus!*

| Aktivite | Puan | Takim 1 | Takim 2 | Takim 3 | Ilk? |
|----------|------|---------|---------|---------|------|
| Bonus 1: Process yasam dongusu | 100 | | | | |
| Bonus 2: Yavas syscall bulucu | 100 | | | | |
| Bonus 3: Yasakli komut | 100 | | | | |

---

## Bolum 10 — `SORU YARISMASI`: Bilgi Testi

*+20 puan (takim) / +10 puan (bireysel — cevaplayan kisiye) her dogru cevap icin*

| Tur | Soru | Takim 1 | Takim 2 | Takim 3 | Ilk Cevap Bonusu |
|-----|------|---------|---------|---------|-----------------|
| 1 | S1: eBPF'i tek cumleyle aciklayin | | | | |
| 1 | S2: BPF ile eBPF farki? | | | | |
| 1 | S3: bpf() syscall | | | | |
| 1 | S4: Guvenlik — verifier mi? | | | | |
| 1 | S5: 3 gercek dunya araci | | | | |
| 2 | S6: Tracepoint vs kprobe | | | | |
| 2 | S7: XDP = pre-stack | | | | |
| 2 | S8: Field'lari gorme komutu | | | | |
| 2 | S9: Uprobe ne yapar? | | | | |
| 2 | S10: XDP_DROP vs XDP_PASS | | | | |
| 3 | S11: NULL check neden? | | | | |
| 3 | S12: Unbounded loop neden? | | | | |
| 3 | S13: BTF/CO-RE ne cozer? | | | | |
| 3 | S14: @counter[comm] = count() | | | | |
| 3 | S15: tid vs pid key | | | | |
| 4 | S16: bpftrace -l komutu | | | | |
| 4 | S17: /uid == 1000/ filtresi | | | | |
| 4 | S18: bpf_probe_read_user_str() | | | | |
| 4 | S19: hist() ne uretir? | | | | |
| 4 | S20: En faydali demo (acik uclu) | | | | |

---

## Final Sonuclari

### Takim Siralamasi

| Siralama | Takim | Puan | Rank |
|----------|-------|------|------|
| 1. | | | |
| 2. | | | |
| 3. | | | |

**Rank Tablosu:**

| Puan | Rank | Rozet |
|------|------|-------|
| 0–200 | Kernel Turisti | `[*]` |
| 201–400 | Probe Ciragi | `[**]` |
| 401–600 | Trace Ustasi | `[***]` |
| 601–800 | eBPF Ninja | `[****]` |
| 800+ | Kernel Overlord | `[*****]` |

### Bireysel Siralama

| Siralama | Kisi | Puan | Rank |
|----------|------|------|------|
| 1. | | | |
| 2. | | | |
| 3. | | | |
| 4. | | | |
| 5. | | | |
| 6. | | | |

**Bireysel Rank:**

| Puan | Rank |
|------|------|
| 0–30 | Gozlemci |
| 31–60 | Cirak |
| 61–100 | Uygulayici |
| 100+ | eBPF MVP Adayi |

---

## Kupa Dolabi

| Kupa | Aciklama | Kazanan |
|------|----------|---------|
| **eBPF MVP** | En yuksek bireysel puan | |
| **Hiz Seytani** | Tum 3 base demo'yu ilk bitiren takim | |
| **Verifier Whisperer** | Verifier hatasini ilk duzelten kisi | |
| **One-Liner Krali** | En iyi bpftrace one-liner (grup oyu) | |
| **Yaraticilik Odulu** | En yaratici bonus cozumu (grup oyu) | |
| **First Blood** | Herhangi bir challenge puani alan ilk takim | |

---

## Oylama (workshop sonu)

### One-Liner Krali Oyu

*Her kisi en iyi one-liner'ini yazar. Herkes oy verir (kendine oy veremezsiniz).*

| Aday | One-Liner | Oy |
|------|-----------|-----|
| Burak | | |
| Oguzhan | | |
| Yasin | | |
| Buse | | |
| Ugur | | |
| Serhat | | |

### Yaraticilik Odulu Oyu

| Aday | Ne Yapti | Oy |
|------|----------|-----|
| | | |
| | | |
| | | |
