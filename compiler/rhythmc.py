# *********************************************************************************************************
#
#		Name:		rhythmc.py
#		Purpose:	Rhythm format compiler.
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Date:		12 Nov 2016
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
		if line.find('"') < 0:															# add default "lyric"
			line = line + ' ""'
		lyric = re.search('(\\".*\\")',line)											# find the lyric
		if lyric is None:
			self.reportError("Lyric Syntax",line)
		lyric = lyric.group(1) 															# this is the lyric
		line = line.replace(lyric,"").strip()											# remove it from line.
		lyric = lyric[1:-1].strip().split("/")											# strip spaces, split up
		lyric = [x.strip().lower() for x in lyric]										# strip spaces individually

		m = re.search("\\@([1-9])",line)												# look for pattern
		if m is not None:
			self.currentPattern = int(m.group(1))
			line = line.replace("@"+str(self.currentPattern),"").strip()
			self.patternStarted = wrapper.getBar()
			
		if re.match("^\\{.*\\}$",line) is None:											# rest must be {}
			self.reportError("Bad line",line)
		line = [x for x in line[1:-1].strip().split() if x != ""] 						# split chords up.
		while len(line) < wrapper.getBeats():											# pad it out
			line.append("-")
		if len(line) > wrapper.getBeats():												# check not too long.
			self.reportError("{} wrong size","")

		for i in range(0,wrapper.getBeats()):											# for each beat.
			if line[i] == "-":															# fill it with current
				line[i] = self.currentChord
			else:																		# or current is this ..
				self.currentChord = line[i]

		for partLyric in lyric:															# for each lyric part
			wrapper.generateLyric(partLyric)
			pattern = wrapper.getAssign("pattern_"+str(self.currentPattern))			# get current pattern
			if pattern is None:
				self.reportError("No such pattern",str(self.currentPattern))
			pattern = pattern.replace(":","")											# remove seperators
			if len(pattern) % (wrapper.getBeats()*2) > 0:								# check it fits.
				self.reportError("Pattern size",str(self.currentPattern))
			patternCount = int(len(pattern)/(wrapper.getBeats()*2))						# how many patterns ?
			barOffset = wrapper.getBar()-self.patternStarted							# offset in pattern.
			n = int(barOffset % patternCount) 											# index into pattern to use
			pattern = pattern[(n*(wrapper.getBeats()*2)):]								# extract pattern
			pattern = pattern[:wrapper.getBeats()*2]

			for n in range(0,len(pattern)):												# for each strum
				strum = pattern[n]
				if strum != "." and strum != " ":										# if actual strum.
					chord = line[int(n/2)]												# get chord for it.
					if chord != "x":													# if not no-chord
						#print(strum,wrapper.currentBeat,chord)
						chordDef = self.convertToChord(chord)							# convert to chord
						chord = chord if chord.find(":") < 0 else chord[:chord.find(":")]
						chord = chord.lower().strip()
						isUpper = (n % 2) != 0
						if strum == "n" or strum == "^":
							isUpper = True
						if strum == "v":
							isUpper = False
						wrapper.generateNote(chordDef,self.currentNumber,chord,isUpper)

				synco = int(wrapper.getAssign("syncopation"))							# get syncopation.
				synco = synco - 50 														# now range -50 to 50
				if n % 2 != 0:															# offset alternates.
					synco = -synco
				synco = synco / 50.0 + 1 												# convert to scalar
				synco = synco * 1000 / wrapper.getBeats() / 2							# convert to millibeat
				wrapper.advanceUnit(synco)												# advance by that.

			#print(line,partLyric,patternCount,barOffset,n,pattern)
			wrapper.nextBar()															# end of bar

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
		std = """
			A=2100 Am=2000 A7=0100
			B=4322 Bm=4222 B7=2322
			C=0003 Cm=0333 C7=0001
			D=2220 Dm=2210 D7=2223
			E=4442 Em=0432 E7=1202
			F=2010 Fm=1013 F7=2313
			G=0232 Gm=0231 G7=0212
		""".lower().split()
		self.library = {}
		for s in std:
			s1 = s.split("=")
			self.library[s1[0].strip()] = s1[1].strip()
		#print(self.library)

#todo: fix 8 and