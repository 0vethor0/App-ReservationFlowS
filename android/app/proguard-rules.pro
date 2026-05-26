# BeamReserve - ProGuard Rules for Release Builds
# Previene la eliminación/renombrado de clases críticas durante la ofuscación

# Mantiene metadatos esenciales para deserializadores JSON y anotaciones
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Protege las clases del motor de Flutter (ciclo de vida, plugins)
-keep class io.flutter.embedding.** { *; }

# Evita que R8 altere las clases del SDK de Firebase
-keep class com.google.firebase.** { *; }

# Asegura la integridad de llamadas de red/WebSocket de Supabase
-keep class io.supabase.** { *; }

# Ignorar advertencias de clases faltantes de Google Play Core
# Flutter las referencia para componentes diferidos (split install),
# pero no son necesarias si no se usan.
-dontwarn com.google.android.play.core.**

# Ignorar advertencias de clases faltantes de Google Tasks
-dontwarn com.google.android.gms.tasks.**
