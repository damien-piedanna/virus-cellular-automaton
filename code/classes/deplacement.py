# -*- cod# -*- coding: utf-8 -*-

# La classe Deplacement représente un moyen de transport allant d'un point à un autre
class Deplacement:
    def __init__(self, etat, posX1, posY1, posX2, posY2, tailleCellule):
        self.setEtat(etat)
        self.posX1 = posX1
        self.posY1 = posY1
        self.posX2 = posX2
        self.posY2 = posY2
        self.tailleCellule = tailleCellule

    def setEtat (self, etat):
        self.etat = etat
        if (self.etat == "pont"):
            self.couleur = 'lime'
        elif (self.etat == "route"):
            self.couleur = 'brown'
        elif (self.etat == "voieFerree"):
            self.couleur = 'orange'
        elif (self.etat == "ligneAerienne"):
            self.couleur = 'pink'
        else: # donc cellule inconnue
            self.couleur = 'yellow'

    def afficher (self, canvas):
        x0 = self.posX1*self.tailleCellule + 2
        y0 = self.posY1*self.tailleCellule + 2
        x1 = (self.posX1*self.tailleCellule)+self.tailleCellule - 2
        y1 = (self.posY1*self.tailleCellule)+self.tailleCellule - 2
        canvas.create_oval(x0, y0, x1, y1, fill=self.couleur, width=0)

        x0 = self.posX2*self.tailleCellule + 2
        y0 = self.posY2*self.tailleCellule + 2
        x1 = (self.posX2*self.tailleCellule)+self.tailleCellule - 2
        y1 = (self.posY2*self.tailleCellule)+self.tailleCellule - 2
        canvas.create_oval(x0, y0, x1, y1, fill=self.couleur, width=0)
        
        x0 = self.posX1*self.tailleCellule + int(self.tailleCellule/2)
        y0 = self.posY1*self.tailleCellule + int(self.tailleCellule/2)
        x1 = self.posX2*self.tailleCellule + int(self.tailleCellule/2)
        y1 = self.posY2*self.tailleCellule + int(self.tailleCellule/2)
        
        epaisseur = 3
        if (self.etat == "pont"):
            epaisseur = self.tailleCellule

        canvas.create_line(x0, y0, x1, y1, fill=self.couleur, width=epaisseur)