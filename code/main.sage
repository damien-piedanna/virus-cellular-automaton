# -*- coding: utf-8 -*-

from tkinter import *
from random import randint
import time

class Carre:
    def __init__(self, tailleCellule, etat):

        self.etat = etat
        self.tailleCellule = tailleCellule

        if (self.etat == "sain"):
            self.couleur = 'green'
        elif (self.etat == "infecte"):
            self.couleur = 'red'
        else:
            self.couleur = 'white'

    def afficher (self, canvas, x, y):
        canvas.create_rectangle(x*self.tailleCellule, y*self.tailleCellule, (x+self.tailleCellule)*self.tailleCellule, (y+self.tailleCellule)*self.tailleCellule, fill=self.couleur)

    def setEtat (self, etat):
        if (etat == "sain"):
            self.couleur = 'green'
        elif (etat == "infecte"):
            self.couleur = 'red'
        else:
            self.couleur = 'white'

#END Carre
"""
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
"""

class Grille:
    def __init__(self, largeur, hauteur, tailleCellule):

        self.grille = Canvas(root, width=largeur, height=hauteur, background='white')
        self.largeur = largeur
        self.hauteur = hauteur
        self.tailleCellule = tailleCellule
        self.matCarre = []

        self.grille.bind("<Button-1>", self.infecte)
        self.grille.pack()

        #Création des carrés qui compose la grile et les ranges dans une matrice.
        for i in range (0, largeur/tailleCellule):
            ligne = []
            for j in range (0, hauteur/tailleCellule):
                if(randint(0, 1)):
                    ligne.append(Carre(tailleCellule, "vide"))
                else:
                    ligne.append(Carre(tailleCellule, "sain"))    
            self.matCarre.append(ligne)    
        
                
    def afficher(self):
        for y in range(self.largeur/self.tailleCellule):
            for x in range(self.hauteur/self.tailleCellule):
                self.matCarre[y][x].afficher(self.grille, x, y)

    def infecte(self, event):
        x = event.x -(event.x%self.tailleCellule)
        y = event.y -(event.y%self.tailleCellule)
        
        for i in range(0, self.largeur/self.tailleCellule):
            for j in range(0, self.hauteur/self.tailleCellule):
                if (i*self.tailleCellule == x and j*self.tailleCellule == y):
                    #TROUVER COMMENT SUPPRIMER LE CARRE PRECEDEMENT À CETTE PLACE
                    self.matCarre[j][i].setEtat("infecte")
                    print(i,j)
        self.afficher()
#END Grille


#Main

root = Tk()
root.title('Propagation virus')


grille = Grille(500, 500, 25)
grille.afficher()




root.mainloop()