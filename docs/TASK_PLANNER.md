# Planificador de Tareas (Task Planner) - Fitness Tracker App

Este documento servirá como guía paso a paso para el desarrollo. Marca las casillas `[x]` conforme vayas completando cada fase.

## Fase 1: Fundaciones (Data & Models)
- [x] **Tarea 1.1:** Inicializar el proyecto en Xcode (Watch App with iOS Companion).
- [x] **Tarea 1.2:** Configurar el contenedor de SwiftData (`ModelContainer`) habilitando CloudKit.
- [x] **Tarea 1.3:** Crear modelo `Routine` (Rutina).
- [x] **Tarea 1.4:** Crear modelo `Exercise` (Ejercicio) y la relación con `Routine`.
- [x] **Tarea 1.5:** Crear modelo `Session` (Sesión) para rastrear entrenamientos diarios.
- [x] **Tarea 1.6:** Crear modelo `WorkoutSet` (Serie) y relaciones.
- [x] **Tarea 1.7:** Escribir extensiones de *Mock data* (datos falsos) para poder previsualizar UI en Xcode Previews.

## Fase 2: iOS Companion App (Setup)
- [x] **Tarea 2.1:** Configurar la UI principal de iOS (`NavigationStack` mostrando lista de rutinas).
- [x] **Tarea 2.2:** Crear vista/formulario para añadir o editar una `Routine` (nombre).
- [x] **Tarea 2.3:** Crear vista para añadir, editar o eliminar un `Exercise` dentro de una rutina.
- [x] **Tarea 2.4:** Permitir reordenar (drag & drop) los ejercicios dentro de la rutina en iOS.
- [x] **Tarea 2.5:** Verificar que CloudKit y el Background Modes están habilitados en Capabilities.

## Fase 3: Core UX en Apple Watch (Navegación y Vista Principal)
- [x] **Tarea 3.1:** Crear la Home View del Watch (`List` de las rutinas creadas).
- [x] **Tarea 3.2:** Mostrar el subtítulo en cada celda indicando la fecha de la última sesión realizada.
- [x] **Tarea 3.3:** Implementar acción de inicio: al tocar una Rutina, se crea una nueva entidad `Session` en la BD con `startTime = Date.now`.
- [x] **Tarea 3.4:** Configurar estructura de navegación paginada (`TabView` con `PageTabViewStyle`) para navegar entre ejercicios fluidamente.

## Fase 4: Registro de Series (El Core del Entrenamiento)
- [x] **Tarea 4.1:** Crear vista individual de `Exercise` (Main Workout View).
- [x] **Tarea 4.2:** Implementar interfaz de variables: un control de *Peso* y otro de *Reps* con botones muy grandes o *Pickers*.
- [x] **Tarea 4.3:** Lógica de "Precarga Inteligente": leer el último `WorkoutSet` de este ejercicio para establecer los valores iniciales.
- [x] **Tarea 4.4:** Conectar la `Digital Crown` para ajustar valores numéricos incrementales de peso o repeticiones sin tap.
- [x] **Tarea 4.5:** Implementar botón verde vibrante gigante "COMPLETAR" en el footer de la pantalla.
- [x] **Tarea 4.6:** Guardado en SwiftData: registrar el nuevo `WorkoutSet` en BD al presionar "COMPLETAR".

## Fase 5: Motor de Descanso y Hápticos
- [x] **Tarea 5.1:** Crear vista superpuesta (Overlay / FullScreenCover) para el tiempo de descanso.
- [x] **Tarea 5.2:** Implementar `CircularProgressView` masivo que cuenta hacia atrás desde X segundos (ej. 90s).
- [x] **Tarea 5.3:** Desarrollar lógica del temporizador tolerante a suspensión (guardar el tiempo objetivo y calcular la diferencia contra `Date.now`).
- [x] **Tarea 5.4:** Añadir botones grandes para modificar el tiempo restante ("+30s", "Saltar").
- [x] **Tarea 5.5:** Integrar notificaciones hápticas (`WKInterfaceDevice.current().play(.success)` al guardar serie y alarmas rítmicas para 3, 2, 1 y final del timer).

