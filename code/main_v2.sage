# -*- coding: utf-8 -*-

from tkinter import *
from random import randint
import time

class Carre:
    def __init__(self, tailleCellule, etat):

        self.etat = etat
        self.tailleCellule = tailleCellule
        
        if (self.etat == "mur"):
            self.couleur = 'black'
        else: # donc case vide
            self.couleur = 'white'

    def afficher (self, canvas, x, y):
        canvas.create_rectangle(x*self.tailleCellule, y*self.tailleCellule, (x*self.tailleCellule)+self.tailleCellule, (y*self.tailleCellule)+self.tailleCellule, fill=self.couleur)

    def setEtat (self, etat):
        self.etat = etat;
        if (self.etat == "mur"):
            self.couleur = 'black'
        else: # donc case vide
            self.couleur = 'white'

#END Carre

class CarrePopulation (Carre):
    def __init__(self, tailleCellule, etat, moyenneAge):

        self.tailleCellule = tailleCellule
        self.etat = etat
        self.moyenneAge = moyenneAge

        if (self.etat == "sain"):
            self.couleur = 'green'
        elif (self.etat == "infecte"):
            self.couleur = 'red'
        else: # donc case inconnue
            self.couleur = 'yellow'

    def setEtat (self, etat):
        self.etat = etat
        if (self.etat == "sain"):
            self.couleur = 'green'
        elif (self.etat == "infecte"):
            self.couleur = 'red'
        else: # donc case inconnue
            self.couleur = 'yellow'

#END Carre_population

class Grille:
    def __init__(self, hauteurPx, nbCelluleHauteur, nbCelluleLargeur):

        self.nbCelluleHauteur = nbCelluleHauteur
        self.nbCelluleLargeur = nbCelluleLargeur

        self.tailleCellule = int(hauteurPx/nbCelluleHauteur)

        self.grille = Canvas(root, width=self.tailleCellule*nbCelluleLargeur, height=hauteurPx, background='white')

        self.matCarre = []

        self.grille.bind("<Button-1>", self.infecte)
        self.grille.bind("<Button-3>", self.guerir)
        self.grille.pack()

        #Création des carrés qui compose la grile et les range dans une matrice.
        for i in range (0, nbCelluleHauteur):
            ligne = []
            for j in range (0, nbCelluleLargeur):
                if(randint(0, 1)):
                    ligne.append(Carre(self.tailleCellule, "vide"))
                else:
                    ligne.append(CarrePopulation(self.tailleCellule, "sain", 50))    
            self.matCarre.append(ligne)    
        
                
    def afficher(self):
        for y in range(self.nbCelluleHauteur):
            for x in range(self.nbCelluleLargeur):
                self.matCarre[y][x].afficher(self.grille, x, y)

    def infecte(self, event):
        x = event.x - (event.x%self.tailleCellule)
        y = event.y - (event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCarre[j][i].etat == "sain"):
            self.matCarre[j][i].setEtat("infecte")
            self.matCarre[j][i].afficher(self.grille, i, j)
            print("la cellule " + repr(i) + " ; " + repr(j) + " a été infectée.")

    def guerir(self, event):
        x = event.x -(event.x%self.tailleCellule)
        y = event.y -(event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCarre[j][i].etat == "infecte"):
            self.matCarre[j][i].setEtat("sain")
            self.matCarre[j][i].afficher(self.grille, i, j)
            print("la cellule " + repr(i) + " ; " + repr(j) + " a été guérie.")

#END Grille


##### MAIN #####

root = Tk()
root.title('Propagation virus')

grille = Grille(700, 50, 70)
grille.afficher()

root.mainloop()