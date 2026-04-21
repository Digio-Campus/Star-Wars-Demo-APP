Directorio con la app iOS

## Vimeo (iOS)

1. Crea el archivo local **no versionado**:
   `iOS/Star-Wars-Demo-APP/Config.xcconfig`

   Contenido:
   ```xcconfig
   VIMEO_ACCESS_TOKEN = <your_token>
   ```

2. Compilar en Mac (sin firmar):
   ```bash
   cd iOS/Star-Wars-Demo-APP
   xcodebuild -scheme Star-Wars-Demo-APP -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' clean build CODE_SIGNING_ALLOWED=NO
   ```

> Nota: la app lee el token desde Info.plist (generado) con la clave `VIMEO_ACCESS_TOKEN`.
