import SwiftUI
import SwiftData

@Model
final class Bar {
    var id: UUID?
    var weight: Double = 0.0
    var name: String = "Sin nombre"
    var type: String = "Estándar"
    
    init(id: UUID = UUID(), weight: Double, name: String, type: String = "ESTÁNDAR") {
        self.id = id
        self.weight = weight
        self.name = name
        self.type = type
    }
    
    static var defaults: [Bar] {
        [
            Bar(weight: 20.0, name: "20 KG", type: "OLÍMPICA"),
            Bar(weight: 10.0, name: "10 KG", type: "ESTÁNDAR"),
            Bar(weight: 7.5, name: "7.5 KG", type: "EZ-BAR")
        ]
    }
}

// Extensión para proporcionar contenedores de SwiftData de forma sencilla para la App y Previews
extension ModelContainer {
    
    // Contenedor principal de producción con CloudKit
    @MainActor
    static var shared: ModelContainer = {
        let schema = Schema([
            Routine.self,
            Exercise.self,
            Session.self,
            WorkoutSet.self,
            WeeklySchedule.self,
            Bar.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            "FitnessTracker",
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.tudominio.FitnessTracker")
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Limpieza de sesiones fantasma (Fase 13)
            cleanupGhostSessions(context: container.mainContext)
            
            // Inicializar barras por defecto si el esquema está vacío
            initializeDefaultBars(context: container.mainContext)
            
            return container
        } catch {
            // Si falla por incompatibilidad de schema, borramos el store local.
            print("⚠️ ModelContainer falló (\(error)). Borrando store local...")
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let storeFiles = (try? FileManager.default.contentsOfDirectory(at: appSupport, includingPropertiesForKeys: nil)) ?? []
            for file in storeFiles where file.pathExtension == "store" || file.lastPathComponent.hasSuffix(".store-shm") || file.lastPathComponent.hasSuffix(".store-wal") {
                try? FileManager.default.removeItem(at: file)
            }
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("No se pudo crear el ModelContainer incluso tras borrar el store: \(error)")
            }
        }
    }()
    
    // Contenedor para Previews (en memoria con datos de prueba)
    @MainActor
    static var preview: ModelContainer = {
        let schema = Schema([
            Routine.self,
            Exercise.self,
            Session.self,
            WorkoutSet.self,
            WeeklySchedule.self,
            Bar.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Generar Mock Data
            let routine = Routine(name: "Día de Empuje")
            container.mainContext.insert(routine)
            
            let ex1 = Exercise(name: "Press Banca", order: 0, routine: routine)
            let ex2 = Exercise(name: "Press Militar", order: 1, routine: routine)
            container.mainContext.insert(ex1)
            container.mainContext.insert(ex2)
            
            let session = Session(startTime: .now.addingTimeInterval(-3600), routine: routine)
            container.mainContext.insert(session)
            
            let set1 = WorkoutSet(weight: 80, reps: 8, exercise: ex1, session: session)
            container.mainContext.insert(set1)
            
            // Insertar barras por defecto en preview
            for bar in Bar.defaults {
                container.mainContext.insert(bar)
            }
            
            try? container.mainContext.save()
            
            return container
        } catch {
            fatalError("No se pudo crear el ModelContainer para previews: \(error)")
        }
    }()
    
    @MainActor
    private static func initializeDefaultBars(context: ModelContext) {
        let descriptor = FetchDescriptor<Bar>()
        if let count = try? context.fetchCount(descriptor), count == 0 {
            for bar in Bar.defaults {
                context.insert(bar)
            }
            try? context.save()
        }
    }
    
    /// Cierra sesiones que se quedaron abiertas más de 12 horas (Fase 13)
    @MainActor
    private static func cleanupGhostSessions(context: ModelContext) {
        let twelveHoursAgo = Date().addingTimeInterval(-12 * 3600)
        let descriptor = FetchDescriptor<Session>()
        
        do {
            let sessions = try context.fetch(descriptor)
            let ghostSessions = sessions.filter { $0.endTime == nil && $0.startTime < twelveHoursAgo }
            
            for session in ghostSessions {
                session.endTime = session.startTime.addingTimeInterval(3600)
                print("🧹 Sesión fantasma cerrada automáticamente: \(session.startTime)")
            }
            try? context.save()
        } catch {
            print("❌ Error al limpiar sesiones fantasma: \(error)")
        }
    }
}
