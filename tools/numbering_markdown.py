#!/usr/bin/env python3
import re

def number_markdown_sections(file_path):
    # Read the markdown file
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.readlines()
    
    # Initialize counters for each heading level
    counters = [0] * 5  # For ##, ###, ####, #####
    output = []
    
    # Regex to match markdown headings, capturing optional existing numbers
    heading_pattern = re.compile(r'^(#+)\s+(?:\d+(?:\.\d+)*\.\s+)?(.+)$')
    
    for line in content:
        match = heading_pattern.match(line)
        if match:
            level = len(match.group(1)) - 2  # Convert # count to 0-based index (## -> 0, ### -> 1, etc.)
            if 0 <= level < 5:  # Only process levels 2 to 5 (## to #####)
                # Increment current level counter, reset lower levels
                counters[level] += 1
                for i in range(level + 1, 5):
                    counters[i] = 0
                
                # Create number prefix (e.g., "1.", "1.1", "1.1.1")
                number = '.'.join(str(counters[i]) for i in range(level + 1) if counters[i] > 0)
                # Replace or add numbered heading
                line = f"{'#' * (level + 2)} {number}. {match.group(2)}\n"
        
        output.append(line)
    
    # Write the modified content back to the file
    with open(file_path, 'w', encoding='utf-8') as file:
        file.writelines(output)

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python number_markdown.py <markdown_file>")
        sys.exit(1)
    number_markdown_sections(sys.argv[1])
