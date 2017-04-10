#!/usr/bin/env python2.7  
#Created By: Dan Fanara,William Komer,Paul Birkholtz
import RPi.GPIO as GPIO  
GPIO.setmode(GPIO.BCM)  
import time
import threading
import SocketServer
import BaseHTTPServer
 
# GPIO 23 & 17 set up as inputs, pulled up to avoid false detection.  
# Both ports are wired to connect to GND on button press.  
# So we'll be setting up falling edge detection for both  
#GPIO.setup(23, GPIO.IN, pull_up_down=GPIO.PUD_UP)  
GPIO.setup(17, GPIO.IN, pull_up_down=GPIO.PUD_UP)  
GPIO.setup(20, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.setup(21, GPIO.OUT)
 
# GPIO 24 set up as an input, pulled down, connected to 3V3 on button press  
#GPIO.setup(24, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)  
 
# now we'll define two threaded callback functions  
# these will run in another thread when our events are detected  
tick = 0
temp = 0
targetTemp = 0
saved = 0
thread = None
server = None
 
lastTime = 0
flowRate = 0
 
class Handler(BaseHTTPServer.BaseHTTPRequestHandler):
    def _set_headers(self):
    self.send_response(200)
    self.send_header('Content-Type', 'text')
    self.end_headers()
 
    def do_GET(self):
    global tick
    global temp
    global targetTemp
    global saved
   
    self._set_headers()
 
        if "api/data" in self.path:
        self.wfile.write(temp)
        self.wfile.write(";")
        self.wfile.write(tick * 0.00007016953)
        self.wfile.write(";")
        self.wfile.write(saved)
    elif "api/set_temp/" in self.path:
        targetTemp = float(self.path.split("/")[-1])
        self.wfile.write("ok")
 
    def do_HEAD(self):
    self._set_headers()
    self.wfile.write("{}")
    def do_POST(self):
    self._set_headers()
    self.wfile.write("{}")
#-- FLOW SENSOR --
def flow_sensor_tick(channel):  
    global tick
    global lastTime
 
    if lastTime != 0:
    delta = time.time() - lastTime
    flowRate = 1 / delta
 
    lastTime = time.time()
    tick+=1 #0.009009
#-- Grab Temperature
def grab_temperature():
    with open("/sys/bus/w1/devices/28-0416932306ff/w1_slave") as f:
    content = f.readlines()
    content = [x.strip() for x in content]
    x = len(content)
    if x >= 2:
    global temp
    temp = float(content[1].split("=")[1])/1000.0
    temp = temp * 9.0 / 5.0 + 32
 
def setup_http():
    global thread
    global server
 
    server = SocketServer.TCPServer(("", 80), Handler)
 
    thread = threading.Thread(target = server.serve_forever)
    thread.start()
 
def start_pump():
    GPIO.output(21, 0)
 
def stop_pump():
    GPIO.output(21, 1)
 
def check_matt():
    return GPIO.input(20)
 
 
setup_http()
 
# when a falling edge is detected on port 17, regardless of whatever  
# else is happening in the program, the function my_callback will be run  
GPIO.add_event_detect(17, GPIO.RISING, callback=flow_sensor_tick)  
 
stop_pump()
 
try:  
    print "Press matt to start program"
    secondLast = time.time()
 
    while check_matt() == 0:
    grab_temperature()
    print temp
 
    grab_temperature()
    targetTemp = temp - 2
 
    while True:
    grab_temperature()
 
        if check_matt():
        secondLast = 0
        start_pump()
    else:
        if (temp > targetTemp):
        stop_pump()
        if secondLast != 0:
            saved += (time.time() - secondLast) * 0.00260417
        secondLast = time.time()
        else:
        secondLast = 0
        start_pump()
 
    print "GALLONS USED:", tick * 0.00007016953, " TEMPERATURE:", temp, "TARGET TEMP:", targetTemp, "GAL SAVED:", saved
 
    stop_pump()
 
    while True:
        time.sleep(1)
 
except KeyboardInterrupt:  
    GPIO.cleanup()       # clean up GPIO on CTRL+C exit  
    server.shutdown()
GPIO.cleanup()           # clean up GPIO on normal exit  
server.shutdown()