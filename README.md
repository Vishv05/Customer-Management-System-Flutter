# Customer-Management-System-Flutter
A cross-platform Customer Management System built with Flutter, allowing businesses to store, update, and manage customer information with an intuitive and user-friendly mobile UI.
 # Customer Management System

A professional Flutter application for managing customer complaints and interactions across multiple e-commerce platforms.

## 📋 Project Description

The Customer Management System is a comprehensive solution designed to help businesses manage customer relationships, track complaints, and monitor customer interactions across various platforms like Amazon, Flipkart, Myntra, Ajio, and more.

## ✨ Features

### Core Features
- **User Authentication** - Login and Registration system
- **User Profile Management** - Manage personal information
- **Customer Management** - Add, view, and delete customers
- **Complaint Management** - Submit and track customer complaints with priority levels
- **Multi-Platform Support** - Support for Amazon, Flipkart, Myntra, Ajio, eBay, Snapdeal, Meesho, Nykaa

### Professional Features
- **Analytics & Reports** - View performance metrics and statistics
- **Complaint Status Tracking** - Track complaints from Open → In Progress → Resolved → Closed
- **Admin Dashboard** - Manage users, roles, and system settings
- **Search & Filtering** - Real-time search through customers and complaints
- **Modern UI** - Beautiful purple and cyan gradient design with smooth animations

### Advanced Functionality
- **Complaint Status Management** - Update complaint status with detailed information
- **User Management** - Admin can create, edit, and delete users with different roles
- **System Settings** - Database backup, security settings, and activity logs
- **Real-time Metrics** - Track key performance indicators at a glance

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Chrome browser (for web development)
- Git

### Step 1: Install Flutter
Download and install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)

### Step 2: Clone/Download the Project
```bash
cd F:\FlutterProjects\customer_management_system
```

### Step 3: Get Dependencies
```bash
flutter pub get
```

## 🗄️ MongoDB & Backend Setup

This application uses MongoDB and Node.js backend for data persistence.

### Prerequisites for Backend
- MongoDB installed (already have MongoDB Compass)
- Node.js installed (for backend server)

### Step 1: Start MongoDB Server
Open PowerShell and run:
```powershell
& "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" --dbpath "F:\MongoDB\data" --port 27017
```
Keep this window **running** in the background.

### Step 2: Connect MongoDB Compass
1. Open MongoDB Compass
2. Connection String: `mongodb://localhost:27017`
3. Click **Connect**
4. You'll see the database `customer_management_db` created automatically when you use the app

### Step 3: Start Backend Server
Open another PowerShell window:
```powershell
cd F:\backend_cms
node server.js
```

You should see:
```
✅ MongoDB Connected Successfully
🚀 Server running on http://localhost:3000
```

### Step 4: Verify Backend is Running
Open browser and go to: `http://localhost:3000`

You should see:
```json
{
	"message": "Customer Management System API",
	"status": "Running",
	"version": "1.0.0"
}
```

