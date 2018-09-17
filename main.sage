# -*- coding: utf-8 -*-

from tkinter import * 

class Carre:
    def __init__(self, etat):
        self.etat = etat
        if   (etat == "sain"):
            self.bouton = Button(fenetre, text="1", borderwidth=1, bg="green")
        elif (etat == "infecte"):
            self.bouton = Button(fenetre, text="2", borderwidth=1, bg="red")
        else:
            self.bouton = Button(fenetre, text="0", borderwidth=1, bg="white")

    def setEtat (self, etat):
        self.etat = etat

    def getEtat (self):
        return self.etat
#END Carre

"""
class Carre_population (Carre):
    def __init__(self, moyenneAge, nbPersonne, etat):
        self.moyenneAge = moyenneAge
        self.nbPersonne = nbPersonne
        self.etat = etat

    def changerEtat (self, etat):
        self.etat = etat
#END Carre_population
"""

class Grille:
    def __init__(self, tailleX, tailleY):
        self.tailleX = tailleX
        self.tailleY = tailleY
        self.mat = []
        for y in range(self.tailleY):
            ligne = []
            for x in range(self.tailleX):
                newCarre = Carre("vide")
                ligne.append(newCarre)
                newCarre.bouton.grid(row=x, column=y) #On ajoute le new bouton à la grille
            self.mat.append(ligne)

#END Grille

fenetre = Tk()
grille = Grille(5,5)
fenetre.mainloop()


