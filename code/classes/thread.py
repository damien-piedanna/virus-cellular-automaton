# -*- cod# -*- coding: utf-8 -*-

import threading
import time

from classes.grille import *

# La classe Thread permet de lancer un second processus
class Thread(threading.Thread):
    def __init__(self, grille, compteur, pctInfecte):
        threading.Thread.__init__(self)
        self._etat = False
        self._pause = True
        self.grille = grille
        self.compteur = compteur
        self.pctInfecte = pctInfecte
 
    def run(self):
        self._etat = True
        cpt = 0
        while self._etat:
            if self._pause:
                time.sleep(0.1)
                continue
            time.sleep (0.5)
            self.grille.propager()
            cpt = cpt +1
            self.compteur.config(text="Jour " + repr(cpt))
            pct = int(self.grille.nbInfecte*100/(self.grille.nbInfecte + self.grille.nbSain))
            self.pctInfecte.config(text="Infectes: " + repr(pct) + "%")
            # Arrêt si grille totalement infectée
            if (pct==100):
                self.pause()

 
    def stop(self):
        self._etat = False
        sys.exit("Arrêt du programme...")
 
    def pause(self):
        self._pause = True
 
    def continu(self):
        self._pause = False