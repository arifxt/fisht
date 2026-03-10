#/bin/bash!


wget https://cloud.rnt-team.me/public.php/dav/files/8yceNR6dTkgYH7n/Delta%20Lite/v2.710.707-02/Android%2010/Lite%2001-2.710.707.apk
wget https://cloud.rnt-team.me/public.php/dav/files/8yceNR6dTkgYH7n/Delta%20Lite/v2.710.707-02/Android%2010/Lite%2002-2.710.707.apk
wget https://cloud.rnt-team.me/public.php/dav/files/8yceNR6dTkgYH7n/Delta%20Lite/v2.710.707-02/Android%2010/Lite%2003-2.710.707.apk
wget https://cloud.rnt-team.me/public.php/dav/files/8yceNR6dTkgYH7n/Delta%20Lite/v2.710.707-02/Android%2010/Lite%2004-2.710.707.apk
#Install all
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
