# StyleSync - Sistema de Gestión de Reservas para Barberías

Aplicación móvil multiplataforma desarrollada en **Flutter** y **Firebase** diseñada para optimizar la gestión de citas, control de servicios y flujos de usuario, con un enfoque riguroso en la calidad de software mediante una sólida suite de pruebas automatizadas.

---

## 🚀 Características Principales
- **Autenticación de Usuarios:** Control de acceso seguro mediante Firebase Auth.
- **Gestión de Reservas en Tiempo Real:** Creación, modificación y seguimiento de citas sincronizadas con Cloud Firestore.
- **Diseño UI/UX "Obsidian & Gold":** Interfaz optimizada con una paleta de colores sobria y elegante.
- **Arquitectura Modular:** Separación clara de responsabilidades para facilitar el mantenimiento y la escalabilidad.

---

## 📱 Tecnologías y Stack
- **Framework:** Flutter (Dart)
- **Backend / BaaS:** Firebase (Authentication, Cloud Firestore)
- **Testing:** Flutter Test, Mockito (Más de 70 pruebas unitarias y de widgets)

---

## 📂 Arquitectura del Proyecto
El código fuente está estructurado por módulos funcionales (*features*) para garantizar una alta cohesión y un bajo acoplamiento:

```text
lib/
├── core/               # Configuración global, temas, paleta "Obsidian & Gold" y util
