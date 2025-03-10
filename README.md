# Hệ Thống Quản Lý Quán Cà Phê

Ứng dụng Flutter toàn diện để quản lý hoạt động của quán cà phê, bao gồm POS, quản lý kho và các chức năng quản trị.

## Tính Năng

- 🔐 **Xác Thực Người Dùng**
  - Hệ thống Đăng nhập/Đăng ký
  - Quản lý mật khẩu
  - Kiểm soát truy cập theo vai trò

- 💰 **Điểm Bán Hàng (POS)**
  - Quản lý thực đơn
  - Xử lý đơn hàng
  - Tùy chọn tùy chỉnh món
  - Xử lý thanh toán
  - Hỗ trợ mã QR
  - Quản lý giỏ hàng

- 📊 **Chức Năng Quản Trị**
  - Bảng điều khiển phân tích
  - Báo cáo doanh thu
  - Phân tích thống kê
  - Quản lý nhân viên
  - Cài đặt cấu hình

- 🏪 **Quản Lý Cửa Hàng**
  - Quản lý bàn
  - Theo dõi kho
  - Quản lý nguyên liệu
  - Hệ thống điểm khách hàng
  - Quản lý khuyến mãi

- 📋 **Quản Lý Đơn Hàng**
  - Theo dõi đơn hàng thời gian thực
  - Tùy chỉnh đơn hàng
  - Lịch sử đơn hàng
  - Tạo hóa đơn
  - Hỗ trợ in PDF

## Công Nghệ Sử Dụng

- **Frontend**: Flutter/Dart
- **Thư Viện Chính**:
  - `go_router` cho điều hướng
  - `provider` cho quản lý trạng thái
  - `hive` cho lưu trữ cục bộ
  - `fl_chart` và `syncfusion_flutter_charts` cho phân tích
  - `rive` cho hoạt ảnh
  - `printing` và `pdf` cho tạo tài liệu

## Yêu Cầu Hệ Thống

- Flutter SDK (>=3.4.4)
- Dart SDK
- Python (cho các script xử lý dữ liệu)
- MySQL (cho cơ sở dữ liệu)

## Hướng Dẫn Cài Đặt

1. Sao chép kho lưu trữ:
```bash
git clone [đường-dẫn-kho-lưu-trữ]
cd coffeeapp
```

2. Cài đặt các gói phụ thuộc:
```bash
flutter pub get
```

3. Cấu hình cơ sở dữ liệu:
   - Thiết lập cơ sở dữ liệu MySQL
   - Cấu hình kết nối trong `lib/connect_mysql.py`

4. Chạy ứng dụng:
```bash
flutter run
```

## Cấu Trúc Dự Án

```
lib/
├── controllers/    # Logic nghiệp vụ
├── models/         # Mô hình dữ liệu
├── views/          # Thành phần giao diện
│   ├── screens/    # Màn hình ứng dụng
│   │   ├── admin/  # Giao diện quản trị
│   │   ├── pos/    # Điểm bán hàng
│   │   └── curd/   # Thao tác CRUD
│   └── widgets/    # Các widget tái sử dụng
```

## Tài Nguyên

Ứng dụng bao gồm:
- Hình ảnh sản phẩm trong `assets/menu/`
- Tệp dữ liệu trong `assets/data/`
- Font chữ tùy chỉnh trong `assets/fonts/`
- Hoạt ảnh trong `assets/animations/`