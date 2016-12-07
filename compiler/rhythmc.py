# *********************************************************************************************************
#
#		Name:		rhythmc.py
#		Purpose:	Rhythm format compiler.
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Date:		12 Nov 2016 (rewritten with new usage 23/11/16)
#
# *********************************************************************************************************

import os,sys,re
from compilerex import CompilerException

# *********************************************************************************************************
#												Song Compiler
# *********************************************************************************************************

class RhythmCompiler:
	def __init__(self):
		self.currentChord = "x"															# default is no chord
		self.currentPattern = 1 														# current pattern is 1.
		self.patternStarted = 1 														# started in first bar
		self.setupStandardChords()

	def processLine(self,line,number,wrapper):
		self.currentNumber = number 													# save line number.
		self.wrapper = wrapper
		for bar in [x.strip() for x in line.split("|") if x.strip() != ""]:				# split into bars
			self.compile(bar)

	def compile(self,bar):
		m = re.search("\\@(\\d)",bar)													# look for @n in bar.
		if m is not None:
			self.setCurrentPattern(int(m.group(1)))										# if found, set pattern.
			bar = bar.replace("@"+m.group(1),"")										# remove @x
		self.chords = [self.currentChord] * (self.wrapper.getBeats())					# chord for each beat.
		self.nextChordBeat = 1 															# where the next chord beat is.
		while bar.find("{") >= 0:														# keep going when chords in there.
			if self.nextChordBeat > self.wrapper.getBeats():							# too many chords
				self.reportError("Chord overflow",bar)
			if self.nextChordBeat == 1:													# first chord beat.
				if bar.find("{") > 0:													# but not at the start.
					self.nextChordBeat = int(self.wrapper.getBeats()/2+1)				# then start in middle.
			bar = self.extractChord(bar)												# extract a chord.
			if self.nextChordBeat == 1:													# if this was the first.					
				self.nextChordBeat = int(self.wrapper.getBeats()/2+1)					# then next in middle.
			else:
				self.nextChordBeat += 1 												# otherwise simple next.
		pattern = self.getCurrentPattern()												# get pattern
		bar = bar.strip()																# work out the lyric
		while bar.find("  ") >= 0:														# remove double spaces
			bar = bar.replace("  "," ")
		if bar != "":																	# generate lyric if exists.
			self.wrapper.generateLyric(bar)
		#print("Now ",bar,self.chords,pattern)
		for n in range(0,self.wrapper.getBeats()*2):									# check each half beat
			if pattern[n] != ".":														# pattern specified.
				chord = self.chords[int(n/2)]											# chord here
				if chord != "x":														# no chord strum now
					chordDetail = self.convertToChord(chord)							# get the chord
					isUpstroke = (n % 2) != 0 											# which direction
					#print(n,self.wrapper.currentBeat,chord,chordDetail)
					self.wrapper.generateNote(chordDetail,self.currentNumber,chord,isUpstroke)
			self.wrapper.advanceUnit(self.getSyncopationStep(n))						# move to next position
		self.currentChord = self.chords[-1]												# default chord is last of current bar
		self.wrapper.nextBar()

	def extractChord(self,bar):
		m = re.search("(\\{.*?\\})",bar)												# rip out a chord definition.
		if m is None:
			self.reportError("Syntax error",bar)
		chordDef = m.group(1)															# the full {}
		n = bar.find(chordDef)															# find first instance.
		assert n >= 0
		bar = bar[:n]+bar[n+len(chordDef):]												# extract it out.
		chordDef = chordDef[1:-1].strip()												# remove {}
		if chordDef == "":																# if empty, then no change
			return bar
		if chordDef[0] >= "1" and chordDef[0] <= str(self.wrapper.getBeats()):			# position set manually.
			self.nextChordBeat = int(chordDef[0])										# so update it
			chordDef = chordDef[1:].strip()												# and remove position

		for n in range(self.nextChordBeat-1,self.wrapper.getBeats()):					# fill to end of bar with chord
			self.chords[n] = chordDef		
		return bar

	def setCurrentPattern(self,patternID):
		self.currentPattern = patternID
		self.patternStarted = self.wrapper.getBar()

	def getCurrentPattern(self):
		pattern = self.wrapper.getAssign("pattern_"+str(self.currentPattern))			# get current pattern
		if pattern is None:
			self.reportError("No such pattern",str(self.currentPattern))
		pattern = pattern.replace(":","")												# remove seperators
		if len(pattern) % (self.wrapper.getBeats()*2) > 0:								# check it fits.
			self.reportError("Pattern size",str(self.currentPattern))
		patternCount = int(len(pattern)/(self.wrapper.getBeats()*2))					# how many patterns ?
		barOffset = self.wrapper.getBar()-self.patternStarted							# offset in pattern.
		n = int(barOffset % patternCount) 												# index into pattern to use
		pattern = pattern[(n*(self.wrapper.getBeats()*2)):]								# extract pattern
		pattern = pattern[:self.wrapper.getBeats()*2]
		return pattern.lower().replace(" ",".") 

	def getSyncopationStep(self,halfBeatNumber):
		synco = int(self.wrapper.getAssign("syncopation"))								# get syncopation.
		synco = synco - 50 																# now range -50 to 50
		if halfBeatNumber % 2 != 0:														# offset alternates.
			synco = -synco
		synco = synco / 50.0 + 1 														# convert to scalar
		synco = synco * 1000 / self.wrapper.getBeats() / 2								# convert to millibeat
		return synco

	def convertToChord(self,chordDef):
		if chordDef.find(":") < 0:														# no definition.
			chord = self.wrapper.getAssign("chord_"+chordDef)							# look up in assigns
			if chord is None: 															# look up in library
				if chordDef in self.library:
					chord = self.library[chordDef]
			if chord is None:
				self.reportError("Unknown chord",chordDef)
			chordDef = chord
		else:
			chordDef = chordDef[chordDef.find(":")+1:].strip()							# definition provided.
		if len(chordDef) != 4:
			self.reportError("Chord wrong length",chordDef)
		return [self.convertFret(x) for x in chordDef]

	def convertFret(self,c):
		if c == 'x':
			return None
		n = self.wrapper.getDecode().find(c)
		if n < 0:
			self.reportError("Bad Fret",c)
		return n

	def reportError(self,msg,item):
		raise CompilerException(msg+" "+item+" @ "+str(self.currentNumber))


	def setupStandardChords(self):
		self.library = {}