## Fase 6: Gestión de Series Múltiples (Sets)
- [x] **Tarea 6.1:** Añadir propiedad `targetSets` al modelo `Exercise` (por defecto 3).
- [x] **Tarea 6.2:** Actualizar iOS App (`AddExerciseView` y `RoutineEditView`) para permitir configurar el número de series objetivo.
- [x] **Tarea 6.3:** Actualizar `ActiveExerciseView` en el Watch para gestionar el estado de la serie actual ("Serie X de Y").
- [x] **Tarea 6.4:** Modificar la lógica de Completar: en lugar de bloquearse para siempre, el botón avanza a la siguiente serie.
- [x] **Tarea 6.5:** Modificar el `TimerManager.onTimerFinished` en `SessionPagingView` para que solo avance de ejercicio si se han completado todas las series de ese ejercicio.

## Fase 7: Descansos Personalizados y Edición de Ejercicios
- [x] **Tarea 7.1:** Añadir propiedades de descanso a `Routine` (`defaultRestBetweenSets`, `defaultRestBetweenExercises`).
- [x] **Tarea 7.2:** Añadir propiedades de descanso a `Exercise` (opcionales) para sobreescribir los generales.
- [x] **Tarea 7.3:** Actualizar UI de la app iOS para configurar estos tiempos al crear/editar la rutina.
- [x] **Tarea 7.4:** Permitir la edición de ejercicios (abrir `EditExerciseView` al tocar un ejercicio).
- [x] **Tarea 7.5:** Actualizar el temporizador en el WatchOS para leer los tiempos configurados en lugar de los 90s fijos.

## Fase 8: Cierre de Sesión y Pulido
- [x] **Tarea 8.1:** Crear última pantalla "Finalizar Sesión" y resumen rápido con el total de volumen o tiempo levantado.
- [x] **Tarea 8.2:** Finalizar la entidad `Session` actualizando `endTime = Date.now`.
- [x] **Tarea 8.3:** Mejorar estilo visual y accesibilidad (Colores vibrantes en modo oscuro, Dynamic Type, SF Symbols).
- [x] **Tarea 8.4:** Pruebas end-to-end instalando la app en dispositivos reales (iPhone y Watch) y comprobando la sincronización en background.
- [ ] **Tarea 8.5:** Solucionar posibles problemas de recarga de Views que puedan ralentizar la app en el Apple Watch.

## Fase 9: Historial y Pulido de Usabilidad (Completada)
- [x] **Tarea 9.1:** Implementar `HistoryCalendarView` en iOS con generación de mock data segura para el simulador.
- [x] **Tarea 9.2:** Permitir eliminación de sesiones con swipe y confirmación (alerta de seguridad).
- [x] **Tarea 9.3:** Ajustar la *Digital Crown* a pasos de 0.1 kg en el Watch.
- [x] **Tarea 9.4:** Implementar `UserNotifications` en `TimerManager` para avisos en background cuando expira el tiempo de descanso.

## Fase 10: Estadísticas Globales y Progreso
- [x] **Tarea 10.1:** Integrar la nueva vista de Estadísticas como una tercera pestaña en el `TabView` principal de iOS.
- [x] **Tarea 10.2:** Crear un componente visual de tarjetas para métricas clave (Volumen total, Total de sesiones).
- [x] **Tarea 10.3:** Desarrollar lógica sobre SwiftData para calcular el "Récord Personal" (peso máximo) por ejercicio iterando sobre los `WorkoutSet`.
- [x] **Tarea 10.4:** Implementar vista de detalle de ejercicio que incluya una gráfica de evolución en el tiempo usando `Swift Charts`.
- [x] **Tarea 10.5:** Añadir un gráfico circular de distribución de rutinas (sectorial/donut) para mostrar la frecuencia de cada tipo de entrenamiento.

