# Plan de Implementación: Sistema de Aprobación de Usuarios (Gatekeeping)

## Contexto Actual

El proyecto utiliza:
- **Clean Architecture** con patrón Feature-First
- **Provider** para gestión de estado (ChangeNotifier)
- **GoRouter** para navegación con guards
- **Supabase** como backend (Auth + Database + Realtime)
- La configuración de Supabase ya está lista: ENUM `user_reg_status`, columna `status` en `perfiles`, función RLS `is_user_approved()`, y políticas RLS

## Fases de Implementación

---

## FASE 1: Refactorizar Feature Auth - Agregar Soporte de Status

### 1.1 Actualizar UserEntity
**Archivo:** `lib/features/auth/domain/entities/user_entity.dart`

- Añadir campo `status` de tipo `UserStatus` (enum con valores: pending, approved, rejected)
- El enum se define junto a la entidad
- Valor por defecto: `UserStatus.pending`

### 1.2 Crear UserModel (nuevo archivo)
**Archivo:** `lib/features/auth/data/models/user_model.dart`

- Crear clase `UserModel` que extienda/implemente `UserEntity`
- Implementar método `factory UserModel.fromMap(Map<String, dynamic> map)` para mapear desde Supabase:
  - Mapear columna `status` de la tabla `perfiles` al enum
  - Mapear campos existentes: `primer_nombre`, `primer_apellido`, `rol`, `correo`, etc.
- Implementar método `toMap()` para operaciones de escritura

### 1.3 Actualizar AuthRemoteDataSource
**Archivo:** `lib/features/auth/data/datasources/auth_remote_datasource.dart`

- **Añadir método nuevo:** `Stream<UserStatus> watchCurrentUserStatus(String uid)`
  - Usar `client.from('perfiles').stream()` con filtro `eq('id', uid)`
  - Escuchar cambios en tiempo real en la columna `status`
  - Emitir el estado actualizado cuando un admin lo cambie
  
- **Actualizar `getUserProfile()`:** para que también retorne el campo `status`

### 1.4 Actualizar AuthRepository (interfaz)
**Archivo:** `lib/features/auth/domain/repositories/auth_repository.dart`

- Añadir método: `Stream<UserStatus> watchCurrentUserStatus(String uid)`

### 1.5 Actualizar AuthRepositoryImpl
**Archivo:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

- Implementar `watchCurrentUserStatus()` delegando al DataSource
- Actualizar `getCurrentUser()` para incluir el status desde el perfil

---

## FASE 2: Crear Feature users_management (Nueva)

### 2.1 Estructura de directorios
```
lib/features/users_management/
├── domain/
│   ├── entities/
│   │   └── pending_user_entity.dart
│   └── repositories/
│       └── i_user_management_repository.dart
├── data/
│   ├── datasources/
│   │   └── users_remote_datasource.dart
│   └── repositories/
│       └── user_management_repository_impl.dart
└── presentation/
    ├── widgets/
    │   └── user_approval_card.dart
    └── providers/
        └── user_management_provider.dart
```

### 2.2 Domain Layer

**Archivo:** `lib/features/users_management/domain/entities/pending_user_entity.dart`
- Entidad pura con: `id`, `fullName`, `email`, `phone`, `avatarUrl`, `registeredAt`
- Sin dependencias externas

**Archivo:** `lib/features/users_management/domain/repositories/i_user_management_repository.dart`
- Interfaz con métodos:
  - `Future<List<PendingUserEntity>> getPendingUsers()`
  - `Future<void> approveUser(String userId)`
  - `Future<void> rejectUser(String userId)`
  - `Stream<List<PendingUserEntity>> watchPendingUsers()`

### 2.3 Data Layer

**Archivo:** `lib/features/users_management/data/datasources/users_remote_datasource.dart`
- Inyectar `SupabaseClient`
- Implementar:
  - `watchPendingUsers()`: usar `.stream()` en tabla `perfiles` con filtro `eq('status', 'pending')`
  - `approveUser(uid)`: update `perfiles` set `status = 'approved'` where `id = uid`
  - `rejectUser(uid)`: update `perfiles` set `status = 'rejected'` where `id = uid`
  - `getPendingUsers()`: query one-shot para carga inicial

**Archivo:** `lib/features/users_management/data/repositories/user_management_repository_impl.dart`
- Implementar `IUserManagementRepository` delegando al DataSource
- Manejo de excepciones (convertir errores de Supabase a excepciones genéricas)

### 2.4 Presentation Layer - Widget

**Archivo:** `lib/features/users_management/presentation/widgets/user_approval_card.dart`
- Widget stateless que recibe `PendingUserEntity` y callbacks `onApprove()` / `onReject()`
- UI: Card con avatar, nombre, email, y dos botones (check verde / X rojo)
- Usar colores del `AppTheme` existente
- Mostrar loading state durante la operación

