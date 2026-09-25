
import os
import re
from collections import Counter


DATA_DIR = "data"
OUTPUT_DIR = "output"
AUTH_LOG = os.path.join(DATA_DIR, "auth.log")
ACCESS_LOG = os.path.join(DATA_DIR, "access.log")
SUSPICIOUS_IPS_FILE = os.path.join(DATA_DIR, "suspicious_ips.txt")
REPORT_FILE = os.path.join(OUTPUT_DIR, "security_report.txt")

IP_REGEX = re.compile(r'src=(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})')

def read_suspicious_ips(filepath):
    """Läser in lista över misstänkta IP-adresser."""
    if not os.path.exists(filepath):
        return set()
    with open(filepath, "r", encoding="utf-8") as f:
        return set(line.strip() for line in f if line.strip())

def parse_logs():
    """Läser loggfiler och extraherar händelser samt hanterar felaktiga rader."""
    ip_counter = Counter()
    failed_logins = Counter()
    malformed_lines = 0
    total_parsed_lines = 0

    files_to_read = [AUTH_LOG, ACCESS_LOG]

    for filepath in files_to_read:
        if not os.path.exists(filepath):
            continue
        with open(filepath, "r", encoding="utf-8") as f:
            for line in f:
                total_parsed_lines += 1
                line_str = line.strip()
                if not line_str:
                    continue

                match = IP_REGEX.search(line_str)
                if match:
                    ip = match.group(1)
                    ip_counter[ip] += 1

                    if "auth Failed login" in line_str:
                        failed_logins[ip] += 1
                else:
                    malformed_lines += 1

    return ip_counter, failed_logins, total_parsed_lines, malformed_lines

def generate_report():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    suspicious_ips = read_suspicious_ips(SUSPICIOUS_IPS_FILE)
    ip_counter, failed_logins, total_lines, malformed_lines = parse_logs()

    with open(REPORT_FILE, "w", encoding="utf-8") as f:
        f.write("==========================================\n")
        f.write("        SECURITY AUTOMATION REPORT        \n")
        f.write("==========================================\n\n")
        f.write(f"Analyserade filer: {AUTH_LOG}, {ACCESS_LOG}\n")
        f.write(f"Totalt behandlade rader: {total_lines}\n")
        f.write(f"Hanterade formatfel/hoppade rader: {malformed_lines}\n\n")

        f.write("--- IP-Aktivitet & IOC-Matchning ---\n")
        for ip, count in sorted(ip_counter.items(), key=lambda x: x[1], reverse=True):
            is_ioc = "JA" if ip in suspicious_ips else "NEJ"
            f.write(f"IP: {ip:<15} Förekomster: {count:<3} Matchar IOC: {is_ioc}\n")

        f.write("\n--- Mönster: Misslyckade inloggningsförsök ---\n")
        for ip, count in failed_logins.items():
            f.write(f"IP: {ip:<15} Misslyckade inloggningar: {count}\n")

        f.write("\n--- Begränsnigar ---\n")
        f.write("1. Analysen baseras enbart på auth.log och access.log.\n")
        f.write("2. En IOC-matchning eller hög frekvens innebär inte bekräftad incident utan kräver vidare verifiering.\n")

    print(f"Rapport genererad: {REPORT_FILE}")

if __name__ == "__main__":
    generate_report()

