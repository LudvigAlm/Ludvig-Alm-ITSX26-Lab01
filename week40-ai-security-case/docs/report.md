# Huvudrapport: Case A – AI-phishing mot en kommun

## 1. Executive Summary
En kommunal förvaltning har utsatts för ett phishingförsök där välformulerade mejl skickats till flera medarbetare under förespegling att komma från den interna IT-supporten. Mejlen innehöll en länk med uppmaning att logga in för att bibehålla åtkomsten till ett internt system. En medarbetare klickade på länken men har uppgett att inga inloggningsuppgifter lämnades. Det finns i dagsläget inga bekräftade tecken på intrång eller dataläckage, och det är ännu inte fastställt om en språkmodell/AI användes för att formulera mejlen.

Huvudrisken identifieras som potentiell stöld av autentiseringsuppgifter eller sessionstakning, vilket kan leda till obehörig åtkomst till kommunala system. Situationen kräver omedelbara tekniska verifieringsåtgärder. Relevanta CIS Controls (v8.1) har mapplats mot händelsen: CIS 6 (Access Control Management), CIS 8 (Audit Log Management) och CIS 14 (Security Awareness and Skills Training). Tre prioriterade och verifierbara åtgärder föreslås: teknisk logganalys, stärkt multifaktorautentisering (MFA) samt rollanpassad utbildning.

---

## 2. Fakta, antaganden och scope

### Givna fakta
- Nätfiske-mejl skickades till flera medarbetare inom förvaltningen.
- Avsändarnamnet liknade den interna IT-supporten.
- Minst en medarbetare har klickat på länken i mejlet.
- Medarbetaren uppger att inga uppgifter/inloggningsuppgifter lämnades på sidan.
- Det finns ingen bekräftad säkerhetsincident eller konstaterat intrång i dagsläget.
- AI-användning är en möjlighet, inte ett fastställt faktum.

### Antaganden
- Länken ledde till en extern phishingsida avsedd att samla in inloggningsuppgifter eller exekvera skadlig kod (t.ex. session hijacking).
- Kommunen använder central identitetshantering (exempelvis Entra ID / Active Directory) för sina interna system.
- Språkbehandlingen i mejlet var av hög kvalitet, vilket gör användning av generative AI/LLM möjlig.

### Frågor som behöver verifieras (Kunskapsluckor)
- Innehöll phishingsidan skadliga skript eller försök till sessionstakning/token theft?
- Har användarens sessioner eller konton uppvisat avvikande aktivitet (t.ex. inloggningar från okända IP-adresser eller platser)?
- Har e-postfiltret upptäckt och spärrat kvarvarande meddelanden från samma avsändare/domän?

---

## 3. Tillgångar och händelsekedja

### Identifierade tillgångar
1. **Kommunens användarkonton/identiteter:** Behörigheter och inloggningsuppgifter till kommunala system och e-post.
2. **Internt verksamhetssystem:** Systemet som mejlet hävdade gälla åtkomst till (innehåller potentiellt känsliga personuppgifter/handlingar).
3. **Klientenhet (medarbetarens dator):** Den enhet som användes för att klicka på länken.
4. **E-postinfrastruktur & E-postfilter:** Kommunens e-postserver och skyddsmekanismer mot phishing/spam.

### Händelsekedja
1. **Leverans:** Angriparen skickar e-postmeddelanden med förfalskat avsändarnamn till flera kommunanställda.
2. **Interaktion:** En medarbetare öppnar e-postmeddelandet och klickar på den bifogade länken.
3. **Omdirigering:** Klienten ansluter till den externa phishingsidan. Medarbetaren stänger sidan utan att fylla i formuläret.
4. **Rapportering:** Medarbetaren rapporterar händelsen till IT-supporten.
5. **Analys & Verifiering:** IT-säkerhetsfunktionen påbörjar logganalys och spärrning av skadliga domäner/IP-adresser.

---

## 4. CIA och enkel riskbedömning

### Impact-analys enligt CIA-triaden
- **Confidentiality (Konfidentialitet):** *Medel/Hög.* Om inloggningsuppgifter eller sessionstokens stulits finns risk för obehörig åtkomst till känsliga personuppgifter.
- **Integrity (Riktighet):** *Låg/Medel.* Ingen förändring av data har bekräftats. Vid ett lyckat intrång finns dock risk för obehörig ändring i interna register.
- **Availability (Tillgänglighet):** *Låg.* Tjänsterna och systemen är fullt fungerande och påverkades inte direkt av phishingmejlet.

