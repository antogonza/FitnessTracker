import SwiftUI
import SwiftData

// Extensión para proporcionar contenedores de SwiftData de forma sencilla para la App y Previews
extension ModelContainer {
    
    // Contenedor principal de producción con CloudKit
    static var shared: ModelContainer = {
        let schema = Schema([
            Routine.self,
            Exercise.self,
            Session.self,
            WorkoutSet.self
        ])
        
        // Habilitamos CloudKit asignando un identificador.
        // TODO: Asegurarse de que el identificador coincide con el configurado en iCloud Capabilities.
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.tudominio.FitnessTracker")
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("No se pudo crear el ModelContainer de producción: \(error)")
        }
    }()
    
    // Contenedor para Previews (en memoria con datos de prueba)
    static var preview: ModelContainer = {
        let schema = Schema([
            Routine.self,
            Exercise.self,
            Session.self,
            WorkoutSet.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Generar Mock Data
            Task { @MainActor in
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
            }
            
            return container
        } catch {
            fatalError("No se pudo crear el ModelContainer para previews: \(error)")
        }
    }()
}
