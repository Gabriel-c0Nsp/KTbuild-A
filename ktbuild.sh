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

emulator_path=""
look_android_emulator() {
  echo -e "\n${yellow}Looking for virtual devices (AVDs)...${reset}\n"

  emulator_path=$(find ~ 2>/dev/null | grep "Android/Sdk/emulator/emulator$")
}

device_not_found() {
  while true; do
    echo -e -n "\nDo you want to start an emulator? (Y/n) "
    read choice

    if [[ $choice == "y" || $choice == "Y" || $choice == "" ]]; then
      look_android_emulator

      if [[ -z "$emulator_path" ]]; then
        echo -e "${red}ERROR: no AVDS found!${reset}"
        echo -e "consider installing the Android SDK and creating an AVD."
        exit
      fi

      local avds=($($emulator_path -list-avds | tail -n +2))
      local avds_count=${#avds[@]}

      if [[ "$avds_count" -eq "0" ]]; then
        echo -e "${red}No devices found.${reset}"
      elif [[ "$avds_count" -eq "1" ]]; then
        echo -e "${yellow}Starting the emulator...${reset}\n"
        $emulator_path -avd ${avds[0]} &
      else
        echo -e "${yellow}Multiple device emulators found. Select one:${reset}"

        while true; do
          for i in "${!avds[@]}"; do
            echo "($((i + 1))) ${avds[$i]}"
          done

          echo -e "\n(q) Quit"
          echo -n "--> "
          read choice

          # checks if the input is a number
          if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -le "$avds_count" ]; then
              echo -e "${yellow}Starting the emulator...${reset}"
              $emulator_path -avd ${avds[$((choice - 1))]} &
              break
            fi
          fi

          if [[ $choice == "q" || $choice == "Q" || $choice == "exit" || $choice == "Exit" ]]; then
            exit
          fi

          clear
          echo -e "${red}Invalid selection. Try again.${reset}\n"
          echo -e "${yellow}Multiple emulators found. Select one:${reset}"
        done
      fi

      break
    elif [[ $choice == "n" || $choice == "N" ]]; then
      exit
    else
      clear
      echo -e "${red}Invalid input. Try again${reset}\n"
    fi
  done
}

# check if there's more than one device and ask which one the user wants
get_device_choice() {
  valid_device_choice=false

  local devices=($(adb devices | grep -w "device" | cut -f1))
  local device_count=${#devices[@]}

  if [ "$device_count" -eq "0" ]; then
    echo -e "${red}No devices found.${reset}"
    
    device_not_found
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

      echo -e "\n(q) Quit"
      echo -n "--> "
      read choice

      # checks if the input is a number
      if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [ "$choice" -le "$device_count" ]; then
          selected_device=${devices[$((choice - 1))]}
          valid_device_choice=true
          break
        fi
      fi

      if [[ $choice == "q" || $choice == "Q" || $choice == "exit" || $choice == "Exit" ]]; then
        exit
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
  echo -e "\nBuilding the APK..."
  ./gradlew assembleDebug

  echo "Installing the APK on the device..."
  adb -s $selected_device install -r app/build/outputs/apk/debug/app-debug.apk

  echo "Starting the main activity..."
  adb -s $selected_device shell am start -n $app_id/.MainActivity
}

# display status messages if everything goes well
display_ok_messages() {
  echo -e "\n${green}App successfully built${reset}"

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
