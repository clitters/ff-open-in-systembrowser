#!/usr/bin/env python3
"""
Native messaging host for Firefox addon to open URLs in system default browser.
"""
import sys
import json
import struct
import subprocess
import platform

def get_message():
    """Read a message from stdin and decode it."""
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        return None
    message_length = struct.unpack('=I', raw_length)[0]
    message = sys.stdin.buffer.read(message_length).decode('utf-8')
    return json.loads(message)

def encode_message(message_content):
    """Encode a message for transmission."""
    encoded_content = json.dumps(message_content).encode('utf-8')
    encoded_length = struct.pack('=I', len(encoded_content))
    return {'length': encoded_length, 'content': encoded_content}

def send_message(message_content):
    """Send an encoded message to stdout."""
    encoded_message = encode_message(message_content)
    sys.stdout.buffer.write(encoded_message['length'])
    sys.stdout.buffer.write(encoded_message['content'])
    sys.stdout.buffer.flush()

def open_in_default_browser(url):
    """Open URL in system's default browser."""
    system = platform.system()
    
    try:
        if system == 'Linux':
            subprocess.run(['xdg-open', url], check=True)
        elif system == 'Darwin':  # macOS
            subprocess.run(['open', url], check=True)
        elif system == 'Windows':
            subprocess.run(['start', url], shell=True, check=True)
        else:
            return {'success': False, 'error': f'Unsupported platform: {system}'}
        
        return {'success': True}
    except subprocess.CalledProcessError as e:
        return {'success': False, 'error': f'Failed to open URL: {str(e)}'}
    except FileNotFoundError:
        return {'success': False, 'error': 'System browser command not found'}

def main():
    """Main loop for native messaging host."""
    while True:
        message = get_message()
        if message is None:
            break
        
        url = message.get('url')
        if not url:
            send_message({'error': 'No URL provided'})
            continue
        
        response = open_in_default_browser(url)
        send_message(response)

if __name__ == '__main__':
    main()