# ARKit Beat Mask

ARKit Beat Mask es una app de realidad aumentada para iOS que detecta tu rostro, coloca una máscara 3D sobre él y añade efectos visuales reactivos al sonido ambiente:

- Máscara 3D sobre el rostro usando ARKit
- Efecto de humo sutil saliendo de la máscara
- Círculos expansivos sincronizados con los beats de la música ambiente (usando el micrófono)
- La máscara "pulsa" al ritmo de la música

## Requisitos
- Xcode 15 o superior
- iOS 17 o superior
- Dispositivo con FaceID (soporte ARKit Face Tracking)

## Instalación
1. Clona este repositorio:
   ```sh
   git clone <URL_DEL_REPO>
   ```
2. Abre `ArKit.xcodeproj` en Xcode.
3. Conecta un dispositivo físico (no funciona en simulador).
4. Compila y ejecuta la app.

## Uso
- Permite el acceso a la cámara y al micrófono.
- Coloca tu rostro frente a la cámara frontal.
- Reproduce música o haz sonidos rítmicos: la máscara y los efectos reaccionarán a los beats detectados.

## Créditos
- Desarrollado por Isaías Chávez Martínez y colaboradores.
- Basado en ARKit, SceneKit y Accelerate.

## Licencia
MIT. Ver [LICENSE](LICENSE). 