#!/bin/bash 
# Number Guessing Game

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Resets the index to 1
#echo $($PSQL "TRUNCATE TABLE customers")
#echo $($PSQL "ALTER SEQUENCE customers_customer_id_seq RESTART WITH 1")

# generate a random variable with a 1 to 1000 range
NUMBER=$(( RANDOM%1000 +1)) 
#echo $NUMBER

MAIN() {
  echo "Enter your username:"
  read NAME
  # check if USER is in the database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE username='$NAME'")
  # greeting the player
  if [[ ! $CUSTOMER_ID ]]
  then 
    echo "Welcome, $NAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO customers(username) VALUES('$NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE username='$NAME'")
    GAMES_PLAYED=0
  else 
    USERNAME=$($PSQL "SELECT username FROM customers WHERE customer_id=$CUSTOMER_ID")
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM customers WHERE customer_id=$CUSTOMER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM customers WHERE customer_id=$CUSTOMER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  GUESS_GAME
}

# guessing the number
GUESS_GAME() {
  COUNT=0 # number of games in this round
  echo "Guess the secret number between 1 and 1000:"
  while [[ $NUMBER -ne $USER_GUESS ]]
  do 
    read USER_GUESS
    if [[ $USER_GUESS =~ ([^0-9]+)$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      if [[ $NUMBER -lt $USER_GUESS ]]
      then
        echo "It's lower than that, guess again:"
        ((COUNT++))
      elif [[ $NUMBER -gt $USER_GUESS ]]
      then
        echo "It's higher than that, guess again:"
        ((COUNT++))
      elif [[ $NUMBER -eq $USER_GUESS ]] 
      then
        ((COUNT++))
        ((GAMES_PLAYED++))
        echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"
        # check if best_game exists
        if [[ ! $BEST_GAME ]]
        then
          INSERT_BEST_GAME=$($PSQL "UPDATE customers SET best_game=$COUNT WHERE customer_id=$CUSTOMER_ID")
          INSERT_GAMES_PLAYED=$($PSQL "UPDATE customers SET games_played=$GAMES_PLAYED WHERE customer_id=$CUSTOMER_ID")
        elif [[ $COUNT -lt $BEST_GAME ]]
        then
          INSERT_BEST_GAME=$($PSQL "UPDATE customers SET best_game=$COUNT WHERE customer_id=$CUSTOMER_ID")
          INSERT_GAMES_PLAYED=$($PSQL "UPDATE customers SET games_played=$GAMES_PLAYED WHERE customer_id=$CUSTOMER_ID")
        else
          #INSERT_BEST_GAME=$($PSQL "UPDATE customers SET best_game=$COUNT WHERE customer_id=$CUSTOMER_ID")
          INSERT_GAMES_PLAYED=$($PSQL "UPDATE customers SET games_played=$GAMES_PLAYED WHERE customer_id=$CUSTOMER_ID") 
        fi
      fi
    fi
  done
}

MAIN