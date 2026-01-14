#!/usr/bin/env python3

"""
Clicker Heroes Save Game Encoder/Decoder Tool
"""

import json
import zlib
import base64
import hashlib
import random
import argparse
from pathlib import Path

HASHES_ALGOS = {
    "7a990d405d2c6fb93aa8fbb0ec1a3b23": "zlib",
    "7e8bb5a89f2842ac4af01b3b7e228592": "deflate"
}
ALGOS_HASHES = {v: k for k, v in HASHES_ALGOS.items()}

# Sprinkle encoding constants
ANTI_CHEAT_CODE = "Fe12NAfA3R6z4k0z"
SALT = "af0ik392jrmt0nsfdghy0"
CHARACTERS = "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"


def get_hash(string: str) -> str:
    chars = list(string)
    chars.sort()
    sorted_chars = ''.join(chars)
    return hashlib.md5((sorted_chars + SALT).encode('utf-8')).hexdigest()

# sprinkle algo
def sprinkle(string: str) -> str:
    """Add a random character after each character"""
    result = []
    for char in string:
        result.append(char)
        random_index = random.randint(0, len(CHARACTERS) - 1)
        result.append(CHARACTERS[random_index])
    return ''.join(result)

def encode_sprinkle(raw_data: dict) -> str:
    """Encode to legacy sprinkle format"""
    json_str = json.dumps(raw_data, separators=(',', ':'))
    base64_string = base64.b64encode(json_str.encode('utf-8')).decode('utf-8')
    return sprinkle(base64_string) + ANTI_CHEAT_CODE + get_hash(base64_string)

def decode_sprinkle(txt_in: str) -> str:
    txt_out = ""

    # Check if Unity format
    if "ClickerHeroesAccountSO" in txt_in:
        start = 53
        txt_out = txt_in[start:len(txt_in) - 1]
    else:
        txt_in = txt_in.strip()
        if not txt_in:
            return ""

        if ANTI_CHEAT_CODE in txt_in:
            result = txt_in.split(ANTI_CHEAT_CODE)
            # Take every other character (remove sprinkle random characters)
            for i in range(0, len(result[0]), 2):
                txt_out += result[0][i]

            # Verify hash (optional, skip verification here)
            expected_hash = get_hash(txt_out)
            if expected_hash != result[1]:
                print(f"Warning: Hash mismatch (expected: {expected_hash}, got: {result[1]})")

        txt_out = base64.b64decode(txt_out).decode('utf-8')

    return txt_out


def decode_save_game(save_data: str) -> tuple[dict, str]:
    # Read first 32 characters (MD5 hash of algorithm)
    algo_hash = save_data[:32]

    # Default to sprinkle (legacy encoding)
    algo = "sprinkle"

    # Detect encoding algorithm
    if algo_hash in HASHES_ALGOS:
        algo = HASHES_ALGOS[algo_hash]

    if algo == "sprinkle":
        json_str = decode_sprinkle(save_data)
        return json.loads(json_str), algo
    else:
        # Remove 32-character algorithm header
        str_stripped = save_data[32:]
        compressed_data = base64.b64decode(str_stripped)

        if algo == "zlib":
            json_str = zlib.decompress(compressed_data).decode('utf-8')
        elif algo == "deflate":
            # deflate uses raw deflate (no zlib header)
            json_str = zlib.decompress(compressed_data, -zlib.MAX_WBITS).decode('utf-8')
        else:
            raise ValueError(f"Unknown algorithm: {algo}")

        return json.loads(json_str), algo


def encode_save_game(raw_data: dict, algo: str) -> str:
    if algo == "sprinkle":
        return encode_sprinkle(raw_data)

    if algo not in ALGOS_HASHES:
        raise ValueError(f"Cannot encode using algo: {algo}")

    algorithm_header = ALGOS_HASHES[algo]

    json_str = json.dumps(raw_data, separators=(',', ':'))

    if algo == "zlib":
        compressed = zlib.compress(json_str.encode('utf-8'))
    elif algo == "deflate":
        # deflate uses raw deflate (no zlib header)
        compress_obj = zlib.compressobj(zlib.Z_DEFAULT_COMPRESSION, zlib.DEFLATED, -zlib.MAX_WBITS)
        compressed = compress_obj.compress(json_str.encode('utf-8')) + compress_obj.flush()
    else:
        raise ValueError(f"Unknown algorithm: {algo}")

    base64_encoded = base64.b64encode(compressed).decode('utf-8')
    return algorithm_header + base64_encoded


