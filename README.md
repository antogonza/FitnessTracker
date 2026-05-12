# Fitness Tracker App

Una aplicación de seguimiento de entrenamiento diseñada con un enfoque prioritario en el Apple Watch (**Watch-First**), permitiendo a los usuarios gestionar sus rutinas y sesiones de ejercicio de forma fluida tanto en iPhone como en su muñeca.

## 🚀 Características Principales

### ⌚ Apple Watch (Enfoque Principal)
- **Seguimiento en Vivo**: Registra series, repeticiones y peso directamente durante el entrenamiento.
- **Calculadora de Discos**: Integrada en la vista de ejercicio para determinar rápidamente qué discos poner en la barra.
- **Temporizador de Descanso**: Notificaciones y visualización del tiempo de recuperación entre series.
- **Soporte para Digital Crown**: Modificación precisa de valores mediante la rueda del reloj.
- **Complicaciones**: Acceso rápido desde la esfera del reloj.

### 📱 iOS App
- **Gestión de Rutinas**: Creación y edición detallada de planes de entrenamiento.
- **Historial y Estadísticas**: Visualización de progresos y récords personales (PR).
- **Sincronización**: Datos compartidos instantáneamente entre iPhone y Apple Watch mediante `WatchConnectivity`.

### 🛠️ Tecnologías Utilizadas
- **SwiftUI**: Interfaz de usuario moderna y declarativa.
- **SwiftData**: Persistencia de datos eficiente y sincronización con CloudKit.
- **HealthKit**: Integración con los datos de salud y actividad de Apple.
- **WatchConnectivity**: Comunicación en tiempo real entre dispositivos.

## 📂 Estructura del Proyecto

El repositorio está organizado de la siguiente manera:

- `FitnessTracker/`: Aplicación principal de iOS.
- `FitnessTracker Watch App/`: Aplicación específica para watchOS.
- `Shared/`: Código compartido entre plataformas, incluyendo:
  - `Models/`: Modelos de datos de SwiftData (`Routine`, `Exercise`, `WorkoutSet`, etc.).
- `FitnessTrackerWidgets/`: Widgets para la pantalla de inicio y pantalla de bloqueo.
- `FitnessTrackerWatchWidgets/`: Complicaciones para el Apple Watch.

## 🛠️ Requisitos de Desarrollo

- **Xcode 15.0+**
- **iOS 17.0+**
- **watchOS 10.0+**
- **Swift 5.9+**

## 🔧 Configuración

1. Clona el repositorio.
2. Abre `FitnessTracker.xcodeproj` en Xcode.
3. Asegúrate de configurar los **Signing & Capabilities** con tu equipo de desarrollo para habilitar HealthKit y iCloud.
4. Selecciona el esquema `FitnessTracker` para ejecutar en iPhone o `FitnessTracker Watch App` para el reloj.

---

Desarrollado con ❤️ para entusiastas del fitness.
