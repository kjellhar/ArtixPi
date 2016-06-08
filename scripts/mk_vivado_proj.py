#!/usr/bin/python

import sys
import os

if len(sys.argv)==1:
	print "No project name."
	sys.exit()


projectName = sys.argv[1]
print "Project name is ", projectName

folders = [
	projectName, 
	projectName+"/scripts", 
	projectName+"/src", 
	projectName+"/src/hdl",
	projectName+"/src/xdc",
	projectName+"/src/hls",
	projectName+"/work"]

if not os.path.exists(projectName):
	for folder in folders: 
		os.makedirs(folder)
		open(folder+"/README", 'a').close	
