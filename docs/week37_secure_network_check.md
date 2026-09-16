<!-- START DEL A -->

-Jag arbetar i en WSL1 miljö. WSL:s skillnader mot en OCI är att WSL nyttjar en virtuell NAT-adapter som Windows hanterar, 
till skillnad från en ren moln-VM i OCI med dedikerad vNIC/säkerhetslista.

-Jag slår först in "ip addr" i min terminal för att kontrollera min nätverksinterface och sedan "ip route". 
Vilket Ger mig bland annat min IP-adress, interface och default gateway.

-Jag ser min lokala IP-adress som skiljer sig från mitt privata som tillhör datorn och sen sklijer sig från routerns publika adress som används för att skicka och ta emot information via nätverket.

-Sedan vill jag installera och kontrollera tcpdump med "tcpdump --version"

-För att starta en begränsad nätverksfångst slår jag in i terminalen "sudo tcpdump -i eth0 -c 100 -w network-investigation.pcap".
"-c 100" gör att jag automatiskt avslutar efter 100 paket.

-Under tiden som tscpdump körs, kör jag i ett nytt terminalfönster "ping -c 2 google.com" 

-Jag testade även köra "curl https://google.com". Efter detta så har min tcpdump nått sina 100 paket och avbröts. Jag startar med nya 100 paket och skriver in kommandot igen. Jag ser "content-type" och då att content="text/html;charset=utf-8">. Svaret skriver även något med 301 moved och att dokumentet har flyttats.

-Jag ska läsa från min pcap fil med "tcpdump -r network-investigation.pcap -n -x". Det som kommer upp är förskräckligt mycket text som jag inte förstår.

<!-- END DEL A -->

<!-- START DEL B -->

(Interface och IP)
-Om jag slår in "ip addr" ser jag under "lo" 3 olika adresser på inet, inet global och inet6. Under "eth0" ser jag även inet fast med två olika IP-adresser än vad som visades under "lo". Det finns även en inet6 med en 64 scope link.

(Routing)
-Med "ip route" får jag upp standard via 172.23.48.1 dev eth0.

(DNS)
-Med "getent hosts" så får jag upp 3 alternativ med den första och tredje är 127.0.0.1 ip. När jag slår in "nslookup" så får jag en omvänd ip och sedan "name = localhost".

(Portar och tjänster)
-Med "ss -tuln" så ser jag protokollet TCP att bara lokala porten 53 som lyssnar. Ingen av dem är exponerad mot det externa internetet.

(Lokal tjänst)
-Jag lyckas inte använda "curl" mot min lokala host. Jag får upp antingen (8080:port Failed to connect) eller (Failed to connect to 127.0.0.1 port 80 after 0 ms: Could not connect to server)

(Process eller systemstatus)
-Med "ps" så ser jag endast de processer som hör till den nuvarande terminalen. Men om jag istället kör "ps aux" så kan jag se alla processer i hela systemet.

<!-- END DEL B -->

<!-- START DEL D -->

(Normalfall 1)
DNS-Uppslaget fungerar med en tydlig markering [OK].

(Normalfall 2)
Efter att programmet startar en lokal testport på 8080, visar programmet tydligt med [IS AVAILABLE].
Den skriver ut porten som nu blir 8080.

(Felfall 1)
Jag tar bort domänen som ska testas och programmet kraschar inte men visar tydligt statusen med [FAIL].

(Felfall 2)
Om jag ändrar port 8080 till 80 och kör programmet så visar det port 80 [IS NOT AVAILABLE] och sammanfattningen som visas i loggen visar att 2 kontroller lyckades och en misslyckades.

<!-- END DEL D -->