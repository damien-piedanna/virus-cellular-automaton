# -*- cod# -*- coding: utf-8 -*-
######################################################################
#
# Ce fichier contient les classes relatives aux éléments de la grille
# Ces éléments peuvent être :
# - Un fleuve
# - Une zone urbaine
# - Un déplacement (d'un point à un autre via un moyen de transport)
#
######################################################################

from tkinter import *
from random import *

from classes.grille import *
from classes.cellule import *


# Classe Fleuve représente un fleuve
class Fleuve:
    def __init__(self, grille):
        print("Création d'un fleuve...")
        self.parcours = []
        # Largueur du fleuve maximum 1/10 de la taille max de la grille
        # Si largeur est paire, le fleuve est représenté avec une largeur de largeur+1
        if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
            self.largeur = randint(3,int(grille.nbCelluleHauteur/10))
        else:
            self.largeur = randint(3,int(grille.nbCelluleLargeur/10))

        # 1 chance sur 2 pour que le fleuve parte du haut ou de la gauche de la grille
        if(randint(0,1)):
            self.departAGauche = True
            # Départ à gauche, ne peut pas partir à moins de 5 cellules des bords supérieur et inférieur
            pos = Position(0, randint(5, grille.nbCelluleHauteur-5))
            # Tant que le fleuve n'atteind pas un bord
            while (pos.X < grille.nbCelluleLargeur and pos.Y > 0 and pos.Y < grille.nbCelluleHauteur):
                # On créer une nouvelle cellule du fleuve
                if (grille.matCell[pos.Y][pos.X].etat == "sain"):
                    grille.nbSain -= 1
                grille.matCell[pos.Y][pos.X] = Cellule(grille.tailleCellule, "eau")
                self.parcours.append(pos)

                # On étend la largeur du fleuve
                for i in range (1,int(self.largeur/2)+1):
                    if (pos.Y-i >= 0):
                        if (grille.matCell[pos.Y-i][pos.X].etat == "sain"):
                            grille.nbSain -= 1
                        grille.matCell[pos.Y-i][pos.X] = Cellule(grille.tailleCellule, "eau")
                    if (pos.Y+i < grille.nbCelluleHauteur):
                        if (grille.matCell[pos.Y+i][pos.X].etat == "sain"):
                            grille.nbSain -= 1
                        grille.matCell[pos.Y+i][pos.X] = Cellule(grille.tailleCellule, "eau")

                # Position de la prochaine cellule du fleuve
                pos.X += 1
                pos.Y = randint(pos.Y-1, pos.Y+1)
                pos = copy.deepcopy(pos) # Pos pointe sur une nouvele case mémoire
        else:
            self.departAGauche = False
            # Départ en haut, ne peut pas partir à moins de 5 cellules des bords gauche et droit
            pos = Position(randint(5, grille.nbCelluleLargeur-5), 0)
            # Tant que le fleuve n'atteind pas un bord
            while (pos.Y < grille.nbCelluleHauteur and pos.X > 0 and pos.X < grille.nbCelluleLargeur):
                # On créer une nouvelle cellule du fleuve
                if (grille.matCell[pos.Y][pos.X].etat == "sain"):
                    grille.nbSain -= 1
                grille.matCell[pos.Y][pos.X] = Cellule(grille.tailleCellule, "eau")
                self.parcours.append(pos)

                # On étend la largeur du fleuve
                for i in range (1,int(self.largeur/2)+1):
                    if (pos.X-i >= 0):
                        if (grille.matCell[pos.Y][pos.X-i].etat == "sain"):
                            grille.nbSain -= 1
                        grille.matCell[pos.Y][pos.X-i] = Cellule(grille.tailleCellule, "eau")
                    if (pos.X+i < grille.nbCelluleLargeur):
                        if (grille.matCell[pos.Y][pos.X+1].etat == "sain"):
                            grille.nbSain -= 1
                        grille.matCell[pos.Y][pos.X+i] = Cellule(grille.tailleCellule, "eau")

                # Position de la prochaine cellule du fleuve
                pos.X = randint(pos.X-1, pos.X+1)
                pos.Y += 1
                pos = copy.deepcopy(pos) # Pos pointe sur une nouvele case mémoire
        print("Fleuve de largeur " + repr(self.largeur) + " généré.")


