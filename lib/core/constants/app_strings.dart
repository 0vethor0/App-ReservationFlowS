/// Constantes de strings para la app BeamReserve.
///
/// Centraliza todos los textos estáticos para evitar
/// hardcoded strings en la UI.
abstract final class AppStrings {
  // ─── General ───
  static const String appName = 'BeamFlow';
  static const String appTagline = 'Gestión y reservación de proyectores';

  // ─── Splash ───
  static const String splashLoading = 'INICIANDO SISTEMA...';

  // ─── Auth ───
  static const String welcomeBack = 'Bienvenido de nuevo';
  static const String createAccount = 'Crear Cuenta';
  static const String joinToday = 'Únete a BeamFlow hoy';
  static const String login = 'Iniciar sesión';
  static const String logout = 'Cerrar sesión';
  static const String email = 'Correo electrónico';
  static const String emailHint = 'ejemplo@correo.com';
  static const String password = 'Contraseña';
  static const String passwordHint = '••••••••';
  static const String passwordMinChars =
      'La contraseña debe tener al menos 8 caracteres.';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String orContinueWith = 'o continúa con';
  static const String continueWithGoogle = 'Continuar con Google';
  static const String continueWithApple = 'Continuar con Apple';
  static const String noAccount = '¿No tienes una cuenta?';
  static const String register = 'Regístrate';
  static const String hasAccount = '¿Ya tienes cuenta?';
  static const String signIn = 'Iniciar sesión →';

  // ─── Register ───
  static const String fullName = 'Nombre completo';
  static const String fullNameHint = 'Juan Pérez';
  static const String phone = 'Teléfono';
  static const String phoneHint = '600 000 000';
  static const String termsAndConditions =
      'He leído y acepto los Términos y condiciones y la Política de privacidad.';
  static const String termsLink = 'Términos y condiciones';
  static const String privacyLink = 'Política de privacidad';
  static const String registerWithGoogle = 'Registrarse con Google';
  static const String orContinueWithAlt = 'O continuar con';

  // ─── Dashboard ───
  static const String todaySummary = 'RESUMEN DE HOY';
  static const String reservationsToday = 'Reservas Hoy';
  static const String availableEquipment = 'Equipos Disponibles';
  static const String available = 'Disp.';
  static const String totalEquipment = 'Total 45';
  static const String inMaintenance = 'En Mantenimiento';
  static const String inUseNow = 'En Uso Ahora';
  static const String newReservation = '+ Nueva Reservación';
  static const String viewRequests = 'Ver Solicitudes';
  static const String utilizationRate = 'TASA DE UTILIZACIÓN';
  static const String currentWeek = 'Semana Actual';
  static const String upcomingReservations = 'PRÓXIMAS RESERVAS';
  static const String viewAll = 'Ver todas';
  static const String hello = 'Hola,';
  static const String settings = 'Configuración';

  // ─── Profile ───
  static const String profileSettings = 'Configuración de Perfil';
  static const String personalInfo = 'Información Personal';
  static const String firstName = 'Nombre';
  static const String lastName = 'Apellido';
  static const String department = 'Departamento';
  static const String role = 'Rol';
  static const String requestAdmin = 'Solicitar ser Administrador';
  static const String requestAdminDesc = 'Envía una solicitud para obtener permisos de administrador';
  static const String adminRequestSent = 'Solicitud enviada';
  static const String alreadyAdmin = 'Ya eres administrador';
  static const String usagePolicies = 'Políticas de Uso del Sistema';
  static const String policiesTitle = 'Políticas de Uso';
  static const String policiesContent =
      '1. Uso Responsable: Los proyectores deben ser utilizados únicamente para fines institucionales.\n\n'
      '2. Reservación: Las reservaciones deben realizarse con al menos 24 horas de anticipación.\n\n'
      '3. Cancelación: Las reservaciones pueden ser canceladas hasta 2 horas antes del horario establecido.\n\n'
      '4. Cuidado del Equipo: El usuario es responsable del cuidado del equipo durante su uso.\n\n'
      '5. Reporte de Daños: Cualquier daño o mal funcionamiento debe ser reportado inmediatamente.\n\n'
      '6. Tiempo Máximo: El tiempo máximo de uso por reservación es de 4 horas.\n\n'
      '7. Prioridad: Las solicitudes de alta prioridad requieren aprobación de un administrador.';
  static const String saveChanges = 'Guardar Cambios';
  static const String changesSaved = 'Cambios guardados exitosamente';
  static const String developer = 'Ing. Vincent Fernandez';
  static const String developedBy = 'Desarrollado por';
  static const String githubProfile = 'GitHub del desarrollador';

  // ─── Navigation ───
  static const String dashboard = 'Dashboard';
  static const String reserve = 'Reservar';
  static const String requests = 'Solicitudes';

  // ─── Reservation ───
  static const String selectVideobeam = 'Seleccionar Videobeam';
  static const String selectDate = 'Seleccionar Fecha';
  static const String selectTime = 'Seleccionar Horario';
  static const String reservationSummary = 'Resumen de Reservación';
  static const String confirmReservation = 'Confirmar Reservación';
  static const String location = 'Ubicación';
  static const String dateAndTime = 'Fecha y Hora';
  static const String equipment = 'Equipo';

  // ─── Requests ───
  static const String notifications = 'Notificaciones';
  static const String pending = 'Pendientes';
  static const String approved = 'Aprobadas';
  static const String rejected = 'Rechazadas';
  static const String approve = 'Aprobar';
  static const String reject = 'Rechazar';
  static const String searchHint = 'Buscar por equipo, usuario o ubicación..';
  static const String highPriority = 'Alta Prioridad';
  static const String normalPriority = 'Normal';

  // ─── Days of Week ───
  static const List<String> weekDays = [
    'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom',
  ];

  // ─── Validation ───
  static const String fieldRequired = 'Este campo es requerido';
  static const String invalidEmail = 'Correo electrónico no válido';
  static const String passwordTooShort = 'Mínimo 8 caracteres';
  static const String invalidPhone = 'Número de teléfono no válido';
  static const String acceptTerms = 'Debes aceptar los términos';
}
