# BeamFlow

Sistema de gestión de reservas para videobeams (proyectores) diseñado para entornos educativos e institucionales. Permite a los usuarios solicitar equipos, a los administradores aprobar/rechazar solicitudes y a todos visualizar la disponibilidad en tiempo real.

## Propósito y funcionamiento

### ¿Qué hace?
BeamFlow es una aplicación móvil (Flutter) que centraliza todo el flujo de reserva de videobeams. Los usuarios pueden:
- Registrarse e iniciar sesión (correo/contraseña o Google OAuth).
- Solicitar la reserva de un videobeam seleccionando fecha, hora y equipo.
- Consultar el calendario general con reservas de otros usuarios.
- Recibir notificaciones en tiempo real sobre cambios en sus solicitudes.
- Los administradores gestionan solicitudes pendientes, aprueban/rechazan reservas y administran el catálogo de equipos.

### Propósito general e integraciones
El objetivo es optimizar el uso de recursos compartidos (videobeams) evitando conflictos de horarios y proporcionando una experiencia fluida tanto para usuarios como para administradores. Se integra con **Supabase** como backend-as-a-service (autenticación, base de datos PostgreSQL en tiempo real, almacenamiento de archivos y canal de presencia en vivo).

### Tecnologías que utiliza
| Categoría          | Tecnologías                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| **Lenguaje**       | Dart 3.x                                                                    |
| **Framework**      | Flutter (multiplataforma: Android, iOS, Web)                                |
| **Backend**        | Supabase (Auth, Database, Realtime, Storage)                                |
| **Estado**         | Provider + ChangeNotifier                                                   |
| **Ruteo**          | GoRouter                                                                    |
| **UI/UX**          | Google Fonts, Animate_do, Font Awesome Icons, Table Calendar                |
| **Arquitectura**   | Clean Architecture con patrón Feature-First                                 |
| **Variables entorno** | flutter_dotenv                                                           |
| **Otros**          | intl (fechas en español), url_launcher, modal_bottom_sheet, fluttertoast    |

## Estructura y arquitectura

### Esquema de la estructura del proyecto
```
App ReservationFlowS/
├── lib/
│   ├── core/                     # Capa de infraestructura compartida
│   │   ├── constants/            # Constantes globales (AppStrings, AppColors)
│   │   ├── theme/                # Tema de la aplicación
│   │   ├── utils/                # Validadores y utilidades
│   │   ├── widgets/              # Widgets reutilizables (NeonTextField, NeonButton, etc.)
│   │   └── router/               # Configuración del GoRouter (app_router.dart)
│   ├── features/                 # Módulos de funcionalidades (Feature-First)
│   │   ├── auth/                 # Módulo de autenticación
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
│   │   ├── dashboard/            # Módulo de panel principal
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # DashboardRemoteDataSource
│   │   │   │   └── repositories/ # DashboardRepositoryImpl
│   │   │   └── domain/
│   │   │       ├── entities/     # DashboardMetrics
│   │   │       └── repositories/ # DashboardRepository (abstracto)
│   │   ├── requests/             # Módulo de solicitudes (admin)
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # RequestsRemoteDataSource
│   │   │   │   └── repositories/ # RequestsRepositoryImpl
│   │   │   └── domain/
│   │   │       ├── entities/     # Reutiliza ReservationEntity
│   │   │       └── repositories/ # RequestsRepository (abstracto)
│   │   ├── users_management/     # Módulo de gestión de usuarios (admin)
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # UsersRemoteDataSource
│   │   │   │   └── repositories/ # UserManagementRepositoryImpl
│   │   │   └── domain/
│   │   │       ├── entities/     # PendingUserEntity, AdminRequestStatusEntity
│   │   │       └── repositories/ # IUserManagementRepository (abstracto)
│   │   └── view_reservation_calendar/  # Módulo de calendario general
│   │       ├── data/
│   │       │   ├── datasources/  # ViewReservationCalendarRemoteDataSource
│   │       │   └── repositories/ # ViewReservationCalendarRepositoryImpl
│   │       └── domain/
│   │           ├── entities/     # CalendarProductEntity, CalendarStatusFilter
│   │           └── repositories/ # ViewReservationCalendarRepository (abstracto)
│   └── presentation/             # Capa de presentación global
│       ├── providers/            # Providers de alto nivel (Auth, Dashboard, Reservations, Requests, etc.)
│       ├── screens/              # Pantallas de la aplicación
│       │   ├── splash/           
│       │   ├── login/            
│       │   ├── register/         
│       │   ├── dashboard/        
│       │   ├── reservation/      
│       │   ├── profile/          
│       │   ├── auth/             # Waiting approval, additional data
│       │   └── admin/            # User approvals
│       └── components/           # Widgets reutilizables específicos de presentación
├── assets/
│   ├── icon/                     # Iconos de la aplicación
│   └── fonts/                    # Fuentes personalizadas (si las hay)
├── .env                          # Variables de entorno (Supabase URL, anon key)
├── pubspec.yaml
└── ...
```

