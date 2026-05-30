# 🚀 BeamFlow - Gestión de Reservas para Videobeams 📽️

Sistema moderno y robusto de gestión de reservas para videobeams (proyectores) diseñado específicamente para entornos educativos e institucionales. Permite a los usuarios solicitar equipos, a los administradores gestionar solicitudes (aprobar/rechazar) y a todos visualizar la disponibilidad en tiempo real sin fricciones de zonas horarias.

---

## 🌟 Propósito y funcionamiento

### 📱 ¿Qué hace?
BeamFlow es una aplicación móvil desarrollada en Flutter que centraliza todo el flujo de reserva de videobeams. Los usuarios pueden:
- 🔐 **Autenticación Segura:** Registro e inicio de sesión con correo electrónico/contraseña o mediante Google OAuth.
- 📅 **Reservas Inteligentes:** Solicitar la reserva de un videobeam seleccionando fecha, hora específica y el equipo deseado.
- 📆 **Calendario Interactivo:** Visualizar un calendario general con la ocupación y reservas de otros usuarios para evitar conflictos.
- 🔔 **Notificaciones en Tiempo Real:** Recibir avisos automáticos sobre cambios de estado en sus solicitudes de reserva.
- 🛠️ **Panel de Administración (Admin):** Gestión ágil de solicitudes pendientes, aprobación o rechazo de reservas y administración del catálogo de equipos de la institución.

### 🔌 Propósito general e integraciones
El objetivo principal es optimizar el uso de recursos compartidos (videobeams), eliminando por completo los solapamientos de horarios y garantizando una experiencia de usuario fluida tanto para el personal docente como para el equipo administrativo. 

La aplicación se integra de forma nativa con **Supabase** como backend-as-a-service, aprovechando al máximo sus servicios de:
- 🔑 **Supabase Auth** para control de accesos.
- 🗄️ **PostgreSQL** como base de datos relacional robusta.
- ⚡ **Supabase Realtime** para la sincronización instantánea de las cuadrículas de horarios.
- 📁 **Supabase Storage** para almacenar fotos de perfil e inventario.

---

## 🛠️ Tecnologías que utiliza

| Categoría              | Tecnologías                                                              |
| :--------------------- | :----------------------------------------------------------------------- |
| **☕ Lenguaje**         | Dart 3.x                                                                 |
| **⚡ Framework**        | Flutter (Soporte multiplataforma: Android, iOS, Web)                     |
| **☁️ Backend**          | Supabase (Auth, Database, Realtime, Storage)                             |
| **🧠 Gestor de Estado** | Provider + ChangeNotifier                                                |
| **🗺️ Enrutamiento**     | GoRouter                                                                 |
| **🎨 UI/UX**            | Google Fonts, Animate_do, Font Awesome Icons, Table Calendar             |
| **📐 Arquitectura**     | Clean Architecture con un enfoque de organización **Feature-First**      |
| **🛡️ Seguridad/Config** | flutter_dotenv (Manejo seguro de variables de entorno)                   |
| **📦 Librerías Extra**  | intl (fechas en español), url_launcher, modal_bottom_sheet, fluttertoast |

---

## 📐 Estructura y Arquitectura

