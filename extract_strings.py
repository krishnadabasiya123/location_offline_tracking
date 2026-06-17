
import os
import re
import sys

def find_strings(root_dir):
    # Regex to match comments OR strings.
    # Comments are matched first so they are consumed and can be ignored.
    pattern = re.compile(r"""
        (?P<comment>
            //[^\n]*                # Single-line comment
            |
            /\*[\s\S]*?\*/          # Multi-line comment
        )
        |
        (?P<string>
            ' (?: [^'\\] | \\. )* '  # Single quoted string
            |
            " (?: [^"\\] | \\. )* "  # Double quoted string
        )
    """, re.VERBOSE | re.DOTALL)

    unique_strings = set()
    
    print(f"Scanning files in {root_dir}...")
    
    count = 0
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                        for match in pattern.finditer(content):
                            if match.group('comment'):
                                continue
                            
                            s = match.group('string')
                            if s:
                                # Strip quotes
                                if s.startswith("'") and s.endswith("'"):
                                    s = s[1:-1]
                                elif s.startswith('"') and s.endswith('"'):
                                    s = s[1:-1]
                                
                                # Filter out imports and file references
                                if s.startswith('package:') or s.startswith('dart:') or s.endswith('.dart'):
                                    continue

                                unique_strings.add(s)
                                count += 1
                except Exception as e:
                    print(f"Failed to read {file_path}: {e}")

    return sorted(list(unique_strings))

if __name__ == '__main__':
    target = 'lib'
    if len(sys.argv) > 1:
        target = sys.argv[1]
    
    target_path = os.path.abspath(target)
    
    if not os.path.exists(target_path):
        print(f"Error: Directory {target_path} does not exist.")
        sys.exit(1)

    found = find_strings(target_path)
    
    print(f"\nFound {len(found)} unique strings (excluding comments):\n")
    print("--------------------------------------------------")
    for s in found:
        print(s)
    print("--------------------------------------------------")
