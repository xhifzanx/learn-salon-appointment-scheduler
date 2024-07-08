#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e '\n~~~~~ MY SALON ~~~~~\n'
SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e 'Welcome to My Salon, how can I help you?\n'
  fi
  ALL_SERVICES=$($PSQL "SELECT * FROM services;")
  if [[ -z $ALL_SERVICES ]]
  then
    echo 'No Services'
  else
    echo "$ALL_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      SERVICES "I could not find that service. What would you like today?"
    else
      CUSTOMER_INFO
      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")
      if [[ -z $SERVICE_ID ]]
      then
        SERVICES "I could not find that service. What would you like today?"
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
        echo -e "What time would you like your cut, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
        read SERVICE_TIME
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")
        if [[ $INSERT_APPOINTMENT = "INSERT 0 1" ]]
        then
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID;")
          echo "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        fi
      fi
    fi
  fi
}

CUSTOMER_INFO() {
  echo -e "What's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_Id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  fi
}



SERVICES