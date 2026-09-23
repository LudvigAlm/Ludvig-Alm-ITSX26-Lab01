
error_count = 0

with open("data/error.log", encoding="utf-8") as log_file:
    for line in log_file:
        if "ERROR" in line:
            error_count += 1
            print(line.strip())

print(f"ERRORS: {error_count}")