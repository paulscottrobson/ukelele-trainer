# *********************************************************************************************************
#
#		Name:		compiler.py
#		Purpose:	compiler wrapper / utilities
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Date:		4 Nov 2016
#
# *********************************************************************************************************

import os,sys,re
from songc import SongCompiler

# *********************************************************************************************************
#												Compiler class
# *********************************************************************************************************

class Compiler:
	def __init__(self,sourceFile,objectFile,compilerObject):
		src = self.readSourceFile(sourceFile)											# read and preprocess
		src = self.processAssignments(src,sourceFile)									# process assignments
		self.tgt = open(objectFile,"w")													# write to object file.
		#self.tgt = sys.stdout 
		self.renderAssignments(self.tgt)												# render assignments
		self.currentBar = 10001000 														# current bar position
		self.currentBeat = 0 															# beat position in note.
		for i in range(0,len(src)):														# for each line
			if src[i] != "":															# if not empty
				compilerObject.processLine(src[i],i+1,self)								# compile it.
		if self.tgt != sys.stdout:														# close file.
			self.tgt.close()

	def readSourceFile(self,sourceFile):
		if not os.path.isfile(sourceFile):												# check file exists
			raise CompilerException("File "+sourceFile+"does not exist")
		src = [x.replace("\t"," ") for x in open(sourceFile).readlines()]				# read file, handle tabs
		src = [x if x.find("//") < 0 else x[:x.find("//")] for x in src]				# remove comments
		src = [x.strip().lower() for x in src]											# trim lines
		return src
		
	def processAssignments(self,src,sourceFile):
		self.assignments = { "beats":"4","tempo":"120","syncopation":"50","translator":"paul robson","author":"" }
		self.assignments["name"] = os.path.splitext(os.path.split(sourceFile)[1])[0].lower()
		for s in [x for x in src if x.find(":=") >= 0]:									# find assignments
			sa = [x.strip().lower() for x in s.split(":=")]								# split into parts
			if len(sa) != 2:
				raise CompilerException("Syntax error in assignment "+s)
			self.assignments[sa[0]] = sa[1]												# update assignments		
		return [x if x.find(":=") < 0 else "" for x in src]								# remove assignments

	def renderAssignments(self,tgt):
		keys = [x for x in self.assignments.keys()]										# get keys
		keys.sort()																		# sort them.
		for i in range(0,len(keys)):													# for each key.
			tgt.write("{0:08}:{1}:={2}\n".format(i+1000000,keys[i],self.assignments[keys[i]]))

	def generateLyric(self,lyric):
		self.tgt.write("{0:08}:\"{1}\"\n".format(self.currentBar,lyric))

	def generateNote(self,note,line,chord = "",upStroke = False):
		note = [x if x is not None else 99 for x in note]								# convert non-played to 99
		note = "".join(["{0:02}".format(x) for x in note])								# make a string
		if chord != "":																	# add chord if required
			note = note + ";"															# add semicolon seperator
			if upStroke:																# add ^ if upstroke.
				note = note + "^"
			note = note + (chord.lower())												# add chord body
		self.tgt.write("{0:08}:{1}\n".format(int(self.currentBar+self.currentBeat),note)) # write it out.

	def isBeatPositionValid(self):
		return int(self.currentBeat) < 1000

	def advancePointer(self,beatNumber):
		beats = int(self.assignments["beats"])
		self.currentBeat += 1000.0 / beats * beatNumber

	def advanceUnit(self,beatCount):
		self.currentBeat += beatCount

	def getBeats(self):
		return int(self.assignments["beats"])

	def getAssign(self,key):
		key = key.lower().strip()
		if key in self.assignments:
			return self.assignments[key]
		else:
			return None
			
	def getBar(self):
		return (self.currentBar - 10000000) / 1000

	def getDecode(self):
		return "0123456789tlwhf"
		
	def nextBar(self):
		self.currentBar += 1000
		self.currentBeat = 0

if __name__ == '__main__':
	from builder import CompilerDispatcher
	c = Compiler("test.song","../app/media/music/test2.music",CompilerDispatcher())
