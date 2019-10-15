#!/usr/bin/env python

################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
################################################################################
## applies to classes CMakeCache and CacheEntry:
##
## Copyright (c) 2009-2011,
##  Sony Pictures Imageworks Inc. and
##  Industrial Light & Magic, a division of Lucasfilm Entertainment Company Ltd.
##
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are
## met:
## *       Redistributions of source code must retain the above copyright
## notice, this list of conditions and the following disclaimer.
## *       Redistributions in binary form must reproduce the above
## copyright notice, this list of conditions and the following disclaimer
## in the documentation and/or other materials provided with the
## distribution.
## *       Neither the name of Industrial Light & Magic nor the names of
## its contributors may be used to endorse or promote products derived
## from this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
## "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
## A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
## OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
## LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
## DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
## THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
################################################################################

# Intended to work with both Python 2.7 and 3.x
# Please report bugs to https://github.com/FairRootGroup/FairSoft/issues. Thx!

from __future__ import with_statement
import curses
import glob
import locale
import os
from pathlib import Path
import re
import subprocess
from sys import platform
import sys

COMMENT = re.compile( r"//|#" )

class CacheEntry( object ):
    def __init__( self, _line ):
        line = _line.strip()
        self._value = None
        self._name = None
        self._type = None

        if not line:
            return None
        elif COMMENT.match( line ):
            return None
        else:
            # get rid of comments at the end of the line
            line = COMMENT.split( line, 1 )[0].strip()
            #  try:
            name_type, value = line.split( '=' )
            self._value = value.strip()
            if self._value == '':
                self._value = None
            name, typ = name_type.split( ':' )
            self._name = name.strip()
            self._type = typ.strip()
            #  except ValueError:
                #  sys.stderr.write( "Could not parse line '%s'\n" % _line )
                #  self._value = None
                #  self._name = None
                #  self._type = None
                #  return None

    def __str__( self ):
        val = ""
        typ = ""
        if self._value != None:
            val = self._value
        if self._type != None:
            typ = self._type

        if self._name == None:
            return ""
        else:
            s = "%s:%s=%s" % ( self._name, typ, val )
            return s.strip()

    def __eq__( self, other ):
        return str( self ) == str( other )

    def __nonzero__( self ):
        try:
            return self._name != None and self._value != None
        except AttributeError:
            return False

    def name( self ):
        return self._name

    def value( self, newval = None ):
        if newval != None:
            self._value = newval
        else:
            return self._value

    def hint( self ):
        """Return the CMakeCache TYPE of the entry; used as a hint to CMake
        GUIs."""
        return self._type

class CMakeCache( object ):
    """This class is used to read in and get programmatic access to the
    variables in a CMakeCache.txt file, manipulate them, and then write the
    cache back out."""

    def __init__( self, path=None ):
        self._cachefile = Path( path )
        _cachefile = str( self._cachefile )
        self._entries = {}
        if self._cachefile.exists():
            with open( _cachefile ) as c:
                entries = filter( None, map( lambda x: CacheEntry( x ),
                                             c.readlines() ) )
                entries = filter( lambda x: x.value() != None, entries )
                for i in entries:
                    self._entries[i.name()] = i

    def __contains__( self, thingy ):
        try:
            return thingy in self.names()
        except TypeError:
            return thingy in self._entries.values()

    def __iter__( self ):
        return self._entries

    def __nonzero__( self ):
        return len( self._entries ) > 0

    def __str__( self ):
        return os.linesep.join( map( lambda x: str( x ), self.entries() ) )

    def add( self, e ):
        if e:
            if not e in self:
                self._entries[e.name()] = e
            else:
                sys.stderr.write( "Entry for '%s' is already in the cache.\n" % \
                                      e.name() )
        else:
            sys.stderr.write( "Could not create cache entry for '%s'\n" % e )

    def update( self, e ):
        if e:
            self._entries[e.name()] = e
        else:
            sys.stderr.write( "Could not create cache entry for '%s'\n" % e )

    def names( self ):
        return self._entries.keys()

    def entries( self ):
        return self._entries.values()

    def get( self, name ):
        return self._entries[name]

    def cachefile( self ):
        return self._cachefile

    def refresh( self ):
        self.__init__( self._cachefile )

    def write( self, newfile = None ):
        if newfile == None:
            newfile = self._cachefile

        with open( newfile, 'w' ) as f:
            for e in self.entries():
                f.write( str( e ) + os.linesep )

