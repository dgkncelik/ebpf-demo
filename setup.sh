#!/usr/bin/env bash
# setup.sh — eBPF Workshop RHEL 9.x sunucu hazirlik script'i
# Multi-user SSH ortami icin tasarlandi.
#
# Kullanim: sudo bash setup.sh
#
# Bu script:
# 1. eBPF araclarini yukler (bpftrace, bcc-tools vs.)
# 2. Workshop dosyalarini /opt/ebpf-demo'ya kopyalar
# 3. Katilimci kullanicilari olusturur (sudo yetkili)
# 4. tmux yukler (coklu terminal icin)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*"; }
header(){ echo -e "${CYAN}$*${NC}"; }

if [[ $EUID -ne 0 ]]; then
    error "Bu script root olarak calistirilmali (sudo bash setup.sh)"
    exit 1
fi

WORKSHOP_DIR="/opt/ebpf-demo"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PARTICIPANTS=("burak" "oguzhan" "yasin" "buse" "ugur" "serhat")
DEFAULT_PASS="ebpf2026"

echo
header "============================================"
header "  eBPF Workshop — RHEL 9.x Sunucu Kurulumu"
header "============================================"
echo

KERNEL_VERSION=$(uname -r)
info "Kernel: $KERNEL_VERSION"

if [[ ! -f /etc/redhat-release ]] || ! grep -q "release 9" /etc/redhat-release; then
    warn "Bu script RHEL 9.x icin tasarlandi. Tespit edilen: $(cat /etc/redhat-release 2>/dev/null || echo 'bilinmiyor')"
    read -p "Yine de devam edilsin mi? [e/H] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Ee]$ ]] || exit 1
fi

# --- Bolum 1: Paket Yukleme ---
header "\n--- 1/4: eBPF Araclari Yukleniyor ---"

dnf install -y \
    bpftrace \
    bcc-tools \
    bcc \
    kernel-devel-$(uname -r) \
    kernel-headers-$(uname -r) \
    elfutils-libelf-devel \
    python3-bcc \
    perf \
    strace \
    tmux \
    vim \
    2>&1 | tail -10

info "Paketler yuklendi."

# --- Bolum 2: Workshop Dosyalarini Kopyala ---
header "\n--- 2/4: Workshop Dosyalari Hazirlaniyor ---"

mkdir -p "$WORKSHOP_DIR"
if [[ "$SCRIPT_DIR" != "$WORKSHOP_DIR" ]]; then
    cp -r "$SCRIPT_DIR"/demos "$WORKSHOP_DIR"/ 2>/dev/null || true
    cp -r "$SCRIPT_DIR"/sunumlar "$WORKSHOP_DIR"/ 2>/dev/null || true
    cp "$SCRIPT_DIR"/INDEX.md "$WORKSHOP_DIR"/ 2>/dev/null || true
    cp "$SCRIPT_DIR"/SCORECARD.md "$WORKSHOP_DIR"/ 2>/dev/null || true
    cp "$SCRIPT_DIR"/README.md "$WORKSHOP_DIR"/ 2>/dev/null || true
fi

chmod -R 755 "$WORKSHOP_DIR"
find "$WORKSHOP_DIR" -name "*.bt" -exec chmod 755 {} \;

info "Workshop dosyalari $WORKSHOP_DIR dizinine kopyalandi."

# --- Bolum 3: Kullanici Olusturma ---
header "\n--- 3/4: Katilimci Kullanicilari Olusturuluyor ---"

for user in "${PARTICIPANTS[@]}"; do
    if id "$user" &>/dev/null; then
        warn "Kullanici '$user' zaten mevcut, atlaniyor."
    else
        useradd -m -s /bin/bash "$user"
        echo "$user:$DEFAULT_PASS" | chpasswd
        info "Kullanici olusturuldu: $user"
    fi

    # sudo yetkisi ver (bpftrace icin gerekli)
    if [[ ! -f "/etc/sudoers.d/$user" ]]; then
        echo "$user ALL=(ALL) NOPASSWD: /usr/bin/bpftrace, /usr/sbin/bpftrace, /usr/share/bcc/tools/*, /usr/bin/perf, /usr/bin/strace" > "/etc/sudoers.d/$user"
        chmod 440 "/etc/sudoers.d/$user"
        info "  → sudo yetkisi verildi: $user (bpftrace, bcc-tools, perf, strace)"
    fi

    # Her kullanicinin home dizininde workshop linkini olustur
    if [[ ! -L "/home/$user/ebpf-demo" ]]; then
        ln -sf "$WORKSHOP_DIR" "/home/$user/ebpf-demo"
    fi
