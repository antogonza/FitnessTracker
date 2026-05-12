import Foundation

// MARK: - Ejercicio del catálogo

struct CatalogExercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: ExerciseCategory
    let muscleGroup: String // Grupo muscular principal (para subtítulo)
}

// MARK: - Catálogo completo

struct ExerciseCatalog {

    static let all: [CatalogExercise] = push + pull + legs + core + other

    // MARK: Empuje (Push)
    static let push: [CatalogExercise] = [
        CatalogExercise(name: "Press Banca", category: .push, muscleGroup: "Pectoral"),
        CatalogExercise(name: "Press Banca Inclinado", category: .push, muscleGroup: "Pectoral superior"),
        CatalogExercise(name: "Press Banca Declinado", category: .push, muscleGroup: "Pectoral inferior"),
        CatalogExercise(name: "Press Banca con Mancuernas", category: .push, muscleGroup: "Pectoral"),
        CatalogExercise(name: "Press Inclinado con Mancuernas", category: .push, muscleGroup: "Pectoral superior"),
        CatalogExercise(name: "Aperturas con Mancuernas", category: .push, muscleGroup: "Pectoral"),
        CatalogExercise(name: "Aperturas en Polea", category: .push, muscleGroup: "Pectoral"),
        CatalogExercise(name: "Fondos en Paralelas", category: .push, muscleGroup: "Pectoral / Tríceps"),
        CatalogExercise(name: "Flexiones", category: .push, muscleGroup: "Pectoral"),
        CatalogExercise(name: "Flexiones Diamante", category: .push, muscleGroup: "Tríceps"),
        CatalogExercise(name: "Press Militar con Barra", category: .push, muscleGroup: "Hombro"),
        CatalogExercise(name: "Press Militar con Mancuernas", category: .push, muscleGroup: "Hombro"),
        CatalogExercise(name: "Press Arnold", category: .push, muscleGroup: "Hombro"),
        CatalogExercise(name: "Elevaciones Laterales", category: .push, muscleGroup: "Hombro lateral"),
        CatalogExercise(name: "Elevaciones Frontales", category: .push, muscleGroup: "Hombro frontal"),
        CatalogExercise(name: "Elevaciones en W", category: .push, muscleGroup: "Hombro posterior"),
        CatalogExercise(name: "Press de Hombro en Máquina", category: .push, muscleGroup: "Hombro"),
        CatalogExercise(name: "Fondos Tríceps en Banco", category: .push, muscleGroup: "Tríceps"),
        CatalogExercise(name: "Extensión Tríceps con Polea", category: .push, muscleGroup: "Tríceps"),
        CatalogExercise(name: "Extensión Tríceps sobre la Cabeza", category: .push, muscleGroup: "Tríceps"),
        CatalogExercise(name: "Press Francés", category: .push, muscleGroup: "Tríceps"),
        CatalogExercise(name: "Patada de Tríceps", category: .push, muscleGroup: "Tríceps"),
        CatalogExercise(name: "Push-Up en TRX", category: .push, muscleGroup: "Pectoral"),
        CatalogExercise(name: "Crossover en Polea Alta", category: .push, muscleGroup: "Pectoral"),
        CatalogExercise(name: "Crossover en Polea Baja", category: .push, muscleGroup: "Pectoral inferior"),
    ]

