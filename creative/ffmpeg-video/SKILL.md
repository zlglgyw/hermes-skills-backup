---
name: ffmpeg-video
description: "Bikin video dari gambar, teks, musik pake FFmpeg di Termux/Android. Slideshow, text overlay, promo, konten sosmed."
version: 1.0.0
author: hermes
license: MIT
platforms: [linux]
prerequisites:
  commands: ["ffmpeg"]
metadata:
  hermes:
    tags: [video, ffmpeg, termux, content, social-media, slideshow]
    category: creative
---

# FFmpeg Video Creator

Bikin video sederhana pake FFmpeg. Cocok buat konten sosmed, promo, slideshow.

## Kapan Dipake

- User minta bikin video dari gambar/foto
- Mau tambah teks/judul di video
- Slideshow foto + musik
- Video promo sederhana
- Video dari background + teks animasi

## Perintah Dasar

### 1. Gambar jadi Video (slideshow)

```bash
# Satu gambar jadi video 10 detik
ffmpeg -loop 1 -i input.png -c:v libx264 -t 10 -pix_fmt yuv420p -vf "scale=1080:1920" output.mp4

# Beberapa gambar jadi slideshow (tiap gambar 3 detik)
# Format input: buat file list gambar
for f in img1.png img2.png img3.png; do
  echo "file '$f'"
  echo "duration 3"
done > list.txt
echo "file 'img3.png'" >> list.txt  # frame terakhir

ffmpeg -f concat -safe 0 -i list.txt -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" -c:v libx264 -pix_fmt yuv420p -r 30 output.mp4
```

### 2. Tambah Teks/Judul

```bash
# Teks di tengah layar
ffmpeg -i input.mp4 -vf "drawtext=text='Judul Video':fontsize=60:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black:shadowx=2:shadowy=2" -c:a copy output.mp4

# Teks di bawah (subtitle style)
ffmpeg -i input.mp4 -vf "drawtext=text='@username':fontsize=40:fontcolor=white:x=(w-text_w)/2:y=h-100:shadowcolor=black:shadowx=1:shadowy=1" -c:a copy output.mp4

# Background box di belakang teks
ffmpeg -i input.mp4 -vf "drawtext=text='PROMO':fontsize=80:fontcolor=white:box=1:boxcolor=red@0.8:boxborderw=20:x=(w-text_w)/2:y=(h-text_h)/2" -c:a copy output.mp4
```

### 3. Tambah Musik/Audio

```bash
# Tambah musik, potong sesuai video
ffmpeg -i video.mp4 -i music.mp3 -c:v copy -c:a aac -shortest output.mp4

# Musik + volume kontrol
ffmpeg -i video.mp4 -i music.mp3 -c:v copy -c:a aac -shortest -af "volume=0.5" output.mp4

# Loop musik kalau lebih pendek dari video
ffmpeg -i video.mp4 -stream_loop -1 -i music.mp3 -c:v copy -c:a aac -shortest output.mp4
```

### 4. Video dari Warna Solid + Teks

```bash
# Background hitam + teks putih (intro/title card)
ffmpeg -f lavfi -i "color=c=black:s=1080x1920:d=5" -vf "drawtext=text='Judul':fontsize=80:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" -c:v libx264 -pix_fmt yuv420p -t 5 title.mp4

# Background gradient
ffmpeg -f lavfi -i "gradients=s=1080x1920:d=5:c0=#1a1a2e:c1=#16213e" -vf "drawtext=text='Welcome':fontsize=70:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" -c:v libx264 -pix_fmt yuv420p gradient_title.mp4
```

### 5. Gabung Video (Concat)

```bash
# Buat list
echo "file 'part1.mp4'" > list.txt
echo "file 'part2.mp4'" >> list.txt
echo "file 'part3.mp4'" >> list.txt

ffmpeg -f concat -safe 0 -i list.txt -c copy output.mp4
```

### 6. Transisi / Fade

