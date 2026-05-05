import os 

# Run this file to generate the filenames and links for the mkdocs.yml navigation bar.

if __name__ == "__main__":
    directory_path = '.'  # Replace with your actual directory path

    # Iterate over files in the directory
    for filename in os.listdir(directory_path):
        if filename.endswith('.md') and filename.startswith('cmd_'):
            cmd_name = os.path.splitext(filename)[0][4:]  # Remove 'cmd_' prefix
            cmd_name = os.path.splitext(filename)[0][4:]  # Remove 'cmd_' prefix
            line_of_code = f'- {cmd_name}: "reference/cli/{filename}"'
            print(line_of_code)