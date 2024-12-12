#!/bin/bash

current_path=$(pwd)

# Colors of the messages
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
reset='\e[0m'

# go to the root directory
go_to_root() {
  found=false

  # look for the root of the project
  while [[ $found == false ]]; do
    if [[ -f "settings.gradle.kts" ]]; then
      found=true
      break
    else 
      if [[ "$(pwd)" != "$HOME" ]]; then
        cd ..
      else 
        echo -e "${red}Kotlin project not found!${reset}"
        break
      fi 
    fi
  done
}

go_to_root

# get the name of the project
get_application_name() {
  local GRADLE_FILE="./app/build.gradle.kts"
  app_id=$(grep -oP 'applicationId\s*=\s*"\K[^"]+' "$GRADLE_FILE")
}

# check if there's more than one device and ask which one the user wants
get_device_choice() {
  valid_device_choice=false

  local devices=($(adb devices | grep -w "device" | cut -f1))
  local device_count=${#devices[@]}

  if [ "$device_count" -eq "0" ]; then
    echo -e "${red}No devices found.${reset}"
  elif [ "$device_count" -eq "1" ]; then
    selected_device=${devices[0]}
    device_exists=true
    valid_device_choice=true
  else
    echo -e "${yellow}Multiple devices found. Select one:${reset}"
    while true; do
      for i in "${!devices[@]}"; do
        echo "($((i + 1))) ${devices[$i]}"
      done
      echo
      echo "(q) Quit"
      echo -n "--> "
      read choice

      if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [ "$choice" -le "$device_count" ]; then
          selected_device=${devices[$((choice - 1))]}
          valid_device_choice=true
          break
        fi
      fi

      if [[ $choice == "q" || $choice == "Q" || $choice == "exit" || $choice == "Exit" ]]; then
        return
      fi

      clear
      echo -e "${red}Invalid selection. Try again.${reset}\n"

      echo -e "${yellow}Multiple devices found. Select one:${reset}"
    done
  fi

  if [ "$device_exists" == true ]; then
    echo -e "${green}Selected device: $selected_device${reset}"
  fi
}

# check the type of the device
check_device() {
  emulated_device=false

  if echo "$selected_device" | grep -q "emulator"; then
    emulated_device=true
  fi
}

build_app() {
  echo
  echo "Building the APK..."
  ./gradlew assembleDebug

  echo "Installing the APK on the device..."
  adb -s $selected_device install -r app/build/outputs/apk/debug/app-debug.apk

  echo "Starting the main activity..."
  adb -s $selected_device shell am start -n $app_id/.MainActivity
}

# display status messages if everything goes well
display_ok_messages() {
  echo
  echo -e "${green}App successfully built${reset}"
  if echo "$selected_device" | grep -q "emulator"; then
    emulated_device=true
    echo -e "${yellow}You can see the updated app on your emulated device${reset}"
  else
    echo -e "${yellow}You can see the updated app on your physical device${reset}"
  fi
}

# check if the script has everything it needs to run
if [ "$found" == true ]; then
  get_application_name
  get_device_choice
  check_device
  if [ "$valid_device_choice" == true ]; then
    build_app
    display_ok_messages
  fi
fi

# go back to the original file the user was before
cd $current_path
