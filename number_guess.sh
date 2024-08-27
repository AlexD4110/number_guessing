#!/bin/bash

# Connect to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
#Display username
read USERNAME

# Check if the user exists in database (number_guess)
USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

# If user does not exist, add them to the database
if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
else
  echo "$USER_INFO" | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME; do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Generates a random number using this logic betweeen 1 and 1000 using + 1
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=0

#Displays userful information to user
echo "Guess the secret number between 1 and 1000:"

# Loop until the correct guess
# while guess is not equal to secret number while loop continues
while [[ $GUESS != $SECRET_NUMBER ]]; do
  read GUESS

  # Check if the input is a valid integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Increment the number of guesses
  (( GUESSES++ ))

  # Give hints
  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  fi
done

# When guessed correctly
echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update user stats
if [[ -z $USER_INFO ]]; then
  UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=1, best_game=$GUESSES WHERE username='$USERNAME'")
else
  CURRENT_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  if [[ $GUESSES -lt $CURRENT_BEST_GAME || $CURRENT_BEST_GAME == 0 ]]; then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE username='$USERNAME'")
  fi
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'")
fi
