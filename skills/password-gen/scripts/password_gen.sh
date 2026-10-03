#!/usr/bin/env bash
set -euo pipefail

LENGTH=16
COUNT=1
INCLUDE="uppercase,lowercase,digits,symbols"
EXCLUDE=""
NO_AMBIGUOUS=0
PASSPHRASE=0
WORDS=4
SEPARATOR="-"
STRENGTH=0
INPUT_STR=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--length) LENGTH="$2"; shift ;;
        -c|--count) COUNT="$2"; shift ;;
        -i|--include) INCLUDE="$2"; shift ;;
        -e|--exclude) EXCLUDE="$2"; shift ;;
        -n|--no-ambiguous) NO_AMBIGUOUS=1 ;;
        -p|--passphrase) PASSPHRASE=1 ;;
        -w|--words) WORDS="$2"; shift ;;
        -s|--separator) SEPARATOR="$2"; shift ;;
        --strength) STRENGTH=1 ;;
        --input) INPUT_STR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

cat << 'EOF' > /tmp/pwd_gen.py
import sys, secrets, math, argparse

parser = argparse.ArgumentParser()
parser.add_argument('--length', type=int, default=16)
parser.add_argument('--count', type=int, default=1)
parser.add_argument('--include', default='uppercase,lowercase,digits,symbols')
parser.add_argument('--exclude', default='')
parser.add_argument('--no-ambiguous', type=int, default=0)
parser.add_argument('--passphrase', type=int, default=0)
parser.add_argument('--words', type=int, default=4)
parser.add_argument('--separator', default='-')
parser.add_argument('--strength', type=int, default=0)
parser.add_argument('--input', default='')

args = parser.parse_args()

if args.strength:
    if not args.input:
        print("--input required for strength check", file=sys.stderr)
        sys.exit(1)
    
    l = len(args.input)
    charsetSize = 0
    if any(c.islower() for c in args.input): charsetSize += 26
    if any(c.isupper() for c in args.input): charsetSize += 26
    if any(c.isdigit() for c in args.input): charsetSize += 10
    if any(not c.isalnum() for c in args.input): charsetSize += 32
    
    entropy = round(l * math.log2(charsetSize), 2) if charsetSize > 0 else 0
    print(f"Password length: {l}")
    print(f"Charset size roughly: {charsetSize}")
    print(f"Estimated entropy: {entropy} bits")
    sys.exit(0)

if args.passphrase:
    wordlist = ['apple', 'banana', 'orange', 'grape', 'lemon', 'peach', 'cherry', 'melon', 'berry', 'plum',
                'car', 'bike', 'train', 'plane', 'boat', 'ship', 'truck', 'bus', 'cart', 'van',
                'dog', 'cat', 'bird', 'fish', 'frog', 'bear', 'wolf', 'lion', 'tiger', 'deer',
                'red', 'blue', 'green', 'yellow', 'black', 'white', 'gray', 'pink', 'purple', 'brown',
                'sun', 'moon', 'star', 'cloud', 'rain', 'snow', 'wind', 'storm', 'sky', 'sea',
                'tree', 'leaf', 'root', 'branch', 'flower', 'grass', 'bush', 'plant', 'seed', 'wood',
                'house', 'door', 'window', 'roof', 'wall', 'floor', 'room', 'bed', 'chair', 'table',
                'book', 'pen', 'paper', 'desk', 'lamp', 'clock', 'phone', 'computer', 'screen', 'mouse',
                'happy', 'sad', 'angry', 'fast', 'slow', 'big', 'small', 'hot', 'cold', 'warm',
                'run', 'walk', 'jump', 'swim', 'fly', 'drive', 'ride', 'climb', 'fall', 'stand']
    for _ in range(args.count):
        phrase = [secrets.choice(wordlist) for _ in range(args.words)]
        print(args.separator.join(phrase))
    sys.exit(0)

if args.length < 8 or args.length > 128:
    print("Length must be between 8 and 128", file=sys.stderr)
    sys.exit(1)

upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
lower = 'abcdefghijklmnopqrstuvwxyz'
digits = '0123456789'
symbols = '!@#$%^&*()-_=+[]{}|;:,.<>?'

reqs = []
if 'uppercase' in args.include: reqs.append(upper)
if 'lowercase' in args.include: reqs.append(lower)
if 'digits' in args.include: reqs.append(digits)
if 'symbols' in args.include: reqs.append(symbols)

exc = args.exclude
if args.no_ambiguous:
    exc += "0O1lI|`'"

for c in exc:
    reqs = [r.replace(c, '') for r in reqs]

charset = "".join(set("".join(reqs)))

if not charset:
    print("Empty charset", file=sys.stderr)
    sys.exit(1)

for _ in range(args.count):
    pwd = []
    for r in reqs:
        if r:
            pwd.append(secrets.choice(r))
    
    while len(pwd) < args.length:
        pwd.append(secrets.choice(charset))
    
    # Shuffle in place securely
    for i in range(len(pwd)-1, 0, -1):
        j = secrets.randbelow(i+1)
        pwd[i], pwd[j] = pwd[j], pwd[i]
        
    print("".join(pwd))
EOF

python3 /tmp/pwd_gen.py \
  --length "$LENGTH" \
  --count "$COUNT" \
  --include "$INCLUDE" \
  --exclude "$EXCLUDE" \
  --no-ambiguous "$NO_AMBIGUOUS" \
  --passphrase "$PASSPHRASE" \
  --words "$WORDS" \
  --separator "$SEPARATOR" \
  --strength "$STRENGTH" \
  --input "$INPUT_STR"

rm /tmp/pwd_gen.py
