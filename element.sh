#!/bin/bash

# Database connection
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # Check if input is a number (atomic_number)
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT elements.atomic_number, name, symbol, type, atomic_mass, 
                    melting_point_celsius, boiling_point_celsius 
                    FROM elements 
                    INNER JOIN properties ON elements.atomic_number = properties.atomic_number 
                    INNER JOIN types ON properties.type_id = types.type_id 
                    WHERE elements.atomic_number = $1")
  else
    # Check if input is a symbol or name
    ELEMENT=$($PSQL "SELECT elements.atomic_number, name, symbol, type, atomic_mass, 
                    melting_point_celsius, boiling_point_celsius 
                    FROM elements 
                    INNER JOIN properties ON elements.atomic_number = properties.atomic_number 
                    INNER JOIN types ON properties.type_id = types.type_id 
                    WHERE symbol = '$1' OR name = '$1'")
  fi

  # If element not found
  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    # Parse the data
    echo "$ELEMENT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING_POINT BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi
