# Plan de Acción: Fitness Tracker App (Watch-First)

## 1. Definición de Arquitectura
* **Estructura de la app:** Aplicación WatchOS independiente (Standalone Watch App) con una Companion App en iOS. La lógica pesada de entrenamiento reside en el Watch. Target recomendado: watchOS 10+ e iOS 17+.
* **Gestión de estado:** `@Observable` (framework Observation de Swift 5.9+). Es extremadamente ligero, elimina el overhead de `ObservableObject` y evita renderizados innecesarios, crucial para ahorrar batería y maximizar la fluidez en el Watch.
* **Persistencia de datos:** **SwiftData**. Es nativo, moderno, requiere muchísimo menos boilerplate que CoreData y se integra de forma transparente con `@Observable` y SwiftUI. Su rendimiento para operaciones transaccionales pequeñas (como guardar una serie) es instantáneo.
* **Sincronización:** `CloudKit` gestionado a través de `SwiftData` (`ModelConfiguration` con CloudKit database privada). Esto ofrece sincronización offline-first transparente: el Watch lee y escribe localmente sin esperar conexión, y el sistema sincroniza con el iPhone en background cuando es posible.

## 2. Modelo de Datos
Usaremos un esquema plano y directo para maximizar la velocidad de lectura.

* **Routine (Rutina)**
  * `id`: UUID
  * `name`: String (ej. "Día de Empuje")
  * `exercises`: `[Exercise]` (Relación 1 a N)
* **Exercise (Ejercicio)**
  * `id`: UUID
  * `name`: String
  * `routine`: `Routine` (Relación inversa)
  * `order`: Int (Para ordenar dentro de la rutina)
* **Session (Sesión de entrenamiento)**
  * `id`: UUID
  * `routineId`: UUID (Referencia a la rutina original)
  * `startTime`: Date
  * `endTime`: Date?
  * `sets`: `[WorkoutSet]` (Relación 1 a N)
* **WorkoutSet (Serie realizada)**
  * `id`: UUID
  * `exerciseId`: UUID
  * `weight`: Double
  * `reps`: Int
  * `completedAt`: Date

## 3. Flujos de Usuario (UX)

**Creación de rutina (iPhone - Setup inicial):**
1. Abrir app -> Pantalla principal "Mis Rutinas".
2. Tap en "+" -> Introducir nombre de la rutina.
3. Buscar y añadir ejercicios desde un catálogo predefinido o crear nombres custom.
4. Ordenar ejercicios (drag & drop) -> Guardar.

**Inicio y registro de entrenamiento (Apple Watch):**
1. Abrir app -> Lista grande de Rutinas disponibles.
2. Tap en una Rutina -> Se crea una `Session` en base de datos.
3. Aparece el primer `Exercise`. En pantalla ya están cargados el peso y repeticiones de la sesión anterior.
4. *¿Mismo peso y reps?* -> Tap directo en el botón gigante "COMPLETAR". (0 fricción).
5. *¿Distinto peso/reps?* -> Girar Digital Crown para ajustar -> Tap "COMPLETAR".
6. Salta automáticamente la vista de descanso.
7. Al expirar el descanso, vuelve al ejercicio (o avanza al siguiente si se alcanzó el límite de series).
8. Swipe a la última pantalla -> "Finalizar Entrenamiento" -> Pantalla de resumen rápido.

## 4. Diseño de Interfaz (Apple Watch)
El diseño usa los paradigmas de watchOS 10 (paginación vertical e interfaces de borde a borde).

* **Pantalla de Inicio:** `List` con botones prominentes que contienen el nombre de la rutina y la fecha de la última vez que se realizó.
* **Pantalla de Ejercicio (Main View):**
  * *Header:* Nombre del Ejercicio y Serie actual (ej. "Press Banca • Serie 2/4").
  * *Cuerpo:* Dos componentes grandes lado a lado (Peso y Reps). Un tap en "Peso" lo resalta y vincula la Digital Crown a ese valor. Un tap en "Reps" cambia el foco de la corona.
  * *Footer:* Un botón expansivo (ocupando todo el ancho inferior), color verde vibrante: "COMPLETAR".
* **Navegación:** `TabView` con `verticalPage` style. Swipe arriba/abajo pasa de un ejercicio a otro al instante.

## 5. Sistema de Descanso
* **Activación:** Automática al pulsar el botón "COMPLETAR" de una serie.
* **UI:** Un overlay (FullScreenCover) oscuro. En el centro, un `CircularProgressView` masivo contando hacia atrás. Dos botones en la base: "+30s" y "Saltar Descanso".
* **Feedback Háptico:**
  * Al guardar la serie: Vibración corta (`.success`).
  * Cuenta atrás: Pequeños "taps" hápticos en los últimos 3 segundos (3.. 2.. 1..).
  * Finalización: Patrón háptico fuerte y sostenido indicando que es momento de levantar la barra.

## 6. Estrategia de “Repetir Última Sesión”
* **Precarga Inteligente:** Al instanciar la vista de un ejercicio en el Watch, la app hace un fetch ultra rápido a SwiftData filtrando `WorkoutSet` por `exerciseId`, ordenado por fecha descendente.
* **Inyección de Estado:** Toma el `weight` y `reps` de la última serie registrada y los inyecta como valor inicial.
* **Ghost Data:** Si se modifica el peso, aparece un texto sutil (ej: *Anterior: 80kg x 8*).

