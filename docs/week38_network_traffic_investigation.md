[WEEK 38 Network Traffic Investigation]

<!-- Start DEL B -->
Den lokala datorns näteverksinterface har en MAC-adress 34:2c:**:**:**:7a (Visar inte hela)
Wireshark visar även att den kommunicerar med en ASUS-enhet med MAC-adressen. ASUS-adressen måste bero på att jag har ett ASUS moderkort i datorn i detta fallet.
Pcap filen visar även Ipv6-adressen.
Jag obsaverade även att namnet på interfacet, exempelvis WI-Fi eller Ethernet, framgår inte i paketet.

Paketet ärn en DNS och datorn frågade efter www.google.com
DNS-servern svar utan fel med (Reply code: No error).
DNS-frågan är av typen HTTPS, vilket innebär att datorn frågar efter information om HTTPS-tjänsten för www.google.com.

I just detta paket så kan inte default route och gateway inte fastställas, paketet visar vilken DNS-server som skickar svaret, men inte vilken default gateway datorn använder.

Adresserna i paketet är IPv6 global unicast-adresser
2a00:1598:....
De är alltså inte privata IPv6.adresser som exempelvis fc00::/7.
I det här paketet används därför puplikt routingsbara IPv6-adresser.

NAT/PAT används normalt för att översätta privata IPv4-adresser till en publik IPv4-adress och ofta skilja anslutningar åt med portnummer.
I den här trafiken finns inget tydligt bevis på NAT/PAT, eftersom kommunikationen använder IPv6 och båda adresserna är globalt routingsbara.

En brandvägg kan fatta beslut när paketet passerar den, exempelvis baserat på
-Källadress
-Destinationsadress
-Protokoll
-Port
-Anslutningens rikting
I detta fall skulle brandväggen exempelvis kunna kontrollera UDP-trafik från DNS-serverns port 53 till klientens port 55567 och avgöra om svaret ska tillåtas.

Transportprotokollet är UDP och källporten är 53 medans destinationsporten är 55567

Applikationsprotokollet är en DNS och DNS används här för att slå upp information om www.google.com
<!-- End DEL B -->

<!-- Del C ligger i docx-filen week38_del_c.docx -->

<!-- Start DEL D -->
Jag väljer en TCP från min pcap-fil och finner först [Stream Packet Number: 4].
Jag kollar även på källa och destination och då är källan CompalBroadb_86:1b:7a medans destinationen är ASUSTekCOMPU_34:e0:61 etc.
En källa port syns med port 443 och även en destinations port 56937.
TCP visar en händelseordning först med SYN-SYN/ACK-ACK-Data-FIN och slutar på RST
Datorns förvantande beteende visar att källan skickar till destiantionen och får bekräftat tillbaka med ACK.
Jag kan tydligt se dom tre olika paketen SYN, SYN-ACK och ACK för en faktisk obsevation.
Jag hittade en rödmarkerad TCP där ACK sekvensen har flaggats som en dubblett.


I en TLS visas [Stream Packet Number: 61].
Källan och destinationen är det samma som i TCP.
Porternas källa och destination stämmer även också som på TCP.
TLS händelseordning går också SYN,SYN-ACK,ACK etc...
Inom TLS rapporten förväntas att ACK ska skickas tillbaka med svar och får även bekräftat svar tillbaka med ACK.
I TLS finner jag en blåmarkerad avvikelse TLSv1.3 Record Layer som är krypterad data. Den säger även att TLS 1.2 och att den (Legacy_version) måste ignoreras.
<!-- End DEL D -->

<!--Start DEL E -->
(Synlig metadata)
-HTTP
I en HTTP-fångst kan man exempelvis se klientens och serverns IP.adresser, TCP-port 80, HTTP-metoden (GET), vilken resurs som kan efterfrågas och HTTP-headers. Själva kommunikationen skickas i klartext.

-TLS/HTTPS
I en HTTPS-fångst kan man se klientens och serverns IP-adresser, TCP-port 443 samt TLS-handshake och viss metadata. Däremot är själva HTTP-kommunikationen, exempelvis (GET), URL-sökväg, headers och innehållet, krypterat och kan inte läsas direkt i paketfångsten.

(Läsbar applikationsdata)
-HTTP
Applikationsdatan är läsbar i klartext. Man kan exemeplvis se HTTP-metoder som (GET), URL-sökvägar, headers och innehållet som skickas mellan klient och server.

-TLS/HTTPS
Applikatiopnsdatan är inte läsbar i en vanlig paketfångst eftersom den krypteras av TLS. Man kan se TLS-handshake och viss metadata men inte det faktiska HTTP-innehållet, exempelvis webbsidans data eller (GET)-förfrågan.

(Felsökningsvärde)
-HTTP
Man kan se nästan hela kommunikationen i klartext. Det gör det möjligt att felsöka exempelvis HTTP-förfrågningar, statuskoder, headers, URL:er och vilket innehåll som skickas.

-TLS/HTTPS
Man kan fortfarande analysera IP-adresser, portar, TCP-anslutningen, TLS-version, handskakningen och annan TLS-metadata. Däremot kan själva HTTP-innehållet inte läsas utan tillgång till rätt dekrypteringsnycklar.

(Konfidentialitetsrisk)
-HTTP
Eftersom HTTP skickar information okrypterat kan en angripare som kan avlyssna trafiken se exempelvis:
*URL:er och sökvägar
*HTTP-förfrågningar och svar
*Användarnamn och lösenord om de skickas
*Cookies och sessionsinformation
*Meddelanden och annan information som skickas
*Själva innehållet på webbsidan