```bash
# Fade in 1 detik, fade out 1 detik
ffmpeg -i input.mp4 -vf "fade=t=in:st=0:d=1,fade=t=out:st=4:d=1" -c:a copy output.mp4

# Crossfade antar 2 video (masing-masing 5 detik, overlap 1 detik)
ffmpeg -i v1.mp4 -i v2.mp4 -filter_complex "[0:v][1:v]xfade=transition=fade:duration=1:offset=4[v]" -map "[v]" -c:v libx264 -pix_fmt yuv420p crossfade.mp4
```

### 7. Zoom/Ken Burns Effect (di gambar)

```bash
# Zoom in pelan-pelan
ffmpeg -loop 1 -i photo.png -vf "scale=8000:-1,zoompan=z='min(zoom+0.0015,1.5)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=250:s=1080x1920:fps=30" -c:v libx264 -t 10 -pix_fmt yuv420p zoom.mp4
```

### 8. Resize / Aspect Ratio

```bash
# Vertikal 9:16 (TikTok/Reels/Shorts)
-vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2"

# Horizontal 16:9 (YouTube)
-vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2"

# Square 1:1 (Instagram post)
-vf "scale=1080:1080:force_original_aspect_ratio=decrease,pad=1080:1080:(ow-iw)/2:(oh-ih)/2"
```

## Workflow Umum

### Video Promo Sederhana
```bash
# 1. Title card 3 detik
ffmpeg -f lavfi -i "color=c=#1a1a2e:s=1080x1920:d=3" \
  -vf "drawtext=text='PROMO SPESIAL':fontsize=70:fontcolor=white:x=(w-text_w)/2:y=(h/2)-60, \
       drawtext=text='Diskon 50%%':fontsize=50:fontcolor=#e94560:x=(w-text_w)/2:y=(h/2)+30" \
  -c:v libx264 -pix_fmt yuv420p title.mp4

# 2. Foto produk 5 detik (Ken Burns)
ffmpeg -loop 1 -i produk.png \
  -vf "scale=2160:-1,zoompan=z='min(zoom+0.001,1.3)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=150:s=1080x1920:fps=30" \
  -c:v libx264 -t 5 -pix_fmt yuv420p produk.mp4

# 3. Gabung + musik
echo "file 'title.mp4'" > list.txt
echo "file 'produk.mp4'" >> list.txt
ffmpeg -f concat -safe 0 -i list.txt -i musik.mp3 -c:v copy -c:a aac -shortest promo.mp4
```

### Slideshow Foto + Musik
```bash
# Tiap foto 4 detik, fade transition
# Step 1: Buat list
for f in foto1.jpg foto2.jpg foto3.jpg foto4.jpg; do
  ffmpeg -loop 1 -i "$f" -t 4 -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,fade=t=in:st=0:d=0.5,fade=t=out:st=3.5:d=0.5" -c:v libx264 -pix_fmt yuv420p -r 30 "clip_${f%.*}.mp4"
done

# Step 2: Gabung
ls clip_*.mp4 | sed 's/^/file /' > list.txt
ffmpeg -f concat -safe 0 -i list.txt -i musik.mp3 -c:v copy -c:a aac -shortest slideshow.mp4
```

## Termux: Font WAJIB

FFmpeg di Termux **gak auto-detect font**. Harus pakai `fontfile=` eksplisit di setiap `drawtext`.

Font yang ada (verified):

| Font | Path |
|------|------|
| DejaVu Sans Bold | `/data/data/com.termux/files/usr/share/fonts/TTF/DejaVuSans-Bold.ttf` |
| DejaVu Sans | `/data/data/com.termux/files/usr/share/fonts/TTF/DejaVuSans.ttf` |
| DejaVu Sans Condensed | `/data/data/com.termux/files/usr/share/fonts/TTF/DejaVuSansCondensed.ttf` |
| DejaVu Mono | `/data/data/com.termux/files/usr/share/fonts/TTF/DejaVuSansMono.ttf` |
| Droid Sans (Android) | `/system/fonts/DroidSans.ttf` |
| Droid Sans Bold | `/system/fonts/DroidSans-Bold.ttf` |
| Dancing Script | `/system/fonts/DancingScript-Regular.ttf` |

