# Changelog

## [1.7.0](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.6.2...v1.7.0) (2026-06-07)


### Features

* implement OTA app update system with Supabase realtime and version check provider ([fd86813](https://github.com/0vethor0/App-ReservationFlowS/commit/fd86813d75ab613a22170ae106e242cdd65980e5))


### Bug Fixes

* He eliminado la importación no utilizada de path_provider en el archivo ([b6d195f](https://github.com/0vethor0/App-ReservationFlowS/commit/b6d195f0d3ebd91823c239b34d782574ca90e3ee))

## [1.6.2](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.6.1...v1.6.2) (2026-06-06)


### Bug Fixes

* error de compilacion del keystore ([8e235dd](https://github.com/0vethor0/App-ReservationFlowS/commit/8e235dd4b311ee86fc55c605d5c8c0d41305d297))

## [1.6.1](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.6.0...v1.6.1) (2026-06-06)


### Bug Fixes

* He añadido la opción --ignore-garbage en el archivo release.yml para que el servidor ignore cualquier espacio o salto de línea que se haya copiado por error. ([b46f597](https://github.com/0vethor0/App-ReservationFlowS/commit/b46f5970c6665ae51e9c942c95b046104ab12b6d))

## [1.6.0](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.5.0...v1.6.0) (2026-06-05)


### Features

* Implementar un proceso automatizado de lanzamiento de CI/CD con firma de APK, implementación y notas de lanzamiento generadas por IA ([d4c43c2](https://github.com/0vethor0/App-ReservationFlowS/commit/d4c43c2a4d902992eb544c1af53cbc34dbad57d4))

## [1.5.0](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.4.0...v1.5.0) (2026-06-05)


### Features

* Implementar la persistencia de la evidencia pendiente para recuperar la captura de imágenes después de la destrucción de la actividad de Android ([625734a](https://github.com/0vethor0/App-ReservationFlowS/commit/625734a6e97062bf02d343b533698c4e46847dfa))

## [1.4.0](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.3.1...v1.4.0) (2026-06-05)


### Features

* implement secure navigation routing, user data model, and authentication provider integration (modificaciones a modo de prueba para estudiar el comportamiento del build apk desde github) ([8bfe1ea](https://github.com/0vethor0/App-ReservationFlowS/commit/8bfe1ea1c4988e8b0c13d021d8707f4cd143d7f3))

## [1.3.1](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.3.0...v1.3.1) (2026-06-05)


### Bug Fixes

* refactirzacion del codigo. Se corrigio las secciones que se conectan al cliente de supabase a traves de la capa de presentacion ([d3ed1a9](https://github.com/0vethor0/App-ReservationFlowS/commit/d3ed1a9b40692afa8a0cc7f361f5608b0b39009a))

## [1.3.0](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.2.0...v1.3.0) (2026-06-04)


### Features

* format code ([4d40fb8](https://github.com/0vethor0/App-ReservationFlowS/commit/4d40fb8e846b67da0f591324892f3963e54308f5))
* Implementar un proceso automatizado de lanzamiento de CI/CD con distribución APK y soporte de actualización de versiones dentro de la aplicación ([5f69bec](https://github.com/0vethor0/App-ReservationFlowS/commit/5f69bec492f219a419b1aece90f5653052f9e44b))


### Bug Fixes

* error de construccion (build) del apk fue corregido ([a68355b](https://github.com/0vethor0/App-ReservationFlowS/commit/a68355bc35ff5dc4ac39d15385b4667858af3c96))
* formateo del codigo ([d776541](https://github.com/0vethor0/App-ReservationFlowS/commit/d776541819476db41da589c6a9157f9f0585d49f))

## [1.2.0](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.1.0...v1.2.0) (2026-05-30)


### Features

* actualzacion del readme ([fdb2383](https://github.com/0vethor0/App-ReservationFlowS/commit/fdb238385887bbdcef27adcc318e4bd64d365ec7))

## [1.1.0](https://github.com/0vethor0/App-ReservationFlowS/compare/v1.0.0...v1.1.0) (2026-05-30)


### Features

* **auth:** add user approval status and remove websocket manager ([ac7d7bd](https://github.com/0vethor0/App-ReservationFlowS/commit/ac7d7bd5b40bd040539d2881583df5a842635a40))
* **auth:** integrate profile photo upload with persistent local storage ([7da9eaf](https://github.com/0vethor0/App-ReservationFlowS/commit/7da9eaffb21bdd3456475388b4788e42ba30582f))
* **dashboard:** add realtime reservation updates with notifications ([42dde3d](https://github.com/0vethor0/App-ReservationFlowS/commit/42dde3d01c72f2d72db004f832707009a703c9e2))
* **dashboard:** separate loading state and optimize reservations reload ([3ec2233](https://github.com/0vethor0/App-ReservationFlowS/commit/3ec2233881e0496d3bef925c4681a3c4a17ab6ba))
* implement dashboard and request management features with realtime Supabase integration ([f40c25b](https://github.com/0vethor0/App-ReservationFlowS/commit/f40c25bbe1429b50a9fa3d42c847bc0270788413))
* implement reservation calendar view and repository integration for real-time schedule tracking ([0cc1445](https://github.com/0vethor0/App-ReservationFlowS/commit/0cc1445d11e8d0a46701716fc106f1cdaf1932d5))
* implementar formato de hora local para las horas de inicio y finalización de la reserva, agregar entidad TimeSlot y mejorar la verificación de conflictos en el proceso de reserva ([c93663e](https://github.com/0vethor0/App-ReservationFlowS/commit/c93663efe63a3a420eb62b2901c635ca17d37e42))
* implementar métricas de panel, fuente de datos de reservas y funciones de vista de calendario, y README ([a25c4e3](https://github.com/0vethor0/App-ReservationFlowS/commit/a25c4e39860ba322250fdad1845b5f3dbe47a775))
* implementar módulo de mensajería, notificaciones push e interfaz de usuario del panel con lógica de capa de datos asociada ([1f98057](https://github.com/0vethor0/App-ReservationFlowS/commit/1f98057aa71544c7e3e1798160db4444b52f1da0))
* mejora en el sistema de reservaciones ([4b13654](https://github.com/0vethor0/App-ReservationFlowS/commit/4b136548af83b3442c10b67ebabfe167df151e0b))
* mejorar el formato de las notificaciones y agregar controles de disponibilidad en tiempo real para las reservas ([f3f0604](https://github.com/0vethor0/App-ReservationFlowS/commit/f3f0604aaca9421582bac683b3536f3d423a6e2d))
* nuevo job para el workflow del github ([30c9405](https://github.com/0vethor0/App-ReservationFlowS/commit/30c94052e6138516ee341607036d83959fa87b20))
* Refactorizar la estructura del código para mejorar la legibilidad y la capacidad de mantenimiento ([20b8c80](https://github.com/0vethor0/App-ReservationFlowS/commit/20b8c80cafd03c40923a420ec779ef07b408e1d1))
* **requests:** add real-time streaming and enhance request handling ([85cfedd](https://github.com/0vethor0/App-ReservationFlowS/commit/85cfedd66ed9f36b22acbc4471e81033933bbae1))
* **reservas:** agregue múltiples funciones de reservas y componentes de interfaz de usuario ([6b91105](https://github.com/0vethor0/App-ReservationFlowS/commit/6b91105c5d9b1d2c55581ac6d4d46f83270aafb6))
* **reservation_calendar:** mejora la funcionalidad del calendario con filtros de producto y estado ([ab6b5b2](https://github.com/0vethor0/App-ReservationFlowS/commit/ab6b5b2633d1e416a43af8df9a2856a111926084))
* se aplico un formateo global al codigo ([dca672a](https://github.com/0vethor0/App-ReservationFlowS/commit/dca672af809204d21a9984e158ca65798cc5c4b0))
* **users_management:** mejora el manejo de solicitudes de administración y los flujos de trabajo de aprobación de usuarios ([43dc6a7](https://github.com/0vethor0/App-ReservationFlowS/commit/43dc6a7ac2dddaf10a96fb3fa81c25bd9e82b4bb))


### Bug Fixes

* correccion dentro del sistemas de gestion de archivos ([5df7338](https://github.com/0vethor0/App-ReservationFlowS/commit/5df7338fdf32db9db1e51554edde7e99b356c8a5))
* correct timezone synchronization and admin UI time display ([b8015f7](https://github.com/0vethor0/App-ReservationFlowS/commit/b8015f729d4341d0b7fa46c141fa56b3cd59c262))
* Error corregido en auth_provider.dart envolviendo la sentencia throw en un bloque {} ([6143e5d](https://github.com/0vethor0/App-ReservationFlowS/commit/6143e5da410cf4eea300ec9cdedfaba957e68fd0))
* errores internos en la logica del calender. Corrección del formato de hora y la distribucion de bloques de tiempo ([5e0a6cd](https://github.com/0vethor0/App-ReservationFlowS/commit/5e0a6cd1e91038740c3b0a5d7f9e99f5c68eaaa3))
* lop que bloquea la redireccion en appRouter ([cc88824](https://github.com/0vethor0/App-ReservationFlowS/commit/cc888246848133215f283fa4779a80858d603a58))
* **requests:** include all future requests instead of only pending ones ([dea0788](https://github.com/0vethor0/App-ReservationFlowS/commit/dea07889c3f05d4b44b5ceac44fd97ca55d6be9d))
* resolve flutter analyze issues - remove unused imports and fields ([05c633f](https://github.com/0vethor0/App-ReservationFlowS/commit/05c633f0c43dc9dbbe0627baef91dcb13d620261))
