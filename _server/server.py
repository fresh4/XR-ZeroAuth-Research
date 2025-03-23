import sys, socket, serial

def exit(event=None):
    print("Shutting down server...")
    server_socket.close()
    serial_port.close()
    sys.exit(0)

# Handles termination on Windows
if sys.platform == "win32":
    import win32api
    win32api.SetConsoleCtrlHandler(exit, True)

# Set up the server
HOST = '127.0.0.1'  # Listen on all available network interfaces
PORT = 6000         # Port number
COM = "COM1"        # Serial COM port

# Create a socket
server_socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
server_socket.bind((HOST, PORT))
# Connect to virtual COM port
serial_port = serial.Serial(port=COM)

print(f"Server listening on {HOST}:{PORT}. Virtual COM port {COM} connected.")

try:
    while True:
        msg, client_address = server_socket.recvfrom(1024)
        print(f"Connected by {client_address}, msg: {msg}")

        if msg:
            serial_port.write(msg)

# Gracefully exit server
except KeyboardInterrupt:
    exit()
finally:
    sys.exit(0)