## 7. Fases Adicionales
* **Gestión de Series Múltiples (Fase 6):** El modelo `Exercise` incluirá un objetivo de series (`targetSets`). La interfaz de iOS permitirá configurar este número, y el Apple Watch controlará el flujo para no avanzar de ejercicio hasta haber completado todas sus series correspondientes, mostrando en tiempo real indicadores del tipo "Serie 2 de 4".
* **Descansos Personalizados y Edición (Fase 7):** Posibilidad de fijar descansos generales por rutina y descansos específicos por ejercicio (diferenciando descanso entre series y entre ejercicios). Se permitirá la edición completa de los ejercicios desde la app de iOS.
* **Historial y Calendario (Fase 8):** Implementación de una vista de calendario interactivo en la app de iOS para consultar entrenamientos previos. Al tocar un día con sesiones, se puede ver el detalle (volumen total, series, pesos y reps). Se añade la posibilidad de **eliminar sesiones** deslizando la tarjeta, previa confirmación mediante un modal de seguridad.
* **Pulido de Usabilidad y Notificaciones en Background (Fase 9):** 
  * Ajuste de la precisión del peso en la *Digital Crown* del Apple Watch para cambiar de **0.1 kg en 0.1 kg**.
  * Implementación de **Notificaciones Locales (UserNotifications)** en el TimerManager del Watch. Esto garantiza que el usuario reciba un aviso háptico (vibración) y sonoro al terminar el descanso, incluso si la pantalla del reloj está bloqueada o apagada.
* **Estadísticas Globales y Progreso (Fase 10):** Creación de un Dashboard o panel de estadísticas en iOS centrado en la motivación del usuario. Incluirá:
  * *Métricas Globales:* Tarjetas resumen con el volumen total levantado, sesiones totales completadas y racha actual.
  * *Récords y Progreso (PRs):* Cálculo de pesos máximos históricos por ejercicio y gráficas evolutivas usando nativamente `Swift Charts`.
  * *Distribución:* Gráfico circular analizando qué rutinas se realizan con más frecuencia.
* **Clasificación de Ejercicios (Fase 11):** Mejora de la estructura de datos para que los ejercicios tengan una categoría (Empuje, Tirón, Pierna, Core, Otro). Se añade un selector al crear o editar el ejercicio, y la vista de estadísticas ("Récords y Progreso") se agrupa visualmente en base a estas categorías.
* **Integración Nativa con Apple Health (Fase 12):** Implementar `HKWorkoutSession` para mantener la app activa en primer plano durante el entrenamiento, registrar la frecuencia cardíaca, calcular calorías activas reales y guardar los datos en la app Fitness de Apple para cerrar los anillos.
* **Sincronización y Fiabilidad de SwiftData (Fase 13):** Optimizar las `@Query` y la comunicación con CloudKit para reducir los tiempos de carga en iOS, implementar forzado de recarga (pull-to-refresh) y crear mecanismos de limpieza automática para sesiones "fantasma" que se quedaron sin terminar.
* **Live Activities y Dynamic Island (Fase 14):** Crear un widget en vivo (`Activity`) para que los tiempos de descanso se muestren en la Dynamic Island y la pantalla de bloqueo del iPhone, facilitando el seguimiento sin mirar el reloj.
* **Calculadora de Discos (Fase 15):** Desarrollar un componente visual interactivo ("Plate Calculator") que indique qué discos exactos (20kg, 10kg, etc.) colocar a cada lado de la barra según el peso objetivo seleccionado.
* **Celebración de Récords y Gamificación (Fase 16):** Detectar nuevos PRs (Personal Records) en tiempo real en el Apple Watch y disparar animaciones visuales nativas y patrones hápticos especiales para premiar al usuario.
* **Complicaciones y Widgets (Fase 17):** Programar complicaciones para las esferas de watchOS que abran la app con un toque, y Widgets de iOS para visualizar métricas clave (racha, último entreno) desde la pantalla de inicio.
* **Catálogo Inteligente de Ejercicios (Fase 18):** Pre-cargar una base de datos de ejercicios estandarizados (con grupos musculares definidos) y un buscador para evitar duplicidades tipográficas y permitir visualizar qué músculo se va a entrenar.
* **Planificación Semanal (Fase 19):** Un sistema de calendario semanal que permite asignar una rutina a cada día de la semana (Lunes → Tirón, Martes → Empuje, etc.). En el Apple Watch, la app sugiere automáticamente la rutina correspondiente al día actual al arrancar el entrenamiento. Un botón de anulación permite elegir cualquier otra rutina creada si el usuario quiere cambiar sobre la marcha.

## 8. Plan de Desarrollo por Fases
Ver el archivo `TASK_PLANNER.md` adjunto para el desglose exhaustivo de las tareas (actualizado con la Fase de Series).

## 9. Riesgos Técnicos y Soluciones
* **Riesgo:** *Latencia o fallos en Sincronización Watch <-> iPhone.*
  * **Solución:** Desacople total. El Watch App lee/escribe en local. Sincronización transparente en background con CloudKit.
* **Riesgo:** *La app se suspende entre series.*
  * **Solución:** Guardado agresivo al tap. Cálculo de tiempo de descanso basado en el delta de `Date.now` en lugar de un `Timer` en memoria.
* **Riesgo:** *Dedos sudados.*
  * **Solución:** Uso de la Digital Crown. Hitboxes inflados (`.contentShape(Rectangle())`) en los botones.