### Backend API Documentation
See complete backend documentation: [F:\backend_cms\README.md](file:///F:/backend_cms/README.md)

**API Base URL**: `http://localhost:3000/api`

### Available Endpoints:
- `/api/auth/register` - Register new user
- `/api/auth/login` - Login user
- `/api/customers` - Manage customers
- `/api/complaints` - Manage complaints
- `/api/users` - User administration

### Troubleshooting Backend
If backend won't start:
1. Ensure MongoDB is running (check MongoDB Compass connection)
2. Verify port 3000 is not in use
3. Check F:\backend_cms folder exists
4. Run `npm install` in F:\backend_cms if packages are missing

## 🚀 Running the Project on Web

### Option 1: Run on Chrome (Recommended)
```bash
cd F:\FlutterProjects\customer_management_system
$env:TEMP="F:\temp"
$env:TMP="F:\temp"
flutter run -d chrome --release
```
This command is used to run this project on web.

### Option 2: Run on Microsoft Edge
```bash
cd F:\FlutterProjects\customer_management_system
flutter run -d edge
```

### Option 3: Let Flutter Choose Device
```bash
cd F:\FlutterProjects\customer_management_system
flutter run
```
Then select from the available devices list.

## 📱 Available Platforms

To list all available devices:
```bash
flutter devices
```

To run on specific device:
```bash
flutter run -d [device-id]
```

Available devices:
- `chrome` - Google Chrome browser
- `edge` - Microsoft Edge browser
- `windows` - Windows Desktop (requires Visual Studio with C++ tools)
- `android` - Android Emulator (requires Android setup)

## 🧹 Cleaning & Rebuilding

### Clean Build
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Full Clean and Get Dependencies
```bash
flutter clean
flutter pub get
```

## 📂 Project Structure

```
customer_management_system/
├── lib/
│   ├── main.dart                    # Application entry point
│   ├── services/
│   │   └── api_service.dart         # API calls to backend
│   └── screens/
│       ├── login_screen.dart        # Login page
│       ├── register_screen.dart     # Registration page
│       ├── dashboard_screen.dart    # Main dashboard with search
│       ├── profile_screen.dart      # User profile management
│       ├── add_customer_screen.dart # Add new customer
│       ├── add_complaint_screen.dart # Submit complaint
│       ├── analytics_screen.dart    # Analytics & reports
│       ├── complaint_status_screen.dart # Complaint tracking
│       └── admin_dashboard_screen.dart  # Admin panel
├── android/                         # Android configuration
├── ios/                            # iOS configuration
├── windows/                        # Windows configuration
└── web/                            # Web configuration

backend_cms/                         # Node.js Backend (F:\backend_cms)
├── models/
│   ├── User.js                     # User schema
│   ├── Customer.js                 # Customer schema
│   └── Complaint.js                # Complaint schema
├── routes/
│   ├── auth.js                     # Authentication routes
│   ├── customers.js                # Customer routes
│   ├── complaints.js               # Complaint routes
│   └── users.js                    # User management routes
├── .env                            # Environment variables
├── server.js                       # Main server file
└── README.md                       # Backend documentation
```

## 🎯 Usage Guide

### Login
- Use any email and password to login
- First time users should click "Register" to create an account

### Dashboard
- View customer and complaint statistics
- Search for customers or complaints in real-time
- Access three main features via action buttons:
	- **Analytics** - View performance charts
	- **Status** - Track complaint progress
	- **Admin** - Manage system and users

### Adding Customers
- Click the "+" button (bottom right) with person icon
- Fill in customer details
- Click "Save"

### Adding Complaints
- Click the "!" button (bottom right) with warning icon
- Select platform and category
- Add complaint details
- Click "Submit"

### Tracking Complaints
- Navigate to "Status" page
- View all complaints with their current status
- Click "Update Status" to change complaint status
- Monitor priority levels and dates

### Admin Dashboard
- Access from main dashboard "Admin" button
- View system overview metrics
- Add/edit/delete users
- Configure system settings
- Access activity logs

### Analytics
- Navigate to "Analytics" page
- View key performance metrics
- See complaints by platform
- Monitor resolution rates
- Track complaint status distribution

## 🔐 Authentication

The app now uses **MongoDB backend** for authentication:
- **Register**: Create a new account with name, email, and password
- **Login**: Use your registered email and password
- **First Time**: Click "Register" to create your account
- **Data Persistence**: All data is saved in MongoDB database

## ⚙️ Build Options

### Run in Release Mode (Faster)
```bash
flutter run -d chrome --release
```

### Run with Verbose Output (For Debugging)
```bash
flutter run -d chrome -v
```

## 🐛 Troubleshooting

### App Not Launching
1. Ensure Chrome is installed
2. Clean and rebuild:
	 ```bash
	 flutter clean
	 flutter pub get
	 flutter run -d chrome
	 ```
3. Check Flutter installation:
	 ```bash
	 flutter doctor
	 ```

### Out of Memory Error
- Close other applications to free up memory
- Use release mode instead of debug mode
- Restart your computer

### Browser Not Opening
- Make sure Chrome/Edge is installed
- Manually go to `http://localhost:port` shown in terminal
- Try a different browser (Edge instead of Chrome)

### Port Already in Use
```bash
flutter run -d chrome --web-port 8080
```

### Backend Connection Errors
If you see connection errors in the app:
1. Make sure MongoDB server is running
2. Verify backend server is running on `http://localhost:3000`
3. Check browser console for detailed error messages
4. Ensure both servers are running before starting the app

## 📝 Notes

- **Data Persistence**: The app now stores all data in MongoDB database
- **Backend Required**: MongoDB and Node.js backend must be running
- **Data Survives Refresh**: Data persists across browser refreshes and app restarts
- **MongoDB Location**: All data stored in `customer_management_db` database
- For production, integrate with a backend database

## 🎨 Customization

The app uses a professional color scheme:
- **Primary Color**: Purple (#6C63FF)
- **Secondary Color**: Cyan (#00D4FF)
- **Success Color**: Green (#00C853)
- **Warning Color**: Red (#FF6B6B)
- **Alert Color**: Orange (#FFA500)

## 📚 Learning Resources

- [Flutter Official Docs](https://docs.flutter.dev/)
- [Flutter WebDev Guide](https://flutter.dev/docs/development/web)
- [Dart Documentation](https://dart.dev/guides)

## 📄 License

This project is open source and available for learning and educational purposes.

## 👨‍💻 Development

### Hot Reload
While the app is running, press 'r' in the terminal to hot reload changes:
```
r - Hot reload
R - Hot restart
q - Quit
```

### Common Commands
```bash
# Check Flutter setup
flutter doctor

# Check available devices
flutter devices

# Run all tests
flutter test

# Get latest dependencies
flutter pub upgrade
```

## 🚀 Future Enhancements

### ✅ Completed
- ✅ Backend API integration (Node.js + Express)
- ✅ Database implementation (MongoDB)
- ✅ User authentication system
- ✅ Data persistence

### 🔜 Planned
- Email notifications
- PDF report generation
- Mobile app version (Android/iOS)
- Enhanced role-based access control
- Data export functionality (CSV/Excel)
- Advanced analytics with interactive charts
- Real-time notifications via WebSocket
- Integration with e-commerce platforms (Amazon API, Flipkart API)
- Password hashing and JWT authentication
- File upload for complaint attachments
- Multi-language support
- Dark mode theme
- Integration with e-commerce platforms

---

**Version**: 1.0.0  
**Last Updated**: February 22, 2026  
**Created for**: Professional Customer Management
