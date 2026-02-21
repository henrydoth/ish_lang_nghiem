# 📖 CÁC LỆNH & VÍ DỤ

------

# 🔢 1️⃣ Tụng theo số

## ▶️ Tụng từ câu N → hết block 12 gần nhất

```
ln 13
```

➡ Kết quả: 13 → 24

```
ln 2
```

➡ Kết quả: 2 → 12

------

## ▶️ Tụng từ A → B

```
ln 13 27
```

➡ Tụng từ 13 → 27

------

# 🧩 2️⃣ Tụng theo block (12 câu / block)

Block tính từ 0:

| Block | Câu     |
| ----- | ------- |
| 0*    | 1 → 12  |
| 1*    | 13 → 24 |
| 2*    | 25 → 36 |
| 3*    | 37 → 48 |

------

## ▶️ Một block

```
ln 0*
ln 1*
ln 2*
```

------

## ▶️ Nhiều block liền mạch

```
ln 0* 1*
```

➡ 1 → 24

```
ln 0* 1* 2*
```

➡ 1 → 36

------

## ▶️ Range block

```
ln 0*:2*
```

➡ 1 → 36

```
ln 2*:4*
```

➡ 25 → 60

------

# 🔎 3️⃣ Tìm theo từ khóa

```
lnk "tát đát"
```

Hiển thị danh sách match:

```
145  Tát đát tha...
149  ...
```

Sau đó:

- Nhập số câu muốn tụng
- Enter = chọn câu đầu tiên
- q = thoát

Ví dụ:

```
lnk "bà"
```

------

# ⏳ 4️⃣ Tốc độ auto next

Mặc định: 3 giây

Thay đổi:

```
LN_TIMEOUT=1 ln 13
```

➡ Chuyển câu sau 1 giây

```
LN_TIMEOUT=5 ln 13
```

➡ 5 giây

------

# 🎹 5️⃣ Điều khiển khi đang tụng

Trong lúc tụng:

| Phím        | Tác dụng            |
| ----------- | ------------------- |
| (không bấm) | Tự động qua câu sau |
| Bất kỳ phím | Qua câu ngay        |
| q           | Thoát               |
| ESC         | Thoát               |

------

# 🎨 6️⃣ Màu sắc

- 12 câu chia 4 nhóm màu
- 3 câu 1 màu
- Phiên âm và chữ Hán khác màu
- Số thứ tự màu xám
- Kết thúc:

```
🙏 Hết đoạn.
Nam Mô A Di Đà Phật.
```

(Nam Mô A Di Đà Phật hiển thị in đậm, mỗi chữ 1 màu, nhảy từng chữ)

------

# 🧘 7️⃣ Ví dụ thực tế

### Tụng từ 145 → hết block

```
ln 145
```

------

### Tụng 3 block đầu

```
ln 0*:2*
```

------

### Tìm chữ “xá”

```
lnk "xá"
```

------

### Tụng nhanh không chờ

```
LN_TIMEOUT=0 ln 13
```

------

# 🛠 8️⃣ Kiểm tra lệnh đang dùng

```
type -a ln
type -a lnk
```

------

# 🔄 9️⃣ Cập nhật tool

```
git pull
./install.sh
```



# 🖥 1️⃣ Windows (Git Bash)

### Clone repo

```
cd /d/GitHub
git clone https://github.com/henrydoth/ish_lang_nghiem.git
cd ish_lang_nghiem
```

### Cài đặt

```
chmod +x install.sh
./install.sh
source ~/.bashrc
```

### Kiểm tra

```
type -a ln
```

Phải thấy:

```
ln is /c/Users/you/.local/bin/ln
```

### Dùng

```
ln 13
ln 0*:2*
lnk "bà"
```

------

# 🖥 2️⃣ Windows WSL

```
sudo apt update
sudo apt install git bash
git clone https://github.com/henrydoth/ish_lang_nghiem.git
cd ish_lang_nghiem
chmod +x install.sh
./install.sh
source ~/.bashrc
```

------

# 🍎 3️⃣ macOS (Giữ ln – override an toàn)

⚠ macOS có `/bin/ln`
 Ta override bằng function trong `.zshrc`

------

### Clone repo

```
cd ~/Documents
git clone https://github.com/henrydoth/ish_lang_nghiem.git
cd ish_lang_nghiem
```

------

### Cài đặt

```
chmod +x install.sh
./install.sh
source ~/.zshrc
```

------

### Kiểm tra

```
type -a ln
```

Phải thấy:

```
ln is a shell function
ln is /bin/ln
```

👉 Điều này đúng.

- Gõ `ln` → chạy tool của bạn
- Gõ `/bin/ln` → chạy ln hệ thống

------

# 📱 4️⃣ iPhone (iSH)

### Cài bash + git

```
apk update
apk add bash git
bash
```

### Clone + cài

```
mkdir -p ~/GitHub
cd ~/GitHub
git clone https://github.com/henrydoth/ish_lang_nghiem.git
cd ish_lang_nghiem
chmod +x install.sh
./install.sh
source ~/.bashrc
```

------

# 🔄 Cập nhật

Trên máy chính:

```
git add .
git commit -m "update"
git push
```

Trên máy khác:

```
cd ish_lang_nghiem
git pull
./install.sh
```

------

# 🛠 Nếu ln không nhận

macOS:

```
unalias ln 2>/dev/null
unset -f ln 2>/dev/null
hash -r
source ~/.zshrc
```

Windows:

```
hash -r
source ~/.bashrc
```

------

# ⚙ Nếu gặp lỗi bash\r

```
perl -pi -e 's/\r\n/\n/g' *.sh *.bash
```

Repo đã có `.gitattributes` ép LF.

------

# 🎯 Sau khi cài thành công

```
ln 13
ln 0*:2*
lnk "tát"
```

Bạn sẽ có:

- 12 câu chia màu
- Auto 3 giây
- Nhấn phím chuyển câu
- q / ESC thoát
- Kết thúc:
   🙏 Hết đoạn.
   Nam Mô A Di Đà Phật. (hào quang từng chữ)