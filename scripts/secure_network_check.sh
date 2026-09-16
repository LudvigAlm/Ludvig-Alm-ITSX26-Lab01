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

adress=$(hostname -i) # Använder "hostname -i" istället för att använda "ip addr". "ip addr" ger flera adresser och är mer komplext
route=$(ip route)

echo "IP Address: $adress" # Skriver ut den lokalas IP-adress

sleep 2

echo "Din Route: $route" # Skriver ut den lokala routen

sleep 2

okdoman="example.com" # Sätt domänen som ska kontrolleras

echo "kontrollerar DNS för: $okdoman" # Skriver ut domänen som kontrolleras

sleep 2

if getent ahosts "$okdoman" > /dev/null 2>&1; then  # Kontrollera DNS-uppslag
    echo "DNS-uppslag [OK] $okdoman." # Skriver ut ett meddelande om att DNS-uppslag lyckades
    successful_checks=$((successful_checks + 1))
else
    echo "DNS-uppslag [FAIL] $okdoman." # Skriver ut ett meddelande om att DNS-uppslag misslyckades
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

sleep 2

if getent hosts "$lokalvard" > /dev/null 2>&1; then
    echo "Lokalhost [OK]." # Skriver ut ett meddelande om att localhost fungerar
    successful_checks=$((successful_checks + 1))
else
    echo "Lokalhost [FAIL]." # Skriver ut ett meddelande om att
    failed_checks=$((failed_checks + 1))
fi

sleep 2

echo "Kontrollerar lokal testport: $testport" # Skriver ut den lokala testporten som kontrolleras

sleep 2

if timeout 2 bash -c ":</dev/tcp/$lokalvard/$testport" > /dev/null 2>&1; then # Kontrollera om porten är öppen
    echo "Tjänsten på port $testport [IS AVAILABLE]." # Skriver ut ett meddelande om att tjänsten på porten är öppen
    successful_checks=$((successful_checks + 1))
else
    echo "Tjänsten på port $testport [IS NOT AVAILABLE]." # Skriver ut ett meddelande om att tjänsten på porten inte är tillgänglig
    failed_checks=$((failed_checks + 1))
fi # Avslutar "if"-satsen

if [[ "$server_pid" != "$$" && "$server_pid" != "$BASHPID" ]]; then
    kill "$server_pid" 2>/dev/null # Avslutar den lokala testtjänsten
fi

sleep 2

echo ""
echo "Sammanfattning: $successful_checks kontroller [SUCCESS], $failed_checks kontroller [FAIL]." # Skriver ut en sammanfattning av antalet lyckade och misslyckade kontroller
echo "Datum och tid för loggen: $date" # Skriver ut datum och tid för loggen
echo "Logg sparad i: $log_file" # Skriver ut sökvägen till loggfilen

sleep 1

echo ""

echo "Väntar på öppna portar..."
sleep 2
echo "..."
sleep 1
echo "*.."
sleep 1
echo "**."
sleep 1
echo "***"
sleep 1

echo "Öppna portar-->" # Skriver ut rubriken för öppna portar
if command -v ss > /dev/null 2>&1; then # Kontrollera om kommandot ss finns i miljön
    ss -tuln || echo "Kunde inte läsa listan över öppna portar." # Skriver ut ett meddelande om att listan över öppna portar inte kunde läsas
else
    echo "Kommandot ss finns inte i miljön." # Skriver ut ett meddelande om att kommandot ss inte finns i miljön
fi
