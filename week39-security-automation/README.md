Security Automation Report - Week 39

## Syfte
Detta verktyg automatiserar den första analysen av syntetiska autentiserings- och webbloggar. Syftet är att extrahera IP-adresser, räkna misslyckade inloggningar och jämföra observationer mot en lista med kända indikationer (IOCs) utan att draga överilade slutsatser.

## Datasetval
- **Dataset**: Basic (Dataset A)
- **Analyserade filer**: 'data/auth.log', 'data/access.log', 'data/suspicious_ips.txt'

## Krav & Miljö
- **Pythonversion**: Python 3.10+ (inga externa bibliotek krävs)

## Körsinstruktion
Kör skriptet från projektroten:
'''bash
python src/security_report.py


Testning och Verifiering
Tre testfall har genomförts och verifierats manuellt:

## Känt positivt utfall (IOC-matchning):
- **Indata**: IP 203.0.113.15 finns i loggarna och i 'suspicious_ips.txt'.
- **Förväntat utfall**: IP identifieras och flaggas som IOC.match.
- **Resultat**: Verifierat korrekt i rapporten.

## Test med noll träffar (Ej IOC):
- **Indata**: IP 192.0.2.25 finns i loggarna men saknas i 'suspicous_ips.txt'.
- **Förväntat utfall**: Visas i rapporten med "Matchar IOC: NEJ".
- **Reslutat**: Verifierat korrekt.

## Formatfel och saknat fält:
- **Indata**: Raden "Malformed line without source" i 'auth.log'.
- **Förväntat utfall**: Programmet krashar inte, skippar raden och ökar räknaren för felaktiga rader.
- **Resultat**: Räknades korrekt som 1 felaktig rad i rapporten.

## Ändringar i skript
- **Fel i projektrot**: Vid första testning valde programmet att skapa en ny mapp 'output/' istället för att spara output-filen i den redan skapade output-mappen i 'week39-security-automation/'. Jag fick ändra i skriptet från (OUTPUT_DIR = "data/output") till (OUTPUT_DIR = "week39-security-automation/output"). Samma gällde för data-mappen som ville läsa från en data-mapp i projektroten från (DATA_DIR = "data") till (DATA_DIR = "week39-security-automation/data"). Med dom nya ändringarna så tvingar jag skriptet att gå in det nuvarande projekt-mappen istället för roten.

## Kända begränsningar
- Programmet analyserar endast mönstermatchningar i text och tar inte hänsyn till tidsstämplars sekvenser.
- Identifierade IOCs utgör analysunderlag och inte färdiga skuldbevis.

## Redovisning av AI-användning
- **AI-verktyg**: ChatGPT/Gemini
- **Användningsområde**: AI har använts för viss kodstrukturering, skapande av regex och vägledning för sparande av output-fil.