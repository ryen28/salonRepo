#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to the Salon Appt Scheduler ~~~~~\n"

echo -e "\n~~~ Which service would you like to try? Select a service number ~~~\n"


MAIN_MENU(){
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$AVAILABLE_SERVICES" | while IFS=' |' read SERVICE_ID SERVICE
  do 
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  SERVICE_REQUEST=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")


  if [[  -z $SERVICE_REQUEST  ]]
  then
    echo -e "\nThat service does not exist, pick a valid service number"
    MAIN_MENU 
  fi
}

MAIN_MENU

echo -e "\nWhat is your phone number?\n"
read CUSTOMER_PHONE

PHONE_SEARCH=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[  -z $PHONE_SEARCH  ]]
then
  echo -e "\nThat phone number is not in the system. What is your name?"
  read CUSTOMER_NAME

  CUSTOMER_ENTRY=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
SERVICE_NAME_REQUESTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/^[[:space:]]*//')
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed 's/^[[:space:]]*//')

echo -e "\nWhat time would you like your $SERVICE_NAME_REQUESTED, $CUSTOMER_NAME?"
read SERVICE_TIME

APPT_ENTRY=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_NAME_REQUESTED at $SERVICE_TIME, $CUSTOMER_NAME."


