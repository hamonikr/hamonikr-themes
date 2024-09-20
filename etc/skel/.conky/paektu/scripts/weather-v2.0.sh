#!/bin/bash

# This script is to get weather data from openweathermap.com in the form of a json file
# so that conky will still display the weather when offline even though it doesn't up to date

# Variables
# get your city id at https://openweathermap.org/find and replace
# Seoul
city_id=1835848

# replace with yours
api_key=18f1953946715102959bd39b2f7a0cfc

# choose between metric for Celcius or imperial for fahrenheit
unit=metric

# i'm not sure it will support all languange, 
#lang=kr
lang=en

# http://api.openweathermap.org/geo/1.0/direct?q=Seoul,kr&limit=5&appid=18f1953946715102959bd39b2f7a0cfc
# Seoul
# lat 37.5666791
# lon 126.9782914

# Main command
url="api.openweathermap.org/data/2.5/weather?id=${city_id}&appid=${api_key}&cnt=5&units=${unit}&lang=${lang}"
curl ${url} -s -o ~/.cache/weather.json

exit
