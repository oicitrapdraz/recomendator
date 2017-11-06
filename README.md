# Sistema Recomendador usando la API de Google Places

## Endpoints

* **POST /get_location**

 Endpoint para obtener varios detalles de algun lugar en especifico, se reciben parametros JSON con el formato de ejemplo:

```
{
	"location": {
		"address": "UTFSM"		
	}
}
```

**Parametros**:

1. address puede ser tanto una direccion como "San Guillermo 294, Valparaiso" como un string que caracterice un lugar, ejemplo "Universidad Federico Santa Maria"

* **POST /get_locations**

  Endpoint para retornar varios lugares dependiendo del lugar en el que uno se encuentra y tipos de lugares que uno busca (ordenados por rating o distancia), se reciben parametros JSON con el formato de ejemplo:

```
{
	"data": {
		"address": "UTFSM,Valparaiso",
		"location": "-33.04092169999999, -71.59291159999999",
		"type": "university",
		"recommend": "rating",
		"radius": 2500
	}
}
 ```

**Parametros**:

1. address puede ser tanto una direccion como "San Guillermo 294, Valparaiso" como un string que caracterice un lugar, ejemplo "Universidad Federico Santa Maria"
1. location son las coordenadas (latitud y longitud) del lugar
1. type sirve para definir que tipos de lugares nos interesa, se acepta "point_of_interest", "university", etc, para ver mas tipos visitar [este link](https://developers.google.com/places/supported_types?hl=es-419)
1. recommend es el criterio de recomendacion y puede ser "rating" o "distance" (con rating la respuesta es una lista de lugares ordenados por rating, mientras que con distance la respuesta es una lista de lugares ordenados por distancia)
1. radius (solo aplicable cuando el criterio de recomendacion es rating) es el radio considerado para realizar la consulta (la unidad usada es metro)

**Nota**: address y location son opcionales en el sentido de que si se omite address se debe poner location y vice versa, pero si o si uno de los dos debe de existir como parametro, en caso de poner ambos se le dara prioridad a address.

* **POST /get_recommendation**

  Endpoint para retornar varios lugares dependiendo del lugar en el que uno se encuentra y de las preferencias del usuario (ordenados por rating), se reciben parametros JSON con el formato de ejemplo:

```
{
	"data": {
                "android_id": "5fg8",
		"address": "UTFSM,Valparaiso",
		"location": "-33.04092169999999, -71.59291159999999",
		"radius": 2500
	}
}
 ```

**Parametros**:

1. android_id sera el id del dispositivo android
1. address puede ser tanto una direccion como "San Guillermo 294, Valparaiso" como un string que caracterice un lugar, ejemplo "Universidad Federico Santa Maria"
1. location son las coordenadas (latitud y longitud) del lugar
1. radius (solo aplicable cuando el criterio de recomendacion es rating) es el radio considerado para realizar la consulta (la unidad usada es metro)

**Nota**: address y location son opcionales en el sentido de que si se omite address se debe poner location y vice versa, pero si o si uno de los dos debe de existir como parametro, en caso de poner ambos se le dara prioridad a address.