### Arquitectura que está utilizando y cómo la implementa
El proyecto sigue **Clean Architecture** con tres capas principales:

1. **Capa de dominio** (`domain/`): Contiene las entidades puras de Dart (sin dependencias externas) y las interfaces abstractas de repositorios. Define el contrato que deben cumplir las implementaciones.

2. **Capa de datos** (`data/`): Implementa los repositorios abstractos (`*Impl`) y contiene las fuentes de datos concretas (remotas mediante Supabase). Se encarga de mapear los modelos de base de datos a entidades de dominio.

3. **Capa de presentación** (`presentation/`): Incluye los Providers (ChangeNotifier) que exponen el estado a la UI, y las pantallas/widgets que construyen la interfaz. Los Providers inyectan los repositorios a través del constructor (Patrón de inyección de dependencias manual).

**Flujo típico**:  
`UI` → `Provider` → `Repository (abstracción)` → `DataSource (Supabase)` → `Base de datos`  
Los cambios en la base de datos se propagan en tiempo real mediante canales Realtime de Supabase.

**Patrón Feature-First**: Cada funcionalidad (auth, reservations, dashboard, etc.) agrupa sus propias capas de data/domain/presentation, lo que facilita el mantenimiento y la escalabilidad.

## Esquema de carpetas con descripción de cada archivo

A continuación se describen los archivos más relevantes del sistema:

### `main.dart`
Punto de entrada. Inicializa `flutter_dotenv`, `Supabase`, el locale en español, y crea el `MaterialApp.router` con los providers globales. Construye las instancias de todos los repositorios y los provee al árbol de widgets mediante `MultiProvider`.

### `core/`
- **`constants/`**: `app_strings.dart` – cadenas de texto en español (títulos, etiquetas, mensajes).  
- **`theme/`**: `app_theme.dart` y `app_colors.dart` – definición del tema claro con colores corporativos (azul primario, tonos de fondo).  
- **`utils/`**: `validators.dart` – funciones de validación de email y contraseña.  
- **`widgets/`**: Componentes reutilizables con estilo "neon": `NeonTextField`, `NeonButton`, `NeonCard`.  
- **`router/app_router.dart`**: Configuración de `GoRouter` con todas las rutas y lógica de redirección basada en el estado de autenticación y datos adicionales.

### `features/auth/`
- **`data/datasources/`**: `auth_remote_datasource.dart` – llama a los métodos de Supabase Auth (signIn, signUp, signInWithGoogle, signOut, getUserProfile).  
- **`data/repositories/`**: `auth_repository_impl.dart` – implementa `AuthRepository` usando el data source.  
- **`domain/entities/`**: `user_entity.dart` – define `UserEntity`, `UserRole` (user, admin, superAdmin), `UserStatus` (pending, approved, rejected).  
- **`domain/repositories/`**: `auth_repository.dart` – interfaz con métodos de autenticación.  
- **`presentation/providers/`**: `auth_provider.dart` – maneja el estado de sesión, carga de perfil, verificación de datos adicionales y suscripción a cambios de estado.