### 2.5 Presentation Layer - Provider

**Archivo:** `lib/features/users_management/presentation/providers/user_management_provider.dart`
- `ChangeNotifier` con:
  - `List<PendingUserEntity> pendingUsers`
  - `bool isLoading`
  - `String? error`
  - Métodos: `loadPendingUsers()`, `approveUser()`, `rejectUser()`
  - Suscribirse al stream del repositorio para actualizaciones en tiempo real
  - Cancelar subscription en `dispose()`

---

## FASE 3: Crear Pantallas Navegables (Screens)

### 3.1 Waiting Approval Screen
**Archivo:** `lib/presentation/screens/auth/waiting_approval_screen.dart`

- Pantalla de bloqueo que se muestra cuando el usuario está logueado pero con status `pending` o `rejected`
- Usar `StreamBuilder` con `watchCurrentUserStatus()` de la feature auth
- UI:
  - Icono de reloj/espera grande
  - Texto: "Tu cuenta está pendiente de aprobación"
  - Subtexto explicando que un administrador debe aprobar el acceso
  - Si el status cambia a `approved`: navegar automáticamente al Dashboard usando `context.go('/')`
  - Si el status es `rejected`: mostrar mensaje de rechazo con opción de contactar soporte
- Diseño limpio centrado con animación sutil

### 3.2 User Approvals Screen (Admin Panel)
**Archivo:** `lib/presentation/screens/admin/user_approvals_screen.dart`

- Pantalla solo accesible para usuarios con rol `admin` o `superAdmin`
- Usar `Consumer<UserManagementProvider>` para obtener la lista de usuarios pendientes
- UI:
  - AppBar con título "Solicitudes Pendientes"
  - Lista scrollable de `UserApprovalCard` widgets
  - Mostrar empty state si no hay usuarios pendientes
  - Pull-to-refresh para recargar la lista
  - SnackBar de confirmación tras aprobar/rechazar

---

## FASE 4: Actualizar Router y Guards de Navegación

### 4.1 Modificar AppRouter
**Archivo:** `lib/core/router/app_router.dart`

**Actualizar lógica de `redirect`:**
- Después de verificar `isAuthenticated` y `hasAdditionalData`:
  - Obtener `userStatus` desde `authProvider.currentUserStatus`
  - Si `status == pending` o `status == rejected` y NO está yendo a `/waiting`:
    - Redirigir a `/waiting`
  - Si `status == approved` y está yendo a `/waiting`:
    - Redirigir al Dashboard `/`
  
**Añadir nuevas rutas:**
```dart
GoRoute(
  path: '/waiting',
  builder: (context, state) => const WaitingApprovalScreen(),
),
GoRoute(
  path: '/admin/user-approvals',
  builder: (context, state) => const UserApprovalsScreen(),
  // Opcional: meta con requiere rol admin
),
```

**Importar nuevas screens:**
```dart
import '../../presentation/screens/auth/waiting_approval_screen.dart';
import '../../presentation/screens/admin/user_approvals_screen.dart';
```

### 4.2 Actualizar AuthProvider
**Archivo:** `lib/presentation/providers/auth_provider.dart`

- Añadir campo: `UserStatus? _currentUserStatus`
- Añadir getter: `UserStatus? get currentUserStatus => _currentUserStatus`
- En `_checkAdditionalData()`, también cargar el status del perfil y actualizar `_currentUserStatus`
- Suscribirse al stream `watchCurrentUserStatus()` para actualizaciones en tiempo real
- Llamar a `notifyListeners()` cuando el status cambie

---

## FASE 5: Eliminar WebSocketManager y Migrar a Streams Locales

### 5.1 Identificar usos de WebSocketManager
**Archivo:** `lib/main.dart` y buscar en toda la codebase

- WebSocketManager se instancia en `main.dart` línea 148-154 como ChangeNotifierProvider
- Buscar en toda la codebase referencias a `WebSocketManager`, `messages`, `connect()`, `disconnect()`

### 5.2 Migrar funcionalidad a Reservation DataSource
**Archivo:** `lib/features/reservations/data/datasources/reservation_remote_datasource.dart`

- **Añadir método:** `Stream<List<Map<String, dynamic>>> watchReservationsChanges()`
  - Usar `client.from('reservas').stream()` con `order('created_at')`
  - Filtrar por usuario actual si es necesario
  - Este stream reemplaza la funcionalidad de `onPostgresChanges` del WebSocketManager

### 5.3 Eliminar WebSocketManager
- **Eliminar archivo:** `lib/data/datasources/websocket_manager.dart`
- **Eliminar de main.dart:**
  - Remover import de `websocket_manager.dart`
  - Remover `ChangeNotifierProvider` de `WebSocketManager` (líneas 148-155)
  
