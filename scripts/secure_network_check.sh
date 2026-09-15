#!/bin/bash

adress=$(hostname -i)
route=$(ip route)

echo "IP Address: $adress" # Skriver ut den lokalas IP-adress

sleep 1

echo "Din Route: $route" # Skriver ut den lokala routen

sleep 2

okdoman="example.com"

echo "kontrollerar DNS för: $okdoman" # Skriver ut domänen som kontrolleras

if getent ahosts "$okdoman" > /dev/null 2>&1; then  # Kontrollera DNS-uppslag
    echo "DNS-uppslag lyckades för $okdoman." # Skriver ut ett meddelande om att DNS-uppslag lyckades
else
    echo "DNS-uppslag misslyckades för $okdoman." # Skriver ut ett meddelande om att DNS-uppslag misslyckades
fi # Avslutar "if"-satsen

sleep 2

lokalvard="localhost"
testport=8080

# Startar en lokal testtjänst på port 8080
python3 -m http.server "$testport" --bind 127.0.0.1 > /tmp/testserver.log 2>&1 &
server_pid=$!

sleep 2

echo "Kontrollerar lokal värd: $lokalvard" # Skriver ut den lokala värden som kontrolleras

if getent hosts "$lokalvard" > /dev/null 2>&1; then
    echo "Lokalhost fungerar." # Skriver ut ett meddelande om att localhost fungerar
else
    echo "Lokalhost fungerar inte." # Skriver ut ett meddelande om att
fi

sleep 2

echo "Kontrollerar lokal testport: $testport" # Skriver ut den lokala testporten som kontrolleras

if timeout 2 bash -c ":</dev/tcp/$lokalvard/$testport" > /dev/null 2>&1; then # Kontrollera om porten är öppen
    echo "Tjänsten på port $testport är öppen." # Skriver ut ett meddelande om att tjänsten på porten är öppen
else
    echo "Tjänsten på port $testport är inte tillgänlig." # Skriver ut ett meddelande om att tjänsten på porten inte är tillgänglig
fi # Avslutar "if"-satsen

kill "$server_pid" 2>/dev/null # Avslutar den lokala testtjänsten