# Säkerhetsanalys & Metodrapport

## Rådata
Analyserade filer: 'data/auth.log' och 'data/accsess.log' (totalt 10 rader bearbetade).

## Observation
IP-adressen '203.0.113.15' förekommer totalt 5 gånger i de analyserade loggarna:
- 3 misslyckade inloggningsförsök i 'auth.log' (användare: admin, root).
- 2 HTTP-anrop i 'access.log' mot '/login' med statuskod 401.
- Adressen finns listad i 'suspicious_ips.txt'.

Dessutom identifierades 1 malformaterad rad utan source-IP i 'auth.log' som filtrerades bort säkert.

## Slutsats
IP-adressen '203.0.113.15' har generat upprepade misslyckade autentiseringsförsök mot både SSH/Auth och webbsystemets inloggning under ett kort tidsintervall.

## Osäkerhet
Skriptet och loggarna kan inte fastställa om der rör sig om en automatiserad attack eller om en behörig användare angivit fel lösenord flera gånger. Då inga lyckade inloggningar noterats för denna IP går det inte att bekräfta ett faktiskt intrång.

## Alternativ förklaring
En felkonfiguerad applikation eller en intern användare som glömt sitt lösenord och försöker logga in via olika gränssnitt.

## Säkerhetsbetydelse
Observationen är relevant för prioritering i SOC då mönstret visar fellinjering mellan tjänster (SSH + Web) i kombination men en IOC-träff. Detta motiverar fördjupad granskning (t.ex. kontroll av brandväggsloggar eller temporär övervakning) utan att direkt klassa det som bekräftat intrång.