### `features/dashboard/`
- **Dominio**: `dashboard_metrics_entity.dart` – métricas del panel.  
- **Repositorio**: `dashboard_repository.dart` – interfaz.  
- **Implementación**: `dashboard_repository_impl.dart` – obtiene productos, reservas del día, conteo de pendientes.  
- **Provider**: `dashboard_provider.dart` – carga métricas, reservas próximas, manejo de tiempo real.

### `features/reservations/`
- **Entidades**: `videobeam_entity.dart`, `reservation_entity.dart` con sus enumeraciones.  
- **Repositorio**: `reservation_repository.dart` – CRUD de videobeams y reservas.  
- **Provider**: `reservation_provider.dart` – estado del formulario de nueva reserva, selección de equipo, fecha, hora, validación de conflictos.

### `features/requests/`
- **Repositorio**: `requests_repository.dart` – carga de solicitudes pendientes, filtros.  
- **Provider**: `requests_provider.dart` – lista filtrada por estado, búsqueda, acciones de aprobar/rechazar.

### `features/users_management/`
- **Entidades**: `pending_user_entity.dart`, `admin_request_status_entity.dart`.  
- **Repositorio**: `i_user_management_repository.dart` – aprobar/rechazar usuarios, promover a admin.  
- **Provider**: `user_management_provider.dart` – gestión de usuarios pendientes.

### `features/view_reservation_calendar/`
- **Entidades**: `calendar_product_entity.dart`, `calendar_status_filter.dart`.  
- **Repositorio**: `view_reservation_calendar_repository.dart` – carga reservas del calendario con filtros.  
- **Provider**: `reservation_calendar_provider.dart` – usado en la vista de calendario mensual.

### `presentation/screens/`
- **`splash/`**: `splash_screen.dart` – animación de logo y barra de progreso.  
- **`login/`**: `login_screen.dart` – formulario de inicio de sesión con opción de Google.  
- **`register/`**: `register_screen.dart` – registro con validación en tiempo real y aceptación de términos.  
- **`dashboard/`**: `dashboard_screen.dart` – panel principal con métricas, gráfico de utilización, reservas próximas, acciones de admin.  
- **`reservation/`**: `reservation_screen.dart` – flujo de nueva reserva (pasos: decisión de ver calendario, selección de equipo, fecha, horario y confirmación).  
- **`profile/`**: `profile_screen.dart` – perfil del usuario, datos personales, solicitud de rol admin y políticas de uso.  
- **`auth/`**: `waiting_approval_screen.dart`, `additional_user_data_screen.dart` – pantallas para completar perfil y esperar aprobación.  
- **`admin/`**: `user_approvals_screen.dart` – lista de usuarios pendientes de aprobación.  
- **`view_reservation_calendar/`**: `view_reservation_calendar_screen.dart` – calendario semanal con detalles de reservas.  
- **`reservation/`**: `reservation_calendar_view.dart` – calendario mensual completo con filtros por producto y estado.

## Requisitos del entorno

- Flutter SDK 3.x
- Dart 3.x
- Una cuenta en Supabase con proyecto configurado (Auth con email/contraseña y Google OAuth, base de datos con tablas `productos`, `perfiles`, `reservas`, `solicitudes_admin`, etc.)
- Archivo `.env` en la raíz con las claves:
  ```
  SUPABASE_URL=https://tu-proyecto.supabase.co
  SUPABASE_ANON_KEY=tu-anon-key
  ```

## Cómo ejecutar

```bash
# 1. Clonar el repositorio
git clone https://github.com/0vethor0/App-ReservationFlowS.git

# 2. Entrar al directorio
cd beam_reserve

# 3. Crear el archivo .env con las credenciales de Supabase

# 4. Obtener dependencias
flutter pub get

# 5. Ejecutar en modo debug
flutter run
```

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o pull request en el repositorio de GitHub.

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

Desarrollado por [0vethor0](https://github.com/0vethor0)  
© 2026 BeamFlow. Todos los derechos reservados.