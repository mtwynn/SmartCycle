import pyrebase
import RPi.GPIO as GPIO
import time
import sys

# Global variable definitions
RED_LED   = 18
YELLOW_LED = 23
GREEN_LED = 25
NEUTRAL   = 0
LANDFILL  = 1
RECYCLE   = 2

# Firebase configurations

config = {
"apiKey" : "AIzaSyDwacQzMS0rK94AwxOArKNbKco2x7sSyOc",
"authDomain" : "rhosmartcycle-19",
"databaseURL" : "https://rhosmartcycle-19.firebaseio.com/",
"storageBucket" : "gs://rhosmartcycle-19.appspot.com/"
}

firebase = pyrebase.initialize_app(config)
db = firebase.database()

# Uncomment rPi code when ready to test with rPi

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(18,GPIO.OUT)
GPIO.setup(23,GPIO.OUT)
GPIO.setup(25,GPIO.OUT)


GPIO.output(YELLOW_LED, GPIO.HIGH)



## Parses data from firebase
## TODO: Implement code to turn the motor
##

data = 0
print ("Start: Neutral")
def test (message):
    data = message['data']
    if (type(data) == dict):
        data = data['SORT']
        
        
            
    if (type(data) != str): #SORT value is 0, 1, 2
        print(data)
        # Red LED (landfill)
        if (data == 0):
            GPIO.output(YELLOW_LED, GPIO.HIGH)
            
        elif (data == 1):
            GPIO.output(YELLOW_LED, GPIO.LOW)
            GPIO.output(GREEN_LED, GPIO.HIGH)
            print ("Ctr-clockwise")
            time.sleep(5)
            GPIO.output(GREEN_LED, GPIO.LOW)
            print ("Neutral")
            db.child('Current analysis').update({'SORT' : 0})
        # Green LED (recycling)
        elif (data == 2):
            GPIO.output(YELLOW_LED, GPIO.LOW)
            GPIO.output(RED_LED, GPIO.HIGH)
            print ("Clockwise")
            time.sleep(5)
            GPIO.output(RED_LED, GPIO.LOW)
            print ("Neutral")
            db.child('Current analysis').update({'SORT' : 0})
        else:
            print ("Updating")
            print("Data", data)
            db.child('Current analysis').update({'SORT' : 0})
            #sys.exit()

mystream = db.child('Current analysis').stream(test)
#mystream.close()
