# GameVault

Rastreador de biblioteca de videojuegos para macOS e iOS, al estilo de [Backloggd](https://backloggd.com/) o [HowLongToBeat](https://howlongtobeat.com/). Permite organizar tu colección, registrar el estado de cada juego (jugando, completado, abandonado, etc.), llevar horas jugadas y consultar información desde la API pública de RAWG.

Proyecto de aprendizaje centrado en SwiftUI moderno, SwiftData y consumo de APIs REST.

## Stack

- **Lenguaje**: Swift 5.9+
- **UI**: SwiftUI (multiplataforma macOS + iOS) con Liquid Glass
- **Arquitectura**: MVVM con `@Observable` y `@MainActor`
- **Concurrencia**: `async/await` (sin Combine)
- **Persistencia**: SwiftData (`@Model`, `@Query`, `modelContext`)
- **Networking**: `URLSession` + `JSONDecoder`
- **API externa**: [RAWG Video Games Database](https://rawg.io/apidocs)
- **Navegación**: `NavigationStack` con rutas tipadas
- **Imágenes**: `AsyncImage`
- **Gráficos**: Swift Charts
- **Tests**: Swift Testing

## Requisitos

- macOS 15+ / iOS 18+
- Xcode 16+
- Cuenta gratuita en [RAWG](https://rawg.io/apidocs) para la API key

## Roadmap

El proyecto se desarrolla por fases incrementales:

1. **Modelo y UI básica** — `struct Game` + lista con datos hardcodeados.
2. **Persistencia con SwiftData** — migración a `@Model class`, alta/edición/borrado.
3. **Formulario manual** — `Form`, `Picker`, `Stepper` para añadir y editar juegos.
4. **Integración con RAWG** — búsqueda y auto-completado de juegos vía API.
5. **Caché de portadas** — `AsyncImage` con caché en disco.
6. **Filtros y búsqueda** — por estado, plataforma, `.searchable`.
7. **Vista detalle** — `NavigationStack` con rutas tipadas.
8. **Estadísticas** — Swift Charts + polish visual con Liquid Glass.
9. **Tests** — cobertura del VM con Swift Testing e inyección de dependencias.

## Estructura del proyecto

```
GameVault/
├── GameVault/
│   ├── GameVaultApp.swift      // Entrada de la app
│   ├── ContentView.swift       // Vista raíz
│   ├── Models/
│   │   └── Game.swift          // Modelo + enums Platform/GameStatus
│   └── Assets.xcassets
└── README.md
```

## Cómo ejecutar

1. Clona el repositorio.
2. Abre `GameVault.xcodeproj` en Xcode.
3. En *Signing & Capabilities*, selecciona **Sign to Run Locally** (evita el límite de App IDs de cuentas gratuitas).
4. Selecciona un destino (My Mac o un simulador iOS) y pulsa Run.

## Licencia

MIT.
