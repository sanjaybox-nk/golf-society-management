import sys

def check_brackets(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    stack = []
    class_start = -1
    for i, char in enumerate(content):
        if char == '{':
            stack.append(i)
            # Find class _EventScoresUserTabState
            if "_EventScoresUserTabState" in content[max(0, i-100):i]:
                class_start = len(stack) - 1
        elif char == '}':
            if not stack:
                print(f"Extra closing bracket at index {i}")
                return
            start_idx = stack.pop()
            if len(stack) == class_start:
                # This was the closing bracket for the class
                # Let's find the line number
                line_no = content.count('\n', 0, i) + 1
                print(f"Class closed at line {line_no}")
                # Print some context around it
                start_context = max(0, i - 50)
                end_context = min(len(content), i + 50)
                print(f"Context: {content[start_context:end_context]}")
    if stack:
        print(f"Brackets not balanced. {len(stack)} open brackets remaining.")

check_brackets('/Users/sanjaypatel/Documents/Projects/Golf Society Management/lib/features/events/presentation/tabs/event_user_placeholders.dart')
