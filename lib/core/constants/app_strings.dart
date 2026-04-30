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
