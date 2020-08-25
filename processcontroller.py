# -*- coding: utf-8 -*-
"""
Created on Fri Aug 21 14:43:51 2020

@author: w6733
"""
from subprocess import Popen, PIPE
from threading import Thread
from queue import Queue, Empty
import shlex
import re

def strip_newline(string):
    nl_match = re.compile(r'(?P<str>^.*)[/r/n]*$')
    return nl_match.Match(string)['str']
    


def file_reader(file, buffer):
    for line in iter(file.readline, b''):
        buffer.put(line)
        
        
def format_input(string):
    string = strip_newline(string)
    # Return a bytestring to stdin with a single newline
    return bytes(string, 'utf-8') + b'\n'
  
          

class OutputBuffer:    
    def __init__(self, file):
        self.buffer = Queue()
        Thread(target=file_reader, args=(file, self.buffer),
               daemon=True).start()
              
            
    def readline(self, timeout=0.1):
        try:
            return self.buffer.get(timeout=timeout)
        except Empty:
            return b''
    
    
    def read_all(self, timeout=0.1):
        output = b''
        try:
            while True:
                output += self.buffer.get(timeout=timeout)
        except Empty:
            return output
        



class Process:
    def __init__(self, cli_program, args=''):
        self.proc = Popen([cli_program] + shlex.split(args), stdin=PIPE,
                           stdout=PIPE, stderr=PIPE)
        self.stdout = OutputBuffer(self.proc.stdout)
        self.stderr = OutputBuffer(self.proc.stderr)
        self.startup_output = self.read()
        
    
    def cmd(self, command: str, silent: bool=False):
        self.write(command)
        output = self.read()
        if not silent:
            return output
    
    
    def write(self, input_: str):
        self.proc.stdin.write(format_input(input_))
        self.proc.stdin.flush()
        
        
    def read(self):
        return {'stdout': self.stdout.read_all(),
                'sdterr': self.stderr.read_all()}
    
    
    def __del__(self):
        self.proc.terminate()
        self.proc.wait()
        
    
