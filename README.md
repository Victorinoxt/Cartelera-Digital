# 📱 Cartelera Digital

Sistema integral de cartelera digital construido con Flutter y Node.js, diseñado para la gestión y visualización dinámica de contenido digital en múltiples pantallas.

## ✨ Características Principales

### 📺 Gestión de Contenido
- **Múltiples Formatos**: Soporte para imágenes, videos y contenido animado
- **Actualización en Tiempo Real**: Cambios instantáneos en todas las pantallas
- **Programación de Contenido**: Planifica la visualización de contenido por fechas y horarios
- **Gestión de Zonas**: División de pantalla en múltiples zonas de contenido

### 🔧 Características Técnicas
- **Multiplataforma**: Aplicaciones para escritorio y dispositivos móviles
- **Sincronización en Tiempo Real**: Implementada con Socket.IO
- **Almacenamiento Seguro**: Gestión encriptada de archivos y datos
- **Sistema de Monitoreo**: Seguimiento del estado de las pantallas
- **Interfaz Responsiva**: Diseño adaptable a diferentes resoluciones

## 🛠️ Stack Tecnológico

### Frontend (Flutter)
- SDK de Flutter ≥3.5.0
- **Gestión de Estado**: Flutter Riverpod
- **UI/UX**: 
  - Material Design 3
  - Google Fonts
  - Animate_do para animaciones
  - Syncfusion Charts para gráficos
- **Almacenamiento Local**: 
  - Shared Preferences
  - Flutter Secure Storage
- **Multimedia**: 
  - Video Player
  - Image Picker
  - File Picker

### Backend (Node.js)
- **Framework**: Express.js
- **Comunicación**: 
  - Socket.IO para tiempo real
  - CORS habilitado
- **Almacenamiento**: 
  - Multer para gestión de archivos
  - MySQL para base de datos
- **Seguridad**:
  - Dotenv para variables de entorno
  - Encriptación de datos sensibles

## 📋 Requisitos Previos

1. **Entorno de Desarrollo**
   - Flutter SDK ≥3.5.0
   - Node.js y npm
   - IDE recomendado: Visual Studio Code con extensiones de Flutter y Dart

2. **Sistema Operativo**
   - Windows 10 o superior (para aplicación de escritorio)
   - Android 6.0+ o iOS 12+ (para aplicación móvil)

3. **Hardware Recomendado**
   - RAM: 8GB mínimo
   - Almacenamiento: 1GB disponible
   - Procesador: Intel i5/AMD Ryzen 5 o superior

## 🚀 Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone https://github.com/Victorinoxt/Cartelera-Digital.git
Iniciar la aplicacion De Escritorio
cd Cartelera_Digital
Iniciar la aplicacion Movile
cd Cartelera_Digital_mobile
```

### 2. Configuración del Backend
```bash
El server ya inicia con la aplicacion de Escritorio.
cd server
npm install

### 3. Configuración del Frontend
```bash
cd cartelera_digital
flutter clean
flutter pub get

```


### 4. Iniciar la Aplicación
Puedes usar los scripts proporcionados:
```bash
# Para compilar la aplicación
./build.bat

# Para iniciar la aplicación
./start_app.bat
```

O iniciar manualmente:
```bash
# Iniciar el servidor
cd server
npm start

# Iniciar la aplicación Flutter
cd cartelera_digital
flutter run
```
## 📁 Estructura del Proyecto

```
Cartelera-Digital/
├── 📂 cartelera_digital/              # Aplicación de Escritorio (Flutter)
│   ├── 📂 lib/
│   │   ├── 📂 screens/               # Pantallas de la aplicación
│   │   │   ├── login_screen.dart     # Pantalla de inicio de sesión
│   │   │   ├── home_screen.dart      # Pantalla principal
│   │   │   ├── preview_screen.dart   # Vista previa de contenido
│   │   │   └── settings_screen.dart  # Configuraciones
│   │   ├── 📂 widgets/              # Componentes reutilizables
│   │   │   ├── content_card.dart
│   │   │   ├── custom_button.dart
│   │   │   └── media_player.dart
│   │   ├── 📂 models/              # Modelos de datos
│   │   │   ├── user.dart
│   │   │   └── content.dart
│   │   ├── 📂 services/           # Servicios
│   │   │   ├── api_service.dart
│   │   │   └── socket_service.dart
│   │   └── main.dart             # Punto de entrada
│   ├── 📂 assets/               # Recursos
│   │   ├── images/
│   │   └── fonts/
│   └── pubspec.yaml            # Dependencias Flutter
│
├── 📂 cartelera_digital_mobile/     # Aplicación Móvil (Flutter)
│   ├── 📂 lib/
│   │   ├── 📂 screens/            # Pantallas móviles
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── viewer_screen.dart
│   │   ├── 📂 widgets/           # Widgets específicos móvil
│   │   │   └── mobile_player.dart
│   │   ├── 📂 services/
│   │   │   └── mobile_api.dart
│   │   └── main.dart
│   ├── 📂 assets/
│   │   └── images/
│   └── pubspec.yaml
│
├── 📂 server/                      # Servidor Backend (Node.js)
│   ├── 📂 controllers/           # Controladores
│   │   ├── auth.controller.js
│   │   ├── content.controller.js
│   │   └── user.controller.js
│   ├── 📂 routes/              # Rutas API
│   │   ├── auth.routes.js
│   │   ├── content.routes.js
│   │   └── user.routes.js
│   ├── 📂 models/             # Modelos de datos
│   │   ├── user.model.js
│   │   └── content.model.js
│   ├── 📂 middleware/        # Middleware
│   │   ├── auth.middleware.js
│   │   └── upload.middleware.js
│   ├── 📂 uploads/          # Archivos subidos
│   │   ├── images/
│   │   └── videos/
│   ├── server.js           # Punto de entrada
│   ├── package.json       # Dependencias Node.js
│   └── .env              # Variables de entorno
│
├── 📂 scripts/          # Scripts de utilidad
│   ├── build.bat       # Compilación
│   └── start_app.bat   # Inicio de aplicación
│
├── .gitignore
└── README.md
```
## ⚙️ Configuración

### Variables de Entorno Backend (.env)
```env
PORT=3000
DB_HOST=localhost
DB_USER=usuario
DB_PASSWORD=contraseña
DB_NAME=cartelera_digital
JWT_SECRET=tu_secreto
```

### Variables de Entorno Frontend (.env)
```env
API_URL=http://localhost:3000
SOCKET_URL=ws://localhost:3000
# Configurar archivo .env para el frontend
# Aplicacion movil la ip de la maquina
SERVER_IP=*******
```

## 📱 Aplicación Móvil

La aplicación móvil permite:
- Visualizar el Contenido enviado desde la aplicación de escritorio
- Gestión de contenido desde dispositivos móviles
- Notificaciones en tiempo real
- Control de programación de contenido

## 🔐 Seguridad

- Autenticación JWT
- Encriptación de datos sensibles
- Validación de tipos de archivo
- Control de acceso basado en roles
- Logs de actividad y auditoría


## 📄 Licencia

Este proyecto es propietario y confidencial. Todos los derechos reservados.

## 👥 Autor

- Victorinoxt
  - Desarrollo Frontend
  - Desarrollo Backend
  - Diseño UI/UX
  - QA y Testing