class Question:
    def __init__(self, parent, question, answers):
        self.parent = parent
        self.question = question
        self.answers = answers
        self.selected = 1
        self.editMode = False

    def draw(self, y, x, selected):
        self.parent.addstr(y, x, "%s: %s" % (self.question, self.answer("display")),
            curses.A_REVERSE if selected else curses.A_NORMAL)
        return y + 1, x

    def answer(self, key):
        res = self.answers[self.selected - 1]
        if isinstance(res, dict):
            res = res[key]
        return res

    def edit(self):
        self.selected = (self.selected + 1) % len(self.answers)

    def handleInput(self, key):
        return True

    def editAction(self):
        return "Change"

    def controls(self):
        return []

    def setCursor(self):
        pass

    def select(self, answer):
        for i, a in enumerate(self.answers, start=1):
            if isinstance(a, dict):
                v = a["value"]
            else:
                v = a
            if answer == v:
                self.selected = i
                break

class PathQuestion(Question):
    def __init__(self, parent, question, default):
        Question.__init__(self, parent, question, [])
        self.text = default
        self.cursor = [0, 0]

    def answer(self, key):
        return self.text

    def draw(self, y, x, selected):
        if self.editMode:
            q = "%s: " % self.question
            self.parent.addstr(y, x, q, curses.A_REVERSE if selected else curses.A_NORMAL)
            self.parent.addstr(y, x + len(q), self.answer("value"))
            self.cursor = [y, x + len(q) + len(self.answer("value"))]
            return (y + 1, x)
        else:
            return Question.draw(self, y, x, selected)

    def edit(self):
        self.editMode = True

    def handleInput(self, key):
        if self.editMode:
            try:
                char = chr(key)
            except:
                raise

            try:
                char.encode('ascii')
                if (   char.isalnum()
                    or char in ["/", "_", "-", "\\", " ",  ".", "~", "$", "{", "}", "(", ")"]):
                    self.text += char
                    return False
            except:
                pass

            if key == ord("\t"):
                self.text = os.path.abspath(self.text)
                globs = glob.glob(self.text + "*")
                if len(globs) > 0:
                    self.text = os.path.commonprefix(globs)
                if os.path.isdir(self.text):
                    self.text = self.text + "/"
                self.text = os.path.expandvars(self.text)
                self.text = self.text.strip()
                return False
            elif key in [curses.KEY_ENTER, 10, 13]:
                self.editMode = False
                return False
            elif key in [curses.KEY_BACKSPACE, ord("\b")] or char in ["\u0107", "\u014a"]:
                self.text = self.text[0:-1]
        else:
            return True

    def editAction(self):
        return "Edit"

    def controls(self):
        if self.editMode:
            return ["<Tab>: Auto-complete", "<Enter>: Confirm"]
        return []

    def setCursor(self):
        if self.editMode:
            curses.curs_set(1)
            self.parent.move(*self.cursor)