### 📁 Esquema de carpetas del proyecto
```
App ReservationFlowS/
├── lib/
│   ├── core/                     # 🛡️ Capa de infraestructura compartida
│   │   ├── constants/            # Constantes globales (AppStrings, AppColors)
│   │   ├── theme/                # Tema de la aplicación (Modo Oscuro/Claro)
│   │   ├── utils/                # Validadores y utilidades utilitarias
│   │   ├── widgets/              # Widgets con estilo "Neon" reutilizables (NeonTextField, NeonButton, etc.)
│   │   └── router/               # Configuración del GoRouter (app_router.dart)
│   ├── features/                 # 🚀 Módulos de funcionalidades (Feature-First)
│   │   ├── auth/                 # Módulo de autenticación completa
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # AuthRemoteDataSource, StorageRemoteDataSource
│   │   │   │   └── repositories/ # AuthRepositoryImpl, StorageRepositoryImpl
│   │   │   ├── domain/
│   │   │   │   ├── entities/     # UserEntity, UserRole, UserStatus
│   │   │   │   └── repositories/ # AuthRepository, StorageRepository (abstractos)
│   │   │   └── presentation/     # Providers de auth (AuthProvider)
│   │   ├── reservations/         # Módulo de reservas de videobeams
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # ReservationRemoteDataSource
│   │   │   │   └── repositories/ # ReservationRepositoryImpl
│   │   │   └── domain/
│   │   │       ├── entities/     # ReservationEntity, VideobeamEntity, ReservationStatus
│   │   │       └── repositories/ # ReservationRepository (abstracto)
│   │   ├── dashboard/            # Módulo de panel principal y métricas
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # DashboardRemoteDataSource
│   │   │   │   └── repositories/ # DashboardRepositoryImpl
│   │   │   └── domain/
│   │   │       ├── entities/     # DashboardMetrics
│   │   │       └── repositories/ # DashboardRepository (abstracto)
│   │   ├── requests/             # Módulo de solicitudes (administrador)
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # RequestsRemoteDataSource
│   │   │   │   └── repositories/ # RequestsRepositoryImpl
│   │   │   └── domain/
│   │   │       ├── entities/     # Reutiliza ReservationEntity
│   │   │       └── repositories/ # RequestsRepository (abstracto)
│   │   ├── users_management/     # Módulo de gestión de usuarios (administrador)
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # UsersRemoteDataSource
│   │   │   │   └── repositories/ # UserManagementRepositoryImpl
│   │   │   └── domain/
│   │   │       ├── entities/     # PendingUserEntity, AdminRequestStatusEntity
│   │   │       └── repositories/ # IUserManagementRepository (abstracto)
│   │   └── view_reservation_calendar/  # Módulo de calendario general institucional
│   │       ├── data/
│   │       │   ├── datasources/  # ViewReservationCalendarRemoteDataSource
│   │       │   └── repositories/ # ViewReservationCalendarRepositoryImpl
│   │       └── domain/
│   │           ├── entities/     # CalendarProductEntity, CalendarStatusFilter
│   │           └── repositories/ # ViewReservationCalendarRepository (abstracto)
│   └── presentation/             # 🎨 Capa de presentación global
│       ├── providers/            # Providers de alto nivel (Auth, Dashboard, Reservations, Requests, etc.)
│       ├── screens/              # Pantallas de la aplicación organizadas por flujos
│       │   ├── splash/           
│       │   ├── login/            
│       │   ├── register/         
│       │   ├── dashboard/        
│       │   ├── reservation/      
│       │   ├── profile/          
│       │   ├── auth/             # Waiting approval, additional data
│       │   └── admin/            # User approvals
│       └── components/           # Widgets de presentación específicos
├── assets/
│   ├── icon/                     # Iconografía oficial
│   └── fonts/                    # Tipografías personalizadas
├── .env                          # ⚠️ Configuración de llaves de Supabase (No incluir en commits)
├── pubspec.yaml                  # Archivo de configuración de dependencias de Flutter
└── ...
```

### 🧠 Implementación de Arquitectura Limpia (Clean Architecture)
El proyecto adopta rigurosamente los principios de **Clean Architecture** distribuidos en tres capas por cada *Feature*:

1. **Capa de Dominio (`domain/`)**: La más interna y pura. Libre de dependencias externas o del framework (Flutter). Contiene las entidades esenciales de negocio y los contratos abstractos (interfaces de repositorios).
2. **Capa de Datos (`data/`)**: Implementa los contratos definidos en el dominio. Interactúa de forma directa con APIs y servicios en la nube a través de los *Data Sources* concretos de Supabase.
3. **Capa de Presentación (`presentation/`)**: Contiene la lógica de las pantallas. Utiliza el patrón **Provider (ChangeNotifier)** para notificar cambios de estado a la UI. El flujo de eventos sigue una estructura unidireccional:
 
---

