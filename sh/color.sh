#!/bin/sh

init_prompt()
{
    Red="$(tput setaf 1)"
    Green="$(tput setaf 2)"
    LightGreen="$(tput bold ; tput setaf 2)"
    Brown="$(tput setaf 3)"
    Yellow="$(tput bold ; tput setaf 3)"
    LightBlue="$(tput bold ; tput setaf 4)"
    NC="$(tput sgr0)" # No Color
}

init_prompt