def main():
    parser = argparse.ArgumentParser(
        description='Clicker Heroes Save Game Encoder/Decoder Tool',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  Decode save to JSON file:
    python save_game_tool.py decode -i save.txt -o save.json

  Encode JSON to save file:
    python save_game_tool.py encode -i save.json -o new_save.txt

  Specify encoding algorithm:
    python save_game_tool.py encode -i save.json -o new_save.txt --algo zlib
        '''
    )

    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Decode command
    decode_parser = subparsers.add_parser('decode', help='Decode save file to JSON')
    decode_parser.add_argument('-i', '--input', required=True, help='Input save file path')
    decode_parser.add_argument('-o', '--output', help='Output JSON file path')
    decode_parser.add_argument('--pretty', action='store_true', help='Pretty print JSON output')

    # Encode command
    encode_parser = subparsers.add_parser('encode', help='Encode JSON to save file')
    encode_parser.add_argument('-i', '--input', required=True, help='Input JSON file path')
    encode_parser.add_argument('-o', '--output', help='Output save file path')
    encode_parser.add_argument('--algo', default='zlib', choices=['sprinkle', 'zlib', 'deflate'],
                               help='Encoding algorithm (default: zlib)')

    # Info command
    info_parser = subparsers.add_parser('info', help='Display save file basic info')
    info_parser.add_argument('-i', '--input', required=True, help='Input save file path')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    if args.command == 'decode':
        save_data = Path(args.input).read_text(encoding='utf-8').strip()

        try:
            data, algo = decode_save_game(save_data)
            print(f"Detected encoding algorithm: {algo}")

            # Output JSON
            if args.pretty:
                json_output = json.dumps(data, indent=2, ensure_ascii=False)
            else:
                json_output = json.dumps(data, ensure_ascii=False)

            if args.output:
                Path(args.output).write_text(json_output, encoding='utf-8')
                print(f"Saved to: {args.output}")
            else:
                print("\n--- JSON Data ---")
                print(json_output)

        except Exception as e:
            print(f"Decode failed: {e}")
            return

    elif args.command == 'encode':
        try:
            json_data = json.loads(Path(args.input).read_text(encoding='utf-8'))

            encoded = encode_save_game(json_data, args.algo)

            if args.output:
                Path(args.output).write_text(encoded, encoding='utf-8')
                print(f"Saved to: {args.output}")
                print(f"Algorithm used: {args.algo}")
            else:
                print("\n--- Encoded Save Data ---")
                print(encoded)

        except Exception as e:
            print(f"Encode failed: {e}")
            return

    elif args.command == 'info':
        save_data = Path(args.input).read_text(encoding='utf-8').strip()

        try:
            data, algo = decode_save_game(save_data)

            print(f"\n=== Save Info ===")
            print(f"Encoding algorithm: {algo}")
            print(f"Hero Souls: {data.get('heroSouls', 'N/A')}")
            print(f"Hero Souls Sacrificed: {data.get('heroSoulsSacrificed', 'N/A')}")
            print(f"Ancient Souls Total: {data.get('ancientSoulsTotal', 'N/A')}")
            print(f"Highest Zone: {data.get('highestFinishedZonePersist', 'N/A')}")
            print(f"Transcendent: {data.get('transcendent', 'N/A')}")

            # Display ancients info
            ancients = data.get('ancients', {}).get('ancients', {})
            if ancients:
                print(f"\n--- Ancients Count: {len(ancients)} ---")
                for aid, ancient in list(ancients.items())[:5]:
                    print(f"  ID {aid}: Level {ancient.get('level', 0)}")
                if len(ancients) > 5:
                    print(f"  ... and {len(ancients) - 5} more ancients")

            # Display outsiders info
            outsiders = data.get('outsiders', {}).get('outsiders', {})
            if outsiders:
                print(f"\n--- Outsiders Count: {len(outsiders)} ---")
                for oid, outsider in outsiders.items():
                    print(f"  ID {oid}: Level {outsider.get('level', 0)}")

        except Exception as e:
            print(f"Parse failed: {e}")
            return


if __name__ == '__main__':
    main()
