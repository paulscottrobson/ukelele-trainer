# *********************************************************************************************************
#
#		Name:		builder.py
#		Purpose:	tree builder
#		Author:		Paul Robson (paul@robsons.org.uk)
#		Date:		5 Nov 2016
#
# *********************************************************************************************************

import os,sys,re
from songc import SongCompiler
from rhythmc import RhythmCompiler
from compiler import Compiler
from compilerex import CompilerException

class CompilerDispatcher:
	def __init__(self):
		self.noteCompiler = SongCompiler()
		self.rhythmCompiler = RhythmCompiler()

	def processLine(self,line,lineNumber,wrapper):
		if line.find("{") >= 0:
			self.rhythmCompiler.processLine(line,lineNumber,wrapper)
		else:
			self.noteCompiler.processLine(line,lineNumber,wrapper)

class Index:
	def __init__(self,path):
		self.items = []
		self.rootPath = path

	def addDirectory(self,dir):
		self.items.append("*"+dir.strip().lower())

	def addFile(self,file):
		file = file.strip().lower()
		self.items.append(file)

	def renderIndex(self):
		self.items.sort()
		h = open(self.rootPath+os.sep+"index.txt","w")
		h.write("\n".join(self.items)+"\n")
		h.close()

class TreeBuilder:
	def __init__(self,sourceDir,objectDir,rebuildAll = True):
		self.rebuildAll = rebuildAll
		self.objectDir = objectDir
		self.compiles = 0
		self.indices = 0
		for path,dirs,files in os.walk(sourceDir):
			self.targetDir = objectDir+(path[len(sourceDir):].lower())
			index = Index(self.targetDir)
			for d in dirs:
				index.addDirectory(d)
				if not os.path.exists(self.targetDir+os.sep+d):
					os.makedirs(self.targetDir+os.sep+d)
					#print("Making "+self.targetDir+os.sep+d)
			for f in files:
				f2 = (os.path.splitext(f)[0]+".music").lower()
				if self.compile(path+os.sep+f,self.targetDir+os.sep+f2):
					index.addFile(f2)
			index.renderIndex()
			self.indices += 1
		print("Compiled {0} pieces of music and built {1} indices.".format(self.compiles,self.indices))

	def compile(self,src,object):
		if not self.rebuildAll:
			if not self.checkRebuild(src,object):
				return True
		print("Compiling "+src)
		try:
			c = Compiler(src,object,CompilerDispatcher())
		except CompilerException as e:
			print("**ERROR** "+e.message)
			sys.exit(1)

		self.compiles += 1
		return True

	def checkRebuild(self,src,object):
		if not os.path.isfile(object):
			return True
		return os.path.getmtime(src) > os.path.getmtime(object)

if __name__ == '__main__':
	c = TreeBuilder("../music","../app/media/music",False or True)
	sys.exit(0)

