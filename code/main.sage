# -*- coding: utf-8 -*-

from tkinter import *
from random import randint


class Carre:
    def __init__(self, grille, x, y, tailleCellule, etat):

        self.etat = etat
        self.grille = grille
        self.x = x
        self.y = y
        self.tailleCellule = tailleCellule

        if   (self.etat == "vide"):
            self.couleur = 'white'
        elif (self.etat == "sain"):
            self.couleur = 'green'
        elif (self.etat == "infecte"):
            self.couleur = 'red'

        grille.create_rectangle(x, y, x+tailleCellule, y+tailleCellule, fill=self.couleur)

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

        #Création du damier de la grillle
        for x in range (0, hauteur, tailleCellule):
            self.grille.create_line(x,0,x,hauteur,width=1,fill='black')

        for y in range (0, largeur, tailleCellule):
            self.grille.create_line(0,y,largeur,y,width=1,fill='black')


        self.grille.bind("<Button-1>", self.infecte)
        self.grille.pack()

        #Création des carrés qui compose la grile et les ranges dans une matrice.
        for i in range (0, largeur/tailleCellule):
            ligne = []
            for j in range (0, hauteur/tailleCellule):
                if(randint(0, 1)):
                    ligne.append(Carre(self.grille, i*tailleCellule, j*tailleCellule, tailleCellule, "vide"))
                else:
                    ligne.append(Carre(self.grille, i*tailleCellule, j*tailleCellule, tailleCellule, "sain"))    
            self.matCarre.append(ligne)    
        
                

    def infecte(self, event):
        x = event.x -(event.x%self.tailleCellule)
        y = event.y -(event.y%self.tailleCellule)
        
        for i in range(0, self.largeur/self.tailleCellule):
            for j in range(0, self.hauteur/self.tailleCellule):
                if (self.matCarre[i][j].x == x and self.matCarre[i][j].y == y):
                    #TROUVER COMMENT SUPPRIMER LE CARRE PRECEDEMENT À CETTE PLACE
                    self.matCarre[i][j] = Carre(self.grille, x, y, self.tailleCellule, "infecte")
                    print(i,j)
#END Grille


#Main

root = Tk()
root.title('Propagation virus')


grille = Grille(500, 500, 25)


root.mainloop()
