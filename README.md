# Juego Gato en flutter

El proyecto es una app para jugar gato creada en Flutter que consta de 3 pantallas principales, inicio, selección de ficha y tablero. 
Al incio el jugador debe presionar el botón de "Iniciar" para pasar a seleccionar la ficha con la cual jugara contra la propia app posteriormente en el tablero. 
El objetivo del juego es colocar tres fichas iguales seguidas. Las combinaciones ganadoras pueden ser:

- Horizontales: cualquiera de las tres filas.
- Verticales: cualquiera de las tres columnas.
- Diagonales:
  - Esquina superior izquierda a esquina inferior derecha.
  - Esquina superior derecha a esquina inferior izquierda.

Cuando se detecta un ganador, aparece un mensaje indicando la ficha ganadora, por ejemplo: "Ganador X", y se dibuja una línea blanca sobre la trayectoria ganadora. 
En caso de que nadie gane aparece en el tablero el mensaje de "Empate" y se vuelve a reiniciar hasta que haya un ganador. 

Siempre va a iniciar el jugador con la ficha seleccionada y posteriormente la app intentara bloquear la jugada con la ficha contraria. 

Para la creación de esta app se utilizo principalmente la libreria base de flutter import 'package:flutter/material.dart'; y CustomPainter para dibujar las fichas de X y O, las líneas del tablero y la línea blanca que marca la jugada ganadora, sin necesidad de imagenes adicionales. 


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
