# Bolum 10 — Bilgi Yarismasi & Skor Tablosu

[← Sonraki Adimlar](09-sonraki-adimlar.md) | [INDEX](../INDEX.md) | [Skor Tablosu →](../SCORECARD.md)

---

> Tum pratik demolar ve challenge'lar bitti. Simdi bugun ogrendiklerinizi test edelim!
> Takimlar icinde tartisabilirsiniz. Bir kisi cevap verir. Ilk dogru cevap **+10 bonus puan** alir.

---

## Tur 1 — eBPF Temelleri

> Her dogru cevap: **+20 puan** (takim) + **+10 puan** (bireysel — cevaplayan kisiye)

**S1:** eBPF'i tek cumleyle aciklayin. (Ipucu: "kernel", "hook", "sandbox" kelimeleri geciyor olmali)

**S2:** BPF ile eBPF arasindaki temel fark nedir?

**S3:** eBPF programini kernel'a yukleyen system call hangisidir?

**S4:** Guvenlik kontrolunu kim yapar — compiler mi, verifier mi, yoksa JIT mi?

**S5:** eBPF kullanan 3 gercek dunya araci sayabilir misiniz?

---

## Tur 2 — Program Turleri

> Ayni puanlama: **+20 puan** (takim) + **+10 puan** (bireysel)

**S6:** Tracepoint ile kprobe arasindaki temel fark nedir? Hangisi daha stabil?

**S7:** Paketleri kernel network stack'inden **once** isleyen eBPF program turu hangisidir?

**S8:** Bir tracepoint'in field'larini (hangi verileri sagladigini) gormek icin hangi komutu kullaniriz?

**S9:** Uprobe ne ise yarar? Tracepoint'ten farki nedir?

**S10:** `XDP_DROP` ve `XDP_PASS` arasindaki fark nedir?

---

## Tur 3 — Verifier & Map'ler

> Ayni puanlama: **+20 puan** (takim) + **+10 puan** (bireysel)

**S11:** Verifier neden map lookup sonucunda NULL check zorlar?

**S12:** eBPF'te neden sinirsiz dongu (unbounded loop) yazilamaz?

**S13:** BTF ve CO-RE hangi problemi cozer? Neden onemlidir?

**S14:** bpftrace'de `@counter[comm] = count();` ne yapar? Bu bir map mi?

**S15:** Entry/exit pattern'inde neden `tid` (thread ID) ile key'liyoruz, `pid` ile degil?

---

## Tur 4 — Pratik Bilgi (Bugun Ne Ogrendik?)

> Ayni puanlama: **+20 puan** (takim) + **+10 puan** (bireysel)

**S16:** `sudo bpftrace -l 'tracepoint:syscalls:*'` komutu ne yapar?

**S17:** bpftrace'de `/uid == 1000/` syntax'i ne anlama gelir?

**S18:** `bpf_probe_read_user_str()` neden gerekli? Neden dogrudan pointer'i okuyamayiz?

**S19:** bpftrace'de `hist()` fonksiyonu ne uretir?

**S20:** Bugun yaptigimiz 3 demo'dan (exec, dosya, network) sizin gunluk isinizde en cok hangisi ise yarar? Neden? (Acik uclu — en iyi aciklama puan alir)

---

## Cevap Anahtari (Dogukan icin)

<details>
<summary>Cevaplari Goster</summary>

| # | Cevap |
|---|-------|
| S1 | eBPF, Linux kernel'de sandbox icinde ozel kod calistirmanizi saglayan bir mekanizmadir — kernel'i degistirmeden event'lere hook olabilirsiniz. |
| S2 | BPF sadece paket filtreleme yapabilirken (tcpdump), eBPF herhangi bir kernel event'ine hook olabilir, map kullanabilir, JIT ile derlenebilir. |
| S3 | `bpf()` system call'i |
| S4 | Verifier. Compiler syntax kontrolu yapar, JIT native code'a cevirir, ama **guvenlik kontrolunu verifier** yapar. |
| S5 | Cilium, Falco, bcc-tools, Pixie, Calico eBPF, Katran, Tetragon (herhangi 3 tanesi) |
| S6 | Tracepoint kernel ABI'nin parcasidir, stabil kalir. Kprobe herhangi bir fonksiyona hook olur ama fonksiyon adi degisirse bozulur. Tracepoint daha stabil. |
| S7 | XDP (eXpress Data Path) |
| S8 | `sudo bpftrace -lv 'tracepoint:...'` veya `cat /sys/kernel/tracing/events/.../format` |
| S9 | Uprobe user-space binary fonksiyonlarina (libc, libssl vs.) hook olur. Tracepoint kernel event'lerine hook olur. |
| S10 | `XDP_DROP` paketi sessizce atar (en hizli discard). `XDP_PASS` paketi kernel network stack'e iletir. |
| S11 | Cunku `bpf_map_lookup_elem()` key bulunamazsa NULL dondurur. NULL pointer dereference kernel crash'e yol acabilir. |
| S12 | Cunku verifier programin **kesinlikle** sonlanacagini garanti etmek zorundadir. Sinirsiz dongu potansiyel sonsuz dongu demektir. |
| S13 | Farkli kernel versiyonlarinda struct layout'lari degisir. CO-RE, BTF bilgisini kullanarak offset'leri yukleme zamaninda ayarlar — tek binary tum versiyonlarda calisir. |
| S14 | Evet, bu otomatik olarak bir BPF hash map olusturur. `comm` (process adi) key olur, her event'te o key'in sayaci artar. |
| S15 | Cunku bir process birden fazla thread'e sahip olabilir. `pid` kullanirsan farkli thread'lerin entry/exit'leri birbirine karisir. `tid` her thread'e ozgu. |
| S16 | Sistemdeki tum syscall tracepoint'lerini listeler. |
| S17 | Bu bir filtredir — probe sadece UID 1000 olan kullanici icin tetiklenir, diger kullanicilar icin atlanir. |
| S18 | `args[0]` user space bellegine isaret eder. eBPF kernel'de calisir, user space memory'ye dogrudan erisin guvenli degildir. Helper fonksiyonu guvenli kopyalama yapar. |
| S19 | Degerlerin dagilimini gosteren bir power-of-2 histogram uretir (kac deger hangi aralikta). |
| S20 | Acik uclu — en iyi aciklama puani alir. |

</details>

---

## Oylama: One-Liner Krali

Her kisi bugun yazdigi **en iyi bpftrace one-liner**'ini paylasin. Herkes oy verir (kendine oy veremezsiniz).

| Aday | One-Liner | Oy |
|------|-----------|-----|
| Burak | | |
| Oguzhan | | |
| Yasin | | |
| Buse | | |
| Ugur | | |
| Serhat | | |

---

## Oylama: Yaraticilik Odulu

Bonus challenge'larda en yaratici cozumu kim yapti?

| Aday | Ne Yapti | Oy |
|------|----------|-----|
| | | |
| | | |
| | | |

---

## Final Skor Hesaplama

Tum puanlari toplayin → [SCORECARD.md](../SCORECARD.md)

---

[← Sonraki Adimlar](09-sonraki-adimlar.md) | [INDEX](../INDEX.md) | [Skor Tablosu →](../SCORECARD.md)
