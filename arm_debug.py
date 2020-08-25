# -*- coding: utf-8 -*-
"""
Created on Wed Aug 19 13:57:07 2020

@author: w6733
"""
import re
from pygdbmi.gdbcontroller import GdbController

reg_value = re.compile(r"^.*\(.*= (?P<value>0x[0-9a-f]+)\)", re.I)

reg_list = ['r%d' % n for n in range(16)] \
         + ['lr', 'pc', 'msp', 'psp'] \
         + ['xpsr', 'apsr', 'epsr', 'ipsr'] \
         + ['cfbp', 'control', 'faultmask', 'basepri', 'primask']



class ProbeSession(object):
    def __init__(self, port, host_ip="localhost"):
        self.session = GdbController(gdb_path="arm-none-eabi-gdb")
        # Connect to the debug probe
        self.session.write("target remote %s:%s" % (host_ip, port))
        
    def __del__(self):
        # Stop the running GDB server
        self.session.exit()

       
     
    def register_read(self, reg):
        
        reg = reg.lower()
        
        if reg not in reg_list:
            raise "Specified register is not valid for this target."
        
        output = self.session.write("monitor reg %s" % reg)
        assert(output[1]['type'] == 'target')
        value = reg_value.match(output[1]['payload'])['value']
        return int(value, 16)
        
        