class Application:
    def load(self, cache, name, default):
        try:
            return cache.get(name).value()
        except:
            return default

    def __init__(self, buildDir):
        locale.setlocale(locale.LC_ALL, '')

        cachefile = Path(buildDir) / "CMakeCache.txt"
        cache = CMakeCache(cachefile)

        self.screen = curses.initscr()
        self.screen.keypad(1)
        self.height, self.width = self.screen.getmaxyx()
        curses.start_color()
        curses.noecho()
        curses.cbreak()

        try:
            try:
                p = subprocess.Popen(["git", "describe"], stdout=subprocess.PIPE)
                self.fairsoftVersion = p.communicate()[0].strip().decode("utf-8")
            except:
                self.fairsoftVersion = "unknown"

            method = [{"display": "spack (default)", "value": "spack"}, "legacy"]
            self.methodQuestion = Question(self.screen, "Installation method", method)
            self.methodQuestion.select(self.load(cache, "BUILD_METHOD", method[0]["value"]))

            self.buildDirQuestion = PathQuestion(self.screen, "Build directory", buildDir)
            prefix = self.load(cache, "CMAKE_INSTALL_PREFIX",
                               os.path.expandvars("$HOME/fairsoft/" + self.fairsoftVersion))
            self.destinationQuestion = PathQuestion(self.screen, "Prefix (SIMPATH)", prefix)

            compilers = [{"display": "GCC (Linux)", "value": "gcc"},
                         {"display": "Clang (macOS)", "value": "Clang"}]
            if platform.startswith('darwin'):
                compilers.reverse()
            compilers += [{"display": "Intel Compiler (Linux)", "value": "intel"},
                          {"display": "CC (Solaris)", "value": "CC"},
                          {"display": "Portland Compiler", "value": "PGI"}]
            self.compilerQuestion = Question(self.screen, "Compiler", compilers)
            self.compilerQuestion.select(self.load(cache, "FAIRSOFT_COMPILER", compilers[0]["value"]))

            optimize = [{"display": "yes (default)", "value": "yes"}, "no"]
            self.optimizerQuestion = Question(self.screen, "  Optimized build", optimize)
            self.optimizerQuestion.select(self.load(cache, "FAIRSOFT_OPTIMIZE", optimize[0]["value"]))

            debug = [{"display": "no (default)", "value": "no"}, "yes"]
            self.debugQuestion = Question(self.screen, "  Debug info", debug)
            self.debugQuestion.select(self.load(cache, "FAIRSOFT_DEBUG", debug[0]["value"]))

            packagesLegacy = [{"display": "full (default)", "value": "full"},
                 {"display": "light (w/o simulation engines and event generators)", "value": "light"},
                 {"display": "FairMQ only", "value": "fairmq"},
                 {"display": "FairMQ dependencies only", "value": "fairmq_deps"}]
            self.packagesLegacyQuestion = Question(self.screen, "Packages", packagesLegacy)
            self.packagesLegacyQuestion.select(self.load(cache, "FAIRSOFT_PACKAGES", packagesLegacy[0]["value"]))

            packagesSpack = [{"display": "full (default)", "value": "full"},
                 {"display": "light (w/o simulation engines and event generators)", "value": "light"},
                 {"display": "FairMQ only", "value": "fairmq"},
                 {"display": "none (advanced, see README)", "value": "none"}]
            self.packagesSpackQuestion = Question(self.screen, "Packages", packagesSpack)
            self.packagesSpackQuestion.select(self.load(cache, "FAIRSOFT_PACKAGES", packagesSpack[0]["value"]))

            python = [{"display": "yes (default)", "value": "yes"}, "no"]
            self.pythonQuestion = Question(self.screen, "  ROOT/Geant4 Python bindings", python)
            self.pythonQuestion.select(self.load(cache, "FAIRSOFT_PYTHON", python[0]["value"]))

            geant4Mt = [{"display": "no (default)", "value": "no"}, "yes"]
            self.geant4MtQuestion = Question(self.screen, "  Geant4 multi-threaded", geant4Mt)
            self.geant4MtQuestion.select(self.load(cache, "FAIRSOFT_GEANT4_MT", geant4Mt[0]["value"]))

            geant4Data = [{"display": "download (default)", "value": "download"}, "no"]
                # TODO add directory option
                #  {"display": "from <build>/legacy/transport directory", "value": "directory"}])
            self.geant4DataQuestion = Question(self.screen, "  Geant4 data files", geant4Data)
            self.geant4DataQuestion.select(self.load(cache, "FAIRSOFT_GEANT4_DATA", geant4Data[0]["value"]))

            self.running = False
            self.selected = 1
            self.showControl = True
            self.version = "2.0 beta"
            self.title = "FairSoft Configurator v%s" % self.version
        except:
            self.shutdown()
            raise

    def questions(self):
        questions = [self.methodQuestion, self.buildDirQuestion, self.destinationQuestion]
        if self.methodQuestion.answer("value").startswith("legacy"):
            questions += [self.packagesLegacyQuestion]
            if self.packagesLegacyQuestion.answer("value").startswith("full"):
                questions += [self.pythonQuestion, self.geant4MtQuestion, self.geant4DataQuestion]
            questions += [self.compilerQuestion, self.optimizerQuestion, self.debugQuestion]
        else:
            questions += [self.packagesSpackQuestion]
        return questions

    def selectedQuestion(self):
        return self.questions()[self.selected - 1]

    def drawTitle(self, y, x):
        self.screen.addstr(y, self.width - len(self.title) - 2, self.title)
        return y + 1, x

    def drawVersion(self, y, x):
        self.screen.addstr(y, x, "FairSoft version: %s" % self.fairsoftVersion)
        return y + 2, x

    def drawQuestions(self, y, x):
        i = 1
        for question in self.questions():
            y, x = question.draw(y, 4, self.selected == i)
            i += 1
            if i == 4:
                y += 1
        return y, x

    def drawControls(self, y, x):
        controls = []
        if self.showControl:
            controls += ["<Up>/<Down>/<Tab>: Select",
                "<Enter>/<Space>: " + self.selectedQuestion().editAction(),
                "a/<F5>: Apply and Exit",
                "q/^C: Abort"]
        else:
            controls += self.selectedQuestion().controls() + ["^C: Abort"]
        self.screen.addstr(y, x, "   ".join(controls))
        return y + 1, x

    def resize(self):
        if curses.is_term_resized(self.height, self.width):
            self.height, self.width = self.screen.getmaxyx()
            self.screen.clear()
            curses.resizeterm(self.height, self.width)
            self.screen.refresh()

    def run(self):
        self.running = True
        while self.running:
            self.resize()
            self.screen.move(0, 0)
            self.screen.erase()
            if self.showControl:
                curses.curs_set(0)
            y, x = (0, 0)
            y, x = self.drawTitle(y, x)
            y, x = self.drawVersion(y, 2)
            y, x = self.drawQuestions(y, x)
            y, x = self.drawControls(y + 1, 2)
            self.screen.refresh()
            if not self.showControl:
                self.selectedQuestion().setCursor()
            key = self.screen.getch()
            if key == curses.KEY_RESIZE:
                self.resize()
            else:
                self.showControl = self.selectedQuestion().handleInput(key)
                if self.showControl:
                    self.handleInput(key)
                self.showControl = not self.selectedQuestion().editMode

    def handleInput(self, key):
        if key == curses.KEY_DOWN:
            if self.selected < len(self.questions()):
                self.selected += 1
        elif key == curses.KEY_UP:
            if self.selected > 1:
                self.selected -= 1
        elif key == ord("\t"):
            self.selected += 1
            if self.selected > len(self.questions()):
                self.selected = 1
        elif key == ord("q"):
            self.running = False
        elif key == curses.KEY_ENTER or key == 10 or key == 13 or key == ord(' '):
            self.selectedQuestion().edit()
        elif key == curses.KEY_F5 or key == ord('a'):
            self.exportToCmake()
            self.running = False

    def updateCache(self, cache, ename, etype, evalue):
        try:
            entry = cache.get(ename)
        except KeyError:
            entry = CacheEntry("%s:%s=" % (ename, etype))
        entry.value(evalue)
        cache.update(entry)

    def exportToCmake(self):
        buildDir = Path(self.buildDirQuestion.answer(None))
        try:
            os.makedirs(buildDir)
        except OSError as ex:
            if not ex.errno == 17: # File exists
                raise ex
        self.cachefile = Path(buildDir) / "CMakeCache.txt"
        self.cache = CMakeCache(self.cachefile)

        self.updateCache(self.cache, "CMAKE_INSTALL_PREFIX", "PATH",
                         self.destinationQuestion.answer(None))
        method = self.methodQuestion.answer("value")
        self.updateCache(self.cache, "BUILD_METHOD", "STRING", method)
        if "legacy" == method:
            self.updateCache(self.cache, "FAIRSOFT_COMPILER", "STRING",
                             self.compilerQuestion.answer("value"))
            self.updateCache(self.cache, "FAIRSOFT_DEBUG", "STRING",
                             self.debugQuestion.answer("value"))
            self.updateCache(self.cache, "FAIRSOFT_OPTIMIZE", "STRING",
                             self.optimizerQuestion.answer("value"))
            packages = self.packagesLegacyQuestion.answer("value")
            self.updateCache(self.cache, "FAIRSOFT_PACKAGES", "STRING",
                             self.packagesLegacyQuestion.answer("value"))
            if "full" == packages:
                self.updateCache(self.cache, "FAIRSOFT_PYTHON", "STRING",
                                 self.pythonQuestion.answer("value"))
                self.updateCache(self.cache, "FAIRSOFT_GEANT4_MT", "STRING",
                                 self.geant4MtQuestion.answer("value"))
                self.updateCache(self.cache, "FAIRSOFT_GEANT4_DATA", "STRING",
                                 self.geant4DataQuestion.answer("value"))
        else:
            # TODO Wire up spack options
            pass

        self.cache.write()

    def shutdown(self):
        curses.curs_set(1)
        curses.nocbreak()
        curses.echo()
        self.screen.keypad(0)
        curses.endwin()