    // MARK: Tirón (Pull)
    static let pull: [CatalogExercise] = [
        CatalogExercise(name: "Dominadas", category: .pull, muscleGroup: "Espalda / Bíceps"),
        CatalogExercise(name: "Dominadas con Agarre Supino", category: .pull, muscleGroup: "Bíceps / Espalda"),
        CatalogExercise(name: "Remo con Barra", category: .pull, muscleGroup: "Espalda"),
        CatalogExercise(name: "Remo con Mancuerna", category: .pull, muscleGroup: "Dorsal"),
        CatalogExercise(name: "Remo en Polea Baja", category: .pull, muscleGroup: "Espalda media"),
        CatalogExercise(name: "Remo en Máquina", category: .pull, muscleGroup: "Espalda"),
        CatalogExercise(name: "Jalón al Pecho", category: .pull, muscleGroup: "Dorsal"),
        CatalogExercise(name: "Jalón con Agarre Neutro", category: .pull, muscleGroup: "Dorsal"),
        CatalogExercise(name: "Jalón con Agarre Supino", category: .pull, muscleGroup: "Bíceps / Dorsal"),
        CatalogExercise(name: "Pullover con Mancuerna", category: .pull, muscleGroup: "Dorsal / Serrato"),
        CatalogExercise(name: "Pullover en Polea", category: .pull, muscleGroup: "Dorsal"),
        CatalogExercise(name: "Face Pull", category: .pull, muscleGroup: "Hombro posterior / Trapecio"),
        CatalogExercise(name: "Remo al Cuello", category: .pull, muscleGroup: "Trapecio / Hombros"),
        CatalogExercise(name: "Encogimientos con Barra", category: .pull, muscleGroup: "Trapecio"),
        CatalogExercise(name: "Encogimientos con Mancuernas", category: .pull, muscleGroup: "Trapecio"),
        CatalogExercise(name: "Curl de Bíceps con Barra", category: .pull, muscleGroup: "Bíceps"),
        CatalogExercise(name: "Curl de Bíceps con Mancuernas", category: .pull, muscleGroup: "Bíceps"),
        CatalogExercise(name: "Curl Martillo", category: .pull, muscleGroup: "Bíceps / Braquial"),
        CatalogExercise(name: "Curl en Polea", category: .pull, muscleGroup: "Bíceps"),
        CatalogExercise(name: "Curl Concentrado", category: .pull, muscleGroup: "Bíceps"),
        CatalogExercise(name: "Curl en Banco Scott", category: .pull, muscleGroup: "Bíceps"),
        CatalogExercise(name: "Curl con Barra EZ", category: .pull, muscleGroup: "Bíceps"),
        CatalogExercise(name: "Remo TRX", category: .pull, muscleGroup: "Espalda"),
        CatalogExercise(name: "Peso Muerto Convencional", category: .pull, muscleGroup: "Espalda / Glúteo"),
        CatalogExercise(name: "Peso Muerto Rumano", category: .pull, muscleGroup: "Isquios / Glúteo"),
        CatalogExercise(name: "Buenos Días", category: .pull, muscleGroup: "Lumbar / Isquios"),
    ]

    // MARK: Pierna (Legs)
    static let legs: [CatalogExercise] = [
        CatalogExercise(name: "Sentadilla con Barra", category: .legs, muscleGroup: "Cuádriceps / Glúteo"),
        CatalogExercise(name: "Sentadilla Frontal", category: .legs, muscleGroup: "Cuádriceps"),
        CatalogExercise(name: "Sentadilla Goblet", category: .legs, muscleGroup: "Cuádriceps / Glúteo"),
        CatalogExercise(name: "Sentadilla con Mancuernas", category: .legs, muscleGroup: "Cuádriceps"),
        CatalogExercise(name: "Sentadilla Búlgara", category: .legs, muscleGroup: "Cuádriceps / Glúteo"),
        CatalogExercise(name: "Zancada con Barra", category: .legs, muscleGroup: "Cuádriceps / Glúteo"),
        CatalogExercise(name: "Zancada con Mancuernas", category: .legs, muscleGroup: "Cuádriceps / Glúteo"),
        CatalogExercise(name: "Zancada Caminando", category: .legs, muscleGroup: "Cuádriceps / Glúteo"),
        CatalogExercise(name: "Prensa de Piernas", category: .legs, muscleGroup: "Cuádriceps"),
        CatalogExercise(name: "Extensión de Cuádriceps", category: .legs, muscleGroup: "Cuádriceps"),
        CatalogExercise(name: "Curl Femoral Tumbado", category: .legs, muscleGroup: "Isquiotibiales"),
        CatalogExercise(name: "Curl Femoral Sentado", category: .legs, muscleGroup: "Isquiotibiales"),
        CatalogExercise(name: "Hip Thrust con Barra", category: .legs, muscleGroup: "Glúteo"),
        CatalogExercise(name: "Hip Thrust con Mancuerna", category: .legs, muscleGroup: "Glúteo"),
        CatalogExercise(name: "Patada de Glúteo en Polea", category: .legs, muscleGroup: "Glúteo"),
        CatalogExercise(name: "Abducción de Cadera", category: .legs, muscleGroup: "Glúteo medio"),
        CatalogExercise(name: "Aducción de Cadera", category: .legs, muscleGroup: "Aductor"),
        CatalogExercise(name: "Gemelo de Pie", category: .legs, muscleGroup: "Gemelos"),
        CatalogExercise(name: "Gemelo Sentado", category: .legs, muscleGroup: "Sóleo"),
        CatalogExercise(name: "Step-Up con Mancuernas", category: .legs, muscleGroup: "Cuádriceps / Glúteo"),
        CatalogExercise(name: "Peso Muerto con Piernas Rígidas", category: .legs, muscleGroup: "Isquios / Glúteo"),
        CatalogExercise(name: "Hack Squat", category: .legs, muscleGroup: "Cuádriceps"),
        CatalogExercise(name: "Sentadilla Sumo", category: .legs, muscleGroup: "Aductor / Glúteo"),
    ]

