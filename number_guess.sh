#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 + 1 ))
echo $NUMBER

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  GAMES_PLAYED=0
  MIN_GUESS=0
else
  GAMES_PLAYED=$($PSQL "SELECT games FROM users WHERE user_id=$USER_ID")
  MIN_GUESS=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $MIN_GUESS guesses."

fi

echo "Guess the secret number between 1 and 1000:"
read NUMBER_GUESS

while [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
do
    echo "That is not an integer, guess again:"
    read NUMBER_GUESS
done

GUESS_NUM=1
while [[ $NUMBER_GUESS != $NUMBER ]]
do
    if [[ $NUMBER_GUESS -gt $NUMBER ]]
    then
        echo "It's lower than that, guess again:"
    else
        echo "It's higher than that, guess again:"
    fi
    read NUMBER_GUESS
    GUESS_NUM=$(( $GUESS_NUM + 1 ))
done
GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))

INSERT_GAMES_RESULT=$($PSQL "UPDATE users SET games=$GAMES_PLAYED, best_game=$GUESS_NUM WHERE username='$USERNAME'")

echo "You guessed it in $GUESS_NUM tries. The secret number was $NUMBER. Nice job!"