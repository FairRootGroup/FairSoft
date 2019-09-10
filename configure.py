#!python

################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

# Intended to work with both Python 2.7 and 3.x
# Please report bugs to https://github.com/FairRootGroup/FairSoft/issues. Thx!

import curses
from curses import panel
import glob
import os
import subprocess
from sys import platform

class Question:
    def __init__(self, parent, question, answers):
        self.parent = parent
        self.question = question
        self.answers = answers
        self.selected = 1
        self.editMode = False

    def draw(self, y, x, selected):
        self.parent.addstr(y, x, "%s: %s" % (self.question, self.answer()),
            curses.A_REVERSE if selected else curses.A_NORMAL)
        return y + 1, x

    def answer(self):
        answer = self.answers[self.selected - 1]
        if isinstance(answer, dict):
            return answer["short"]
        return answer

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

class PathQuestion(Question):
    def __init__(self, parent, question, default):
        Question.__init__(self, parent, question, [])
        self.text = default
        self.cursor = [0, 0]

    def answer(self):
        return self.text

    def draw(self, y, x, selected):
        if self.editMode:
            q = "%s: " % self.question
            self.parent.addstr(y, x, q, curses.A_REVERSE if selected else curses.A_NORMAL)
            self.parent.addstr(y, x + len(q), self.answer())
            self.cursor = [y, x + len(q) + len(self.answer())]
            return (y + 1, x)
        else:
            return Question.draw(self, y, x, selected)

    def edit(self):
        self.editMode = True

    def handleInput(self, key):
        if self.editMode:
            try:
                char = chr(key)
                if char.isalnum() or char in ["/", "_", "-", "\\", " ", ".", "~", "$", "{", "}", "(", ")"]:
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
            elif key == curses.KEY_ENTER or key == 10 or key == 13:
                self.editMode = False
                return False
            elif key == curses.KEY_BACKSPACE:
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
    def __init__(self):
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

            self.methodQuestion = Question(self.screen, "Installation method", ["legacy", "spack"])

            defaultCompilers = []
            if platform.startswith('darwin'):
                defaultCompilers = ["Clang (macOS)", "GCC (Linux)"]
            else:
                defaultCompilers = ["GCC (Linux)", "Clang (macOS)"]
            self.compilerQuestion = Question(self.screen, "Compiler",
                defaultCompilers + ["Intel Compiler (Linux)", "CC (Solaris)", "Portland Compiler"])
            self.optimizerQuestion = Question(self.screen, "  Optimized build", ["yes", "no"])
            self.debugQuestion = Question(self.screen, "  Debug Info", ["no", "yes"])
            self.packagesQuestion = Question(self.screen, "Packages",
                ["all", "FairMQ only", "FairMQ dependencies only"])
            self.simQuestion = Question(self.screen, "  Simulation engines and event generators", ["yes", "no"])
            self.pythonQuestion = Question(self.screen, "  ROOT/Geant4 Python Bindings", ["yes", "no"])
            self.geant4MtQuestion = Question(self.screen, "  Geant4 Multi-threaded", ["no", "yes"])
            self.geant4DataQuestion = Question(self.screen, "  Geant4 Data Files",
                ["download", "no", "from <build>/legacy/transport directory"])
            self.buildDirQuestion = PathQuestion(self.screen, "Build Directory", "TODO")
            defaultPrefix = os.path.expandvars("$HOME/fairsoft/" + self.fairsoftVersion)
            self.destinationQuestion = PathQuestion(self.screen, "Install Prefix", defaultPrefix)

            self.running = False
            self.selected = 1
            self.showControl = True
            self.title = "FairSoft Configurator v2.0"
        except:
            self.shutdown()
            raise

    def questions(self):
        if self.methodQuestion.answer() == "legacy":
            questions =  [self.methodQuestion, self.compilerQuestion, self.optimizerQuestion,
                self.debugQuestion, self.packagesQuestion]
            if not self.packagesQuestion.answer().startswith("FairMQ"):
                questions += [self.simQuestion, self.pythonQuestion, self.geant4MtQuestion,
                    self.geant4DataQuestion]
            questions += [self.buildDirQuestion, self.destinationQuestion]
            return questions
        else:
            return [self.methodQuestion, self.buildDirQuestion, self.destinationQuestion]

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
        return y, x

    def drawControls(self, y, x):
        controls = []
        if self.showControl:
            controls += ["<Up>/<Down>/<Tab>: Select",
                "<Enter>/<Space>: " + self.selectedQuestion().editAction(),
                "<F5>: Save and exit",
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

    def shutdown(self):
        curses.curs_set(1)
        curses.nocbreak()
        curses.echo()
        self.screen.keypad(0)
        curses.endwin()

def main():
    try:
        app = Application()
        app.run()
        app.shutdown()
    except KeyboardInterrupt:
        app.shutdown()
    except:
        app.shutdown()
        raise

if __name__ == "__main__":
    main()
