# -*- coding: utf-8 -*-

from tkinter import *
from random import randint

fenetre = Tk()
zoneDessin = Canvas(fenetre, width=1950, height=1080, background='gray')
test = zoneDessin.create_rectangle(20, 20, 40, 40, fill = 'green')

class Carre:
    def __init__(self, etat):
        self.etat = etat

        if (self.etat == "mur"):
            self.couleur = 'black'
        else: # donc case vide
            self.couleur = 'white'

    def afficher (self, posX, posY):
        zoneDessin.create_rectangle(posX*20, posY*20, (posX+20)*20, (posY+20)*20, fill = self.couleur)

    def setEtat (self, etat):
        self.etat = etat

    def getEtat (self):
        return self.etat
#END Carre

class Carre_population (Carre):
    def __init__(self, moyenneAge, nbPersonne, etat):
        self.moyenneAge = moyenneAge
        self.nbPersonne = nbPersonne
        self.etat = etat

        if (self.etat == "sain"):
            self.couleur = 'green'
        elif (self.etat == "contamine"):
            self.couleur = 'red'
        else: # donc case inconnue
            self.couleur = 'yellow'

    def changerEtat (self, etat):
        self.etat = etat
#END Carre_population

class Grille:
    def __init__(self, tailleX, tailleY):
        self.tailleX = tailleX
        self.tailleY = tailleY
        self.mat = []
        for y in range(self.tailleY):
            ligne = []
            for x in range(self.tailleX):
                nbAlea = randint (0,2)
                if (nbAlea == 0):
                    nouvCarre = Carre_population(54, 100, "sain")
                elif (nbAlea == 1):
                    nouvCarre = Carre_population(54, 100, "contamine")
                else:
                    nouvCarre = Carre("")

                ligne.append(nouvCarre)
            self.mat.append(ligne)

    def afficher (self):
        for y in range(self.tailleY):
            for x in range(self.tailleX):
                self.mat[y][x].afficher(x, y)
#END Grille

grille = Grille(10, 10)
grille.afficher()

zoneDessin.pack()
fenetre.mainloop()