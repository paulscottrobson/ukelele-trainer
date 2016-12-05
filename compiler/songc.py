# *********************************************************************************************************
#
#		Name:		songc.py
#		Purpose:	song format compiler.
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Date:		4 Nov 2016
#
# *********************************************************************************************************

import os,sys,re
from compilerex import CompilerException

# *********************************************************************************************************
#												Song Compiler
# *********************************************************************************************************

class SongCompiler:
	def __init__(self):
		self.defaultBeat = 1.0 															# default for note.
		self.currentString = 1 															# current string
		self.overrideCurrentString = None 												# when set overrides once.
		self.adjusters = { "&":1,"o":1,"-":-0.5,"=":-0.75,".":0.5 }						# offsetters

	def processLine(self,line,number,wrapper):
		self.currentNumber = number 													# save line number.
		self.wrapper = wrapper
		fretDecode = wrapper.getDecode()												# get char->fret
		for bar in line.split("|"):														# for each bar.
			bar = bar.strip().lower()													# preprocess		
			if bar != "":																# if not empty.
				#print("**** "+bar+" ****")
				bar = self.processLyrics(bar).strip()
				while bar != "":														# something to do.
					if "eadg".find(bar[0]) >= 0:										# is it to switch string.
						self.currentString = "eadg".find(bar[0])+1
						bar = bar[1:]
					elif fretDecode.find(bar[0]) >= 0:									# is it a note ?
						note = [None,None,None,None]									# create the note
						string = self.currentString 									# string to sound
						if self.overrideCurrentString is not None: 						# check for override
							string = self.overrideCurrentString
							self.overrideCurrentString = None
						if string < 1 or string > 4:									# not allowed.
							self.reportError("Bad string","")
						note[string-1] = fretDecode.find(bar[0])
						if not self.wrapper.isBeatPositionValid():
							self.reportError("Bar too long",bar)
						self.wrapper.generateNote(note,self.currentNumber) 				# render it.
						self.wrapper.advancePointer(self.defaultBeat)					# and move by the default beat
						bar = bar[1:]
					elif bar[0] in self.adjusters:										# positional adjuster ?
						self.wrapper.advancePointer(self.adjusters[bar[0]])
						bar = bar[1:]
					elif bar[0] == '^' or bar[0] == 'v':								# one off shift
						self.overrideCurrentString = self.currentString + (-1 if bar[0] == '^' else 1)
						bar = bar[1:]
					elif bar[0] == '@':													# standard beat change
						if len(bar) == 1 or bar[1] < "1" or bar[1] > "4":
							self.reportError("Bad default rate ",bar)
						self.defaultBeat = 1.0 / int(bar[1])
						bar = bar[2:]
					elif re.match("\\[[0-9x][0-9x][0-9x][0-9x]\\]",bar) is not None:	# is it a multi bar strum.
						note = [None if x == 'x' else int(x) for x in bar[1:5]]			# convert it to a note
						if not self.wrapper.isBeatPositionValid():
							self.reportError("Bar too long",bar)
						self.wrapper.generateNote(note,self.currentNumber) 				# render it.
						self.wrapper.advancePointer(self.defaultBeat)					# and move by the default beat
						#print(note)
						bar = bar[6:]
					else:
						self.reportError("Syntax Error",bar)
					bar = bar.strip()
				self.wrapper.nextBar()

	def reportError(self,msg,item):
		raise CompilerException(msg+" "+item+" @ "+str(self.currentNumber))

	def processLyrics(self,bar):
		m = re.search('(\\"[a-z0-9\\.\\,\\;\\:\\s]+\\")',bar)							# check for lyrics
		if m is not None:
			self.wrapper.generateLyric(m.group(1)[1:-1].strip())						# create lyrics
			bar = bar.replace(m.group(1),"")
		return bar


