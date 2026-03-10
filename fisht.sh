#!/system/bin/sh
# ================================================
# FISH IT 24/7 Multi-Instance Launcher + AutoClean
# Versi: Private Server Selector
# Delay aman: 8–10 detik (RAM Friendly)
# ================================================

# Default (akan diganti setelah user memilih server)
ROBLOX_URL=""

# === DAFTAR PAKET (Prioritas utama) ===
APPS="
com.nakune.lite2
com.nakune.lite3
com.nakune.lite4
com.nakune.lite5
"

# === Fallback jika prioritas tidak ada ===
FALLBACK="
com.delta.zinnc1
com.delta.zinnc2
com.delta.zinnc3
com.delta.zinnc4
com.delta.zinnc5
"

# === Paket lainnya (reconnect, dll) ===
OTHER="
com.roblox.reconnect0
com.roblox.reconnect1
com.roblox.reconnect2
com.roblox.reconnect3
com.roblox.reconnect4
com.roblox.reconnect5
com.roblox.reconnect6
"

TMPFILE="/data/local/tmp/final_pkgs.txt"
AUTO_CLEAN_PID=""

# ================================================
# MENU UTAMA
# ================================================
menu() {
  clear
  echo "========================================"
  echo "     FISH IT 24/7 MULTI LAUNCHER"
  echo "     Delay 8-10 detik (RAM Friendly)"
  echo "========================================"
  echo "1. Install semua APK di folder ini"
  echo "2. Open APP (dengan Private Server)"
  echo "3. Force Close APP (Prioritas)"
  echo "4. Hapus Data APP (Prioritas)"
  echo "5. Auto: Force Close → Clear Cache"
  echo "6. Exit"
  echo "========================================"
  echo -n "Pilih (1-6): "
}