-TLS/HTTPS
HTTPS krypterar själva applikationsdatan, men viss information är fortfarande synlig, exempelvis:
*Klientens och serverns IP-adresser
*Portnummer, normalt TCP 443
*Att en TLS-anslutning används
*Viss information från TLS-handshaken
*Trafikens storlek och timing
*I vissa fall information om vilket domännamn klienten ansluter till
<!-- End DEL E -->

<!-- Start DEL F -->
1. Observerat flöde och berörd brandväggsregel
-Observerat flöde: I den analyserade nätverkstrafiken (PCAP) observeras ett initialt TCP SYN-paket skickat från klientens dynamiska port (t.ex. port 55604 eller 55606) mot serverns IP-adress 10.160.87.119 på port 80 (HTTP). Detta utgör det första steget i TCP-protokollets trevägshandskakning (Three-Way Handshake).

-Berörda brandväggsregler: För att denna trafik ska kunna passera och etablera en anslutning krävs följande konfigurationer i brandväggen:
-Inkommande regel
*Käll-IP: Tillåtna klientsegment (eller Any om tjänsten är publik)
*Destinations-IP: 10.160.87.119
*Protokoll: TCP
*Destinationsport: 80
*Åtgärd: ALLOW (Tillåt)

-Utgående Regel
*I en tillståndsbaserad brandvägg (Stateful Firewall) skapas en tillfällig regel automatiskt för returtrafiken (SYN-ACK) när det inkommande SYN-paketet godkänns. Returtrafiken tillåts genom den övergripande regeln som släpper igenom etablerad och relaterad trafik (ESTABLISHED, RELATED).
*Om en tillståndslös brandvägg (Stateless Firewall) används måste en explicit utgående regel konfigureras från källport 80/TCP mot klientens ephemeral-portområde.

2. Skillnaden mellan en lokal lyssnande tjänst och brandväggstillåten trafik
-Ett vanligt missförstånd inom nätverkssäkerhet är att likställa en lokal tjänst med att den automatiskt är tillgänglig utifrån. Ur ett härdningsperspektiv är det två helt olika lager i säkerhetskedjan:
-Lokal lyssnande tjänst (Local Listening Service):
*Innebär att en applikation eller process på operativsystemsnivå har öppnat och bundit en socket till ett nätverksgränssnitt (t.ex. 0.0.0.0:80 för alla gränssnitt eller 127.0.0.1:80 för endast loopback).
*Tjänsten är redo att ta emot anslutningar, men om nätverksfiltret blockerar trafiken når inga paket fram.

-Trafik tillåten av brandvägg (Firewall Permitted Traffic):
*Innebär att nätverks- eller hostbrandväggen har en regel som tillåter att paket med en specifik destinationsport passerar genom nätverkslagret.
*Om brandväggen tillåter port 80, men ingen tjänst lyssnar på porten, kommer inkommande SYN-paket antingen att tas emot utan svar eller resultera i ett TCP RST (Reset)-paket.

-Betydelse för hardening:
-För att uppnå en säker miljö krävs ett samspel i enlighet med principen om försvar i djupet (Defense in Depth):
1. Om en tjänst av misstag binder till alla gränssnitt (0.0.0.0) stoppar brandväggen obehöriga anslutningar från nätverket.
2. Om brandväggen av misstag öppnar en port finns inget applikationslager som svarar och kan utnyttjas så länge ingen lokal tjänst lyssnar.
3. Säker härdning innebär att endast nödvändiga tjänster körs lokalt OCH att endast nödvändiga portar är öppna i brandväggen.
   
3. Resonemang kring Default Deny och Minsta nödvändiga öppning
-Två av de mest fundamentala principerna inom nätverkssäkerhet är Default Deny och Least Privilege.
-Default Deny (Implicit Deny)
*Innebörd: Brandväggen konfigureras med en grundinställning där all trafik spärras som standard. Endast trafik som explicit matchar en tillåtande regel släpps igenom.
*Säkerhetsnytta: Detta eliminerar risken för att okända, glömda eller potentiellt skadliga protokoll och tjänster exponeras av misstag. Det tvingar administratören att ha full kontroll över vilken trafik som tillåts i nätverket.

-Minsta nödvändiga öppning (Least Privilege / Need-to-Know)
*Innebörd: När en brandväggsregel väl skapas ska den begränsas så mycket som möjligt gällande käll-IP, destinations-IP, protokoll och portar.
*Säkerhetsnytta: Genom att inte öppna hela portintervall eller breda IP-intervall begränsas angreppsytan (attack surface). Om en server i nätverket blir komprometterad förhindrar detta principen om lateral förflyttning (pivoting), då angriparen inte kan nå andra interna resurser på godtyckliga portar.

4. tvärdering och rimlighetsanalys av de observerade flödena
-Vid en samlad utvärdering av de observerade flödena och principerna för härdning identifieras följande punkter gällande rimlighet och åtgärder:
-Brister gällande kryptering (HTTP vs. HTTPS):
*Det observerade flödet använder okrypterad HTTP (port 80). Ur ett härdningsperspektiv är detta inte rimligt i en modern produktionsmiljö, eftersom all data (inklusive inloggningsuppgifter och sessions-tokens) överförs i klartext och kan snappas upp via en Man-in-the-Middle (MitM)-attack.
*Åtgärd: Port 80 bör inaktiveras eller strikt omdirigera trafiken till HTTPS (port 443) med TLS-kryptering.

-Rimlighet i tjänsteexponering:
*Om serverns avsedda funktion är att fungera som en publik webbserver är inkommande webbtrafik principmässigt rimlig.
*Däremot ska administrativa tjänster (såsom SSH på port 22 eller RDP på port 3389) samt databasportar aldrig exponeras på samma gränssnitt eller vara tillgängliga från osäkra nätverk.
<!-- End DEL F -->