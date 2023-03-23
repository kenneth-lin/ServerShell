import socket
import datetime

HOST = '::'                 # Symbolic name meaning all available interfaces
PORT = 80              # Arbitrary non-privileged port

sock_server = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
sock_server.bind((HOST, PORT))


sock_server.listen(5) 

def connect():
    conn, addr = sock_server.accept()
    conn.settimeout(3)
    try:
        with conn:
            print('Connected by', addr)
            while True:
                data = conn.recv(1024) 
                if not data: break 
                file_path = './data/' + str(addr[0]) + '.bin'
                with open(file_path, "ab") as fo:
                    fo.write(bytes(str(datetime.datetime.now())+'   port: 80\n','utf-8'))
                    fo.write(data)
                    fo.write(bytes('\n\n','utf-8'))
                conn.sendall(b"<error>Unknown error</error>")
                break
    except Exception as e:
        print(e)
    print("done.") 

if __name__ == "__main__":
    while True:
        connect()