# ================================================
# INSTALL SEMUA APK
# ================================================
install_all() {
  echo "🔍 Mencari file .apk..."
  for APK in ./*.apk; do
    [ -f "$APK" ] || { echo "⚠️ Tidak ada APK ditemukan"; return; }
    echo "📦 Install $(basename "$APK")..."
    cp "$APK" /data/local/tmp/ 2>/dev/null
    if pm install -r "/data/local/tmp/$(basename "$APK")" >/dev/null 2>&1; then
      echo "✅ Sukses"
    else
      echo "❌ Gagal"
    fi
    rm -f "/data/local/tmp/$(basename "$APK")"
  done
  echo "🎉 Semua APK selesai diproses"
}

# ================================================
# CARI PAKET
# ================================================
find_pkgs_priority() {
  : > "$TMPFILE"
  for PKG in $APPS; do pm list packages | grep -q "^package:$PKG$" && echo "$PKG" >> "$TMPFILE"; done
  [ -s "$TMPFILE" ] && return
  for PKG in $FALLBACK; do pm list packages | grep -q "^package:$PKG$" && echo "$PKG" >> "$TMPFILE"; done
  [ -s "$TMPFILE" ] && return
  for PKG in $OTHER; do pm list packages | grep -q "^package:$PKG$" && echo "$PKG" >> "$TMPFILE"; done
}

find_pkgs_all() {
  : > "$TMPFILE"
  for list in "$APPS" "$FALLBACK" "$OTHER"; do
    for PKG in $list; do
      pm list packages | grep -q "^package:$PKG$" && echo "$PKG" >> "$TMPFILE"
    done
  done
}

# ================================================
# AUTO CLEAN CACHE 1 JAM
# ================================================
auto_clean_cache_loop() {
  echo "♻️ AutoClean aktif (setiap 1 jam)"
  while true; do
    sleep 3600
    echo "🧹 Membersihkan RAM & cache..."
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    pm trim-caches 9999M >/dev/null 2>&1

    for PKG in $(cat "$TMPFILE" 2>/dev/null); do
      [ -d "/data/data/$PKG/cache" ] && find "/data/data/$PKG/cache" -mindepth 1 -delete
    done
    echo "✅ AutoClean selesai"
  done
}

# ================================================
# OPEN APPS + PILIH PRIVATE SERVER
# ================================================
open_apps() {

  # ====== PILIH PRIVATE SERVER ======
  echo "==============================="
  echo "    PILIH PRIVATE SERVER"
  echo "==============================="
  echo "1. Garden 1"
  echo "2. Garden 2"
  echo "3. YTTA GEYZZZ"
  echo "4. Input manual"
  echo "5. Batal"
  echo -n "Pilih server (1-5): "
  read SVC

  case "$SVC" in
    1) SERVER_CODE="8b107e5507c7a14d9817e4a6087dae08" ;;
    2) SERVER_CODE="81b107e5507c7a14d9817e4a6087dae08" ;;
    3) SERVER_CODE="83b107e5507c7a14d9817e4a6087dae08" ;;
    4)
       echo -n "Masukkan privateServerLinkCode: "
       read SERVER_CODE
       ;;
    5)
       echo "❌ Dibatalkan"
       sleep 1
       return
       ;;
    *)
       echo "❌ Pilihan tidak valid"
       sleep 1
       return
       ;;
  esac

  ROBLOX_URL="https://www.roblox.com/games/121864768012064/UPD-Fish-It?privateServerLinkCode=${SERVER_CODE}"
  echo "🔗 Server dipilih:"
  echo "$ROBLOX_URL"
  sleep 1


  # ====== LANJUTKAN BUKA MULTI INSTANCE ======
  find_pkgs_all
  [ ! -s "$TMPFILE" ] && { echo "❌ Tidak ada app mod ditemukan!"; sleep 2; return; }

  echo "=== APLIKASI TERDETEKSI ==="
  declare -a PKG_ARRAY
  i=1
  while read PKG; do PKG_ARRAY[$i]="$PKG"; echo "$i. $PKG"; i=$((i+1)); done < "$TMPFILE"
  echo "==============================="
  echo -n "Pilih nomor (1,3,5 atau 'all'): "
  read CHOICE

  if [ "$CHOICE" = "all" ] || [ "$CHOICE" = "ALL" ]; then
    PKGS_TO_OPEN=$(cat "$TMPFILE")
  else
    PKGS_TO_OPEN=""
    for num in $(echo "$CHOICE" | tr ',' ' '); do
      case "$num" in ''|*[!0-9]*) continue ;; esac
      [ "$num" -ge 1 ] && [ "$num" -lt "$i" ] && PKGS_TO_OPEN="$PKGS_TO_OPEN ${PKG_ARRAY[$num]}"
    done
  fi

  [ -z "$PKGS_TO_OPEN" ] && { echo "❌ Tidak ada yang dipilih"; sleep 1; return; }

  # ==== BUKA SATU PER SATU ====
  for PKG in $PKGS_TO_OPEN; do
    echo "🚀 Membuka $PKG ..."
    am start -a android.intent.action.VIEW -d "$ROBLOX_URL" "$PKG" >/dev/null 2>&1 &

    for t in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
      PID=$(pidof "$PKG") && break
      sleep 0.5
    done

    if [ -n "$PID" ]; then
      echo 0 > "/proc/$PID/oom_adj" 2>/dev/null
      echo 0 > "/proc/$PID/oom_score_adj" 2>/dev/null
      renice -10 "$PID" >/dev/null 2>&1
      echo "🛡️ $PKG dilindungi (PID: $PID)"
    fi

    DELAY=$((8 + RANDOM % 3))
    echo "⏳ Delay $DELAY detik..."
    sleep "$DELAY"
  done

  # ==== JALANKAN AUTOCLEAN ====
  if [ -z "$AUTO_CLEAN_PID" ] || ! kill -0 "$AUTO_CLEAN_PID" 2>/dev/null; then
    auto_clean_cache_loop &
    AUTO_CLEAN_PID=$!
    echo "♻️ AutoClean running (PID: $AUTO_CLEAN_PID)"
  fi

  echo "🎉 Semua instance berhasil dibuka!"
}

# ================================================
# FORCE CLOSE PRIORITAS
# ================================================
force_close() {
  find_pkgs_priority
  [ ! -s "$TMPFILE" ] && { echo "❌ Tidak ada app prioritas"; return; }
  for PKG in $(cat "$TMPFILE"); do am force-stop "$PKG" && echo "🛑 $PKG ditutup"; done
}

# ================================================
# CLEAR DATA PRIORITAS
# ================================================
clear_data() {
  find_pkgs_priority
  [ ! -s "$TMPFILE" ] && { echo "❌ Tidak ada app prioritas"; return; }
  for PKG in $(cat "$TMPFILE"); do pm clear "$PKG" && echo "🧨 Data $PKG dihapus"; done
}

# ================================================
# AGRESIF CLEAN
# ================================================
agresif_clean() {
  find_pkgs_priority
  [ ! -s "$TMPFILE" ] && { echo "❌ Tidak ada app prioritas"; return; }
  for PKG in $(cat "$TMPFILE"); do am force-stop "$PKG"; done
  sleep 1
  pm trim-caches 9999M >/dev/null 2>&1
  echo "🧹 Cache global dibersihkan"
  for PKG in $(cat "$TMPFILE"); do
    [ -d "/data/data/$PKG/cache" ] && find "/data/data/$PKG/cache" -mindepth 1 -delete
  done
  echo "✅ Agresif clean selesai"
}

# ================================================
# MAIN LOOP
# ================================================
while true; do
  menu
  read pilihan
  case "$pilihan" in
    1) install_all ;;
    2) open_apps ;;
    3) force_close ;;
    4) clear_data ;;
    5) agresif_clean ;;
    6)
      [ -n "$AUTO_CLEAN_PID" ] && kill "$AUTO_CLEAN_PID"
      echo "👋 Exit. AutoClean dihentikan."
      exit 0
      ;;
    *) echo "❌ Pilihan salah!" ;;
  esac
  echo "Tekan Enter untuk kembali ke menu..."
  read
done