    // MARK: Core
    static let core: [CatalogExercise] = [
        CatalogExercise(name: "Plancha", category: .core, muscleGroup: "Core completo"),
        CatalogExercise(name: "Plancha Lateral", category: .core, muscleGroup: "Oblicuos"),
        CatalogExercise(name: "Crunch Abdominal", category: .core, muscleGroup: "Recto abdominal"),
        CatalogExercise(name: "Crunch en Polea", category: .core, muscleGroup: "Recto abdominal"),
        CatalogExercise(name: "Sit-Up", category: .core, muscleGroup: "Recto abdominal / Flexores"),
        CatalogExercise(name: "Elevación de Piernas Tumbado", category: .core, muscleGroup: "Recto abdominal inferior"),
        CatalogExercise(name: "Elevación de Piernas en Barra", category: .core, muscleGroup: "Recto abdominal inferior"),
        CatalogExercise(name: "Rodillo Abdominal", category: .core, muscleGroup: "Core completo"),
        CatalogExercise(name: "Rotación Rusa", category: .core, muscleGroup: "Oblicuos"),
        CatalogExercise(name: "Mountain Climbers", category: .core, muscleGroup: "Core / Cardio"),
        CatalogExercise(name: "Dead Bug", category: .core, muscleGroup: "Core estabilizador"),
        CatalogExercise(name: "Pallof Press", category: .core, muscleGroup: "Core antirotación"),
        CatalogExercise(name: "Dragon Flag", category: .core, muscleGroup: "Core completo"),
        CatalogExercise(name: "Hollow Hold", category: .core, muscleGroup: "Core"),
        CatalogExercise(name: "Extensión Lumbar", category: .core, muscleGroup: "Lumbar"),
        CatalogExercise(name: "Superman", category: .core, muscleGroup: "Lumbar"),
        CatalogExercise(name: "Birddog", category: .core, muscleGroup: "Lumbar / Core"),
    ]

    // MARK: Otro
    static let other: [CatalogExercise] = [
        CatalogExercise(name: "Burpee", category: .other, muscleGroup: "Cuerpo completo"),
        CatalogExercise(name: "Kettlebell Swing", category: .other, muscleGroup: "Cadena posterior"),
        CatalogExercise(name: "Clean & Press", category: .other, muscleGroup: "Cuerpo completo"),
        CatalogExercise(name: "Turkish Get-Up", category: .other, muscleGroup: "Cuerpo completo"),
        CatalogExercise(name: "Box Jump", category: .other, muscleGroup: "Cuádriceps / Potencia"),
        CatalogExercise(name: "Battle Ropes", category: .other, muscleGroup: "Hombros / Cardio"),
        CatalogExercise(name: "Farmer's Walk", category: .other, muscleGroup: "Agarre / Core"),
        CatalogExercise(name: "Sled Push", category: .other, muscleGroup: "Cuerpo completo"),
        CatalogExercise(name: "Tirón de Trineo", category: .other, muscleGroup: "Isquios / Glúteo"),
        CatalogExercise(name: "Salto a la Comba", category: .other, muscleGroup: "Cardio / Pantorrillas"),
    ]
}
