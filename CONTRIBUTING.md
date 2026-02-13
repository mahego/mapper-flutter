# Guía de Contribución

¡Gracias por tu interés en contribuir a Mapper! 

## 🚀 Cómo Empezar

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Realiza tus cambios siguiendo las guías de estilo
4. Haz commit de tus cambios (`git commit -m 'Add some AmazingFeature'`)
5. Push a la rama (`git push origin feature/AmazingFeature`)
6. Abre un Pull Request

## 📝 Guías de Estilo

### Dart/Flutter

- Sigue las [Effective Dart guidelines](https://dart.dev/guides/language/effective-dart)
- Usa `flutter format` antes de hacer commit
- Ejecuta `flutter analyze` para verificar el código
- Todos los tests deben pasar: `flutter test`

### Estructura de Código

```dart
// ✅ Correcto
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Hello');
  }
}

// ❌ Incorrecto
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Hello");
  }
}
```

### Commits

- Usa mensajes descriptivos en español
- Formato: `tipo: descripción breve`
- Tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Ejemplos:
```
feat: agregar pantalla de login
fix: corregir error en navegación
docs: actualizar README
```

## 🏗️ Arquitectura

El proyecto sigue una arquitectura limpia por features:

- **core/**: Funcionalidades compartidas
  - `constants/`: Constantes globales
  - `router/`: Configuración de navegación
  - `theme/`: Temas y estilos
  - `utils/`: Utilidades

- **features/**: Módulos por funcionalidad
  - `[feature]/presentation/`: UI y lógica de presentación
  - `[feature]/domain/`: Lógica de negocio
  - `[feature]/data/`: Acceso a datos

- **shared/**: Componentes reutilizables

## ✅ Checklist de PR

- [ ] El código sigue las guías de estilo
- [ ] Los tests pasan correctamente
- [ ] Se agregaron tests para la nueva funcionalidad
- [ ] La documentación fue actualizada si es necesario
- [ ] No hay warnings de `flutter analyze`
- [ ] El código está formateado con `flutter format`

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ver coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📞 Contacto

Si tienes preguntas, no dudes en abrir un issue.
