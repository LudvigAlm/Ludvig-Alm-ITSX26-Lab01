[WEEK 38 Network Traffic Investigation]
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

