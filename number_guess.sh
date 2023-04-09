#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
RANDOM_NUMBER=$(($RANDOM % 1000 + 1))
read USERNAME
USER=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
if [[ -z $USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username)VALUES('$USERNAME')")
  USER=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
else
  echo $USER | while IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_RECORD
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_RECORD guesses."
  done
fi
echo "Guess the secret number between 1 and 1000:"
GUESSES_COUNT=0
GUESS=0
TAKE_GUESS(){
  while [[ $GUESS -ne $RANDOM_NUMBER ]]
  do
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      GUESSES_COUNT=$(($GUESSES_COUNT + 1))
      if [[ $GUESS -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        TAKE_GUESS
      elif [[ $GUESS -lt $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
        TAKE_GUESS
      fi
    fi
  done
}
TAKE_GUESS
echo "You guessed it in $GUESSES_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
# update games_played and best_record if it's necessary
echo $USER | while IFS="|" read USER_ID USERNAME GAMES_PLAYED BEST_RECORD
do
  UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED + 1)) WHERE username = '$USERNAME'")
  if [[ $BEST_RECORD -eq 0 || $GUESSES_COUNT -lt $BEST_RECORD ]]
  then
    UPDATE_BEST_RECORD_RESULT=$($PSQL "UPDATE users SET best_record = $GUESSES_COUNT where username='$USERNAME'")
  fi
done
