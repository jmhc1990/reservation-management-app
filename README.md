# StyleSync — App de Barbería

Aplicación móvil para gestión de citas de barbería, desarrollada con Flutter y Firebase.

🎨 **Diseño del Proyecto**
👉 [Ver archivos en Figma](https://www.figma.com/design/Uo8QEWR8LchOKp1LqZrizK/StyleSync-Design-System?node-id=0-1&t=QNwzcLZfKBrV0e7o-1)

---

## Requisitos

- Flutter SDK (ver `pubspec.yaml` para versión exacta)
- Dart
- Android Studio / VS Code con extensión Flutter
- Cuenta de Firebase con acceso al proyecto `stylesync-4b86c`
- Archivo `google-services.json` en `android/app/` (no incluido en el repositorio)

---

## Instalación

```bash
git clone <url-del-repositorio>
cd style_sync
flutter pub get
flutter run
```

---

## Comandos útiles

```bash
flutter pub get            # instalar dependencias
flutter analyze            # análisis estático
flutter test               # ejecutar tests
flutter build apk --debug  # build debug Android
```

---

## Estructura del proyecto

```
lib/
├── core/
│   └── theme/app_colors.dart        # colores globales (gold, cancel, etc.)
├── controllers/
│   ├── auth_controller.dart         # gestión de autenticación
│   └── theme_controller.dart        # toggle tema claro/oscuro
├── models/
│   ├── user.dart                    # ModeloUsuario, RolUsuario
│   ├── staff.dart                   # ModeloStaff, Specialization, TramoHorario
│   ├── staff_off_day.dart           # ModeloStaffOffDay, TipoAusencia
│   ├── appointments.dart            # ModeloCita, EstadoCita
│   └── services.dart                # ModeloServicio
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── appointment_service.dart
│   ├── catalog_service.dart
│   ├── staff_service.dart
│   ├── staff_off_day_service.dart
│   └── user_service.dart
├── navigation/
│   └── auth_wrapper.dart            # raíz: decide NavigationScreen según rol
├── widgets/
│   └── role_dialog.dart
└── screens/
    ├── auth/                        # login, registro
    ├── home/                        # HomeScreen (sin Scaffold propio)
    ├── admin/                       # AppointmentsScreen, StaffFormScreen, etc.
    ├── booking/                     # BookingScreen (multi-paso), MyAppointmentsSection, AppointmentHistoryScreen
    ├── services/                    # ServicesListScreen, ServiceFormScreen
    └── shared/                      # NavigationScreen, SettingsScreen, UserProfileScreen,
                                     # StaffProfileScreen, AppointmentDetailScreen
```

---

## Navegación

- `AuthWrapper` → `NavigationScreen(role, uid)` siempre
- **Admin** — 5 tabs: Citas, Servicios, Usuarios, Trabajadores, Vacaciones
- **Cliente** — 3 tabs: Inicio, Historial, Mi perfil *(pendiente de merge)*
- Botón ⚙️ en `AppBar` para ambos roles → `SettingsScreen`
- Logout en `SettingsScreen` con `Navigator.popUntil((route) => route.isFirst)`
- `HomeScreen` devuelve `ColoredBox` (sin `Scaffold`) — el `Scaffold` lo provee `NavigationScreen`

---

## Roles de usuario

| Rol | Acceso |
|---|---|
| `admin` | Panel completo |
| `client` | Reservas, historial, perfil |
| `staff` | Sin cuenta Firebase Auth — objetos pasivos en Firestore |

---

## Firestore — Colecciones

| Colección | Descripción |
|---|---|
| `users/{uid}` | Usuarios con rol y fidelización |
| `appointments/{id}` | Citas con estado (`confirmed`, `cancelled`, `completed`, `noShow`) |
| `services/{id}` | Catálogo de servicios |
| `staff/{id}` | Trabajadores con horario semanal (`workingHours`) |
| `staff_off_days/{id}` | Ausencias/vacaciones de trabajadores |

### Índices desplegados
- `staff_off_days`: staff_id↑ + start_date↑
- `appointments`: staff_id↑ + status↑ + start_time↑
- `appointments`: client_id↑ + start_time↓
- `appointments`: staff_id↑ + start_time↑

---

## Funcionalidades implementadas

### Cliente
- Registro e inicio de sesión
- Reserva de citas multi-paso (barbero → servicio → fecha/hora → confirmar)
- Ver próximas citas con estado en `HomeScreen`
- Historial de citas pasadas *(pendiente de merge)*
- Cancelar cita (con validación de 2h de antelación)
- Perfil editable (nombre, teléfono)
- Tarjeta de fidelización (lógica temporal, pendiente conectar a Firestore)
- Cambio de tema claro/oscuro desde Ajustes

### Admin
- Panel con calendario y lista de citas del día agrupadas por trabajador
- Crear/editar/eliminar servicios con imagen
- Gestión de usuarios y roles
- Gestión de trabajadores (horario semanal, especialidades, servicios)
- Gestión de ausencias/vacaciones del staff
- Cambio de estado de citas
- Eliminar citas

---

## Cómo contribuir

Este proyecto sigue un flujo de trabajo basado en ramas y pull requests. **Está prohibido hacer push directo a `main`.**

### Ramas principales

| Rama | Uso |
|---|---|
| `main` | Producción — protegida, solo merge desde PR aprobada |
| `dev` | Desarrollo — rama base para crear nuevas ramas |

### Flujo de trabajo

1. Crea una rama desde `dev` (no desde `main`):
   ```bash
   git checkout dev
   git pull
   git checkout -b feat/nombre-de-la-funcionalidad
   ```
2. Realiza los cambios y haz commits siguiendo [Conventional Commits](https://www.conventionalcommits.org/):
   ```
   feat: descripción del cambio
   fix: corrección de bug
   chore: cambios de configuración o mantenimiento
   refactor: refactorización sin cambio de funcionalidad
   ```
3. Asegúrate de que el código pasa el análisis estático antes de hacer push:
   ```bash
   flutter analyze
   flutter test
   ```
4. Abre una Pull Request hacia `dev` en GitHub.
5. La PR debe ser aprobada por al menos un miembro del equipo antes de mergear.
6. El workflow de CI debe pasar correctamente (flutter analyze + flutter test).
7. Una vez estable, el coordinador mergea `dev` → `main`.

### Definition of Done

- `flutter analyze` pasa sin warnings
- Tests verdes
- Sin TODOs sin ticket asociado
- PR enlazada a la tarea del Sprint
- Código revisado y aprobado antes de merge

---

## Seguridad

- Nunca commitear `google-services.json` ni archivos `.env`
- No incluir datos reales de usuarios en commits ni logs
- Las reglas de Firestore están en `firestore.rules`
- Imágenes almacenadas como base64 en Firestore (`image_url`, `photo_url`)
