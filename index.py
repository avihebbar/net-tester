import threading
import commands
import re
import time
import threading

def checkConnection() :
  output = commands.getstatusoutput("./speedtest-cli")
  downloadSpeed = uploadSpeed = 0

  if(output[0] == 0):
    m = re.search('Download: [0-9]*(\.)*[0-9]*', output[1])
    downloadSpeed =  float(str.split(m.group(0), ': ')[1])

    n = re.search('Upload: [0-9]*(\.)*[0-9]*', output[1])
    uploadSpeed =  float(str.split(n.group(0), ': ')[1])
  
  f = open("speed.csv", "a")
  f.write('%s, %f, %f \n' %( time.strftime("%H:%M:%S"), downloadSpeed, uploadSpeed) )
  f.close()
  print ("Current readings noted")
  threading.Timer(10, checkConnection).start()

f = open( time.strftime("%C") + ".csv", "w")
f.write("Time, Download, Upload\n")
f.close()

checkConnection()