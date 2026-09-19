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