Kalau gak ada yang cocok: `pkg install fontconfig` lalu `fc-list` buat cari font lain.

**Setiap `drawtext` HARUS mulai dengan `fontfile=/path/to/font.ttf:`**

## Animasi Teks Fade-In (Verified Working)

Teknik fade-in bertahap: tiap baris teks muncul satu-satu pakai `enable` + `alpha` expression:

```bash
ffmpeg -y -f lavfi -i "color=c=#0f0f23:s=1080x1920:d=8" -vf "\
drawtext=fontfile=/data/data/com.termux/files/usr/share/fonts/TTF/DejaVuSans-Bold.ttf:\
text='JUDUL':fontsize=65:fontcolor=white:\
x=(w-text_w)/2:y=(h/2)-100:\
enable='gte(t,1)':alpha='if(lt(t,1),0,if(lt(t,2),(t-1),1))':\
shadowcolor=#e94560:shadowx=3:shadowy=3,\
drawtext=fontfile=/data/data/com.termux/files/usr/share/fonts/TTF/DejaVuSans.ttf:\
text='SUBTITLE':fontsize=80:fontcolor=#e94560:\
x=(w-text_w)/2:y=(h/2)+20:\
enable='gte(t,2)':alpha='if(lt(t,2),0,if(lt(t,3),(t-2),1))':\
shadowcolor=black:shadowx=2:shadowy=2,\
drawtext=fontfile=/data/data/com.termux/files/usr/share/fonts/TTF/DejaVuSansCondensed.ttf:\
text='deskripsi':fontsize=40:fontcolor=#cccccc:\
x=(w-text_w)/2:y=(h/2)+140:\
enable='gte(t,3)':alpha='if(lt(t,3),0,if(lt(t,4),(t-3),1))',\
fade=t=in:st=0:d=1,fade=t=out:st=7:d=1" \
-c:v libx264 -pix_fmt yuv420p -crf 23 output.mp4
```

Pattern: `enable='gte(t,N)'` = teks muncul di detik N. `alpha='if(lt(t,N),0,if(lt(t,N+1),(t-N),1))'` = fade 1 detik.

## Deliver Video ke User

Video di Termux gak auto-muncul di galeri/FileManager. Pindahin ke Download:

```bash
cp output.mp4 /storage/emulated/0/Download/output.mp4
```

Kalau `/storage/emulated/0` gak bisa diakses, coba `termux-setup-storage` dulu (kasih permission storage ke Termux).

## Pitfalls

1. **Font gak ketemu** — Termux kadang gak punya font default. Install: `pkg install fontconfig` atau pake font path eksplisit: `:fontfile=/path/to/font.ttf`
2. **Video gak keplay di HP** — pastikan pakai `-pix_fmt yuv420p` (compatibility)
3. **Aspect ratio rusak** — selalu pakai `force_original_aspect_ratio=decrease` + `pad` biar gak stretch
4. **File gede** — kurangi bitrate: `-b:v 2M` atau `-crf 28` (default 23, makin tinggi = makin kecil)
5. **Audio sync** — kalau concat video beda codec, re-encode dulu jangan `-c copy`
6. **Termux OOM** — video panjang/high-res bisa makan RAM. Buat potongan pendek dulu, baru concat
7. **drawtext escape** — karakter `%` di teks harus `%%`, `:` harus `\:`

## Referensi Resolusi

| Platform | Resolusi | Aspect |
|----------|----------|--------|
| TikTok/Reels/Shorts | 1080x1920 | 9:16 |
| YouTube | 1920x1080 | 16:9 |
| Instagram Post | 1080x1080 | 1:1 |
| Instagram Story | 1080x1920 | 9:16 |
| Twitter/X | 1280x720 | 16:9 |
