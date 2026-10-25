# Task Manager API

Backend REST API cho ứng dụng Quản lý và Giao Công Việc Nhóm.

## Thông tin cá nhân

- **MSSV:** 
- **Họ tên:** 

## Công nghệ

- Node.js + Express
- MongoDB + Mongoose
- JWT Authentication
- Nodemailer (Email)
- node-cron (Scheduled Tasks)

## Cài đặt

```bash
npm install
cp .env.example .env
# Cập nhật thông tin trong file .env
npm run dev
```

## Base URL

```
http://localhost:3000/api
```

## API Endpoints

### Xác thực
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập
- `GET /api/auth/me` - Thông tin người dùng hiện tại
- `PUT /api/auth/me` - Cập nhật thông tin
- `PUT /api/auth/change-password` - Đổi mật khẩu

### Người dùng
- `GET /api/users/search?q=` - Tìm người dùng
- `GET /api/users/:id` - Xem thông tin người dùng

### Công việc
- `GET /api/tasks` - Danh sách công việc
- `POST /api/tasks` - Tạo công việc
- `GET /api/tasks/:id` - Chi tiết công việc
- `PUT /api/tasks/:id` - Cập nhật công việc
- `DELETE /api/tasks/:id` - Xóa công việc
- `PATCH /api/tasks/:id/status` - Cập nhật trạng thái

### Giao việc
- `GET /api/tasks/:id/assignees` - Danh sách người được giao
- `POST /api/tasks/:id/assignees` - Giao việc
- `PATCH /api/tasks/:id/assignees/:userId` - Cập nhật vai trò
- `DELETE /api/tasks/:id/assignees/:userId` - Hủy giao việc

### Chia sẻ
- `GET /api/tasks/:id/shares` - Danh sách chia sẻ
- `POST /api/tasks/:id/shares` - Chia sẻ công việc
- `PATCH /api/tasks/:id/shares/:shareId` - Thay đổi quyền
- `DELETE /api/tasks/:id/shares/:shareId` - Thu hồi quyền

### Thông báo
- `GET /api/notifications` - Danh sách thông báo
- `GET /api/notifications/unread-count` - Đếm chưa đọc
- `PATCH /api/notifications/:id/read` - Đánh dấu đã đọc
- `PATCH /api/notifications/read-all` - Đánh dấu tất cả đã đọc

### Thống kê
- `GET /api/statistics/tasks` - Thống kê theo trạng thái
- `GET /api/statistics/assignments` - Thống kê giao việc
- `GET /api/statistics/deadlines` - Thống kê hạn hoàn thành
