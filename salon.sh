#! /bin/bash

# Define the psql command with username, dbname, and tuples-only option
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Main menu function
MAIN_MENU() {
  if [[ -z $1 ]]; then
    echo -e "\nWelcome to My Salon, how can I help you?"
  else
    echo -e "\n$1"
  fi

  # Display available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while IFS='|' read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Prompt for service ID
  echo -e "\nPlease enter the number of the service you want:"
  read SERVICE_ID_SELECTED

  # Check if the service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  # Prompt for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" > /dev/null
  fi

  # Get customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Prompt for service time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Insert appointment
  $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" > /dev/null

  # Confirm the appointment
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//')
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU
