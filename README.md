# chess
PROYECTO FINAL THE ODIN PROJECT
AUTOR: ALEJANDRO CHAPARRO

Este es mi proyecto final del subcurso de Ruby en The Odin Project. 
Este se trata de un juego de ajedrez de consola, el cual se podra ejecutar en modo un jugador 
(contra una IA primitiva que realizara movimientos al azar) y tambien un modo dos jugadores donde
dos humanos podran enfrentarse. 

El proyecto ademas de toda la complejidad en sus funcionalidades tambien se podra guardar el estado de una partida
ya empezada si asi lo desea el jugador.

Estoy feliz de poder haberlo finalizado con exito desarrollandolo por mi cuenta, unicamente 
buscando en la documentacion y en foros de Ruby.

Le meti mucho esfuerzo espero que les guste!

26/02/26

notas de version 1.2: serializacion
le agregamos una variable de estado al modo de juego de board para que a la hora de cerrar o abrir el juego
podemos saber si es necesario la serializacion o deserealizacion.
agregamos variables globales de exit y sp_player.
agregamos el modulo serializer
modificamos do a play para que retorne exit y podamos parar y guardar la partida

