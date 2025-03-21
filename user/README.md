# RushGo - Aplicación de Usuario (Refactorizada)

Este directorio contiene la versión refactorizada de la aplicación de usuario de RushGo, siguiendo los principios de Clean Architecture.

## Estructura de Carpetas

La aplicación sigue una arquitectura de tres capas:

- **Presentation**: Contiene las pantallas, widgets y componentes de UI.
- **Domain**: Contiene las entidades de negocio, casos de uso e interfaces de repositorios.
- **Data**: Contiene las implementaciones de repositorios, modelos de datos y fuentes de datos.

## Implementación Gradual

La refactorización se está realizando de forma gradual siguiendo estos pasos:

1. Creación de la estructura de carpetas base ✅
2. Migración de los modelos de datos a la nueva estructura
3. Implementación de los repositorios y casos de uso
4. Refactorización de la UI para utilizar la nueva arquitectura
5. Migración de la gestión de estado a Riverpod con Notifiers

## Cómo Contribuir

Para contribuir a este proyecto, asegúrate de seguir las convenciones de código establecidas y mantener la coherencia con la arquitectura definida.