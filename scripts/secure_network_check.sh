#!/bin/bash

set -o pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) # Hämta den absoluta sökvägen till skriptets katalog
log_dir="$script_dir/../logs" # Sätt loggkatalogen till en katalog som heter "logs" i föräldrakatalogen till skriptets katalog
log_file="$log_dir/secure_network_check.log" # Sätt loggfilen till en fil som heter "secure_network_check.log" i loggkatalogen
mkdir -p "$log_dir" # Skapa loggkatalogen om den inte redan finns

exec > >(tee "$log_file") 2>&1

successful_checks=0 # Variabel för att hålla reda på antalet lyckade kontroller
failed_checks=0 # Variabel för att hålla reda på antalet misslyckade kontroller
date=$(date '+%Y-%m-%d %H:%M:%S') # Hämta det aktuella datumet och tiden för en timestamp på loggen

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
    successful_checks=$((successful_checks + 1))
else
    echo "DNS-uppslag misslyckades för $okdoman." # Skriver ut ett meddelande om att DNS-uppslag misslyckades
    failed_checks=$((failed_checks + 1))
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
    successful_checks=$((successful_checks + 1))
else
    echo "Lokalhost fungerar inte." # Skriver ut ett meddelande om att
    failed_checks=$((failed_checks + 1))
fi

sleep 2

echo "Kontrollerar lokal testport: $testport" # Skriver ut den lokala testporten som kontrolleras

if timeout 2 bash -c ":</dev/tcp/$lokalvard/$testport" > /dev/null 2>&1; then # Kontrollera om porten är öppen
    echo "Tjänsten på port $testport är öppen." # Skriver ut ett meddelande om att tjänsten på porten är öppen
    successful_checks=$((successful_checks + 1))
else
    echo "Tjänsten på port $testport är inte tillgänlig." # Skriver ut ett meddelande om att tjänsten på porten inte är tillgänglig
    failed_checks=$((failed_checks + 1))
fi # Avslutar "if"-satsen

if [[ "$server_pid" != "$$" && "$server_pid" != "$BASHPID" ]]; then
    kill "$server_pid" 2>/dev/null # Avslutar den lokala testtjänsten
fi

sleep 2

echo ""
echo "Sammanfattning: $successful_checks kontroller lyckades, $failed_checks kontroller misslyckades."
echo "Datum och tid för loggen: $date"
echo "Logg sparad i: $log_file"

echo "Öppna portar-->" # Skriver ut rubriken för öppna portar
if command -v ss > /dev/null 2>&1; then
    ss -tuln || echo "Kunde inte läsa listan över öppna portar."
else
    echo "Kommandot ss finns inte i miljön."
fi