done

# Concurrent bpftrace icin RLIMIT_MEMLOCK ayari
header "\n--- Concurrent eBPF Ayarlari ---"

# locked memory limitini artir (6 kisi ayni anda bpftrace calistiracak)
if ! grep -q "memlock" /etc/security/limits.d/ebpf-workshop.conf 2>/dev/null; then
    cat > /etc/security/limits.d/ebpf-workshop.conf << 'LIMITS'
# eBPF Workshop: BPF map'ler icin locked memory limiti
*    soft    memlock    unlimited
*    hard    memlock    unlimited
LIMITS
    info "RLIMIT_MEMLOCK: unlimited olarak ayarlandi (BPF map'ler icin)"
else
    info "RLIMIT_MEMLOCK: zaten ayarli"
fi

# perf_event_paranoid: bpftrace icin gerekli
PARANOID=$(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo "?")
if [[ "$PARANOID" -gt 1 ]]; then
    echo 1 > /proc/sys/kernel/perf_event_paranoid
    echo "kernel.perf_event_paranoid = 1" >> /etc/sysctl.d/99-ebpf-workshop.conf
    sysctl -p /etc/sysctl.d/99-ebpf-workshop.conf &>/dev/null
    info "perf_event_paranoid: 1 olarak ayarlandi"
else
    info "perf_event_paranoid: $PARANOID (uygun)"
fi

info "Tum katilimci kullanicilari hazir."
echo
info "Kullanicilar ve sifre:"
for user in "${PARTICIPANTS[@]}"; do
    echo "    $user / $DEFAULT_PASS"
done
warn "Sifreleri degistirmeyi unutmayin: passwd <kullanici>"

# --- Bolum 4: Dogrulama ---
header "\n--- 4/4: Dogrulama ---"

echo
if command -v bpftrace &>/dev/null; then
    info "bpftrace: $(bpftrace --version 2>&1 | head -1)"
else
    error "bpftrace: BULUNAMADI"
fi

if command -v /usr/share/bcc/tools/execsnoop &>/dev/null || \
   command -v execsnoop-bpfcc &>/dev/null; then
    info "bcc-tools: yuklu"
else
    warn "bcc-tools: bazi araclar eksik olabilir"
fi

if command -v tmux &>/dev/null; then
    info "tmux: yuklu ($(tmux -V))"
else
    warn "tmux: bulunamadi"
fi

BPF_CONFIG=$(cat /boot/config-$(uname -r) 2>/dev/null | grep "CONFIG_BPF=" || echo "bulunamadi")
if [[ "$BPF_CONFIG" == *"=y"* ]]; then
    info "CONFIG_BPF: etkin"
else
    error "CONFIG_BPF: $BPF_CONFIG — eBPF calismayabilir!"
fi

BTF_CONFIG=$(cat /boot/config-$(uname -r) 2>/dev/null | grep "CONFIG_DEBUG_INFO_BTF=" || echo "bulunamadi")
if [[ "$BTF_CONFIG" == *"=y"* ]]; then
    info "CONFIG_DEBUG_INFO_BTF: etkin (CO-RE destekleniyor)"
else
    warn "CONFIG_DEBUG_INFO_BTF: $BTF_CONFIG — bazi ozellikler kisitli olabilir"
fi

echo
header "--- Smoke Test ---"
info "Calistiriliyor: bpftrace -e 'BEGIN { printf(\"eBPF calisiyor!\\n\"); exit(); }'"
if bpftrace -e 'BEGIN { printf("eBPF calisiyor!\n"); exit(); }' 2>/dev/null; then
    info "Smoke test BASARILI"
else
    error "Smoke test BASARISIZ — kernel konfigurasyonunu kontrol edin"
fi

echo
header "============================================"
info "Kurulum tamamlandi!"
echo
info "Workshop dizini: $WORKSHOP_DIR"
info "Katilimcilar SSH ile baglanabilir:"
for user in "${PARTICIPANTS[@]}"; do
    echo "    ssh $user@$(hostname -I | awk '{print $1}')"
done
echo
info "Baglanti sonrasi: cd /opt/ebpf-demo"
header "============================================"
