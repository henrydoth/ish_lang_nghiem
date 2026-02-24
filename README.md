```
# 📿 ish_lang_nghiem

Tụng Kinh / Chú Lăng Nghiêm trên Terminal  
Chạy được trên:

- 🖥 Windows (Git Bash / WSL)
- 📱 iPhone (iSH – Alpine Linux)

Giữ màu ANSI, block 12 câu, tìm keyword, và tự động chuyển câu sau 3 giây nếu không bấm phím.

---

## ✨ Tính năng

### 🔢 Tụng theo số

```bash
ln 13        # 13 → 24 (auto block 12)
ln 13 27     # 13 → 27
ln 0*        # block 0 (1 → 12)
ln 1*        # block 1 (13 → 24)
ln 2*        # block 2 (25 → 36)
ln 0* 1*     # 1 → 24 (liền mạch)
ln 0*:2*     # 1 → 36 (range block)
```

------

### 🔎 Tìm theo từ khóa

```
lnk "tát đát"
```

- Liệt kê các câu match
- Chọn số câu để tụng
- Tự động tụng đến hết block 12

------

### 🎨 Màu sắc

- 12 câu chia 4 nhóm màu
- Phiên âm và Hán tách màu khác nhau
- Số thứ tự hiển thị màu xám

------

### ⏳ Auto next 3 giây

- Không bấm phím → tự động sang câu sau 3 giây
- Bấm phím bất kỳ → sang ngay
- Nhấn `q` hoặc `ESC` → thoát

Có thể đổi tốc độ:

```
LN_TIMEOUT=1 ln 13
LN_TIMEOUT=5 ln 13
```

------

## 📂 Cấu trúc thư mục

```
ish_lang_nghiem/
├── ln_lang_nghiem.bash
├── lang_nghiem.md
└── README.md
```

- `ln_lang_nghiem.bash` : script chính
- `lang_nghiem.md` : nội dung kinh

------

## 🚀 Cài đặt trên iPhone (iSH)

### 1️⃣ Cài bash + git

```
apk update
apk add bash git
```

### 2️⃣ Clone repo

```
mkdir -p ~/GitHub
cd ~/GitHub
git clone https://github.com/henrydoth/ish_lang_nghiem.git
cd ish_lang_nghiem
```

### 3️⃣ Chạy

```
bash
source ln_lang_nghiem.bash
ln 13
```

------

## 🖥 Cài đặt trên Windows

### Git Bash

```
git clone https://github.com/henrydoth/ish_lang_nghiem.git
cd ish_lang_nghiem
source ln_lang_nghiem.bash
ln 13
```

------

### WSL (khuyên dùng)

```
sudo apt update
sudo apt install git bash
git clone https://github.com/henrydoth/ish_lang_nghiem.git
cd ish_lang_nghiem
source ln_lang_nghiem.bash
ln 13
```

------

## 🔄 Cập nhật khi sửa code

Trên PC:

```
git add .
git commit -m "update"
git push
```

Trên iSH:

```
cd ~/GitHub/ish_lang_nghiem
git pull
```

------

## 🧘 Mục đích

Dự án này giúp:

- Học Bash thực tế
- Làm chủ Git + GitHub
- Đồng bộ môi trường Windows ↔ iPhone
- Biến terminal thành không gian tu tập

------

## 🙏 Nam Mô A Di Đà Phật

```
---

# 🎯 Sau khi paste xong

Trong Terminal:

```bash
git add README.md
git commit -m "add README"
git push
```

------

