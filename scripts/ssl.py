#!/usr/bin/python3
# To decode TLS 1.3 Hello Client packet trace from mod_ssl

import sys

def main():
  print(f"Arguments count: {len(sys.argv)}")
  for i, arg in enumerate(sys.argv):
    filename = {arg}
    print(f"Argument {i:>6}: {arg}")

  with open(arg) as file:
    msg = bytearray()
    for line in file:
      if line.endswith("|\n"):
        start = " | "
        end = "|\n"
        string = (line.split(start))[1].split(end)[0]
        data = string[6:-19]
        data = data.replace('-', ' ')
        print(data)
        hexdata = bytearray.fromhex(data)
        msg += hexdata

    print(msg)

    # analisys of the message
    i  = 3
    if msg[0] == 0x16:
      print("TLS handshake protocol")
      print("Version: "  + str(msg[1]) + str(msg[2]))
      # length is the 2 next bytes
      l = msg[3]*256 + msg[4]
      print("Length: "  + str(l) + ":" + str(len(msg)))
      if l > len(msg):
        raise SystemExit("not enough bytes in the trace")
      i = 5
      if msg[5] == 0x01:
        print("client hello")
        l = (msg[6]*256 + msg[7])*256 + msg[8]
        print("Payload length: "  + str(l))
        # version again
        i = 9
        i += 2
        # Client Random
        i += 32
        # Client Session
        l = msg[i]
        print("Session ID length: " + str(l))
        i += l + 1
        # Cipher Suites
        l = msg[i]*256 + msg[i+1]
        print("Cipher Suites length: " + str(l))
        i +=l + 2
        # Compression Methods
        l = msg[i]
        print("Compression Methods length: " + str(l))
        i +=l + 1
        # Extensions
        l = msg[i]*256 + msg[i+1]
        print("Extensions length: " + str(l))
        i += 2
        endext = i + l
        while i < endext:
          # the extensions are 2 bytes type + 2 bytes length + value
          t = msg[i]*256 + msg[i+1]
          i += 2
          l = msg[i]*256 + msg[i+1]
          i += 2
          print("Extension: " + str(t) + " length: " + str(l))
          if t == 0:
            # the sni several pieces 2 byte length + 1 byte type + 2 byte length
            j = i + 3
            snil = msg[j]*256 + msg[j+1]
            j +=3
            sni = msg[j:j+snil]
            print("SNI: length: " + str(snil) + " value: " +  str(sni))
          if t == 41:
            print("pre_shared_key")
          if t == 65281:
            print("65281: weird...")
          i += l

        print("client hello: " + str(i) + " bytes decoded")


if __name__=="__main__":
   main()
