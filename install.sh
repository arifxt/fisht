#Install ALL APK
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