## Fase 11: Clasificación de Ejercicios
- [x] **Tarea 11.1:** Añadir propiedad `category` (enum `ExerciseCategory` con opciones como Empuje, Tirón, Pierna) al modelo `Exercise`.
- [x] **Tarea 11.2:** Actualizar `AddExerciseView` y `EditExerciseView` para permitir al usuario seleccionar la categoría.
- [x] **Tarea 11.3:** Refactorizar la lista de "Récords y Progreso" en `StatisticsView` para agrupar los ejercicios por categoría mostrando headers separadores.

## Fase 12: Integración Nativa con Apple Health (HealthKit)
- [x] **Tarea 12.1:** Configurar los entitlements y permisos de HealthKit en iOS y WatchOS.
- [x] **Tarea 12.2:** Refactorizar el gestor de entrenamientos para iniciar una `HKWorkoutSession` en el Apple Watch.
- [x] **Tarea 12.3:** Guardar la sesión y calorías quemadas en la app Fitness al finalizar.

## Fase 13: Sincronización y Fiabilidad de SwiftData
- [x] **Tarea 13.1:** Implementar forzado de recarga (pull-to-refresh) en iOS para forzar la actualización de SwiftData.
- [x] **Tarea 13.2:** Crear un job/proceso automático que cierre las sesiones fantasma (sesiones en progreso por más de 12 horas) marcando su `endTime`.
- [x] **Tarea 13.3:** Optimizar la persistencia y reducir la carga asíncrona de datos desde CloudKit.

## Fase 14: Live Activities y Dynamic Island
- [x] **Tarea 14.1:** Crear la extensión de Widget y configurar permisos de Live Activities en iOS.
- [x] **Tarea 14.2:** Diseñar la UI compacta y expandida del cronómetro de descanso para la Dynamic Island.
- [x] **Tarea 14.3:** Comunicar el estado del temporizador del Watch al iPhone para actualizar o iniciar la Live Activity.

## Fase 15: Calculadora de Discos (Plate Calculator)
- [x] **Tarea 15.1:** Crear el algoritmo matemático para desglosar un peso (descontando la barra de 20kg) en discos estándar (20, 15, 10, 5, 2.5, 1.25).
- [x] **Tarea 15.2:** Diseñar la vista en watchOS/iOS que dibuje gráficamente la barra y los discos a colocar.

## Fase 16: Celebración de Récords en Vivo (Gamificación)
- [x] **Tarea 16.1:** Lógica on-the-fly para comprobar si la serie recién completada supera el máximo histórico.
- [x] **Tarea 16.2:** Implementar el trigger háptico y la animación de celebración (confeti o destello) en la vista del Watch.

## Fase 17: Complicaciones de WatchOS y Widgets de iOS
- [x] **Tarea 17.1:** Crear los assets y el target para las complicaciones del WatchOS (Circular, Rectangular).
- [x] **Tarea 17.2:** Desarrollar un Widget de iOS usando App Intents para leer SwiftData y mostrar el resumen semanal en la pantalla de inicio.

## Fase 18: Catálogo Inteligente de Ejercicios
- [x] **Tarea 18.1:** Crear un archivo de recursos (JSON) o enum con >100 ejercicios estandarizados.
- [x] **Tarea 18.2:** Implementar una vista con barra de búsqueda para la selección de ejercicios, reemplazando el `TextField` libre.

## Fase 19: Planificación Semanal
- [x] **Tarea 19.1:** Crear el modelo `WeeklySchedule` en SwiftData que asocia cada día de la semana (1-7) con una `Routine` opcional.
- [x] **Tarea 19.2:** Diseñar la vista de configuración en iOS (`WeeklyScheduleView`) con los 7 días de la semana, cada uno con un selector de rutina y posibilidad de dejarlo vacío (día de descanso).
- [x] **Tarea 19.3:** Adaptar la pantalla de inicio del Watch para leer el plan del día actual y sugerir automáticamente la rutina asignada.
- [x] **Tarea 19.4:** Añadir un botón "Cambiar rutina" en el Watch que permita anular la sugerencia y elegir cualquier rutina disponible de la lista.
