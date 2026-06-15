# Fase 4 — Integración con RAWG: explicación detallada

Esta fase introduce **5 capas nuevas** que trabajan juntas para integrar una API REST externa con búsqueda en tiempo real.

---

## Índice

1. [Arquitectura general](#arquitectura-general)
2. [Capa 1 — DTOs (`RAWGModels.swift`)](#capa-1--dtos-rawgmodelsswift)
3. [Capa 2 — API Key (`RAWGConfig.swift`)](#capa-2--api-key-rawgconfigswift)
4. [Capa 3 — Service (`RAWGService.swift`)](#capa-3--service-rawgserviceswift)
5. [Capa 4 — Mapper (`RAWGMapper.swift`)](#capa-4--mapper-rawgmapperswift)
6. [Capa 5 — ViewModel (`GameSearchViewModel.swift`)](#capa-5--viewmodel-gamesearchviewmodelswift)
7. [Capa 6 — View (`GameSearchView.swift`)](#capa-6--view-gamesearchviewswift)
8. [Wiring en ContentView](#wiring-en-contentview)
9. [Conceptos nuevos](#conceptos-nuevos)
10. [Las 3 cosas a recordar siempre](#las-3-cosas-a-recordar-siempre)

---

## Arquitectura general

Lo que has construido sigue el principio de **separación de responsabilidades**. Cada capa tiene un trabajo, y solo conoce a sus vecinas inmediatas.

```
┌─────────────────────────────────────────────────────┐
│  GameSearchView (UI)                                │
│  - Pinta resultados, barra de búsqueda, estados     │
│  - NO conoce: HTTP, JSON, RAWG                      │
└──────────────────────┬──────────────────────────────┘
                       │ lee/escribe
                       ▼
┌─────────────────────────────────────────────────────┐
│  GameSearchViewModel (lógica de presentación)       │
│  - Gestiona query, results, isLoading, errorMessage │
│  - Llama al Service                                 │
│  - NO conoce: SwiftUI, vistas                       │
└──────────────────────┬──────────────────────────────┘
                       │ pide datos
                       ▼
┌─────────────────────────────────────────────────────┐
│  RAWGService (capa HTTP)                            │
│  - Construye URL, hace request, valida, decodifica  │
│  - Devuelve DTOs                                    │
│  - NO conoce: UI, ViewModel, Game (dominio)         │
└──────────────────────┬──────────────────────────────┘
                       │ devuelve
                       ▼
┌─────────────────────────────────────────────────────┐
│  RAWGGame, RAWGSearchResponse (DTOs)                │
│  - Espejo EXACTO del JSON de RAWG                   │
│  - Inmutables                                       │
└──────────────────────┬──────────────────────────────┘
                       │ se convierte con toGame()
                       ▼
┌─────────────────────────────────────────────────────┐
│  Game (modelo de dominio)                           │
│  - TU modelo, persistido con SwiftData              │
└─────────────────────────────────────────────────────┘
```

**La regla de oro**: cada flecha va en una sola dirección. La UI no llama directamente a la API. Los DTOs no saben nada de UI. Si mañana cambias RAWG por IGDB, **solo tocas dos archivos** (Service y DTOs).

---

## Capa 1 — DTOs (`RAWGModels.swift`)

### ¿Qué es un DTO?

**Data Transfer Object**. Un struct que **espejea exactamente** el formato JSON que llega por la red.

### ¿Por qué un DTO y no usar `Game` directamente?

Si tu `Game` decodificara JSON de RAWG, **tu modelo de dominio dependería del formato de un tercero**. Cualquier cambio en RAWG rompería tu app entera. Y por ejemplo:

- RAWG llama `name` a lo que tú llamas `title`.
- RAWG da un **array** de plataformas; tú quieres **una**.
- RAWG no tiene `status` ni `notes` (eso es tuyo).

Por eso: **DTO = forma del wire**, **Game = forma de tu dominio**.

### Las decisiones técnicas

```swift
struct RAWGGame: Decodable, Identifiable {
    let id: Int
    let slug: String
    let name: String
    let released: String?           // fecha como String porque RAWG manda "2017-02-24"
    let backgroundImage: URL?       // URL? por seguridad: puede venir nulo
    let rating: Double
    let platforms: [RAWGPlatformWrapper]?
    
    enum CodingKeys: String, CodingKey {
        case id, slug, name, released
        case backgroundImage = "background_image"   // mapping snake_case → camelCase
        case rating, platforms
    }
}
```

### Conceptos clave

- **`Decodable` (no `Codable`)**: solo necesitamos leer JSON, no serializar.
- **`Identifiable`**: para iterarlo con `ForEach` sin tener que poner `id: \.id`. El `id: Int` de RAWG ya nos sirve.
- **`CodingKeys`**: el mecanismo de Swift para renombrar campos al decodificar. La clave del JSON va a la derecha (en string), la propiedad Swift a la izquierda.
- **Opcionales generosos (`?`)**: en redes, **todo puede faltar**. Solo `id` y `name` están "seguros".
- **`URL?` en vez de `String?`**: Swift convierte automáticamente strings JSON a URL al decodificar. Más type-safe.

### El wrapper feo de plataformas

RAWG manda `"platforms": [{ "platform": { ... } }]` — un array de objetos con UNA SOLA key. Por eso:

```swift
struct RAWGPlatformWrapper: Decodable {
    let platform: RAWGPlatform
}
```

**No lo "limpies"**. El DTO debe espejear el JSON exacto. La lógica de aplanar va al **mapper**, no aquí.

---

## Capa 2 — API Key (`RAWGConfig.swift`)

### El problema

Si pones la key directamente en código y haces `git push`, **la regalas al mundo**. Es uno de los errores más comunes en GitHub (bots escanean repos buscando keys filtradas).

### La solución

```swift
enum RAWGConfig {
    static let apiKey = "TU_KEY_AQUI"
    static let baseURL = URL(string: "https://api.rawg.io/api")!
}
```

Y el archivo va al **`.gitignore`** — nunca sube al repo.

### Conceptos clave

- **`enum` sin casos = namespace estático**. No instanciable, perfecto para utilidades static. Más limpio que `struct` con un init privado.
- **`URL(string:)!`** con force-unwrap — aquí está justificado: si la URL hardcodeada es inválida, queremos crash en desarrollo, no propagar un error opcional.
- **`RAWGConfig.swift.example`**: copia plantilla que SÍ se commitea. Otros pueden clonar el repo, copiar a `.swift`, y rellenar su key.

---

## Capa 3 — Service (`RAWGService.swift`)

### La responsabilidad

**Solo HTTP**: construir URL → hacer request → validar → decodificar. Nada más. No conoce `Game`, no conoce vistas.

### Anatomía

```swift
struct RAWGService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
}
```

### Conceptos clave

#### 1. Dependency Injection con defaults

- Los parámetros `session` y `decoder` tienen defaults razonables.
- Para uso normal: `RAWGService()`.
- Para tests: `RAWGService(session: mockSession)` → puedes inyectar una sesión falsa que devuelve respuestas predeterminadas.

#### 2. `URLComponents` para construir URLs

```swift
guard var components = URLComponents(
    url: RAWGConfig.baseURL.appendingPathComponent("games"),
    resolvingAgainstBaseURL: false
) else { throw RAWGError.invalidURL }

components.queryItems = [
    URLQueryItem(name: "key", value: RAWGConfig.apiKey),
    URLQueryItem(name: "search", value: query),
    URLQueryItem(name: "page_size", value: String(pageSize))
]
```

**Nunca** concatenes strings para URLs. `URLComponents` **codifica automáticamente** caracteres especiales: `"Pokemon: Sword"` → se transforma a `Pokemon%3A%20Sword`. Si concatenaras strings, el `:` y los espacios romperían la URL.

#### 3. `URLSession.data(from:)` con async/await

```swift
let (data, response) = try await session.data(from: url)
```

**Una sola línea**:

- `try` porque puede lanzar `URLError` (sin red, dominio inválido, etc.).
- `await` porque suspende hasta que llegue la respuesta.
- Devuelve una tupla `(Data, URLResponse)`.

Antes de `async/await`, esto eran completion handlers con callbacks anidados. Ahora es lineal y legible.

#### 4. Cast a `HTTPURLResponse` para acceder al status code

```swift
guard let httpResponse = response as? HTTPURLResponse else {
    throw RAWGError.invalidResponse
}
guard (200..<300).contains(httpResponse.statusCode) else {
    throw RAWGError.httpError(statusCode: httpResponse.statusCode)
}
```

`URLResponse` es la clase base. Para acceder a `.statusCode` necesitas castearla a su subclase HTTP. El rango `200..<300` es el "éxito" estándar.

#### 5. `enum RAWGError: LocalizedError`

```swift
enum RAWGError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(underlying: Error)
    
    var errorDescription: String? { ... }
}
```

**`LocalizedError`** te da `error.localizedDescription` automáticamente. Es lo que SwiftUI muestra cuando enseñas errores. Sin esto, sale solo el nombre del case (feo).

**`decodingFailed(underlying: Error)`** envuelve el error original de decode. Así, si el JSON cambia, ves el error real (no solo "Decoding failed").

---

## Capa 4 — Mapper (`RAWGMapper.swift`)

### La responsabilidad

Convertir un DTO de RAWG en un `Game` de tu dominio. Una traducción.

### Anatomía

```swift
extension RAWGGame {
    func toGame() -> Game {
        Game(
            rawgID: self.id,
            title: self.name,
            platform: inferredPlatform,
            status: .backlog,
            coverArtURL: self.backgroundImage
        )
    }
    
    private var inferredPlatform: Platform {
        guard let platforms else { return .pc }
        for wrapper in platforms {
            switch wrapper.platform.slug {
            case "playstation5":         return .ps5
            // ...
            default:                     continue
            }
        }
        return .pc
    }
}
```

### Conceptos clave

#### 1. `extension` para añadir comportamiento

- Añades una función a `RAWGGame` sin modificar la declaración original.
- Mantiene el DTO "limpio" (solo Decodable + propiedades) y la lógica de mapeo en su propio archivo.

#### 2. Defaults sensatos para campos que no existen en RAWG

- `status: .backlog` → RAWG no sabe si lo has jugado.
- `rating` no se pasa (deja default `nil`) → tu rating es **del usuario**, no de la comunidad.
- `hoursPlayed` no se pasa (default `0`).

#### 3. Inferencia inteligente de plataforma

- RAWG manda un array. Tú quieres uno solo.
- Iteramos y devolvemos el **primer match conocido**.
- Si nada coincide → `.pc` como fallback razonable.

---

## Capa 5 — ViewModel (`GameSearchViewModel.swift`)

### La responsabilidad

**Lógica de presentación**: estado de la UI (query, results, loading, error), orquestar llamadas al service, manejar errores. **NO** sabe nada de SwiftUI.

### Anatomía

```swift
@MainActor
@Observable
final class GameSearchViewModel {
    var query: String = ""
    var results: [RAWGGame] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let service: RAWGService
    
    init(service: RAWGService? = nil) {
        self.service = service ?? RAWGService()
    }
    
    func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            errorMessage = nil
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            results = try await service.searchGames(query: query, pageSize: 20)
        } catch {
            results = []
            errorMessage = error.localizedDescription
        }
    }
}
```

### Conceptos clave

#### 1. `@MainActor @Observable final class`

- **`@MainActor`** → todo este código corre en hilo principal. Necesario porque cambia state que la UI lee.
- **`@Observable`** (macro de iOS 17+) → SwiftUI redibuja automáticamente cuando cambia cualquier propiedad. Sustituye al viejo `ObservableObject + @Published`.
- **`final`** → no se hereda. Mejor performance + intención clara.

> Reconocerás este patrón de MusicPlayer.

#### 2. `init` con default opcional + nil-coalescing

```swift
init(service: RAWGService? = nil) {
    self.service = service ?? RAWGService()
}
```

¿Por qué este zigzag en vez de `init(service: RAWGService = RAWGService())`?  
Porque en Swift 6 con `@MainActor`, los **default arguments se evalúan en el contexto del caller**. Si el caller no es `@MainActor`, salta warning. Mover la creación al cuerpo del init evita el problema. Patrón Apple-style.

#### 3. `defer { isLoading = false }`

`defer` ejecuta el bloque **cuando la función termina, pase lo que pase** (return, throw, fin normal). Garantiza que el spinner se apaga incluso si lanzamos error. Sin `defer`, tendrías que escribir `isLoading = false` antes de cada `return`.

#### 4. El error NO sube

`search()` es `async` pero **no es `throws`**. El VM **absorbe** el error y lo expone como `errorMessage: String?`. La vista no maneja `try` — solo lee el mensaje y lo pinta. Más simple para la vista.

---

## Capa 6 — View (`GameSearchView.swift`)

### La responsabilidad

**Solo pintar**. Toma estado del VM, llama a sus métodos al cambiar la query, presenta resultados visualmente.

### Conceptos clave

#### 1. `@State` para `@Observable` class

```swift
@State private var vm = GameSearchViewModel()
```

Con `@Observable` (macOS 14+), se usa `@State`, no `@StateObject` (que era el viejo patrón para `ObservableObject`).

#### 2. `.searchable` — barra de búsqueda nativa

```swift
.searchable(text: $vm.query, prompt: "Buscar en RAWG...")
```

- Bindea a `$vm.query` → escribir actualiza el VM directamente.
- En iOS sale en la nav bar al hacer scroll.
- En macOS sale en el toolbar.
- **Cero código de UI** para la barra.

#### 3. `.task(id:)` — el truco del debounce

```swift
.task(id: vm.query) {
    try? await Task.sleep(for: .milliseconds(400))
    guard !Task.isCancelled else { return }
    await vm.search()
}
```

**El concepto más potente de la fase**:

- `.task(id: vm.query)` crea una Task que se ejecuta al aparecer la vista Y cada vez que cambia `vm.query`.
- Cuando `vm.query` cambia, SwiftUI **cancela** la Task anterior y crea una nueva.
- Si la Task está en `Task.sleep(...)` cuando es cancelada, el sleep se interrumpe.
- Resultado: el usuario escribe "H" → "Ho" → "Hol" → "Holl" → "Hollow Knight" → solo se dispara la búsqueda 400ms **después** de la última pulsación.
- **Debounce gratis en 4 líneas**. Sin Combine, sin timers, sin Cancellable.

#### 4. `.overlay` — estados sobrepuestos

```swift
.overlay {
    if vm.isLoading {
        ProgressView()
    } else if let msg = vm.errorMessage {
        ContentUnavailableView(msg, systemImage: "exclamationmark.triangle")
    } else if vm.query.isEmpty {
        ContentUnavailableView("Busca un juego", systemImage: "magnifyingglass")
    } else if vm.results.isEmpty {
        ContentUnavailableView.search
    }
}
```

`.overlay` pinta encima del contenido. Si `vm.results` tiene cosas, ninguna condición matchea y el overlay no pinta nada (queda transparente). Perfecto para empty/error/loading states sin condicionales feos en el body principal.

**`ContentUnavailableView.search`** es un preset nativo de Apple ya configurado para "no search results".

#### 5. Importar al tocar = `insert` + `dismiss`

```swift
Button {
    modelContext.insert(rawgGame.toGame())
    dismiss()
}
```

Toca → DTO se mapea a Game con `toGame()` → SwiftData lo persiste → la sheet se cierra → el nuevo juego aparece en la lista de ContentView (gracias a `@Query` reactivo).

---

## Wiring en ContentView

Tu `ContentView` ahora tiene **3 sheets**:

1. `isShowingForm` → form manual
2. `gameBeingEdited` → form en modo editar
3. `isShowingSearch` → search en RAWG

Y un `Menu` en el toolbar con dos opciones que activan cada `isShowing...`.

---

## Conceptos nuevos

| Concepto | Dónde lo usaste |
|---|---|
| **DTO pattern** | RAWGModels |
| **`Decodable` + `CodingKeys`** | RAWGModels |
| **`URLComponents` + `URLQueryItem`** | RAWGService |
| **`URLSession.data(from:)` async** | RAWGService |
| **`HTTPURLResponse` cast** | RAWGService |
| **`LocalizedError`** | RAWGError |
| **`async` sin `throws` (VM absorbe error)** | GameSearchViewModel |
| **`defer` para cleanup** | GameSearchViewModel.search |
| **`Optional + ??`** para default args en `@MainActor` | GameSearchViewModel.init |
| **`.searchable`** | GameSearchView |
| **`.task(id:)` + `Task.sleep` = debounce** | GameSearchView |
| **`ContentUnavailableView.search`** | GameSearchView |
| **`Menu` en toolbar** | ContentView |
| **`.sheet(isPresented:)` + `.sheet(item:)` coexistiendo** | ContentView |
| **Gestión de secrets con `.gitignore` + `.example`** | RAWGConfig |

---

## Las 3 cosas a recordar siempre

1. **DTOs ≠ modelos de dominio**. Espejea el JSON con un DTO, traduce al dominio con un mapper. Esa separación te da resiliencia.

2. **`.task(id: query) + sleep` = debounce gratis**. Es el patrón moderno SwiftUI. Olvídate de timers y Combine.

3. **El VM absorbe los errores y los expone como `errorMessage`**. La vista no maneja `try/catch`, solo pinta lo que el VM le diga.
