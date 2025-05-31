# 🍫 App Flutter - Detección de Vainas Abortadas

Esta aplicación móvil desarrollada en **Flutter** permite detectar vainas abortadas en imágenes de mazorcas de cacao usando un modelo YOLOv8 desplegado en la nube con **FastAPI**.

## 📱 Características

- 📷 Permite seleccionar una imagen desde la galería o tomar una foto
- 🔍 Envía la imagen a una API de detección de objetos basada en YOLOv8
- 🌱 Muestra el número de vainas abortadas detectadas
- 🖼 Visualiza la imagen con los resultados dibujados
- 📜 Guarda un historial de análisis realizados
- 🧹 Posibilidad de limpiar resultados o eliminar entradas del historial

---

## 🧰 Tecnologías

- Flutter (Dart)
- [image_picker](https://pub.dev/packages/image_picker)
- [http](https://pub.dev/packages/http)
- FastAPI (backend, ver repositorio [despliegue_modelo](https://github.com/camilodelgado23/despliegue_modelo))

---

## 🚀 Requisitos previos

- Tener instalado **Flutter** y **Android Studio**
- Dispositivo físico o emulador para probar la app
- Acceso a la API ya desplegada (`https://despliegue-modelo-vx85.onrender.com/predict`)

---

## 🛠 Instalación y ejecución

1. Clona este repositorio:

```bash
git clone https://github.com/camilodelgado23/deteccion_de_vainas_abortadas_app.git
cd deteccion_de_vainas_abortadas_app
