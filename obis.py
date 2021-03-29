"""
Obis Laser Control (RS-232 over USB)

!!! All Powers are notated in mW!!!
Kwangmin Ryu, 2021/3/29
(Original code from X. Zhuang lab, MIT)
"""
import traceback

import RS232

class Obis(RS232.RS232):
    """
    This controls a Coherent Obis laser using RS-232.
    """
    def __init__(self, **kwds):
        """
        Connect to the laser at the specified port and verify that the laser is responding.
        """
        # Add Obis RS232 default settings.
        kwds["baudrate"] = 9600
        kwds["end_of_line"] = "\r"
        kwds["wait_time"] = 0.05
        
        self.on = False
        self.pmin = None
        self.pmax = None
            
        try:
            # Open port.
            super().__init__(**kwds)

            # See if the laser is connected.
            assert not(self.commWithResp("?SYSTem:INFormation:MODel?") == None)

        except (AttributeError, AssertionError):
            print(traceback.format_exc())
            self.live = False
            print("Failed to connect to Obis Laser at port", kwds["port"])
            print("Perhaps it is turned off or the COM ports have")
            print("been scrambled?")

        if self.live:
            self.pmin, self.pmax = self.getPowerRange()
            self.setExtControl(False)
            if (not self.getLaserOnOff()):
                self.setLaserOnOff(True)

        self.handshake = self.getHandshakeState()
            

    #def respToFloat(self, resp, start):
    #    return float(resp[start:-1])
    def getHandshakeState(self):
        """
        Return True/False whether system handshaking is on/off
        """
        self.sendCommand("SYSTem:COMMunicate:HANDshaking?")
        response = self.waitResponse()

        if ("ON" in response):
            return True
        else:
            return False

    def getExtControl(self):
        """
        Return True/False the laser can be controlled with an external voltage.
        """
        self.sendCommand("SOURce:AM:SOURce?")
        response = self.waitResponse()
        if ("CWP" in response) or ("CWC" in response):
            return False
        else:
            return True

    def getLaserOnOff(self):
        """
        Return True/False the laser is on/off.
        """
        self.sendCommand("SOURce:AM:STATe?")
        resp = self.waitResponse()
        if ("ON" in resp):
            self.on = True
            return True
        else:
            self.on = False
            return False

    def getPowerRange(self):
        """
        Return [minimum power, maximum power] in mW.
        """
        self.sendCommand("SOURce:POWer:LIMit:LOW?")
        pmin = 1000.0 * float(self.waitResponse().split("\r")[0])
        self.sendCommand("SOURce:POWer:LIMit:HIGH?")
        pmax = 1000.0 * float(self.waitResponse().split("\r")[0])
        return pmin, pmax

    def getPower(self):
        """
        Return the current laser power in mW
        """
        self.sendCommand("SOURce:POWer:LEVel?")
        #print(self.waitResponse())
        return 1000.0 * float(self.waitResponse().split("\r")[0])

    def setHandshakeState(self, on):
        """
        Turn on/off system handshaking.
        """

        if on and (not self.handshake):
            self.sendCommand("SYSTem:COMMunicate:HANDshaking ON")
            self.waitResponse()
            self.handshake = True

        if (not on) and self.handshake:
            self.sendCommand("SYSTem:COMMunicate:HANDshaking OFF")
            self.waitResponse()
            self.handshake = False

    def setExtControl(self, mode):
        """
        Turn on/off external control mode.
        """
        if mode:
            self.sendCommand("SOURce:AM:EXTernal DIGital")
        else:
            self.sendCommand("SOURce:AM:INTernal CWP")
        self.waitResponse()

    def setLaserOnOff(self, on):
        """
        Turn the laser on/off.
        """
        if on and (not self.on):
            self.sendCommand("SOURce:AM:STATe ON")
            self.waitResponse()
            self.on = True
        if (not on) and self.on:
            self.sendCommand("SOURce:AM:STATe OFF")
            self.waitResponse()
            self.on = False

    def setLaserOn(self):
        """
        Turn the laser on.
        """
        if (not self.on):
            self.sendCommand("SOURce:AM:STATe ON")
            self.waitResponse()
            self.on = True

    def setLaserOff(self):
        """
        Turn the laser off.
        """
        if self.on:
            self.sendCommand("SOURce:AM:STATe OFF")
            self.waitResponse()
            self.on = False

    def setPower(self, power_in_mw):
        """
        power_in_mw - The desired laser power in mW.
        """
        if self.pmax is None:
            self.pmin, self.pmax = self.getPowerRange()
        if power_in_mw > self.pmax:
            print("request exceeded maximum power. power will be set on its maximum : {} mW".format(self.pmax))
            power_in_mw = self.pmax
        if power_in_mw < self.pmin:
            print("invalid request (too low input). power will be set on its minimum : {} mW".format(self.pmin))
            power_in_mw = self.pmin
        self.sendCommand("SOURce:POWer:LEVel:IMMediate:AMPLitude " + str(0.001 * power_in_mw))
        self.waitResponse()

    def shutDown(self):
        """
        Turn the laser off and close the RS-232 port.
        """
        if self.live:
            self.setLaserOnOff(False)
        super().shutDown()


#
# Testing
#
if (__name__ == "__main__"):
    import time
    
    obis = Obis(port = "COM5")
    if obis.getStatus():
        obis.setLaserOff()
        obis.setPower(150.0)
        print(obis.pmin, obis.pmax)
        print(obis.getPowerRange())
        print(obis.getLaserOnOff())
        print(obis.getHandshakeState())
        print(obis.getPower())
        #obis.setLaserOff()
        #time.sleep(10)
        #obis.shutDown()