#!/bin/bash

# List of ICS-related keywords
keywords=("modbus" "scada" "siemens" "bacnet")

echo "Starting ICS device search..."
echo "Keywords: ${keywords[@]}"

# Read URLs from urls.txt and loop through them
while read url; do
  echo "Scanning URL: $url"

  # Fetch the contents of the URL and search for ICS-related keywords in the HTML code
  for keyword in "${keywords[@]}"; do
    echo "Searching for keyword: $keyword"
    if curl -s "$url" | grep -qi "$keyword"; then
      echo "Keyword found: $keyword"

      # Extract the domain name from the URL and run nmap with the script for Modbus
      domain=$(echo "$url" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
      echo "Scanning $domain for $keyword..."

      # Run nmap in the background and wait for 10 seconds
      nmap -sV --script "$keyword"-* -p502 "$domain" &
      sleep 10

      # Kill the nmap process after 10 seconds
      kill $(jobs -p)

      echo "Stopped searching for keyword: $keyword"
    fi
  done

done < urls.txt

echo "ICS device search complete."
