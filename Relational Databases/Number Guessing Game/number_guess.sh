#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU() {
  #take username as input
  echo "Enter your username:"
  read USERNAME

  #get username from database
  USERNAME_DB=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

  #queries for user stats
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")

  # if user not in database
  if [[ -z $USERNAME_DB ]]
  then
    #insert user to database
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  GAME
}


GAME() {
  #randomly generate a number
  NUM=$(( $RANDOM % 1000 + 1))

  #read user input
  echo "Guess the secret number between 1 and 1000:"

  #track num guesses
  TRIES=0

  #track if guessed or not
  GUESSED=0

  while [[ $GUESSED -eq 0 ]];
  do
    read GUESS
    # if not integer
    if [[ ! $GUESS =~ ^[0-9]+$ ]];
    then
      echo "That is not an integer, guess again:"

    # if correct guess
    elif [[ $GUESS -eq $NUM ]];
    then
      TRIES=$(($TRIES + 1))
      echo "You guessed it in $TRIES tries. The secret number was $NUM. Nice job!"
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
      GAMES_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES('$USER_ID','$TRIES')")
      GUESSED=1
      
    #if guess > num  
    elif [[ $GUESS -gt $NUM ]];
    then
      TRIES=$(($TRIES + 1))
      echo "It's lower than that, guess again:"
    
    #if guess < num
    else
      TRIES=$(($TRIES + 1))
      echo "It's higher than that, guess again:"
    fi
  done
  
}

MAIN_MENU
