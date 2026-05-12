import SwiftUI
import SwiftData

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
            WeeklySchedule.self
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
            WeeklySchedule.self
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
            
            try? container.mainContext.save()
            
            return container
        } catch {
            fatalError("No se pudo crear el ModelContainer para previews: \(error)")
        }
    }()
    
    /// Cierra sesiones que se quedaron abiertas más de 12 horas (Fase 13)
    @MainActor
    private static func cleanupGhostSessions(context: ModelContext) {
        let twelveHoursAgo = Date().addingTimeInterval(-12 * 3600)
        
        // Usamos un FetchDescriptor simple
        var descriptor = FetchDescriptor<Session>()
        // Nota: Las predicates complejas a veces fallan en SwiftData, 
        // así que filtramos manualmente si es necesario, o usamos una sencilla.
        
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
