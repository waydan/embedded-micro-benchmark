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
from time import time#, sleep

def strip_newline(string):
    nl_match = re.compile(r'(?P<str>^.*)[/r/n]*$')
    return nl_match.match(string)['str']
    


def file_reader(file, buffer):
    for line in iter(file.readline, b''):
        buffer.put(line)
        
        
def format_input(string):
    string = strip_newline(string)
    # Return a bytestring to stdin with a single newline
    return bytes(string, 'utf-8') + b'\n'
  
          
# =============================================================================
# 
# =============================================================================
class OutputBuffer:    
    def __init__(self, file):
        self.buffer = Queue()
        Thread(target=file_reader, args=(file, self.buffer),
               daemon=True).start()
              
            
    def readline(self):
        try:
            return self.buffer.get(block=False)
        except Empty:
            return b''
    
    
    def read_all(self):
        output = b''
        try:
            output += self.buffer.get(timeout=1)
            while True:
                output += self.buffer.get(timeout=0.2)
        except Empty:
            return output
        

# =============================================================================
# 
# =============================================================================
class ProcessWrapper:
    def __init__(self, cli_program, args='', timeout=0.1):
        self.proc = Popen([cli_program] + shlex.split(args), stdin=PIPE,
                           stdout=PIPE, stderr=PIPE)
        # self.stdout = OutputBuffer(self.proc.stdout)
        # self.stderr = OutputBuffer(self.proc.stderr)
        _make_non_blocking(self.proc.stdout)
        _make_non_blocking(self.proc.stderr)
        self.timeout = timeout
        # sleep(timeout)
        self.startup_output = self.read()
        
    
    def cmd(self, command: str, silent: bool=False):
        self.write(command)
        # self.sleep(timeout)
        output = self.read()
        if not silent:
            return output
    
    
    def write(self, input_: str):
            self.proc.stdin.write(format_input(input_))
            self.proc.stdin.flush()
        
        
    def read(self):
        output = {'stdout': b'',
                  'stderr': b''}
        try:
            self.proc.stdout.flush()
            self.proc.stderr.flush()
            read_timeout = time() + 1.0
            while time() < read_timeout:
                try:
                    stdout = self.proc.stdout.readline()
                    stderr = self.proc.stderr.readline()
                except IOError:
                    stderr = b''
                    stdout = b''
                    # Check if any output was read and add adjust timeout
                if stdout or stderr:
                    output['stdout'] += stdout
                    output['stderr'] += stderr        
                    read_timeout = time() + 1
        except IOError:
            pass
        
        return output
    
    
    def __del__(self):
        self.cmd('q')
        self.proc.terminate()
        self.proc.wait()
        
        
# =============================================================================
# _make_non-blocking function from pygdbmi
# =============================================================================
import msvcrt
from ctypes import windll, byref, wintypes, WinError, POINTER
from ctypes.wintypes import HANDLE, DWORD, BOOL


def _make_non_blocking(file_obj):
    """make file object non-blocking
    Windows doesn't have the fcntl module, but someone on
    stack overflow supplied this code as an answer, and it works
    http://stackoverflow.com/a/34504971/2893090"""

    LPDWORD = POINTER(DWORD)
    PIPE_NOWAIT = wintypes.DWORD(0x00000001)

    SetNamedPipeHandleState = windll.kernel32.SetNamedPipeHandleState
    SetNamedPipeHandleState.argtypes = [HANDLE, LPDWORD, LPDWORD, LPDWORD]
    SetNamedPipeHandleState.restype = BOOL

    h = msvcrt.get_osfhandle(file_obj.fileno())

    res = windll.kernel32.SetNamedPipeHandleState(h, byref(PIPE_NOWAIT), None, None)
    if res == 0:
        raise ValueError(WinError())
    
