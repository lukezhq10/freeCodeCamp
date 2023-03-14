#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# if no argument is given
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# check the argument, give me the element
if [[ $1 ]]
then
  # if argument is atomic number
  if [[ $1 =~ ^[1-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT properties.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties JOIN elements ON properties.atomic_number = elements.atomic_number JOIN types ON properties.type_id = types.type_id WHERE properties.atomic_number = '$1'")
  else
  # if argument is string
    ELEMENT=$($PSQL "SELECT properties.atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties JOIN elements ON properties.atomic_number = elements.atomic_number JOIN types ON properties.type_id = types.type_id WHERE name = '$1' OR symbol = '$1'")
  fi
  # if element not in database
  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
    exit
  fi
fi

# return the element in formatted sentence
echo $ELEMENT | while IFS="|" read ATOMIC_NUM NAME SYMBOL TYPE MASS MELT_POINT BOIL_POINT
do
  echo "The element with atomic number $ATOMIC_NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
done
