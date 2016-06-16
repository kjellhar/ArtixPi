#!/usr/bin/python

import sys
import os
from shutil import copyfile


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
	projectName+"/src/ip",
	projectName+"/work"]

if not os.path.exists(projectName):
	for folder in folders: 
		os.makedirs(folder)
		open(folder+"/README", 'a').close

copyfile("./scripts/template_files/build_project.tcl", projectName+"/scripts/build_project.tcl")
copyfile("./scripts/template_files/artixpi_io.xdc", projectName+"/src/xdc/artixpi_io.xdc")
copyfile("./scripts/template_files/artixpi_config_spi.xdc", projectName+"/src/xdc/artixpi_config_spi.xdc")
