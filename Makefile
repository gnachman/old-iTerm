##
## $Id: Makefile,v 1.7 2009-01-16 07:46:53 delx Exp $
## iTerm Makefile
## 2003 Copyright(C) Ujwal S. Setlur
##

CONFIGURATION=Development
PROJECTNAME=iTerm

all:
	xcodebuild -alltargets -configuration $(CONFIGURATION) && \
	chmod -R go+rX build

clean:
	xcodebuild -alltargets clean
	rm -rf build
	rm -f *~

Development:
	xcodebuild -alltargets -configuration Development && \
	chmod -R go+rX build/Deployment

Deployment:
	xcodebuild -alltargets -configuration Deployment && \
	chmod -R go+rX build/Deployment


