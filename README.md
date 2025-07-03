## 🏠 rent-room-app

**تطبيق لتأجير الغرف والمنازل يشبه [Airbnb](https://www.airbnb.com/) باستخدام Flutter.**

---

### ✨ الميزات

- 👋 **شاشة الترحيب والمقدمة**  
  `features/home/presentation`

- 🔐 **تسجيل الدخول وإنشاء حساب**  
  `features/auth/presentation`

- 🏘️ **عرض العقارات والفلاتر والتفاصيل**  
  `features/property/presentation`

- 📅 **الحجز والدفع**  
  `features/booking/presentation`

- 💬 **نظام الدردشة بين المستأجر والمالك**  
  `features/chat`

- 🧑‍💼 **لوحة تحكم المالك (قريبًا)**  
  `features/profile` و `features/settings`

---

### 📁 هيكل المجلدات

```bash
lib/
│
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   ├── widgets/
│   └── services/
│
└── features/
    ├── auth/
    │   ├── presentation/
    │   ├── data/
    │   └── domain/
    ├── home/
    ├── property/
    ├── booking/
    ├── chat/
    ├── profile/
    └── settings/