# La classe zone urbaine représente des regroupements de population sur la grille
class ZoneUrbaine:
    def __init__(self, grille, genre):
        self.genre = genre # (Metropole, Ville, ZonePeuplee, Village)
        self.pos = Position(randint(0, grille.nbCelluleLargeur-1), randint(0, grille.nbCelluleHauteur-1))
        self.nbSain = 0
        self.nbInfecte = 0

        if (self.genre == "Metropole"): # Rayon entre 1/3 et 1/2 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/3), int(grille.nbCelluleHauteur/2))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/3), int(grille.nbCelluleLargeur/2))
        elif (self.genre == "Ville"): # Rayon entre 1/8 et 1/4 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/8), int(grille.nbCelluleHauteur/4))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/8), int(grille.nbCelluleLargeur/4))
        elif (self.genre == "Village"): # Rayon entre 1/8 et 1/2 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/16), int(grille.nbCelluleHauteur/10))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/16), int(grille.nbCelluleLargeur/10))
        elif (self.genre == "ZonePeuplee"): # Rayon entre 1/8 et 1/2 de la taille maximale de la grille
            if (grille.nbCelluleHauteur < grille.nbCelluleLargeur):
                self.rayon = randint(int(grille.nbCelluleHauteur/8), int(grille.nbCelluleHauteur/2))
            else:
                self.rayon = randint(int(grille.nbCelluleLargeur/8), int(grille.nbCelluleLargeur/2))
        else: #Zone inconnue
            self.rayon = 1
        # Rayon < 1 interdit
        if (self.rayon == 0):
            self.rayon = 1

    # Renvoie la distance du point (posX, posY) au centre de la zone courante
    def distanceAuCentre(self, position):
        return position.distance(self.pos)

    # Renvoie True si le point (posX, posY) appartient à la zone courante
    def contient(self, position):
        if (self.distanceAuCentre(position) <= self.rayon):
            return True;
        return False;

    # Renvoie True si la zone courante chevauche la zone zoneUrbaine
    def chevauche(self, zoneUrbaine):
        distanceZones = zoneUrbaine.distanceAuCentre(self.pos)
        if (distanceZones < self.rayon + zoneUrbaine.rayon):
            return True
        return False


# La classe Deplacement représente un moyen de transport allant d'un point à un autre
class Deplacement:
    def __init__(self, etat, pos1, pos2, tailleCellule):
        self.setEtat(etat)
        self.pos1 = pos1
        self.pos2 = pos2
        self.tailleCellule = tailleCellule

    def setEtat (self, etat):
        self.etat = etat
        if (self.etat == "pont"):
            self.couleur = 'lime'
            self.probaVoyage = 100
            self.vitesse = 1 # en nombre de pixels par dixième de seconde
        elif (self.etat == "route"):
            self.couleur = 'brown'
            self.probaVoyage = 5
            self.vitesse = 2 # en nombre de pixels par dixième de seconde
        elif (self.etat == "voieFerree"):
            self.couleur = 'orange'
            self.probaVoyage = 3
            self.vitesse = 3 # en nombre de pixels par dixième de seconde
        elif (self.etat == "ligneAerienne"):
            self.couleur = 'pink'
            self.probaVoyage = 1
            self.vitesse = 5 # en nombre de pixels par dixième de seconde
        else: # donc cellule inconnue
            self.couleur = 'yellow'
            self.probaVoyage = 0
            self.vitesse = 0 # en nombre de pixels par dixième de seconde

    def afficher (self, canvas):
        x0 = self.pos1.X*self.tailleCellule + int(10/100 * self.tailleCellule)
        y0 = self.pos1.Y*self.tailleCellule + int(10/100 * self.tailleCellule)
        x1 = (self.pos1.X*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        y1 = (self.pos1.Y*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        canvas.create_oval(x0, y0, x1, y1, fill=self.couleur, width=0)

        x0 = self.pos2.X*self.tailleCellule + int(10/100 * self.tailleCellule)
        y0 = self.pos2.Y*self.tailleCellule + int(10/100 * self.tailleCellule)
        x1 = (self.pos2.X*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        y1 = (self.pos2.Y*self.tailleCellule)+self.tailleCellule - int(10/100 * self.tailleCellule)
        canvas.create_oval(x0, y0, x1, y1, fill=self.couleur, width=0)
        
        x0 = self.pos1.X*self.tailleCellule + int(self.tailleCellule/2)
        y0 = self.pos1.Y*self.tailleCellule + int(self.tailleCellule/2)
        x1 = self.pos2.X*self.tailleCellule + int(self.tailleCellule/2)
        y1 = self.pos2.Y*self.tailleCellule + int(self.tailleCellule/2)

        epaisseur = int(20/100 * self.tailleCellule)
        if (self.etat == "pont"):
            epaisseur = self.tailleCellule - int(20/100 * self.tailleCellule)
        if (epaisseur < 3):
            epaisseur = 3 # Sinon difficilement visible

        canvas.create_line(x0, y0, x1, y1, fill=self.couleur, width=epaisseur)