def main():
    buildDir = os.path.abspath(sys.argv[1] if len(sys.argv) == 2 else "build")
    try:
        app = Application(buildDir)
        app.run()
        app.shutdown()

        sourceDir = Path(os.path.dirname(os.path.realpath(sys.argv[0])))
        buildDir = Path(app.buildDirQuestion.answer(None))

        buildDir_pre13_1 = buildDir
        buildDir_pre13_2 = buildDir
        buildDir_post13 = buildDir
        sourceDir_pre13 = sourceDir
        sourceDir_post13 = sourceDir
        if sourceDir == buildDir.parent:
            buildDir_pre13_1 = buildDir.parts[-1]
            buildDir_pre13_2 = "."
            sourceDir_pre13 = ".."
            buildDir_post13 = buildDir.parts[-1]
        if sourceDir == Path.cwd():
            sourceDir_post13 = "."

        #  print("\n".join(("  %s" % str(e)) for e in app.cache.entries()))
        try:
            print("%s written." % app.cachefile)
            print()
            if "legacy" == app.methodQuestion.answer("value"):
                print("Continue the FairSoft installation with:")
                print()
                print("(CMake < 3.13)")
                print("  cd %s" % buildDir_pre13_1)
                print("  cmake %s" % sourceDir_pre13)
                print("  cmake --build %s --target install" % buildDir_pre13_2)
                print()
                print("(CMake >= 3.13)")
                print("  cmake -S %s -B %s" % (sourceDir_post13, buildDir_post13))
                print("  cmake --build %s --target install" % buildDir_post13)
            else:
                print("Guided spack installation method not yet implemented.")
        except:
            print("CMakeCache.txt NOT updated. FairSoft Configurator aborted.")
            pass
    except KeyboardInterrupt:
        app.shutdown()
    except:
        app.shutdown()
        raise

if __name__ == "__main__":
    main()
