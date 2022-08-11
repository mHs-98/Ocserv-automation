from secrets import choice
NUM = '0123456789'
SPECIAL = '!"%&/:*+'
DELIMITER = '-_.'

WORDS = set()
with open('words.txt', 'r') as f:
    for w in f:
        w = w.split()[-1]
      #  print(w)
        if (len(w) < 7):
            if (len(w) > 3):
                WORDS.add(w.strip().lower())
WORDS = list(WORDS)
        
print("\nUsernames:")
for _ in range(24):
    uname = ''
    uname += choice(WORDS).strip()
    uname += choice(DELIMITER)
    uname += choice(WORDS).strip()
    print(uname)
    with open("/tmp/randomuser.txt", 'a') as f:
        print(uname, file=f)

print("\nPasswords:")
for _ in range(24):
    pw = ''
    pw += choice(WORDS).strip()
    pw += choice(DELIMITER)
    pw += choice(WORDS).strip()
    pw += choice(DELIMITER)
    pw += choice(WORDS).strip()
    pw += choice(DELIMITER)
    pw += choice(NUM)
    pw += choice(SPECIAL)
    print(pw)
    with open("/tmp/randompassw.txt", 'a') as f:
        print(pw, file=f)