## 🔄 Novedades y Correcciones de Sincronización (SDPT) 🛠️

En las últimas versiones, el sistema ha sido optimizado con correcciones profundas de horarios y asincronía (SDPT) para garantizar consistencia horaria global de la base de datos (UTC) con la hora del dispositivo local (por ejemplo, Venezuela/Caracas):

* 🕐 **Fronteras Locales Absolutas:** Se corrigió el método `escucharReservasPorDia` en `ReservationProvider`. Ya no define los límites del día actual usando strings UTC directamente (lo cual causaba que reservas de madrugada se filtraran de manera invisible). Ahora utiliza el huso horario local puro (`00:00:00` a `23:59:59`) para realizar el corte del día de manera exacta.
* 🛰️ **Parseo Integrado a Local:** El stream en tiempo real de Supabase ahora convierte automáticamente los campos `hora_inicio` y `hora_fin` mediante `.toLocal()` antes de agregarlos al listado de la interfaz. Los bloques pintados en rojo (`TimeSlot`) reflejan con exactitud matemática el espacio horario seleccionado.
* 🖥️ **Corrección en Interfaz de Administrador y Calendarios:** Se erradicó el uso del método manual `.substring(11, 16)` para los campos de hora textuales en pantallas del administrador (`RequestsRepositoryImpl`), el panel del dashboard (`DashboardProvider`) y el calendario general (`ViewReservationCalendarRepositoryImpl`). Toda hora extraída en texto plano ahora se parsea adecuadamente como un objeto de tiempo local (`.toLocal()`) y se formatea de forma segura garantizando siempre las dos cifras (`HH:mm`).
* 🚨 **Validación Robusta de Colisiones:** Se sincronizó `tieneConflictoDeHorario` para comparar exclusivamente intervalos locales, evitando colisiones fantasmas o aprobación de reservas solapadas en husos mixtos.
* 🛡️ **Compilación con Análisis Estricto:** Se corrigieron advertencias menores de formateo y sintaxis en la totalidad del proyecto, asegurando un paso limpio de `flutter analyze` al 100%.

---

## 📋 Requisitos del Entorno

- **Flutter SDK:** `^3.x`
- **Dart:** `^3.x`
- **Supabase Account:** Proyecto configurado con tablas relacionales (`productos`, `perfiles`, `reservas`, `solicitudes_admin`, etc.).
- **Archivo de Configuración `.env`** en la raíz del proyecto con la siguiente estructura:
  ```env
  SUPABASE_URL=https://tu-proyecto.supabase.co
  SUPABASE_ANON_KEY=tu-anon-key-de-supabase
  ```

---

## 🚀 Cómo ejecutar

Sigue estos sencillos pasos para iniciar el proyecto en tu entorno local:

```bash
# 1. Clonar el repositorio
git clone https://github.com/0vethor0/App-ReservationFlowS.git

# 2. Entrar al directorio del proyecto
cd "App ReservationFlowS"

# 3. Asegúrate de crear el archivo .env en la raíz con tus credenciales

# 4. Obtener todos los paquetes y dependencias de Flutter
flutter pub get

# 5. Ejecutar la aplicación en tu emulador o dispositivo físico favorito
flutter run
```

---

## 🤝 Contribuciones

¿Quieres mejorar BeamFlow? ¡Las contribuciones de todo tipo son bien recibidas!
1. Haz un **Fork** del proyecto.
2. Crea una rama para tu funcionalidad (`git checkout -b feature/nueva-mejora`).
3. Realiza un commit con tus cambios (`git commit -m 'feat: Agregada nueva funcionalidad visual'`).
4. Sube la rama (`git push origin feature/nueva-mejora`).
5. Abre un **Pull Request**.

---

## 📄 Licencia

Este proyecto se distribuye bajo la licencia **MIT**. Para más detalles, consulta el archivo `LICENSE` dentro de la raíz del repositorio.

---

Desarrollado con ❤️ por [0vethor0](https://github.com/0vethor0)  
*© 2026 BeamFlow. Todos los derechos reservados.*