### Kvalitativ riskbedömning

| Händelse / Hot | Sannolikhet | Konsekvens | Sammanvägd Risk | Motivering |
| :--- | :--- | :--- | :--- | :--- |
| Stöld av inloggningsuppgifter via phishing | Medel | Hög | **Hög** | Phishing är en vanlig ingångsvektor; AI-stöd gör mejlen svåra att identifiera. |
| Drive-by download / Session theft vid länkklick | Låg | Hög | **Medel** | Medarbetaren klickade på länken; om skadlig kod exekverades kan sessionen vara komprometterad. |

---

## 5. CIS-mappning

| CIS Control (v8.1) | Konkret relaterad åtgärd | Verifieringsmetod |
| :--- | :--- | :--- |
| **CIS 6: Access Control Management** | Kräv multifaktorautentisering (MFA) för alla externa och interna systeminloggningar samt tillämpa principen om minsta behörighet (LGP). | Genomför en behörighetsgranskning i IDP (Identity Provider) och verifiera att 100 % av användarkontona kräver MFA. |
| **CIS 8: Audit Log Management** | Centralisera och analysera e-post- och inloggningsloggar för att upptäcka misslyckade/avvikande inloggningsförsök och MFA-bypasses. | Gör en testsökning i SIEM/loggsystemet efter händelse-ID för misslyckade/lyckade inloggningar för den berörda användaren under de senaste 24 timmarna. |
| **CIS 14: Security Awareness and Skills Training** | Genomför uppdaterad utbildning med fokus på AI-genererade phishingmejl och etablera en enkel "Rapportera phishing"-knapp i e-postklienten. | Kontrollera genomföringsgraden i utbildningsportalen samt mät antalet rapporterade misstänkta mejl via phishingknappen. |

---

## 6. Prioriterade åtgärder

1. **Teknisk logganalys och sessionshantering (Kortsiktig/Omedelbar):**  
   Identifiera och granska alla loggar (DNS, proxy, e-post, IDP) kopplade till den medarbetare som klickade på länken. Återställ användarens lösenord och rensa alla aktiva sessioner som en försiktighetsåtgärd.
2. **Krav på MFA och villkorad åtkomst (Conditional Access) (Mellansikt):**  
   Säkerställ att nätfiskebeständiga MFA-metoder (t.ex. FIDO2/Passkeys eller autentiseringsapp med nummermatchning) krävs vid alla inloggningar till kommunala system.
3. **E-postskydd och tekniska spärrar (Mellansikt):**  
   Konfigurera och strama åt e-postfilter (SPF, DKIM, DMARC) samt blockera den identifierade skadliga domänen/URL:en i kommunens brandvägg och DNS-filter.

---

## 7. Teknisk koppling

Analysen bygger på kursens moment gällande **identitetshantering, logganalys och SOC-metodik**. 

Vid en misstänkt phishing-incident där en länk öppnats räcker det inte med medarbetarens muntliga utsago om att inga uppgifter fyllts i. Tekniskt sett kan webbsidor utnyttja så kallade *Adversary-in-the-Middle (AiTM)*-ramverk (exempelvis Evilginx) för att stjäla sessionstokens (cookies) utan att användaren märker det, eller köra skadliga skript i webbläsaren. Logggranskning i IDP (t.ex. Microsoft Entra ID Sign-in logs) måste kontrollera:
- Om inloggningsförsök gjorts från avvikande IP-adresser eller User-Agent-strängar.
- Om nya enheter eller MFAs har registrerats på kontot.
- Eventuella DNS-uppslag mot den externa domänen i klientens lokala loggar eller proxy-loggar.

---

## 8. Slutsats

Händelsen visar på vikten av ett flerlagrat försvar (Defense in Depth) där tekniska kontroller (CIS 6, CIS 8) kompletteras med mänsklig medvetenhet (CIS 14). Även om medarbetaren agerade ansvarsfullt genom att rapportera klicket, kvarstår en teknisk osäkerhet kring om skadlig kod eller sessionstöld ägt rum innan logganalys slutförts. Genom att genomföra de föreslagna åtgärderna reduceras risken för framtida lyckade phishingförsök avsevärt.
