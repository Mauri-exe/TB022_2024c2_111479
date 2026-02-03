#!/bin/bash

# Verifico si en la terminal se paso los 2 argumentos de manera correcta
if [ "$#" -ne 2 ]; then
    echo "No le pasaste los 2 argumentos correctamente o te falta agregar más argumentos"
    exit 1
fi

padron="$1"
directorio_resultados="$2"

# Si el directorio pasado no existe, lo creo
if [ ! -d "$directorio_resultados" ]; then
    mkdir -p "$directorio_resultados"
fi

archivo_resultado="$directorio_resultados/resultado.txt"

# Sobrescribo el archivo de resultados, con nada, así lo reinicio. Y de paso lo creo
> "$archivo_resultado"

tipo_pokemon_seleccionado=$(( (padron % 18) + 1 ))
estadistica_total_minima=$(( (padron % 100) + 350 ))

# Ubicar los archivos CSV (cualquiera sea su subdirectorio)
archivo_pokemon_stats=( **/pokemon_stats.csv )
archivo_pokemon_types=( **/pokemon_types.csv )
archivo_pokemon=( **/pokemon.csv )

#Creo un diccionario (varios arrays dentro de otro array) para las estadísticas totales
total_stats=()

# Leer el archivo pokemon_stats.csv y sumar las estadísticas por cada pokemon_id
while IFS=',' read -r pokemon_id stat_id base_stat effort; do
    #Verifico si las variables de esa columna, ya se declararon como un número
    if [[ "$base_stat" =~ ^[0-9]+$ ]]; then
        total_stats["$pokemon_id"]=$(( ${total_stats["$pokemon_id"]} + base_stat ))
    fi
done < "$archivo_pokemon_stats"

# Creo una lista de pokemones que superen la estádistica minima. 
pokemones_filtrados=()
for pokemon_id in "${!total_stats[@]}"; do
    if [ "${total_stats["$pokemon_id"]}" -ge "$estadistica_total_minima" ]; then
        pokemones_filtrados+=("$pokemon_id")
    fi
done

# Creo una lista de pokemones que cumplen el criterio de tipo
pokemones_finales=()
while IFS=',' read -r pokemon_id type_id slot; do
    # Verifico que type_id sea numérico
    if [[ "$type_id" =~ ^[0-9]+$ ]]; then
        if [ "$type_id" -eq "$tipo_pokemon_seleccionado" ] && [[ "${pokemones_filtrados[@]}" =~ "$pokemon_id" ]]; then 
            #Ahi obtengo los id finales       
            pokemones_finales+=("$pokemon_id")
        fi
    fi
done < "$archivo_pokemon_types"

# Y por último busco los nombres de los pokemones con su id correspondiente y los escribo en resultado.txt
while IFS=',' read -r pokemon_id identifier species_id height weight base_experience order is_default; do
    if [[ "${pokemones_finales[@]}" =~ "$pokemon_id" ]]; then
        echo "$identifier" >> "$archivo_resultado"
    fi
done < "$archivo_pokemon"