### 5.4 Actualizar providers que usaban WebSocketManager
**Archivo:** Buscar en `lib/presentation/providers/`

- Identificar qué providers escuchaban `WebSocketManager.messages`
- Suscribirlos directamente al stream del DataSource correspondiente
- Ejemplo: `ReservationProvider` debería usar `watchReservationsChanges()` del repositorio

---

## FASE 6: Registrar Providers y Configurar main.dart

### 6.1 Actualizar main.dart
**Archivo:** `lib/main.dart`

**Añadir imports:**
```dart
import 'features/users_management/data/datasources/users_remote_datasource.dart';
import 'features/users_management/data/repositories/user_management_repository_impl.dart';
import 'features/users_management/domain/repositories/i_user_management_repository.dart';
import 'features/users_management/presentation/providers/user_management_provider.dart';
```

**Inicializar repositorio en `_BeamReserveAppState.initState()`:**
```dart
final usersRemoteDataSource = UsersRemoteDataSource(supabaseClient);
_usersManagementRepository = UserManagementRepositoryImpl(usersRemoteDataSource);
```

**Añadir a MultiProvider:**
```dart
Provider<IUserManagementRepository>.value(value: _usersManagementRepository),
ChangeNotifierProvider(
  create: (_) => UserManagementProvider(_usersManagementRepository),
),
```

---

## FASE 7: Verificación Final y Testing

### 7.1 Checklist de Verificación (según agent.md)
- [ ] Las pantallas navegables están en `lib/presentation/screens/` (waiting_approval_screen.dart y user_approvals_screen.dart)
- [ ] La lógica de aprobación está en `lib/features/users_management/`, separada de auth
- [ ] No existe `WebSocketManager` ni ninguna clase global de gestión de sockets
- [ ] Los DataSources usan `.stream()` nativo de Supabase para tiempo real
- [ ] Las entidades de dominio no tienen lógica de Supabase (sin fromJson/toMap en entidades)
- [ ] Los models en data layer manejan la serialización

### 7.2 Flujo de Testing Manual
1. **Registro de usuario nuevo:**
   - Crear cuenta desde `/register`
   - Completar datos adicionales en `/additional-data`
   - Debería redirigir a `/waiting` automáticamente
   
2. **Aprobación desde Admin:**
   - Login como admin
   - Navegar a `/admin/user-approvals`
   - Ver usuario pendiente en la lista
   - Click en "Aprobar"
   
3. **Tiempo real:**
   - En la pantalla de espera del usuario pendiente
   - Cuando el admin aprueba, debería navegar automáticamente al Dashboard

4. **Rechazo:**
   - Admin rechaza usuario
   - Usuario ve mensaje de "cuenta rechazada" con opción de contacto

### 7.3 Verificar compilación
- Ejecutar `flutter analyze` para verificar errores estáticos
- Ejecutar `flutter run` para verificar que la app compila y navega correctamente

---

## Orden de Ejecución Recomendado

1. **FASE 1** (Auth Domain + Data) - Base del sistema
2. **FASE 2** (users_management feature) - Lógica de administración
3. **FASE 4** (Router + AuthProvider updates) - Integración de navegación
4. **FASE 3** (Screens) - UI dependiente de las fases anteriores
5. **FASE 6** (main.dart configuration) - Wiring final
6. **FASE 5** (Eliminar WebSocketManager) - Limpieza (puede hacerse en paralelo)
7. **FASE 7** (Verificación) - QA final

## Archivos Clave a Modificar

**Modificar:**
- `lib/features/auth/domain/entities/user_entity.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/presentation/providers/auth_provider.dart`
- `lib/core/router/app_router.dart`
- `lib/main.dart`
- `lib/features/reservations/data/datasources/reservation_remote_datasource.dart`

**Crear:**
- `lib/features/auth/data/models/user_model.dart`
- `lib/features/users_management/` (estructura completa)
- `lib/presentation/screens/auth/waiting_approval_screen.dart`
- `lib/presentation/screens/admin/user_approvals_screen.dart`

**Eliminar:**
- `lib/data/datasources/websocket_manager.dart`

## Consideraciones Importantes

1. **No mezclar lógica de admin en auth:** La feature `users_management` es completamente independiente
2. **Streams locales:** Cada feature usa su propio stream de Supabase, no hay managers globales
3. **Clean Architecture estricta:** Entidades puras en domain, models con fromMap en data, screens en presentation
4. **Provider existente:** No migrar a Riverpod, mantener ChangeNotifier como el proyecto actual
5. **Tiempo real nativo:** Usar `.stream()` de Supabase, no WebSockets custom