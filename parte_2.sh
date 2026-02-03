#!/bin/bash

# Variables
archivo_pokemon=$(find . -name 'pokemon.csv')
archivo_pokemon_abilities=$(find . -name 'pokemon_abilities.csv')
archivo_ability_names=$(find . -name 'ability_names.csv')

# Función para mostrar información del Pokémon
mostrar_informacion_pokemon() {
    local pokemon_nombre="$1"
    
    # Buscar id del Pokémon, altura y peso en pokemon.csv
    pokemon=$(grep -E "^([0-9]+),${pokemon_nombre}," "$archivo_pokemon")
    #-z = si el string es NULL
    if [[ -z "$pokemon" ]]; then
        echo "El Pokémon $pokemon no fue encontrado."
        return
    fi

    pokemon_id=$(echo "$pokemon" | cut -d ',' -f 1)
    altura=$(echo "$pokemon" | cut -d ',' -f 4)
    peso=$(echo "$pokemon" | cut -d ',' -f 5)

    # Convierto la altura y el peso a las unidades deseadas
    altura_en_cm=$((altura * 10))
    peso_en_kg=$((peso / 10))

    # Obtengo las habilidades del pokemon desde pokemon_abilities.csv
    habilidad_ids=$(grep "^$pokemon_id," "$archivo_pokemon_abilities" | cut -d ',' -f 2)
    
    # Obtengo los nombres de las habilidades en español (ubicado en la fila 7 de cada habilidad) desde ability_names.csv
    habilidades=""
    for habilidad_id in $habilidad_ids; do
        habilidad=$(grep "^$habilidad_id,7," "$archivo_ability_names" | cut -d ',' -f 3)
        habilidades+=$habilidad$'\n'
    done

    # Muestro la información del pokemon elegido
    echo "---------------------"
    echo "Pokemon: $pokemon_nombre"
    echo "Altura: $altura_en_cm centimetros"
    echo "Peso: $peso_en_kg kilos"
    echo ""
    echo "Habilidades:"
    echo "$habilidades"
    echo "---------------------"
}

# Leo los nombres del pokemon desde el stdin
while IFS= read -r pokemon_nombre; do
    #Si no esribo nada, el script se termina
    if [ -z "$pokemon_nombre" ]; then 
        exit 1 
    else
        mostrar_informacion_pokemon "$pokemon_nombre"
    fi 
done
